package project.views.Header.AlertDrawer {
	
	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// Framework
	import components.controls.Label;	
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.ViewTransitionEvent;

	
	
	public class AlertDrawerItem extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _text:String;
		private var _label:Label;
		private var _marker:Shape;
		private var _xml:XML;
		private var _markerCleared:Boolean = false;
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function AlertDrawerItem($xml:XML) {
			super();
			verbose = true;
			_xml = $xml;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			
		}
		
		public function hide():void {
			
		}
		
		public function reset():void {
			if (_xml.@marker == 'yes' && !_markerCleared) {
				TweenMax.to(_marker, 0, {autoAlpha:1});
			}
		}
		
		public function clear():void {
			if (_xml.@marker == 'yes') {
				TweenMax.to(_marker, 0, {autoAlpha:0});
			}
		}
		
		public function restore():void {
			_markerCleared = false;
			if (_xml.@marker == 'yes') {
				TweenMax.to(_marker, 0, {autoAlpha:1});
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			this.addChild(Register.ASSETS.getBitmap(_xml.@file));
			if (_xml.@enabled == 'yes') {
				var btn:Sprite = new Sprite();
				btn.addChild(Register.ASSETS.getBitmap('alertDrawer_OpenInEditor'));
				btn.addEventListener(MouseEvent.MOUSE_OVER, _handleAlertBtn);
				btn.addEventListener(MouseEvent.MOUSE_OUT, _handleAlertBtn);
				btn.addEventListener(MouseEvent.CLICK, _handleAlertBtn);
				btn.x = 27;
				btn.y = 44;
				this.addChild(btn);
			}
			
			if (_xml.@marker == 'yes') {
				_marker = new Shape();
				_marker.graphics.beginFill(0x00A3DA);
				_marker.graphics.drawCircle(0,0,4);
				_marker.graphics.endFill();
				_marker.x = -18;
				_marker.y = 10;
				
				if (_xml.@enabled != 'yes'){
					this.addEventListener(MouseEvent.CLICK, _clearAlert);
				}
				this.addChild(_marker);
			}
			
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _handleAlertBtn($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(Sprite($e.target), 0, {tint:0x00A3DA});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(Sprite($e.target), 0.3, {tint:null, ease:Cubic.easeOut});
					break;
				
				case MouseEvent.CLICK:
					_clearAlert();
					this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.PREPARE_TO_ADD));
					break;
			}		
		}
		
		private function _clearAlert($e:MouseEvent = null):void {
			if (_marker.alpha == 1) {
				_markerCleared = true;
				this.dispatchEvent(new Event('alertCleared'));
				TweenMax.to(_marker, 0.3, {autoAlpha:0});
			}
		}
	}
}