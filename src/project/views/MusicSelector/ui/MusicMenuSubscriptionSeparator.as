package project.views.MusicSelector.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;	
	
	
	public class MusicMenuSubscriptionSeparator extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		
		private var _label:Label;
		private var _bkgd:Shape;
		private var _initX:Number;
		
		

		/***************** GETTERS & SETTERS ******************/			
		public function get initX():Number{ return _initX; }
		public function set initX($value:Number):void { _initX = $value; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MusicMenuSubscriptionSeparator() {
			super();
			verbose = true;
			
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			// Selected Shape
			_bkgd = new Shape();
			_bkgd.graphics.beginFill(0x141414, 0);
			_bkgd.graphics.drawRect(0,0,424,80);
			_bkgd.graphics.endFill();
			_bkgd.alpha = 0;
			this.addChild(_bkgd);
			
			var img:Bitmap = Register.ASSETS.getBitmap('musicItem_subscriptionOnly')
			img.x = (this.width - img.width) * 0.5
			img.y = (this.height - img.height) * 0.5
			this.addChild(img);
			
			// Title Label
			/*_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = 'SUBSCRIPTION ONLY';
			_label.autoSize = 'left';
			_label.textFormatName = 'music-item-title';
			_label.x = 74
			_label.y = 16;
			this.addChild(_label);*/
			
			// Bottom Line
			var line:Shape = new Shape();
			line.graphics.beginFill(0x353535);
			line.graphics.drawRect(0,0,424,1);
			line.graphics.endFill();
			line.y = 79
			this.addChild(line);
		}
		
		private function _addListeners():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();			
		}
	}
}