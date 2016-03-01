package project.views.Header {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	
	// Framework
	import components.controls.Label;	
	import display.Sprite;
	import utils.Register;
	import utils.Utilities;
	
	// Project
	import project.views.Header.AlertDrawer.AlertDrawerItem;
	
	

	public class AlertDrawer extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _text:String;
		private var _label:Label;
		private var _numAlerts:uint = 2;
		private var _icon:Sprite;
		private var _initX:Number;
		private var _showing:Boolean = false;
		private var _bg:Sprite;
		private var _closeBtn:Sprite;
		private var _xml:XMLList
		private var _alertsV:Vector.<AlertDrawerItem>;
		private var _mouseIsOver:Boolean = false;
		private var _activated:Boolean = false;
		private var _circle:Sprite;

		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function AlertDrawer() {
			super();
			verbose = true;
			_xml = Register.PROJECT_XML.content.header.alertDrawer;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			_showing = true;
			Utilities.mouseEnable(_icon,false,_onMouseEvent);
			TweenMax.to(this, 0.3, {x:_initX-98, ease:Cubic.easeInOut});
			TweenMax.to(_bg, 0.3, {x:-52, autoAlpha:1, ease:Cubic.easeInOut, onComplete:_onShowComplete});
			TweenMax.to(_closeBtn, 0, {tint:null});
			for (var i:uint = 0; i < _alertsV.length; i++) {
				if (_activated) {
					_alertsV[i].reset();
				} else {
					_alertsV[i].clear();
				}
				TweenMax.to(_alertsV[i], 0.3, {x:37, autoAlpha:1, ease:Back.easeOut, delay:0.2 + (i * 0.05)});
			}

		}
		
		public function hide():void {
			_showing = false;
			_removeListeners();
			Utilities.mouseEnable(_icon,true,_onMouseEvent);
			TweenMax.to(this, 0.3, {x:_initX, ease:Cubic.easeInOut});
			TweenMax.to(_bg, 0.3, {x:50, autoAlpha:0, ease:Cubic.easeInOut, onComplete:_onHideComplete});
		}
		
		public function reset($e:Event = null):void {
			_numAlerts = 2;
			_label.text = _numAlerts.toString();
			for (var i:uint = 0; i < _alertsV.length; i++) {
				_alertsV[i].reset();
			}
		}
		
		public function activate($b:Boolean = true):void {
			_activated = $b;
			if ($b) {
				for (var i:uint = 0; i < _alertsV.length; i++) {
					_alertsV[i].restore();
				}
				TweenMax.to(_circle, 0.3, {autoAlpha:1, scaleX:1, scaleY:1, ease:Back.easeOut});
			} else {
				TweenMax.to(_circle, 0.3, {autoAlpha:0, scaleX:0, scaleY:0, ease:Back.easeIn});
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_icon = new Sprite()
			this.addChild(_icon);
			_icon.name = '_icon'
			Utilities.mouseEnable(_icon,true,_onMouseEvent);
			
			// default alert icon
			var alertStatic:Bitmap = Register.ASSETS.getBitmap('alert_static');
			alertStatic.x = -alertStatic.width * 0.5
			alertStatic.y = -alertStatic.height * 0.5
			_icon.addChild(alertStatic);
			
			// create the alert shape and amount label
			_circle = new Sprite();
			_icon.addChild(_circle);
			
			var s:Shape = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawCircle(0,0,15);
			s.graphics.endFill();
			_circle.addChild(s);
			
			_label = new Label();
			_label.text = _numAlerts.toString();
			_label.autoSize = 'left';
			_label.textFormatName = 'alert-drawer-amount';
			_label.x = Math.round(-_label.width * 0.5);
			_label.y = Math.round(-_label.height * 0.5);			
			_circle.addChild(_label);
			
			activate(false);
		}
		
		private function _onShowComplete():void {
			_addListeners();
		}
		
		private function _onHideComplete():void {
			for (var i:uint = 0; i < _alertsV.length; i++) {
				TweenMax.to(_alertsV[i], 0, {x:87, autoAlpha:0});
			}
		}
		
		private function _createDrawer():void {
			// background
			_bg = new Sprite();
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0xFFFFFF);
			bgShape.graphics.drawRect(0,0,292,860);
			bgShape.graphics.endFill();
			_bg.addChild(bgShape);
			this.addChildAt(_bg,0);
			TweenMax.to(_bg, 0, {x:50, y:-this.y, autoAlpha:0});
			
			_closeBtn = new Sprite();
			_closeBtn.addChild(Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlertClose'));
			_closeBtn.x = _bg.width - _closeBtn.width - 13;
			_closeBtn.y = 13;
			_bg.addChild(_closeBtn);
			
			_alertsV = new Vector.<AlertDrawerItem>();
			for (var i:uint = 0; i < _xml.alert.length(); i++) {
				var tAlert:AlertDrawerItem = new AlertDrawerItem(_xml.alert[i]);
				tAlert.x = 87;
				tAlert.y = (i == 0) ? 69 : _alertsV[(i-1)].y + _alertsV[(i-1)].height + 10; 
				tAlert.addEventListener('alertCleared', _onAlertCleared);
				TweenMax.to(tAlert, 0, {autoAlpha:0});
				_bg.addChild(tAlert);
				_alertsV.push(tAlert);
			}
			
		}
		
		private function _addListeners():void {
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			
			_closeBtn.addEventListener(MouseEvent.MOUSE_OVER, _handleCloseBtn);
			_closeBtn.addEventListener(MouseEvent.MOUSE_OUT, _handleCloseBtn);
			_closeBtn.addEventListener(MouseEvent.CLICK, _handleCloseBtn);
		}
		
		private function _removeListeners():void {
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			
			_closeBtn.removeEventListener(MouseEvent.MOUSE_OVER, _handleCloseBtn);
			_closeBtn.removeEventListener(MouseEvent.MOUSE_OUT, _handleCloseBtn);
			_closeBtn.removeEventListener(MouseEvent.CLICK, _handleCloseBtn);
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_initX = this.x;
			
			_createDrawer();
		}
		
		private function _onMouseEvent($e:MouseEvent):void {
			
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					
					break;
				
				case MouseEvent.MOUSE_OUT:
					
					break;
				
				case MouseEvent.CLICK:
					if ($e.target == _icon) {
						if (!_showing) {
							show();
						}
					}
					break;
			}
		}
		
		private function _handleCloseBtn($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(_closeBtn, 0, {tint:0x00A3DA});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(_closeBtn, 0.3, {tint:null, ease:Cubic.easeOut});
					break;
				
				case MouseEvent.CLICK:
					if (_showing) hide();
					break;
			}		
		}
		
		private function _onAlertCleared($e:Event):void {
			_numAlerts --;
			
			if (_numAlerts > 0){			
				_label.text = _numAlerts.toString();
			} else {
				activate(false);
			}
			
			if (_showing) hide();
		}
		
		private function _handleMouseDown($e:MouseEvent):void {
			if (!_mouseIsOver) {
				if (_showing) hide();
			}
		}
		
		private function _handleMouseMove($e:MouseEvent):void {
			var p:Point = localToGlobal(new Point(mouseX, mouseY));
			_mouseIsOver = this.hitTestPoint(p.x,p.y);
		}
	}
}