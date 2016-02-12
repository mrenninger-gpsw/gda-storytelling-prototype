package project.views {
	
	// Flash
	import flash.events.Event;
	
	// Framework
	import display.Sprite;
	
	// Project
	import project.events.MusicMenuEvent;
	import project.views.MusicSelector.MusicMenu;
	import project.views.MusicSelector.MusicPreviewArea;
	
	
	
	public class MusicSelector extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _musicPreview:MusicPreviewArea;
		private var _musicMenu:MusicMenu;
		private var _isActive:Boolean = false;
		

		
		/***************** GETTERS & SETTERS ******************/			
		public function get isActive():Boolean { return _isActive; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MusicSelector() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			_isActive = true;
			_musicPreview.show(); // starts immediately, multi-part, 0.8s to complete
			_musicMenu.show(); // starts immediately, multi-part, 0.6s to complete
		}
		
		public function hide():void {
			_isActive = false;
			_musicPreview.hide(); // starts immediately, multi-part, takes 0.8s to complete
			_musicMenu.hide();  // starts immediately, multi-part, takes 0.8s to complete
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			// ************* MusicPreviewArea *****************
			// ************************************************
			_musicPreview = new MusicPreviewArea()
			_musicPreview.x = 487;
			_musicPreview.y = 111;
			this.addChild(_musicPreview);
			// ************************************************
			// ************************************************
			
			
			// ***************** MusicMenu ********************
			// ************************************************
			_musicMenu = new MusicMenu();
			_musicMenu.y = 66;
			log('_musicMenu now listening for CHANGE event');
			_musicMenu.addEventListener(MusicMenuEvent.CHANGE, _musicPreview.updateUI);
			this.addChild(_musicMenu);
			// ************************************************
			// ************************************************
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