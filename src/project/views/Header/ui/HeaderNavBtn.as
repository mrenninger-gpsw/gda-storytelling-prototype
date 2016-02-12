package project.views.Header.ui {

	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	
	// Framework
	import components.controls.Label;
	import display.Sprite;
	
	// Project
	
	
	
	public class HeaderNavBtn extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _text:String;
		private var _label:Label;
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function HeaderNavBtn($str:String) {
			super();
			verbose = true;
			_text = $str;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			
		}
		
		public function hide():void {
			
		}
		
		public function addMarker():void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawCircle(0,0,4);
			s.graphics.endFill();
			s.x = _label.x - 12;
			s.y = this.height * 0.5;
			this.addChild(s);
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0xFF00FF,0);
			s.graphics.drawRect(0,0,134,36);
			s.graphics.endFill();
			this.addChild(s);
			
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = _text.toUpperCase();
			_label.autoSize = 'left';
			_label.textFormatName = 'header-nav-item';
			_label.x = (this.width - _label.width) * 0.5;
			_label.y = (this.height - _label.height) * 0.5 + 1;
			
			this.addChild(_label);
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
	}
}

