package project.views.StoryBuilder {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import project.events.PreviewEvent;

// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	// Framework
	import display.Sprite;
	import utils.Register;



	public class VideoPreviewArea extends Sprite {

		/******************* PRIVATE VARS *********************/
		private var _holder:Sprite;
		private var _bgShape:Shape;
		private var _ds:Bitmap;
        private var _locked:Boolean = false;
        private var _lockFilename:String;
        private var _nav:Sprite;
        private var _isPlaying:Boolean = false;



		/******************** CONSTRUCTOR *********************/
		public function VideoPreviewArea() {
			super();
            verbose = true;
            //this.mouseChildren = false;
            //this.mouseEnabled = false;
            this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}



		/******************** PUBLIC API *********************/
		public function update($filename:String):void {
            _holder.removeChildren();
            try {
			    _holder.addChild(Register.ASSETS.getBitmap($filename));
            } catch ($e) {
                log($filename+'does not exist');
            }
		}

		public function clear():void {
            _holder.removeChildren();
            if (_locked) {
                try {
                    _holder.addChild(Register.ASSETS.getBitmap(_lockFilename));
                } catch ($e) {
                    log(_lockFilename+'does not exist');
                }
            }
		}

        public function lock($b:Boolean, $filename:String):void {
            if ($b) {
                //log('LOCK - '+$filename);
                _locked = true;
                _lockFilename = $filename;
                clear();
            } else {
                log('UNLOCK');
                _locked = false;
            }
        }

        public function resetControls():void {
            TweenMax.to(_nav.getChildByName('pause'), 0, {autoAlpha:0});
            TweenMax.to(_nav.getChildByName('play'), 0, {autoAlpha:1});
            _isPlaying = false;
        }

		public function switchStates($id:String,$immediate:Boolean = false):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					TweenMax.to(this, ($immediate) ? 0 : 0.3, {autoAlpha:0, y:'-20', ease:Cubic.easeOut});
					break;

				case 'video':
					TweenMax.to(this, ($immediate) ? 0 : 0.3, {autoAlpha:1, y:98, ease:Cubic.easeOut, delay:($immediate) ? 0 : 0.2});
					break;
			}
		}

		public function show($immediate:Boolean = false):void {
			TweenMax.to(this, ($immediate) ? 0 : 0.25, {autoAlpha:1, y:77, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}

		public function hide($immediate:Boolean = false):void {
			TweenMax.to(this, ($immediate) ? 0 : 0.25, {autoAlpha:0, y:'-20', ease:Cubic.easeOut, onComplete:_onHideComplete});
		}



		/******************** PRIVATE API *********************/
		private function _init():void {

			_ds = Register.ASSETS.getBitmap('preview_dropshadow');
			/*_ds.x = -24;
			_ds.y = -3;*/
            _ds.x = -20;
            _ds.y = -2;
            _ds.scaleX = 0.83575581;
            _ds.scaleY = 0.83575581;
            this.addChild(_ds);


			_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x000000);
			//_bgShape.graphics.drawRect(0,0,688,387);
            _bgShape.graphics.drawRect(0,0,575,323); //-113,-65
            _bgShape.graphics.endFill();
			this.addChild(_bgShape);

			_holder = new Sprite();
            _holder.scaleX = 0.83575581;
            _holder.scaleY = 0.83575581;
			this.addChild(_holder);

            _nav = new Sprite();
            var __navBG:Shape = new Shape();
            __navBG.graphics.beginFill(0x000000);
            __navBG.graphics.drawRect(0,0,575,50);
            __navBG.graphics.endFill();
            _nav.addChild(__navBG);
            _nav.x = 0;
            _nav.y = 323;
            this.addChild(_nav);

            var __fs:Bitmap = Register.ASSETS.getBitmap('VideoPreview-FullScreen');
            TweenMax.to(__fs, 0, {x:__navBG.width - 18 - __fs.width, y:(__navBG.height - __fs.height)/2});
            _nav.addChild(__fs);

            var __bmp:Bitmap;

            var __playBtn:Sprite = new Sprite();
            __playBtn.name = 'play';

            __bmp = Register.ASSETS.getBitmap('VideoPreview-Play');
            __playBtn.addChild(__bmp);

            TweenMax.to(__playBtn, 0, {x:Math.round((__navBG.width - __playBtn.width)/2), y:Math.round((__navBG.height - __playBtn.height)/2)});
            __playBtn.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
            _nav.addChild(__playBtn);

            var __pauseBtn:Sprite = new Sprite();
            __pauseBtn.name = 'pause';

            __bmp = Register.ASSETS.getBitmap('VideoPreview-Pause');
            __pauseBtn.addChild(__bmp);

            TweenMax.to(__pauseBtn, 0, {autoAlpha:0, x:Math.round((__navBG.width - __pauseBtn.width)/2), y:Math.round((__navBG.height - __pauseBtn.height)/2)});
            __pauseBtn.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
            _nav.addChild(__pauseBtn);

            TweenMax.to(this, 0, {autoAlpha:0, y:'-20'});

		}

		private function _onShowComplete():void {
			dispatchEvent(new Event('showComplete'));
		}

		private function _onHideComplete():void {
			dispatchEvent(new Event('hideComplete'));
		}

        private function _togglePlayPause():void {
            if (_isPlaying){
                _pause();
            } else {
                _play();
            }
        }

        private function _play():void {
            _isPlaying = true;
            TweenMax.to(_nav.getChildByName('pause'), 0, {autoAlpha:1});
            TweenMax.to(_nav.getChildByName('play'), 0, {autoAlpha:0});
            dispatchEvent(new PreviewEvent(PreviewEvent.PLAY));
        }

        private function _pause():void {
            _isPlaying = false;
            TweenMax.to(_nav.getChildByName('pause'), 0, {autoAlpha:0});
            TweenMax.to(_nav.getChildByName('play'), 0, {autoAlpha:1});
            dispatchEvent(new PreviewEvent(PreviewEvent.PAUSE));
        }


        private function _onAdded($e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
        }

        private function _handleMouseEvent($e:MouseEvent):void {
            log($e.type + ' | ' +$e.target.name);
            switch ($e.target.name) {
                case 'pause':
                    log('clicked PAUSE');
                    _pause();
                    break;

                case 'play':
                    log('clicked PLAY');
                    _play();
                    break;
            }
        }

        private function _keyDownHandler($e:KeyboardEvent):void {
            log('_keyDownHandler - keyCode: '+$e.keyCode);
            switch ($e.keyCode) {
                case Keyboard.SPACE:
                    _togglePlayPause();
                    break;
            }
        }
	}
}
