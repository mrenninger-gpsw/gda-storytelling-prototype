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
	
	// Project
	import project.events.UITransitionEvent;
	import project.view.ui.FooterBtn;
	import project.view.ui.UITransitionBtn;
	
	
	
	public class Footer extends Sprite {
		
		/********************* CONSTANTS **********************/	
		private var _changeVideoBtn:UITransitionBtn;
		private var _changeMusicBtn:UITransitionBtn;
		private var _previewBtn:FooterBtn;
		private var _saveBtn:FooterBtn;
		private var _subscriptionBtn:FooterBtn;
		private var _menu:Bitmap;
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function Footer() {
			super();
			verbose = true;
			_init();	
		}
		
	
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0x141414);
			bgShape.graphics.drawRect(0,0,Register.APP.WIDTH, 80);
			bgShape.graphics.endFill();
			addChild(bgShape);
			
			_changeVideoBtn = new UITransitionBtn('footer_videoIcon');
			_changeVideoBtn.x = 22;
			_changeVideoBtn.y = 28;
			_changeVideoBtn.id = '_changeVideoBtn';
			this.addChild(_changeVideoBtn);			
				
			_changeMusicBtn = new UITransitionBtn('footer_musicIcon');
			_changeMusicBtn.x = 66;
			_changeMusicBtn.y = 29;
			_changeMusicBtn.id = '_changeMusicBtn';
			_changeMusicBtn.alpha = 0.66;
			this.addChild(_changeMusicBtn);
			_enableBtn(_changeMusicBtn);
			
			_menu = Register.ASSETS.getBitmap('footer_ClipLengthMenu')
			_menu.x = 115;
			_menu.y = 26;
			this.addChild(_menu);
			
			_previewBtn = new FooterBtn(145, 44, Register.ASSETS.getBitmap('previewBtnText'));
			_previewBtn.x = (Register.APP.WIDTH - _previewBtn.width) * 0.5;
			_previewBtn.y = (bgShape.height - _previewBtn.height) * 0.5;
			addChild(_previewBtn);
			
			_saveBtn = new FooterBtn(114, 44, Register.ASSETS.getBitmap('saveBtnText'));
			_saveBtn.x = Register.APP.WIDTH - _saveBtn.width - 21;
			_saveBtn.y = (bgShape.height - _saveBtn.height) * 0.5;
			addChild(_saveBtn);
			
			_subscriptionBtn = new FooterBtn(202, 44, Register.ASSETS.getBitmap('subscriptionBtnText'));
			_subscriptionBtn.x = Register.APP.WIDTH - _subscriptionBtn.width - 21;
			_subscriptionBtn.y = (bgShape.height - _subscriptionBtn.height) * 0.5;
			TweenMax.to(_subscriptionBtn, 0, {autoAlpha:0});
			addChild(_subscriptionBtn);
		}
		
		private function _enableBtn($btn:UITransitionBtn):void {
			//log('enabling: '+$btn.id)
			TweenMax.to($btn, 0.3, {alpha:0.66});
			
			$btn.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvents);
			$btn.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvents);
			$btn.addEventListener(MouseEvent.CLICK, _handleMouseEvents);
		}		
		
		private function _disableBtn($btn:UITransitionBtn):void {
			//log('disabling: '+$btn.id)
			TweenMax.to($btn, 0, {alpha:1});
			
			$btn.removeEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvents);
			$btn.removeEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvents);
			$btn.removeEventListener(MouseEvent.CLICK, _handleMouseEvents);			
		}
		
		private function _switchStates($id:String):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					TweenMax.to(_menu, 0.3, {autoAlpha:0});
					TweenMax.to(_previewBtn, 0.3, {autoAlpha:0, delay:0.05});
					TweenMax.to(_saveBtn, 0.3, {autoAlpha:0, delay:0.1});
					TweenMax.to(_subscriptionBtn, 0.3, {autoAlpha:1, delay:0.15});
					break;
				
				case 'video':
					TweenMax.to(_subscriptionBtn, 0.3, {autoAlpha:0});
					TweenMax.to(_menu, 0.3, {autoAlpha:1, delay:0.05});
					TweenMax.to(_previewBtn, 0.3, {autoAlpha:1, delay:0.1});
					TweenMax.to(_saveBtn, 0.3, {autoAlpha:1, delay:0.15});
					break;
			}
			
		}

		
		
		/******************* EVENT HANDLERS *******************/	
		/*********************** HELPERS **********************/
		private function _handleMouseEvents($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(($e.target as Sprite),0,{alpha:1});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(($e.target as Sprite),0.3,{alpha:0.66});
					break;
				
				case MouseEvent.CLICK:
					//log('CLICK: '+($e.target as UITransitionBtn).id);
					_disableBtn($e.target as UITransitionBtn);
					if ($e.target == _changeMusicBtn) {
						dispatchEvent(new UITransitionEvent(UITransitionEvent.MUSIC, true));
						_switchStates('music');
						_enableBtn(_changeVideoBtn);
					} else {
						dispatchEvent(new UITransitionEvent(UITransitionEvent.VIDEO, true));
						_switchStates('video');
						_enableBtn(_changeMusicBtn);
					}
					break;				
			}
		}		
	}
}