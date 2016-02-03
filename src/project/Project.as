package project{
	
	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// CandyLizard Framework
	import air.desktop.ProjectRoot;
	import air.desktop.stage.Window;
	import components.controls.TextArea;
	import utils.Register;	
	
	// Project
	import project.events.UITransitionEvent;
	import project.views.Header;
	import project.views.MusicEditor;
	import project.views.Storytelling;
	import project.views.Footer.Footer;
	import project.views.SettingsOverlay.SettingsOverlay;	
	
		
	
	public class Project extends ProjectRoot {
		
		/********************* CONSTANTS **********************/
		
		
		
		/******************* PRIVATE VARS *********************/
		private var _xml:XML;
		private var _window:Window;
		private var _windowTitle:String = 'GDA Storytelling Prototype';		
		private var _textArea:TextArea;
		private var _showing:Boolean = false;
		private var _settingsShowing:Boolean = false;
		private var _projectInitiated:Boolean = false;
		private var _storytelling:Storytelling;		
		private var _musicEditor:MusicEditor;		
		private var _footer:Footer;
		private var _header:Header;
		
		
		
		/***************** GETTERS & SETTERS ******************/		
		public function get windowTitle():String { return _windowTitle; }
		public function set windowTitle($value:String):void { _windowTitle = $value; }
		
		public function get settingsShowing():Boolean { return _settingsShowing; }
		
		public function get projectInitiated():Boolean { return _projectInitiated; }
		
		public function get window():Window { return _window; }
		
		public function get liveArea():Rectangle { return new Rectangle(Constants.MARGIN_WIDTH, 22, _window.width - (Constants.MARGIN_WIDTH * 2), _window.height - 22); }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function Project(){
			super();
			verbose = true;
			
			Register.PROJECT = this;
			Multitouch.inputMode = MultitouchInputMode.GESTURE;			
			
			_xml = Register.PROJECT_XML;
			
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		
		
		/******************** PUBLIC API *********************/
		//INITIALIZATION
		public override function init($e:Event = null):void {
			super.init($e);
			log('############   INITIALIZED  ############');
			
			// ******************** WINDOW ********************
			// ************************************************
			_window = Register.APP.windowManager.getWindowByID('project');
			log('window: '+_window);
			_window.acceptsDragImport = false;
			
			_window.width = 1280;
			_window.height = 860;
			_window.center();
			
			stage.nativeWindow.minSize = new Point(485, 260);
			// ************************************************
			// ************************************************
			

			var s:Shape;
			// ****************** Background ******************
			// ************************************************
			s = new Shape();
			s.graphics.beginFill(0x000000);
			s.graphics.drawRoundRect(0,0,Register.APP.WIDTH, Register.APP.HEIGHT,10,10);
			s.graphics.endFill();
			this.addChild(s);
			// ************************************************
			// ************************************************
			
			
			// ************** Content Area Bkgd ***************
			// ************************************************
			s = new Shape();
			s.graphics.beginFill(0x222222);
			s.graphics.drawRect(0,0,Register.APP.WIDTH, 794);
			s.graphics.endFill();
			s.y = 66;
			this.addChild(s);
			// ************************************************
			// ************************************************-
						
			_storytelling = new Storytelling();
			this.addChild(_storytelling);

			_musicEditor = new MusicEditor();
			this.addChild(_musicEditor);

			_header = new Header();
			this.addChild(_header);

			_footer = new Footer();
			_footer.y = Register.APP.HEIGHT - _footer.height;
			this.addChild(_footer);
			_footer.addEventListener(UITransitionEvent.MUSIC, _handleUITransitionEvent);
			_footer.addEventListener(UITransitionEvent.VIDEO, _handleUITransitionEvent);
			
			TweenMax.to(this, 0, {autoAlpha:0});
		}
		
		public function show():void{
			if (!_showing) {	
				log('ƒ show');
				_showing = true;
				Register.APP.applicationMenu.enableAllMenus();
				_addListeners();
				TweenMax.to(this, 3, {autoAlpha:1, ease:Cubic.easeOut, onComplete:_onShowComplete});
			}
		}
		
		public override function onResize():void {
			//log('ƒ onResize')
			super.onResize();
		}
		
		
			
		/******************** PRIVATE API *********************/
		private function _addListeners():void {
			log('ƒ _addListeners');
			this.visible = true;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
		}
		
		private function _onShowComplete():void {
			log('ƒ _onShowComplete');
			_projectInitiated = true;
		}
		
		
		
		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			log('############ ADDED ############');
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _keyDownHandler($e:KeyboardEvent):void {
			log('_keyDownHandler - keyCode: '+$e.keyCode);
			switch ($e.keyCode) {
				case Keyboard.S:
					log('\tShow Preferences');
					Multitouch.inputMode = MultitouchInputMode.NONE;
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
					
					var _settings:SettingsOverlay = new SettingsOverlay(this);
					_settings.addEventListener('Hidden', _onSettingsOverlayHidden);
					addChild(_settings);
					_settingsShowing = true;
					break;
			}
		}
		
		private function _onSettingsOverlayHidden($e:Event):void {
			log('ƒ _onSettingsOverlayHidden');
			removeChild($e.target as SettingsOverlay);
			_settingsShowing = false;
			stage.focus = stage;
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
			trace('DONE!!!');
		}
		
		protected function _handleUITransitionEvent($e:UITransitionEvent):void {
			switch ($e.type) {
				case UITransitionEvent.MUSIC:
					log('UITransitionEvent - MUSIC');
					
					_storytelling.hide();
					_header.switchStates('music'); // starts immediately, takes 0.3s to complete					
					TweenMax.delayedCall(0.6, _musicEditor.show);
					break;
				
				case UITransitionEvent.VIDEO:
					log('UITransitionEvent - VIDEO');
					
					_musicEditor.hide();
					_header.switchStates('video'); // starts immediately, takes 0.3s to complete
					TweenMax.delayedCall(0.8, _storytelling.show)					

					break;			
				
			}			
		}
	}
}