package project.views.MusicSelector.ui {

	// Flash
	import flash.display.Bitmap;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;

	
	
	public class MusicPreviewHighlightIcon extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _icon:Bitmap;
		private var _showing:Boolean = false;

		

		/******************** CONSTRUCTOR *********************/
		public function MusicPreviewHighlightIcon() {
			super();
			TweenMax.to(this, 0, {scaleX:0, scaleY:0});
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		

		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_icon = Register.ASSETS.getBitmap('musicPreview_highlightIcon');
			_icon.x = -_icon.width * 0.5;
			_icon.y = -_icon.height * 0.5;
			this.addChild(_icon);
		}
		
		private function _show():void {
			if (!_showing) {
				_showing = true;
				TweenMax.to(this, 0.3, {scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:_hide});
			}
		}
		
		private function _hide():void {
			if (_showing) {
				_showing = false;
				TweenMax.to(this, 0.3, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:0.5});
			}
		}
		

		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_show();
		}
		
		
	}
}