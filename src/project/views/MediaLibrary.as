package project.views {
	
	// Flash
	import flash.events.Event;
	
	// Greensock
	
	// CandyLizard Framework
	import display.Sprite;
	
	// Project
	
	
	
	public class MediaLibrary extends Sprite {
		
		/********************* CONSTANTS **********************/	

		/******************** PRIVATE VARS ********************/	
		
		/***************** GETTERS & SETTERS ******************/			
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MediaLibrary() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}

	
	
		/********************* PUBLIC API *********************/	
		public function show():void {
		
		}
		
		public function hide():void {

		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
		
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
	}
}