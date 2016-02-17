package project.views {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.ViewTransitionEvent;
	import project.views.Header.AlertDrawer;
	import project.views.Header.HeaderNav;	
	
		
	
	public class Header extends Sprite {
		
		/******************* PRIVATE VARS *********************/
		private var _addMediaBtn:Bitmap;
		private var _headerNav:HeaderNav;
		private var _alertDrawer:AlertDrawer;
		private var _settingsIcon:Bitmap
		
		
		
		/******************** CONSTRUCTOR *********************/		
		public function Header() {
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/******************** PUBLIC API *********************/
		public function switchStates($id:String):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					//TweenMax.to(_addMediaBtn, 0.3, {autoAlpha:0});
					break;
				
				case 'video':
					//TweenMax.to(_addMediaBtn, 0.3, {autoAlpha:1});
					break;
			}
		}
		
		public function showAlert($b:Boolean = true):void {
			_alertDrawer.activate($b)
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0x141414);
			bgShape.graphics.drawRoundRectComplex(0,0,Register.APP.WIDTH,66,5,5,0,0);
			bgShape.graphics.endFill();
			addChild(bgShape);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, _dragWindow);
			
			// Window controls
			var closeBtn:Sprite = new Sprite();
			closeBtn.graphics.beginFill(0xFC625D);
			closeBtn.graphics.drawCircle(0,0,6);
			closeBtn.graphics.endFill();
			closeBtn.x = 23;
			closeBtn.y = (bgShape.height * 0.5);
			addChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_OVER, _handleCloseBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_OUT, _handleCloseBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_DOWN, _handleCloseBtn);
			
			var minBtn:Sprite = new Sprite();
			minBtn.graphics.beginFill(0xFDBC40);
			minBtn.graphics.drawCircle(0,0,6);
			minBtn.graphics.endFill();
			minBtn.x = closeBtn.x + closeBtn.width + 6;
			minBtn.y = closeBtn.y;
			addChild(minBtn);

			var maxBtn:Sprite = new Sprite();
			maxBtn.graphics.beginFill(0x34C849);
			maxBtn.graphics.drawCircle(0,0,6);
			maxBtn.graphics.endFill();
			maxBtn.x = minBtn.x + minBtn.width + 6;
			maxBtn.y = closeBtn.y;
			addChild(maxBtn);
			
			/*_addMediaBtn = Register.ASSETS.getBitmap('addMediaBtn');
			_addMediaBtn.x = 95;
			_addMediaBtn.y = (bgShape.height - _addMediaBtn.height) * 0.5;
			addChild(_addMediaBtn);*/
			
			// create the add media drawer here
			
			/*var alertStatic:Bitmap = Register.ASSETS.getBitmap('alert_static');
			alertStatic.x = 1130;
			alertStatic.y = (bgShape.height - alertStatic.height) * 0.5;
			addChild(alertStatic);*/
			
			_settingsIcon = Register.ASSETS.getBitmap('settings_icon');
			_settingsIcon.x = 1165;
			_settingsIcon.y = (bgShape.height - _settingsIcon.height) * 0.5;
			TweenMax.to(_settingsIcon, 0, {autoAlpha:0});
			addChild(_settingsIcon);
			
			var loggedInWithAvatar:Bitmap = Register.ASSETS.getBitmap('logged_in_with_avatar');
			loggedInWithAvatar.x = 1206;
			loggedInWithAvatar.y = (bgShape.height - loggedInWithAvatar.height) * 0.5;
			addChild(loggedInWithAvatar);
			
			_headerNav = new HeaderNav();
			_headerNav.x = (bgShape.width - _headerNav.width) * 0.5;
			_headerNav.y = (bgShape.height - _headerNav.height) * 0.5;
			this.addChild(_headerNav);
			
			// create the alert drawer here
			_alertDrawer = new AlertDrawer();
			_alertDrawer.x = 1138;
			_alertDrawer.y = bgShape.height * 0.5;
			TweenMax.to(_alertDrawer, 0, {autoAlpha:0});
			this.addChild(_alertDrawer);
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.stage.addEventListener(ViewTransitionEvent.MEDIA, _alertDrawer.reset);
			this.stage.addEventListener(ViewTransitionEvent.EDITOR, _handleViewTransitionEvent);
			this.stage.addEventListener(ViewTransitionEvent.MEDIA, _handleViewTransitionEvent);
		}
		
		private function _dragWindow($e:MouseEvent):void {
			log('MOUSE DOWN!!!');
			stage.nativeWindow.startMove();
		}
		
		private function _handleCloseBtn($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(($e.target as Sprite),0,{tint:0xFF0000});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(($e.target as Sprite),0.3,{tint:null});
					break;
				
				case MouseEvent.MOUSE_DOWN:
					Register.APP.windowManager.closeCurrentWindow();
					break;
				
			}
		}
		
		private function _handleViewTransitionEvent($e:ViewTransitionEvent):void {
			switch ($e.type) {
				case ViewTransitionEvent.EDITOR:
					TweenMax.to(_alertDrawer, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
					TweenMax.to(_settingsIcon, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
					break;
				
				case ViewTransitionEvent.MEDIA:
					_alertDrawer.reset();
					TweenMax.to(_alertDrawer, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
					TweenMax.to(_settingsIcon, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
					break;
			}
		}
	}
}