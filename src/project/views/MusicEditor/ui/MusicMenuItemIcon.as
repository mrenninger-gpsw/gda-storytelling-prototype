package project.views.MusicEditor.ui {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// CandyLizard Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;
	
	
	
	public class MusicMenuItemIcon extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _bkgd:Shape;
		private var _label:Label;
		private var _text:String;
		private var _defaultIcon:Bitmap;
		private var _selectedIcon:Bitmap;
		private var _lockedIcon:Bitmap;
		private var _locked:Boolean
		private var _dancingBars:DancingBars;

		
		
		/******************** CONSTRUCTOR *********************/
		public function MusicMenuItemIcon($text:String, $locked:Boolean) {
			super();
			
			_text = $text;
			_locked = $locked;
			
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function select($b:Boolean, $immediate:Boolean = false):void {
			var time:Number = ($immediate) ? 0 : 0.3; 
			if ($b) {
				TweenMax.to(_defaultIcon, time, {alpha:0, ease:Cubic.easeOut});
				//TweenMax.to(_selectedIcon, time, {alpha:1, ease:Cubic.easeOut});
				TweenMax.to(_label, time, {tint:0xFFFFFF, ease:Cubic.easeOut});
				TweenMax.to(_bkgd, time, {tint:0x00A3DA, ease:Cubic.easeOut});
				TweenMax.to(_dancingBars, time, {alpha:1, ease:Cubic.easeOut});
				_dancingBars.activate();
			} else {
				TweenMax.to(_defaultIcon, time, {alpha:1, ease:Cubic.easeOut});
				//TweenMax.to(_selectedIcon, time, {alpha:0, ease:Cubic.easeOut});
				TweenMax.to(_label, time, {tint:null, ease:Cubic.easeOut});
				TweenMax.to(_bkgd, time, {tint:null, ease:Cubic.easeOut});				
				TweenMax.to(_dancingBars, time, {alpha:0, ease:Cubic.easeOut});
				_dancingBars.deactivate();
			}
		}
		

		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_bkgd = new Shape();
			_bkgd.graphics.beginFill(0x141414);
			_bkgd.graphics.drawRect(0,0,45,45);
			_bkgd.graphics.endFill();
			this.addChild(_bkgd);
			
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = _text;
			_label.autoSize = 'left';
			_label.textFormatName = 'music-item-icon';
			_label.x = (this.width - _label.width) * 0.5;
			_label.y = 27;
			this.addChild(_label);		
			
			if (_locked) {
				_lockedIcon = Register.ASSETS.getBitmap('musicItem_lockIcon');
				_lockedIcon.x = (this.width - _lockedIcon.width) * 0.5;
				_lockedIcon.y = _label.y - 3 - _lockedIcon.height;
				this.addChild(_lockedIcon);
			} else {
				_defaultIcon = Register.ASSETS.getBitmap('musicItem_albumIcon');
				_defaultIcon.x = (this.width - _defaultIcon.width) * 0.5;
				_defaultIcon.y = _label.y - 3 - _defaultIcon.height;
				this.addChild(_defaultIcon);
				
				_dancingBars = new DancingBars() 
				_dancingBars.x = (this.width - _dancingBars.width) * 0.5;
				_dancingBars.y = _label.y - 3 - 14;
				_dancingBars.alpha = 0;
				this.addChild(_dancingBars);
			}
			
		}
	}
}