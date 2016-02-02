package project.view.ui {
	import flash.display.Bitmap;
	
	import display.Sprite;
	import utils.Register;
	
	
	public class UITransitionBtn extends Sprite {
		private var _eventStr:String;
		private var _iconName:String;
		public function UITransitionBtn($iconName:String) {
			super();
			
			_iconName = $iconName;
			
			_init();
		}
		
		private function _init():void {
			var icon:Bitmap = Register.ASSETS.getBitmap(_iconName);
			this.addChild(icon);			
		}
		
		
	}
}