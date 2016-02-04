package project.views.MusicSelector.ui {
	
	// CandyLizard Framework
	import components.controls.Label;
	import display.Sprite;	
	
	
	
	public class MusicNavBtn extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _w:Number;
		private var _text:String;
		private var _label:Label;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MusicNavBtn($text:String, $width:Number) {
			super();
			
			_w = $width;
			_text = $text;
			
			_init();
		}		


		
		/******************** PRIVATE API *********************/
		private function _init():void {
			this.graphics.beginFill(0x000000, 0);
			this.graphics.drawRect(0, 0, _w, 51);
			this.graphics.endFill();
			
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = _text;
			_label.autoSize = 'left';
			_label.textFormatName = 'music-nav';
			_label.x = (this.width - _label.width) * 0.5;
			_label.y = (this.height - _label.height) * 0.5;
			
			this.addChild(_label);
		}
	}
}