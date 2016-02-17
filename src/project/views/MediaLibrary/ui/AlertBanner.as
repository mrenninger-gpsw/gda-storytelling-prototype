package project.views.MediaLibrary.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// Framework
	import components.controls.Label;	
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.ViewTransitionEvent;	
	
	
	
	public class AlertBanner extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _text:String;
		private var _label:Label;
		private var _cta:Sprite;
		private var _close:Sprite;
		private var _bg:Bitmap 
		private var _mouseIsOver:Boolean = false;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function AlertBanner() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			TweenMax.to(this, 0.3, {x:'-20', autoAlpha:1, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}
		
		public function hide():void {
			_removeListeners()

			TweenMax.to(this, 0.3, {x:'20', autoAlpha:0, ease:Cubic.easeOut, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_bg = Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlert');
			addChild(_bg);
			
			_cta = new Sprite();
			_cta.addChild(Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlertCTA'));
			_cta.x = 61;
			_cta.y = 71;
			addChild(_cta);

			_close = new Sprite();
			_close.addChild(Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlertClose'));
			_close.x = 274;
			_close.y = 48
			
			addChild(_close);
			
			TweenMax.to(this, 0, {autoAlpha:0});
			
		}
		
		private function _onShowComplete():void {
			_addListeners();
		}
		
		private function _onHideComplete():void {
			this.parent.removeChild(this);
		}
		
		private function _addListeners():void {
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			
			_cta.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
			_cta.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
			_cta.addEventListener(MouseEvent.CLICK, _handleMouseEvent);
			
			_close.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
			_close.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
			_close.addEventListener(MouseEvent.CLICK, _handleMouseEvent);
		}
		
		private function _removeListeners():void {
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);

			_cta.removeEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
			_cta.removeEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
			_cta.removeEventListener(MouseEvent.CLICK, _handleMouseEvent);
			
			_close.removeEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
			_close.removeEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
			_close.removeEventListener(MouseEvent.CLICK, _handleMouseEvent);
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.x += 20;
		}
		
		private function _handleMouseEvent($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(Sprite($e.target), 0, {tint:0x00A3DA});
					break;
				
				case MouseEvent.MOUSE_OUT:
					_mouseIsOver = false;
					TweenMax.to(Sprite($e.target), 0.3, {tint:null, ease:Cubic.easeOut});
					break;
				
				case MouseEvent.CLICK:
					hide();	
					if ($e.target == _cta) {
						this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.PREPARE_TO_ADD));
					}
					break;
			}
		}
		
		private function _handleMouseDown($e:MouseEvent):void {
			if (!_mouseIsOver) {
				hide();
			}
		}
		
		private function _handleMouseMove($e:MouseEvent):void {
			var p:Point = localToGlobal(new Point(mouseX, mouseY));
			_mouseIsOver = this.hitTestPoint(p.x,p.y);
		}
	}
}
