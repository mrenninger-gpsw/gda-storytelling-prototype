package project.views.StoryBuilder.ui {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;

	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;

	// Framework
	import display.Sprite;
	import utils.Register;

	// Project
	import project.events.StoryboardManagerEvent;



	public class StoryboardClipMarker extends Sprite {

		/******************* PRIVATE VARS *********************/
        private var _icon:Sprite;
        private var _bg:Bitmap;
		private var _line:Shape;

        public function get icon():Sprite { return _icon; }



		/******************** CONSTRUCTOR *********************/
		public function StoryboardClipMarker() {
			super();
			verbose = true;
			_init();
		}



		/******************** PUBLIC API *********************/
		public function show($immediate:Boolean = false):void {
			// show the marker
			TweenMax.to(_icon, ($immediate) ? 0 : 0.4, {scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut});
			TweenMax.to(_line, ($immediate) ? 0 : 0.4, {alpha:1, height:94, y:-47, ease:Expo.easeInOut, delay:($immediate) ? 0 : 0.3, onComplete:($immediate) ? null : _onShowMarkerComplete});
		}

        public function activate($b:Boolean = true):void {
            var a:Number = ($b) ? 0.5 : 0.3;
            var t:Number = ($b) ? 0 : 0.5;
            TweenMax.to(_bg, t, {alpha:a, ease:Expo.easeOut});
        }



		/******************** PRIVATE API *********************/
		private function _init():void {
			_line = new Shape();
			_line.graphics.beginFill(0x00A3DA);
			_line.graphics.drawRect(0, 0, 1, 1);
			_line.graphics.endFill();
			_line.alpha = 0;
			addChild(_line);

			_icon = new Sprite();
			addChild(_icon);
			_icon.alpha = 0;
			_icon.scaleX = _icon.scaleY = 0.5;

            _bg = Register.ASSETS.getBitmap('storyboardClip_marker3_bg');
            _bg.x = -_bg.width * 0.5;
            _bg.y = -_bg.height * 0.5;
            _bg.alpha = 0.3;
            _icon.addChild(_bg);

            var bmp:Bitmap = Register.ASSETS.getBitmap('storyboardClip_marker3_icon');
			bmp.x = -bmp.width * 0.5;
			bmp.y = -bmp.height * 0.5;
			_icon.addChild(bmp);
		}

		private function _onShowMarkerComplete():void {
			log('_onShowMarkerComplete');
			Register.PROJECT.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.SHOW_MARKER));
		}

    }
}
