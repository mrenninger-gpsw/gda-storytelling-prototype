package project.views {
	
	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.UITransitionEvent;
	import project.views.Footer.ui.FooterBtn;
	
	
	
	public class Footer extends Sprite {
		
		/********************* CONSTANTS **********************/	
		private var _changeToEditorBtn:FooterBtn;
		private var _changeToMusicBtn:FooterBtn;
		private var _previewBtn:FooterBtn;
		private var _saveBtn:FooterBtn;
		private var _addToVideoBtn:FooterBtn;
		private var _clipLengthMenuBtn:FooterBtn;
		private var _curState:String = 'video';
		
		
		
		/***************** GETTERS & SETTERS ******************/
		public function set curState($value:String):void { _switchStates($value); }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function Footer() {
			super();
			verbose = true;
			_init();	
		}
		
		public function show():void {
			TweenMax.to(this, 0.3, {y:Register.APP.HEIGHT - this.height, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}
		
		public function hide():void {
			TweenMax.to(this, 0.3, {y:Register.APP.HEIGHT, ease:Cubic.easeOut, onComplete:_onHideComplete});
		}
		
	
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0x141414);
			bgShape.graphics.drawRect(0,0,Register.APP.WIDTH, 80);
			bgShape.graphics.endFill();
			addChild(bgShape);
			
			_changeToMusicBtn = new FooterBtn(145, 44, Register.ASSETS.getBitmap('footer_musicBtnText'));//new UITransitionBtn('footer_musicIcon');
			TweenMax.to(_changeToMusicBtn, 0, {autoAlpha:1, x:24, y:(bgShape.height - _changeToMusicBtn.height) * 0.5});
			this.addChild(_changeToMusicBtn);
			_enableBtn(_changeToMusicBtn);
			
			_changeToEditorBtn = new FooterBtn(145, 44, Register.ASSETS.getBitmap('footer_editorBtnText'));//new UITransitionBtn('footer_videoIcon');
			TweenMax.to(_changeToEditorBtn, 0, {autoAlpha:0, x:24, y:(bgShape.height - _changeToEditorBtn.height) * 0.5});
			this.addChild(_changeToEditorBtn);			
				
			_clipLengthMenuBtn = new FooterBtn(145, 44, Register.ASSETS.getBitmap('footer_ClipLengthMenu2'));//= Register.ASSETS.getBitmap('footer_ClipLengthMenu')
			TweenMax.to(_clipLengthMenuBtn, 0, {x:_changeToMusicBtn.x + _changeToMusicBtn.width + 10, y:(bgShape.height - _clipLengthMenuBtn.height) * 0.5});
			this.addChild(_clipLengthMenuBtn);
			
			_previewBtn = new FooterBtn(145, 44, Register.ASSETS.getBitmap('previewBtnText'));
			TweenMax.to(_previewBtn, 0, {x:(Register.APP.WIDTH - _previewBtn.width) * 0.5, y:(bgShape.height - _previewBtn.height) * 0.5});
			this.addChild(_previewBtn);
			
			_saveBtn = new FooterBtn(115, 44, Register.ASSETS.getBitmap('saveBtnText'));
			TweenMax.to(_saveBtn, 0, {x:Register.APP.WIDTH - _saveBtn.width - 21, y:(bgShape.height - _saveBtn.height) * 0.5});
			this.addChild(_saveBtn);
			
			_addToVideoBtn = new FooterBtn(165, 44, Register.ASSETS.getBitmap('FooterBtn_addToVideoText'));
			TweenMax.to(_addToVideoBtn, 0, {autoAlpha:0, x:(Register.APP.WIDTH - _addToVideoBtn.width) * 0.5, y:(bgShape.height - _addToVideoBtn.height) * 0.5});
			this.addChild(_addToVideoBtn);
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			_switchStates('video');
		}
		
		private function _enableBtn($btn:FooterBtn):void {
			log('enabling: '+$btn.id)
			$btn.addEventListener('clicked', _handleClick);
			TweenMax.to($btn, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
		}		
		
		private function _disableBtn($btn:FooterBtn):void {
			log('disabling: '+$btn.id)
			$btn.removeEventListener('clicked', _handleClick);
			TweenMax.to($btn, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
		}
		
		private function _switchStates($id:String):void {
			log('_switchStates: '+$id);
			_curState = $id;
			switch ($id) {
				case 'music':
					_enableBtn(_changeToEditorBtn);
					_disableBtn(_changeToMusicBtn);
					TweenMax.to(_clipLengthMenuBtn, 0.3, {autoAlpha:0});
					TweenMax.to(_previewBtn, 0.3, {autoAlpha:0, delay:0.05});
					TweenMax.to(_saveBtn, 0.3, {autoAlpha:0, delay:0.1});
					TweenMax.to(_addToVideoBtn, 0.3, {autoAlpha:1, delay:0.15});
					break;
				
				case 'video':
					_enableBtn(_changeToMusicBtn);
					_disableBtn(_changeToEditorBtn);
					TweenMax.to(_addToVideoBtn, 0.3, {autoAlpha:0});
					TweenMax.to(_clipLengthMenuBtn, 0.3, {autoAlpha:1, delay:0.05});
					TweenMax.to(_previewBtn, 0.3, {autoAlpha:1, delay:0.1});
					TweenMax.to(_saveBtn, 0.3, {autoAlpha:1, delay:0.15});
					break;
			}
			
		}

		
		
		/******************* EVENT HANDLERS *******************/	
		private function _handleClick($e:Event):void {
			//log('CLICK: '+($e.target as UITransitionBtn).id);
			if ($e.target == _changeToMusicBtn) {
				dispatchEvent(new UITransitionEvent(UITransitionEvent.MUSIC, true));
				_switchStates('music');
			} else {
				dispatchEvent(new UITransitionEvent(UITransitionEvent.VIDEO, true));
				_switchStates('video');
			}
		}		
	}
}