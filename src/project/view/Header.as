package project.view {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	
	// CandyLizard Framework	
	import display.Sprite;
	import utils.Register;
	
		
	
	public class Header extends Sprite {
		
		/******************* PRIVATE VARS *********************/
		private var _addMediaBtn:Bitmap;
		
		
		
		/******************** CONSTRUCTOR *********************/		
		public function Header() {
			super();			
			_init();	
		}
		
		
		
		/******************** PUBLIC API *********************/
		public function switchStates($id:String):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					TweenMax.to(_addMediaBtn, 0.3, {autoAlpha:0});
					break;
				
				case 'video':
					TweenMax.to(_addMediaBtn, 0.3, {autoAlpha:1});
					break;
			}
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
			
			_addMediaBtn = Register.ASSETS.getBitmap('addMediaBtn');
			_addMediaBtn.x = 95;
			_addMediaBtn.y = (bgShape.height - _addMediaBtn.height) * 0.5;
			addChild(_addMediaBtn);

			var alertStatic:Bitmap = Register.ASSETS.getBitmap('alert_static');
			alertStatic.x = 1130;
			alertStatic.y = (bgShape.height - alertStatic.height) * 0.5;
			addChild(alertStatic);
			
			var settingsIcon:Bitmap = Register.ASSETS.getBitmap('settings_icon');
			settingsIcon.x = 1165;
			settingsIcon.y = (bgShape.height - settingsIcon.height) * 0.5;
			addChild(settingsIcon);
			
			var loggedInWithAvatar:Bitmap = Register.ASSETS.getBitmap('logged_in_with_avatar');
			loggedInWithAvatar.x = 1206;
			loggedInWithAvatar.y = (bgShape.height - loggedInWithAvatar.height) * 0.5;
			addChild(loggedInWithAvatar);
			
			// nav
			var navBkgd:Bitmap = Register.ASSETS.getBitmap('header_nav_bkgd');
			navBkgd.x = 507;
			navBkgd.y = (bgShape.height - navBkgd.height) * 0.5;
			addChild(navBkgd);
			
			var activeShape:Shape = new Shape();
			activeShape.graphics.beginFill(0x353535);
			activeShape.graphics.drawRect(0,0,133,36);
			activeShape.graphics.endFill();
			activeShape.x = 640;
			activeShape.y = navBkgd.y;
			addChild(activeShape);
			
			var manageText:Bitmap = Register.ASSETS.getBitmap('manageText');
			manageText.x = 545;
			manageText.y = (bgShape.height - manageText.height) * 0.5;
			addChild(manageText);
			
			var editText:Bitmap = Register.ASSETS.getBitmap('editText');
			editText.x = 693;
			editText.y = (bgShape.height - editText.height) * 0.5;
			TweenMax.to(editText,0,{tint:0xFFFFFF});
			addChild(editText);

		}
		
		
		
		/******************* EVENT HANDLERS *******************/
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
		
		
	}
}