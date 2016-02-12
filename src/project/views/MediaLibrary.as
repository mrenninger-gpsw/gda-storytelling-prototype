package project.views {
	
	// Flash
	import flash.events.Event;
	
	import com.greensock.TweenMax;

	import display.Sprite;
	
	import project.events.MediaMenuEvent;
	import project.views.MediaLibrary.MediaLibraryContentArea;
	import project.views.MediaLibrary.MediaLibraryMenu;
	import project.views.MediaLibrary.ui.AlertBanner;
	
	
	
	public class MediaLibrary extends Sprite {
		
		/********************* CONSTANTS **********************/	

		/******************** PRIVATE VARS ********************/
		private var _menu:MediaLibraryMenu;
		private var _content:MediaLibraryContentArea;
		private var _banner:AlertBanner;
		
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
			log('show');
			_menu.show();
			_content.show();
			//TweenMax.to(this, 0, {autoAlpha:1});
		}
		
		public function hide():void {
			log('hide');
			_menu.hide();
			_content.hide();
			if (this.getChildByName('alertBanner')) _banner.hide();
			//TweenMax.to(this, 0, {autoAlpha:0}); 
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			
			_content = new MediaLibraryContentArea();
			
			_menu = new MediaLibraryMenu();
			_menu.y = 66;
			this.addChild(_menu);
			_menu.addEventListener(MediaMenuEvent.CHANGE, _onMediaMenuEvent);
			
			_content.x = _menu.x + _menu.width;
			_content.y = 66;
			this.addChild(_content);
			
			hide();
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _onMediaMenuEvent($e:MediaMenuEvent):void {
			var num:uint = _menu.curMenuItem.num;
			_content.update(num);
			if (num == 1) {
				_banner = new AlertBanner();
				_banner.x = 945;
				_banner.y = 66;
				_banner.name = 'alertBanner';
				this.addChild(_banner);
				TweenMax.delayedCall(0.75, _banner.show);
			} else {
				if (this.getChildByName('alertBanner')) _banner.hide();
			}
		}
	}
}