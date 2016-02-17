package project.views.SettingsOverlay {
	
	// Flash
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// Framework
	import display.Sprite;
	
	// Project
	import project.Constants;
	import project.Project;
	import project.events.ScrollEvent;
	
	
	
	public class ScrollBar extends Sprite {
		
		/********************* CONSTANTS **********************/
		public static const HORIZONTAL:String = 'horizontal';
		public static const VERTICAL:String = 'vertical';
		
		
		
		/******************* PRIVATE VARS *********************/
		private var _enabled:Boolean = false;
		private var _showing:Boolean = true;
		private var _activated:Boolean = false;
		
		private var _defaultX:Number;
		private var _defaultY:Number;
		
		private var _orientation:String;
		
		private var _barBody:Shape;
		
		private var _barCap1:Bitmap;
		private var _barCap2:Bitmap;
		
		private var _bk:Sprite;
		private var _bar:Sprite;
		
		private var _deactivateTimer:Timer = new Timer(1000, 3);
		
		private var _view:Project;
		private var _dragging:Boolean;
		
		
		
		/***************** GETTERS & SETTERS ******************/
		public function get enabled():Boolean { return _enabled; }
		public function set enabled($value:Boolean):void {
			//log('ƒ SET enabled: '+$value);
			
			if ($value == true && !_enabled) _enable();
			
			if ($value == false && _enabled) _disable();
			
			_enabled = $value;
		}
		
		public function get orientation():String { return _orientation; }
		public function set orientation($value:String):void { _orientation = $value; }
		
		public function get aTarg():Number { return (_enabled) ? 1 : 1; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function ScrollBar($orientation:String, $view:Project) {
			super();
			verbose = true;			
			log('CONSTRUCTOR: '+$orientation);
			
			_orientation = id = $orientation;
			
			_view = $view;
			log('\t_view: '+_view);
			
			addEventListener(Event.ADDED_TO_STAGE, _onAdded)
		}
		
		
		
		/******************** PUBLIC API *********************/		
		public function show():void {
			//log('ƒ show');
			_showing = true;
			TweenMax.to(this, 0, {autoAlpha:aTarg, ease:Cubic.easeOut, onComplete:_onShow});
		}
		
		public function hide():void {
			if (_showing) {
				//log('ƒ hide');
				_showing = false;
				TweenMax.to(this, 0.3, {autoAlpha:0, ease:Cubic.easeOut, onComplete:_onHide});
			}
		}
		
		public function update():void {
			//log('ƒ update - _view: '+_view);
			
			if ( _view.spreadManager.curSpread.bounds) {
				var _topLeft:Point = _view.spreadManager.curSpread.globalTopLeft;
				//log('\t_topLeft: '+_topLeft);
				if (_orientation == VERTICAL) {
					_bk.height = (_view.window.height - 22) - 16;
					
					this.x = _defaultX = _view.window.width - this.width + 5;
					
					// look at the difference in height between the view and the spreadmanager - that's the vert pan range
					//var _panRangeY:Number = (_view.spreadManager.height - (_view.window.height - 22));
					var _panRangeY:Number = (_view.spreadManager.height - _view.liveArea.height);
					//log('\t_panRangeY: '+_panRangeY);
					if (_panRangeY > 1) {  // if you can scroll vertically						
						//_bar.height = (_bk.height * ((_view.window.height - 22)/_view.spreadManager.height)) - 4;
						_bar.height = (_bk.height * (_view.liveArea.height/_view.spreadManager.height)) - 4;
						
						// get the topleft x/y of the curSpread					
						var _panPctY:Number = Math.abs(_topLeft.y)/_panRangeY;
						
						var _scrollRangeY:Number = _bk.height - _bar.height - 4;
						
						_bar.y = 2 + _scrollRangeY *  _panPctY;
						
						show();
					} else {
						hide();
					}
					
				}
				
				if (_orientation == HORIZONTAL) {
					_bk.width = _view.window.width - 16;
					
					this.y = _defaultY = (_view.window.height - 22) - this.height + 5;
					
					// look at the difference in width between the view and the spreadmanager - that's the horiz pan range
					//var _panRangeX:Number = (_view.spreadManager.width - _view.window.width);
					var _panRangeX:Number = (_view.spreadManager.width - _view.liveArea.width);
					//log('\t_panRangeX: '+_panRangeX);
					if (_panRangeX > 1) {  // if you can scroll vertically
						//_bar.width = (_bk.width * (_view.window.width/_view.spreadManager.width)) - 4;
						_bar.width = (_bk.width * (_view.liveArea.width/_view.spreadManager.width)) - 4;						
						
						// get the topleft x/y of the curSpread					
						var _panPctX:Number = Math.abs(Constants.MARGIN_WIDTH - _topLeft.x)/_panRangeX;
						
						var _scrollRangeX:Number = _bk.width - _bar.width - 4;
						
						_bar.x = 2 + _scrollRangeX *  _panPctX;
						
						show();
					} else {
						hide();
					}
				}
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _draw():void{
			log('ƒ _draw');
			
			_bk = new Sprite();
			addChild(_bk);
			//TweenMax.to(_bk, 0, {autoAlpha:0});
			
			var _bkgdShape:Shape = new Shape();
			_bkgdShape.graphics.beginFill(0xFFFFFF, 0.5);
			_bkgdShape.graphics.drawRect(0,0,16,16);
			_bkgdShape.graphics.endFill();
			_bk.addChild(_bkgdShape);
			
			var _bkRule:Shape = new Shape()
			_bkRule.graphics.beginFill(0x000000, 0.3);
			if (_orientation == VERTICAL) {
				_bkRule.graphics.drawRect(0,0,1,16);
			} else {
				_bkRule.graphics.drawRect(0,0,16,1);
			}
			_bkRule.graphics.endFill();
			_bk.addChild(_bkRule);
			
			_bar = new Sprite();
			
			_barBody = new Shape();
			_barBody.graphics.beginFill(0x000000, 0.5);
			//_barBody.graphics.drawRect(0,0,7,7);// v1
			if (_orientation == VERTICAL) {
				_barBody.graphics.moveTo(10,0);
				_barBody.graphics.curveTo(20,0,20,6);
				_barBody.graphics.lineTo(20,34);
				_barBody.graphics.curveTo(20,40,10,40)
				_barBody.graphics.curveTo(0,40,0,34);
				_barBody.graphics.lineTo(0,6);
				_barBody.graphics.curveTo(0,0,10,0);
			} else {
				_barBody.graphics.moveTo(0,10);
				_barBody.graphics.curveTo(0,0,6,0);
				_barBody.graphics.lineTo(34,0);
				_barBody.graphics.curveTo(40,0,40,10)
				_barBody.graphics.curveTo(40,20,34,20);
				_barBody.graphics.lineTo(6,20);
				_barBody.graphics.curveTo(0,20,0,10);
			}
			_barBody.graphics.endFill();
			_bar.addChild(_barBody);
			log('SETTING SCALE9GRID!!!!!!');
			_bar.scale9Grid = (_orientation == VERTICAL) ? new Rectangle(10,6,1,28) : new Rectangle(6,10,28,1);
			
			_bar.x = (_orientation == VERTICAL) ? 3 : 2;
			_bar.y = (_orientation == VERTICAL) ? 2 : 3;
			addChild(_bar);
			
			hide();
			
		}
		
		private function _enable():void {
			//log('ƒ _enable - bar: '+_bar);
			_bar.buttonMode = true;
			
			_bar.addEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
			_bar.addEventListener(MouseEvent.MOUSE_OVER, _mouseHandler);
			_bar.addEventListener(MouseEvent.MOUSE_MOVE, _mouseHandler);
			_bar.addEventListener(MouseEvent.MOUSE_OUT, _mouseHandler);
			
			if (_showing) this.alpha = aTarg;
		}
		
		private function _disable():void {
			//log('ƒ _disable');
			_bar.buttonMode = false;
			
			_bar.removeEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
			_bar.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
			_bar.removeEventListener(MouseEvent.MOUSE_OVER, _mouseHandler);
			_bar.addEventListener(MouseEvent.MOUSE_MOVE, _mouseHandler);
			_bar.removeEventListener(MouseEvent.MOUSE_OUT, _mouseHandler);
			
			if (_showing) this.alpha = aTarg;
		}
		
		private function _onShow():void {
			//log('ƒ _onShow');
			// start/restart a 1s timer to deactivate
			enabled = true;
			if (_deactivateTimer.running) _deactivateTimer.reset();
			_deactivateTimer.start();
		}
		
		private function _onHide():void {
			//log('ƒ _onHide');
			enabled = false;
			
			// reset _bk and _bar to their unactivated width/height
			if (_orientation == VERTICAL) {
				_bar.width = 7;
				this.x = _defaultX;
			} else {
				_bar.height = 7;
				this.y = _defaultY;
			}
			
			TweenMax.to(_bk, 0, {autoAlpha:0});
			
		}
		
		private function _activate():void {
			//log('ƒ _activate - _activated: '+_activated);
			if (!_activated) {
				_activated = true;
				
				_deactivateTimer.stop();
				
				if (_orientation == VERTICAL) {
					/*log('\t_defaultX: '+_defaultX);
					log('\tnewX: '+(_view.window.width - _bk.width));*/
					TweenMax.to(_bar, 0.3, {width:11, ease:Cubic.easeOut});
					TweenMax.to(this, 0.3, {x:_view.window.width - _bk.width, ease:Cubic.easeOut});
					
				} else {
					/*log('\t_defaultY: '+_defaultY);
					log('\tY: '+this.y);
					log('\tnewY: '+(_view.window.height - 22 - _bk.height));*/
					
					TweenMax.to(_bar, 0.3, {height:11, ease:Cubic.easeOut});
					TweenMax.to(this, 0.3, {y:_view.window.height - 22 - _bk.height, ease:Cubic.easeOut});
				}
				TweenMax.to(_bk, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			}
		}
		
		private function _deactivate():void {
			//log('ƒ _deactivate');
			_activated = false;
			hide();
		}
		
		private function _scrollContent():void {
			var _scrollRange:Number;
			var _scrollPct:Number;
			var _panRange:Number;
			
			if (_orientation == VERTICAL) {
				_scrollRange = _bk.height - _bar.height - 4;
				_scrollPct = (2 + Math.abs(_bar.y))/_scrollRange;
				
				//_panRange = (_view.spreadManager.height - (_view.window.height - 22));
				_panRange = (_view.spreadManager.height - _view.liveArea.height);
				
				//_view.spreadManager.y = (((_view.window.height - 22) * 0.5) + (_panRange * 0.5)) - (_panRange * _scrollPct);
				_view.spreadManager.y = ((_view.liveArea.height * 0.5) + (_panRange * 0.5)) - (_panRange * _scrollPct);
				
				stage.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL_V));
			} else {
				_scrollRange = _bk.width - _bar.width - 4;
				_scrollPct = (2 + Math.abs(_bar.x))/_scrollRange;
				
				//_panRange = (_view.spreadManager.width - _view.window.width);
				_panRange = (_view.spreadManager.width - _view.liveArea.width);
				
				// v1 
				//_view.spreadManager.x = ((_view.window.width * 0.5) + (_panRange * 0.5)) - (_panRange * _scrollPct);
				
				// v2 
				//var newX:Number = (Constants.MARGIN_WIDTH + (_view.liveArea.width * 0.5)) + (_panRange * 0.5) - (_panRange * _scrollPct);
				var newX:Number = Constants.MARGIN_WIDTH + (_view.spreadManager.width * 0.5)  - ((_view.spreadManager.width - _view.liveArea.width) * (_bar.x)/(_bk.width - _bar.width));
				//if (newX < _view.window.width - 1))
				_view.spreadManager.x = newX;
				//v3

				
				stage.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL_H));
			}
			
			//_view.spreadManager.curSpread.repositionFlags(_view.window.width, (_view.window.height - 22))
			_view.spreadManager.curSpread.repositionFlags(_view.liveArea.width, _view.liveArea.height)

		}
		
		
		
		/******************* EVENT HANDLERS********************/
		private function _onAdded($e:Event):void {
			//log('ƒ _onAdded');
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			
			stage.addEventListener(PanEvent.PAN_DRAG, _onPan);
			stage.addEventListener(PanEvent.PAN_DRAG_V, _onPan);
			stage.addEventListener(PanEvent.PAN_DRAG_H, _onPan);
			stage.addEventListener(PanEvent.PAN_MOUSE_WHEEL, _onPan);			
						
			_deactivateTimer.addEventListener(TimerEvent.TIMER, _onTimer);
			
			_draw();
		}
		
		private function _mouseHandler($e:MouseEvent):void{
			if(_enabled){
				switch($e.type){
					case MouseEvent.MOUSE_OVER:
						_activate();						
						break;
					
					case MouseEvent.MOUSE_OUT:
						// start/restart a timer to deactivate
						_deactivateTimer.reset();
						_deactivateTimer.start();
						break;
					
					case MouseEvent.MOUSE_DOWN:
						// startDrag
						$e.stopImmediatePropagation();
						
						_deactivateTimer.stop();
						
						var _dragBounds:Rectangle = (_orientation == VERTICAL) ? new Rectangle(3, 2, 0, _bk.height - _bar.height - 4) : _dragBounds = new Rectangle(2, 3, _bk.width - _bar.width - 4, 0);
						_bar.startDrag(false,_dragBounds);
						
						_dragging = true;
						break;
					
					case MouseEvent.MOUSE_MOVE:
						$e.stopImmediatePropagation();
						
						if (_dragging) _scrollContent();
						break;
					
					case MouseEvent.MOUSE_UP:
						$e.stopImmediatePropagation();
						
						_bar.stopDrag();
						
						_dragging = false;
						break;
				}
			}
		}
		
		private function _onTimer($e:TimerEvent):void {
			_deactivate();
		}
		
		private function _onPan($e:PanEvent):void {
			switch ($e.type) {
				case PanEvent.PAN_UP:
					log('PAN_UP');
					if (_orientation == VERTICAL) update();
					break;
				
				case PanEvent.PAN_DOWN:
					log('PAN_DOWN');
					if (_orientation == VERTICAL) update();
					break;
				
				case PanEvent.PAN_LEFT:
					log('PAN_LEFT');
					if (_orientation == HORIZONTAL) update();
					break;
				
				case PanEvent.PAN_RIGHT:
					log('PAN_RIGHT');
					if (_orientation == HORIZONTAL) update();
					break;
				
				case PanEvent.PAN_DRAG_V:
					log('PAN_DRAG_V');
					if (_orientation == VERTICAL) update();
					break;
				
				case PanEvent.PAN_DRAG_H:
					log('PAN_DRAG_H');
					if (_orientation == HORIZONTAL) update();
					break;
				
				case PanEvent.PAN_MOUSE_WHEEL:
					log('PAN_MOUSE_WHEEL');
					if (_orientation == VERTICAL) update();
					break;
			}
		}
		
		/********************* HELPERS ***********************/
		
	}
}