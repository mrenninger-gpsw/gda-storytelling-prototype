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
	import utils.StringUtilities;

	// Project

	
	
	public class EventClipPreview extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XML;
		private var _label:Label;
		private var _outline:Sprite;
		private var _outlineThickness:Number = 6;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get isVideo():Boolean { return (_xml.@type == 'video');};
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function EventClipPreview($xml:XML) {
			super();
			verbose = true;
			_xml = $xml
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			log('show');
			TweenMax.to(this, 0, {autoAlpha:1});
		}
		
		public function hide():void {
			log('hide');
			TweenMax.to(this, 0, {autoAlpha:0}); 
		}
		
		public function select($b:Boolean = true):void {
			TweenMax.to(_outline, 0.2, {autoAlpha:($b)?1:0, ease:Cubic.easeOut});
		}
		
		public function soften($b:Boolean = true):void {
			TweenMax.to(this, 0.2, {autoAlpha:($b)?0.3:1, ease:Cubic.easeOut});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			//log('_init');
			
			// get the preview image
			var img:Bitmap = Register.ASSETS.getBitmap(_xml.@file);
			this.addChild(img);
			
			// create the icon
			var icon:Bitmap =  Register.ASSETS.getBitmap('mediaContentArea_'+StringUtilities.initialCap(_xml.@type)+'Icon');
			icon.x = 10;
			icon.y = this.height - icon.height - 10;
			this.addChild(icon);
			
			// create the amount label
			_label = new Label();
			_label.text = (_xml.@amt == 0) ? '' : _xml.@amt;
			_label.autoSize = 'left';
			_label.textFormatName = 'media-event-clip-preview-amount';
			_label.x = icon.x + icon.width + 9;
			_label.y = icon.y + ((icon.height - _label.height) * 0.5);
			this.addChild(_label);
			
			// hilite icon if type == video
			if (_xml.@type == 'video' && _xml.@hilites == 'true') {
				icon =  Register.ASSETS.getBitmap('mediaContentArea_HiliteIcon');
				icon.x = this.width - icon.width - 10;
				icon.y = this.height - icon.height - 10;
				this.addChild(icon);
			}
			
			// draw blue highlight
			_outline = new Sprite();
			var s:Shape = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawRect(0,0,this.width - _outlineThickness,_outlineThickness);
			s.graphics.endFill();
			_outline.addChild(s);
			
			s = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawRect(0,0,this.width - _outlineThickness,_outlineThickness);
			s.graphics.endFill();
			s.x = _outlineThickness;
			s.y = this.height - _outlineThickness;
			_outline.addChild(s);
			
			s = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawRect(0,0,_outlineThickness,this.height - _outlineThickness);
			s.graphics.endFill();
			s.x = this.width - _outlineThickness;
			s.y = 0;			
			_outline.addChild(s);
			
			s = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawRect(0,0,_outlineThickness,this.height - _outlineThickness);
			s.graphics.endFill();
			s.x = 0;
			s.y = _outlineThickness;			
			_outline.addChild(s);
			
			_outline.alpha = 0;
			_outline.mouseChildren = false;
			_outline.mouseEnabled = false;
			this.addChild(_outline);
			
			
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		
		
		/******************* HELPERS *******************/
		

	}
}