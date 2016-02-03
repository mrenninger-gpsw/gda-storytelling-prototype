package project.views.Footer.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;
		
	// Project
	import project.events.UITransitionEvent;
	
	
	
	public class ChangeMusicBtn extends Sprite {
		
		/******************** CONSTRUCTOR *********************/
		public function ChangeMusicBtn() {
			super();
			_init();
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			this.alpha = 0.66;

			var musicIcon:Bitmap = Register.ASSETS.getBitmap('footer_musicIcon');
			this.addChild(musicIcon);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvents);
			this.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvents)
			this.addEventListener(MouseEvent.CLICK, _handleMouseEvents)				
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
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