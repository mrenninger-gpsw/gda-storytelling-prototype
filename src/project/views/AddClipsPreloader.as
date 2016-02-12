package project.views {
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	import components.controls.Label;
	
	import display.Sprite;
	
	import project.events.ViewTransitionEvent;
	
	import utils.Register;
	
	
	
	public class AddClipsPreloader extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _text:String;
		private var _label:Label;
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function AddClipsPreloader() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			TweenMax.to(this, 0.5, {autoAlpha:1, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}
		
		public function hide():void {
			this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.ADD_LIBRARY_CLIPS));
			TweenMax.to(this, 0.5, {autoAlpha:0, ease:Cubic.easeOut, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0x000000, 0.66);
			s.graphics.drawRoundRect(0,0,Register.APP.WIDTH, Register.APP.HEIGHT,10,10);
			s.graphics.endFill();
			this.addChild(s);
			
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = 'Opening 2 videos in Editor';
			_label.autoSize = 'left';
			_label.textFormatName = 'media-content-title';
			_label.x = (this.width - _label.width) * 0.5;
			_label.y = (this.height - _label.height) * 0.5;
			
			this.addChild(_label);
			
			TweenMax.to(this, 0, {autoAlpha:0});

		}
		
		private function _onShowComplete():void {
			TweenMax.delayedCall(1, hide);
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
	}
}