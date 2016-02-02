package project.view.ui {
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import components.controls.Label;
	
	import display.Sprite;
	
	import utils.Register;
	
	import project.events.UITransitionEvent;
	
	
	
	public class ChangeMusicBtn extends Sprite {
		public function ChangeMusicBtn() {
			super();
			_init();
		}
		
		private function _init():void {
			this.alpha = 0.66;

			var musicIcon:Bitmap = Register.ASSETS.getBitmap('footer_musicIcon');
			this.addChild(musicIcon);
			
			/*var _songTitleTF:Label = new Label();
			_songTitleTF.mouseEnabled = false;
			_songTitleTF.mouseChildren = false;
			_songTitleTF.id = 'footer-song-title';
			_songTitleTF.text = Register.PROJECT_XML.content.initSongTitle;
			_songTitleTF.autoSize = 'left';
			_songTitleTF.textFormatName = 'footer-song-title';
			_songTitleTF.x = 35;
			_songTitleTF.y = 1;
			this.addChild(_songTitleTF);
			
			var moreIcon:Bitmap = Register.ASSETS.getBitmap('footer_moreIcon');
			moreIcon.x = _songTitleTF.x + _songTitleTF.width + 14;
			moreIcon.y = 10;
			this.addChild(moreIcon);*/
			
			this.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvents);
			this.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvents)
			this.addEventListener(MouseEvent.CLICK, _handleMouseEvents)
				
		}
		
		private function _handleMouseEvents($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(($e.target as Sprite),0,{alpha:1});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(($e.target as Sprite),0.3,{alpha:0.66});
					break;
				
				case MouseEvent.CLICK:
					dispatchEvent(new UITransitionEvent(UITransitionEvent.MUSIC, true));
					break;
				
			}
		}
	}
}