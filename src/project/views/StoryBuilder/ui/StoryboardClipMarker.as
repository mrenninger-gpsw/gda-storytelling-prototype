package project.views.StoryBuilder.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.StoryboardManagerEvent;
	
	
	
	public class StoryboardClipMarker extends Sprite {
		
		/******************* PRIVATE VARS *********************/
		private var _icon:Sprite;
		private var _line:Shape;
		
		
		
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
			TweenMax.to(_line, ($immediate) ? 0 : 0.4, {alpha:1, height:115, ease:Expo.easeInOut, delay:($immediate) ? 0 : 0.3, onComplete:($immediate) ? null : _onShowMarkerComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_line = new Shape();
			_line.graphics.beginFill(0x00A3DA);
			_line.graphics.drawRect(-0.5, -0.5, 1, 1);
			_line.graphics.endFill();
			_line.alpha = 0;
			addChild(_line);
			
			_icon = new Sprite();
			addChild(_icon);
			_icon.alpha = 0;
			_icon.scaleX = _icon.scaleY = 0.5;
			var bmp:Bitmap = Register.ASSETS.getBitmap('storyboardClip_marker2');
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