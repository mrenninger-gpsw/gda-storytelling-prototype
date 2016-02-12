package project.views.MediaLibrary.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;

	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;
	

	
	public class MediaLibraryMenuItem extends Sprite {
		
		
		/******************** PRIVATE VARS ********************/
		private var _num:uint;
		private var _xml:XML;
		private var _title:String;
		private var _bkgd:Shape;
		private var _label:Label;
		private var _selected:Boolean;
		private var _icon:Bitmap;

		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get num():Number{ return _num; }
		public function get label():Label { return _label; }
		public function get title():String { return _title; }

		
		
		public function MediaLibraryMenuItem($num:uint, $xml:XML) {
			super();
			verbose = true;
			
			_num = $num;
			_xml = $xml.item[_num];
			_title = _xml;
			//log('xml: '+_xml);
			
			_init();
		}
		
		
		/********************* PUBLIC API *********************/	
		public function select($b:Boolean, $immediate:Boolean = false):void {
			
			if ($b && !_selected) {
				log('selecting item: '+_num);
				_selected = true;
				_label.textFormatName = 'media-menuitem-select';
				_label.y = (this.height - _label.height) * 0.5;
				TweenMax.to(_bkgd, ($immediate) ? 0: 0.3, {alpha:1, ease:Cubic.easeOut});
				TweenMax.allTo([_icon,_label], ($immediate) ? 0: 0.3, {tint:0xFFFFFF, ease:Cubic.easeOut});

			} 
			
			if (!$b && _selected) {
				log('deselecting item: '+_num);
				_selected = false;
				_label.textFormatName = 'media-menuitem-default';
				_label.y = (this.height - _label.height) * 0.5;
				TweenMax.to(_bkgd, ($immediate) ? 0: 0.3, {alpha:0, ease:Cubic.easeOut});
				TweenMax.allTo([_icon,_label], ($immediate) ? 0: 0.3, {tint:null, ease:Cubic.easeOut});
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			// Selected Shape
			_bkgd = new Shape();
			_bkgd.graphics.beginFill(0x141414);
			_bkgd.graphics.drawRect(0,0,224,40);
			_bkgd.graphics.endFill();
			_bkgd.alpha = 0;
			this.addChild(_bkgd);
			
			// icon
			_icon = Register.ASSETS.getBitmap(_xml.@icon);
			_icon.x = 21
			_icon.y = (this.height - _icon.height) * 0.5;
			this.addChild(_icon);
			
			// Title Label
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = _xml.@title;
			_label.autoSize = 'left';
			_label.textFormatName = 'media-menuitem-default';
			_label.x = 48;
			_label.y = (this.height - _label.height) * 0.5;
			this.addChild(_label);
			
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