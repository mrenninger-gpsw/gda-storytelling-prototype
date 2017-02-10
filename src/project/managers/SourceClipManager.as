package project.managers {

	// Flash
    import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
    import com.greensock.easing.Expo;

	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;

	// Project
	import project.events.AddMediaDrawerEvent;
	import project.events.PreviewEvent;
	import project.events.SourceClipManagerEvent;
	import project.events.StoryboardManagerEvent;
	import project.views.StoryBuilder.SourceClip;
	import project.views.StoryBuilder.VideoPreviewArea;



	public class SourceClipManager extends Sprite {

		// Vars
		private var _xml:XMLList;
		private var _bgShape:Shape;
		private var _scrollbar:Sprite;
		private var _shadow:Bitmap;
		private var _addBtn:Sprite;
		private var _sourceClipsV:Vector.<SourceClip>;
		private var _previewArea:VideoPreviewArea;
		private var _addFromLibrary:Boolean = false;
		private var _showing:Boolean = false;
		private var _titleLabel:Label;
        private var _sourceClipHolder:Sprite;



		/***************** GETTERS & SETTERS ******************/
		public function set previewArea($value:VideoPreviewArea):void { _previewArea = $value; }

		public function set addFromLibrary($value:Boolean):void { _addFromLibrary = $value; }



		/******************** CONSTRUCTOR *********************/
		public function SourceClipManager() {
			super();

			verbose = true;

			_xml = Register.PROJECT_XML.content.editor.storybuilder.sourceClips;

			_sourceClipsV = new Vector.<SourceClip>();

			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            this.addEventListener(SourceClipManagerEvent.SHOW_HILITE, _handleSourceClipHiliteShow);
			_init();
		}



		/******************** PUBLIC API *********************/
		public function show():void {
			if (_showing){
				log('showing... calling _checkforLibraryAdd');
				_checkforLibraryAdd();
			} else {
				log('not showing... default show');
				// position the source clips based on _addFromLibrary value and fade them up
				var startIndex:uint = 2;//(_addFromLibrary) ? 0 : 2;
				for (var i:uint = startIndex; i < _sourceClipsV.length; i++) {
					_sourceClipsV[i].y = (i == startIndex) ? 0 : _sourceClipsV[i - 1].y + 80;
					var onComplete:Function = (i == _sourceClipsV.length - 1) ? _checkforLibraryAdd : null;
					TweenMax.to(_sourceClipsV[i], 0.2, {x:0, autoAlpha:1, ease:Back.easeOut, delay:i * 0.03, onComplete:onComplete});
				}

				//TweenMax.to(_scrollbar, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
				//TweenMax.to(_bgShape, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
                //TweenMax.allTo([_titleLabel,_addBtn, _shadow, _scrollbar], 0.2, {autoAlpha:1, ease:Cubic.easeOut});
                TweenMax.allTo([_titleLabel,_addBtn, _scrollbar], 0.2, {autoAlpha:1, ease:Cubic.easeOut});
				//TweenMax.to(_shadow, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.25});
			}
		}

		public function hide($immediate:Boolean = false):void {
			var startIndex:uint = 0;//(_addFromLibrary) ? 0 : 2;
			for (var i:uint = startIndex; i < _sourceClipsV.length; i++) {
				var onComplete:Function = (i == _sourceClipsV.length - 1) ? _onHideComplete : null;
				TweenMax.to(_sourceClipsV[i], ($immediate) ? 0 : 0.2, {autoAlpha:0, ease:Cubic.easeOut, delay:($immediate) ? 0 : (i * 0.03), onComplete:onComplete});
			}
			TweenMax.allTo([_titleLabel,_scrollbar,_addBtn], ($immediate) ? 0 : 0.2, {autoAlpha:0, ease:Cubic.easeOut});
			//TweenMax.to(_bgShape, ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut});
			//TweenMax.to(_shadow, ($immediate) ? 0 : 0.2, {autoAlpha:0, ease:Cubic.easeOut, delay:($immediate) ? 0 : 0.15});
		}



		/******************** PRIVATE API *********************/
		private function _init():void {
			// create the _bgShape
			/*_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x1e1e1e);
			_bgShape.graphics.drawRect(0,0,Register.APP.WIDTH, 399);
			_bgShape.graphics.endFill();
			_bgShape.alpha = 0;
			this.addChild(_bgShape);*/

			_titleLabel = new Label();
			_titleLabel.text = _xml.@title;
			_titleLabel.autoSize = 'left';
			_titleLabel.textFormatName = 'sourceclip-title';
			_titleLabel.x = 26;
			_titleLabel.y = 20;
			this.addChild(_titleLabel);

            _sourceClipHolder = new Sprite();
            _sourceClipHolder.x = 20;
            _sourceClipHolder.y = 59;
            this.addChild(_sourceClipHolder);

            var s:Shape = new Shape();
            s.graphics.beginFill(0x1e1e1e);
            s.graphics.drawRect(0,0,Register.APP.WIDTH, 339);//395
            s.graphics.endFill();
            s.y = _sourceClipHolder.y;
            this.addChild(s);
            _sourceClipHolder.mask = s;

			var i:uint;
			var tSourceClip:SourceClip;

			// create the source clips from the media library
			for (i = 0; i < _xml.library.item.length(); i++) {
				tSourceClip = new SourceClip(i, _xml.library.item[i]);

				tSourceClip.x = 0;
				tSourceClip.y = (i == 0) ? 0 : _sourceClipsV[_sourceClipsV.length - 1].y + 80;
				tSourceClip.alpha = 0;

				//_addListeners(tSourceClip);

				/*tSourceClip.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
				tSourceClip.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);*/

				_sourceClipsV.push(tSourceClip);

                _sourceClipHolder.addChild(tSourceClip);

			}

			// create the default editor source clips
			for (i = 0; i < _xml.editor.item.length(); i++) {
				tSourceClip = new SourceClip(i, _xml.editor.item[i]);

				tSourceClip.x = 0;
				tSourceClip.y = _sourceClipsV[_sourceClipsV.length - 1].y + 80;
				tSourceClip.alpha = 0;

				//_addListeners(tSourceClip);

				/*tSourceClip.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
				tSourceClip.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);*/
				_sourceClipsV.push(tSourceClip);

                _sourceClipHolder.addChild(tSourceClip);
			}

            log('_sourceClipsV.length: '+_sourceClipsV.length);

			// create the shadow gradient and faux scrollbar here
			_scrollbar = new Sprite();
            var __shape:Shape = new Shape();
            __shape.graphics.beginFill(0x353535);
            __shape.graphics.drawRect(0,0,5,98);
            __shape.graphics.endFill();
            _scrollbar.addChild(__shape);
            _scrollbar.mouseChildren = false;
			_scrollbar.x = 662;//547;
			_scrollbar.y = 59;
			_scrollbar.alpha = 0;
			this.addChild(_scrollbar);
            _scrollbar.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);

			_shadow = Register.ASSETS.getBitmap('sourceclip_gradient');
			_shadow.x = 20;
			_shadow.y = 385;
			_shadow.alpha = 0;
			this.addChild(_shadow);

			_addBtn = new Sprite();
			_addBtn.addChild(Register.ASSETS.getBitmap('sourceClip_AddNew'));
			_addBtn.x = _sourceClipsV[0].x + _sourceClipsV[0].width - _addBtn.width;
			_addBtn.y = _titleLabel.y + _titleLabel.height - _addBtn.height;
			_addBtn.addEventListener(MouseEvent.MOUSE_OVER, _onMouseEvent);
			_addBtn.addEventListener(MouseEvent.MOUSE_OUT, _onMouseEvent);
			_addBtn.addEventListener(MouseEvent.CLICK, _onMouseEvent);
			this.addChild(_addBtn);

			//show();
		}

		private function _checkforLibraryAdd():void {
			log('_checkforLibraryAdd: '+_addFromLibrary);
			if (_addFromLibrary) {
				var i:uint;
				for (i = (_sourceClipsV.length - 1); i > 1; i--) {
					TweenMax.to(_sourceClipsV[i], 0.2, {x:0, y:_sourceClipsV[i].y + 160, ease:Cubic.easeInOut, delay:((_sourceClipsV.length-1) - i) * 0.03});
				}
				for (i = 0; i < 2; i++) {
					var onComplete:Function = (i == 1) ? _onShowComplete : null;
					TweenMax.to(_sourceClipsV[i], 0.2, {x:0, autoAlpha:1, ease:Back.easeOut, delay:0.21 + (i * 0.03), onComplete:onComplete});
				}
				//TweenMax.to(_shadow, 0.2, {autoAlpha:1, ease:Cubic.easeOut});
				TweenMax.to(_scrollbar, 0.2, {autoAlpha:1, ease:Cubic.easeOut});
			} else {
				_onShowComplete();
			}
		}

		private function _onShowComplete():void {
			log('_onShowComplete');
			_showing = true;
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.SHOW_COMPLETE));
		}

		private function _onHideComplete():void {
			log('_onHideComplete');
			_showing = false;
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				TweenMax.to(_sourceClipsV[i], 0, {x:-20});
			}
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.HIDE_COMPLETE));
		}

		private function _enableSourceClips($b:Boolean = true):void {
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				_sourceClipsV[i].canAddToStoryboard = $b;
			}
		}

        private function _startScroll($b:Boolean = true):void {
            if ($b) {
                var r:Rectangle = new Rectangle(_scrollbar.x,_sourceClipHolder.mask.y,0,_sourceClipHolder.mask.height - _scrollbar.height);
                log('_startScroll - dragRect: '+r);
                _scrollbar.startDrag(false,r);
                this.addEventListener(Event.ENTER_FRAME, _trackScrollPosition);
            } else {
                this.removeEventListener(Event.ENTER_FRAME, _trackScrollPosition);
                _scrollbar.stopDrag();
            }
        }

        private function _trackScrollPosition($e:Event):void {
            var __scrollPct:Number = (_scrollbar.y - _sourceClipHolder.mask.y)/(_sourceClipHolder.mask.height - _scrollbar.height);
            //log('_trackScrollPosition: '+__scrollPct);

            //scroll the _clipholder
            var __range:Number = _sourceClipHolder.mask.height - _sourceClipHolder.height;
            var __newY:Number =  _sourceClipHolder.mask.y + (__scrollPct * __range);

            TweenMax.to(_sourceClipHolder, 0.3, {y:__newY, ease:Expo.easeOut});

        }



		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _handleStoryboardManagerEvent);
			this.stage.addEventListener(StoryboardManagerEvent.FOUR_CLIPS, _handleStoryboardManagerEvent);
			this.stage.addEventListener(AddMediaDrawerEvent.ADD_MEDIA_DRAWER_SHOW, _resetSourceClips);
		}

        /*private function _handlePreviewEvent($e:PreviewEvent):void {
			switch ($e.type) {
				case PreviewEvent.PREVIEW:
					var tSourceClip:SourceClip = $e.target as SourceClip;
					_previewArea.update(tSourceClip.curFileName);
					break;
				case PreviewEvent.CLEAR:
					_previewArea.clear();
					break;
			}
		}*/

		private function _handleStoryboardManagerEvent($e:StoryboardManagerEvent):void {
			switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					_enableSourceClips();
					break;

				case StoryboardManagerEvent.FIVE_CLIPS:
					_enableSourceClips(false);
					break;
			}
		}

		private function _onMouseEvent($e:MouseEvent):void {
            log('_onMouseEvent: '+$e.target);
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					if ($e.target == _addBtn) TweenMax.to(_addBtn, 0, {tint:0xFFFFFF});
					break;

				case MouseEvent.MOUSE_OUT:
					if ($e.target == _addBtn) TweenMax.to(_addBtn, 0.3, {tint:null, ease:Cubic.easeOut});
					break;

				case MouseEvent.CLICK:
					TweenMax.to(_addBtn, 0.3, {tint:null, ease:Cubic.easeOut});
					if ($e.target == _addBtn) this.stage.dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.ADD_MEDIA));
					break;

                case MouseEvent.MOUSE_DOWN:
                    if ($e.target == _scrollbar) {
                        _startScroll();
                        this.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);
                    }
                    break;

                case MouseEvent.MOUSE_UP:
                    _startScroll(false);
                    this.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);
                    break;
			}
		}

        private function _handleScroll($e:MouseEvent):void {

            switch ($e.type) {
                case MouseEvent.MOUSE_OVER:
                    if ($e.target == _addBtn) TweenMax.to(_addBtn, 0, {tint: 0xFFFFFF});
                    break;

                case MouseEvent.MOUSE_OUT:
                    if ($e.target == _addBtn) TweenMax.to(_addBtn, 0.3, {tint: null, ease: Cubic.easeOut});
                    break;

                case MouseEvent.MOUSE_DOWN:
                    break;

                case MouseEvent.MOUSE_UP:
                    break;
            }
        }

		private function _resetSourceClips($e:AddMediaDrawerEvent):void {
			_addFromLibrary = false;

            //TweenMax.allTo([_shadow, _scrollbar], 0, {autoAlpha:1});
            TweenMax.to(_scrollbar, 0, {autoAlpha:1});
            _scrollbar.y = _sourceClipHolder.mask.y;
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				if (i < 2){
					TweenMax.to(_sourceClipsV[i], 0, {x:-20, autoAlpha:0});
				} else {
					_sourceClipsV[i].y = (i == 2) ? 0 : _sourceClipsV[i - 1].y + 80;
					TweenMax.to(_sourceClipsV[i], 0, {x:0, autoAlpha:1});
				}
			}
		}

        private function _handleSourceClipHiliteShow($e:SourceClipManagerEvent):void {
            switch ($e.type) {
                case SourceClipManagerEvent.SHOW_HILITE:
                    var __clip:SourceClip = $e.target.parent as SourceClip;
                    /*log('SHOW_HILITE - __clip : '+new Point(__clip.x,__clip.y));
                    log('SHOW_HILITE - __clip(l2g): '+localToGlobal(new Point(__clip.x,__clip.y)));
                    log('SHOW_HILITE - __clip(actual): '+new Point(__clip.x,(this.y + _sourceClipHolder.y + __clip.y)));*/
                    var __clipY:Number = (this.y + _sourceClipHolder.y + __clip.y);
                    // put logic here to move the _sourceClipHolder so that the clip is visible
                    // and so that the scrollbar.y reflects the proper scroll pct

                    var __btmLimit:Number = 384;//439;
                    var __topLimit:Number = 125;
                    if (__clipY > __btmLimit || __clipY < __topLimit) {
                        var __shiftY:Number = _sourceClipHolder.y;
                        // determine the y difference to make the clip visible and move the holder
                        if (__clipY > __btmLimit) {
                            __shiftY = _sourceClipHolder.y + ((__btmLimit + 1) - __clipY);
                        }

                        if (__clipY < __btmLimit) {
                            __shiftY = _sourceClipHolder.y + (__topLimit - __clipY);
                        }

                        //_sourceClipHolder.y = 454 - __clip.y;
                        TweenMax.to(_sourceClipHolder, 0.4, {y:__shiftY, ease:Expo.easeOut});

                        var __range:Number = _sourceClipHolder.mask.height - _sourceClipHolder.height;
                        var __scrollPct:Number = (Number(__shiftY) - _sourceClipHolder.mask.y)/__range;

                        log('new holderScrollPct: '+__scrollPct);

                        var __newScrollbarY:Number = (__scrollPct * (_sourceClipHolder.mask.height - _scrollbar.height)) + _sourceClipHolder.mask.y;

                        TweenMax.to(_scrollbar, 0.4, {y:__newScrollbarY, ease:Expo.easeOut});

                    }





                    break;
            }
        }

	}
}
