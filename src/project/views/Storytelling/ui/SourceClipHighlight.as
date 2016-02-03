package project.views.Storytelling.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
		
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;
	
	

	public class SourceClipHighlight extends Sprite {
		
		/********************* CONSTANTS **********************/
		public static const YELLOW:uint = 0xF5A700;
		public static const BLUE:uint = 0x00A3DA;

		
		
		/******************** PRIVATE VARS ********************/
		private var _color:uint;
		private var _showing:Boolean = false;
		private var _cover:Shape;
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function SourceClipHighlight($color:String = 'yellow') {
			super();
			verbose = true;
			_color = ($color == 'yellow') ? YELLOW : BLUE;
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/
		public function show():void {
			if (!_showing) {
				_showing = true;
				TweenMax.to(_cover, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
				TweenMax.to(this, 0.3, {tint:null, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:_onShowComplete});
			}
		}
		
		public function hide():void {
			if (_showing) {
				_showing = false;
				TweenMax.to(_cover, 0.3, {autoAlpha:1, ease:Cubic.easeIn});
				TweenMax.to(this, 0.3, {tint:_color, scaleX:0.2, scaleY:0.2, ease:Back.easeIn, onComplete:_onHideComplete});
			}
		}
		
		
	
		/******************** PRIVATE API *********************/
		private function _init():void {
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0x000000, 0.3);
			circle.graphics.drawCircle(0,0,15);
			circle.graphics.endFill();
			this.addChild(circle);
			
			var icon:Bitmap = Register.ASSETS.getBitmap('highlightTag');
			icon.x = -icon.width * 0.5;
			icon.y = -icon.height * 0.5;
			TweenMax.to(icon, 0, {tint:_color});
			this.addChild(icon);
			
			_cover = new Shape();
			_cover.graphics.beginFill(0x000000);
			_cover.graphics.drawCircle(0,0,15);
			_cover.graphics.endFill();
			this.addChild(_cover);
			
			TweenMax.to(this, 0, {tint:_color, scaleX:0.2, scaleY:0.2});
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
	}
}