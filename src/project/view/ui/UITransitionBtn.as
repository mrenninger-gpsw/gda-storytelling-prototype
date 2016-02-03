package project.view.ui {
	
	// Flash
	import flash.display.Bitmap;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;

	
	
	public class UITransitionBtn extends Sprite {

		/******************** PRIVATE VARS ********************/	
		private var _eventStr:String;
		private var _iconName:String;

		
		
		/******************** CONSTRUCTOR *********************/
		public function UITransitionBtn($iconName:String) {
			super();
			
			_iconName = $iconName;
			
			_init();
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var icon:Bitmap = Register.ASSETS.getBitmap(_iconName);
			this.addChild(icon);			
		}
		
		
	}
}