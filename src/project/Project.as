package project{
	
	// Flash
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	import air.desktop.ProjectRoot;
	import air.desktop.stage.Window;
	
	import components.controls.TextArea;
	
	import project.events.MusicMenuEvent;
	import project.events.SourceClipManagerEvent;
	import project.events.StoryboardManagerEvent;
	import project.events.UITransitionEvent;
	import project.managers.SourceClipManager;
	import project.managers.StoryboardManager;
	import project.view.CustomStoryboardClip;
	import project.view.Footer;
	import project.view.Header;
	import project.view.MusicMenu;
	import project.view.MusicPreviewArea;
	import project.view.SettingsOverlay;
	import project.view.VideoPreviewArea;
	import project.view.ui.StoryboardClipMarker;
	
	import utils.GeomUtilities;
	import utils.Register;
	
		
	
	public class Project extends ProjectRoot {
		
		/********************* CONSTANTS **********************/
		
		
		
		/******************* PRIVATE VARS *********************/
		//XML
		private var _xml:XML;
		
		//WINDOW
		private var _window:Window;
		private var _windowTitle:String = 'GDA Storytelling Prototype';
		
		private var _textArea:TextArea;
		private var _showing:Boolean = false;
		private var _settingsShowing:Boolean = false;
		private var _projectInitiated:Boolean = false;
		
		private var _previewArea:VideoPreviewArea;
		private var _sourceClipMgr:SourceClipManager;
		private var _storyboard:StoryboardManager;
		private var _footer:Footer;
		private var _header:Header;
		private var _musicMenu:MusicMenu;
		private var _musicPreview:MusicPreviewArea;
		private var _tempClipMarker:StoryboardClipMarker;
		private var _sourceClipMgrTransitionStart:Number;
		private var _time:Number;
		
		public function get storyboard():StoryboardManager { return _storyboard; }
		
		
		
		
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
			var s:Shape;
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
			// ************************************************
						
			
			// ********* SourceClipManager & Mask ***********
			// ************************************************
			_sourceClipMgr = new SourceClipManager();
			_sourceClipMgr.y = 66;
			this.addChild(_sourceClipMgr);
			_sourceClipMgr.addEventListener(SourceClipManagerEvent.SHOW_COMPLETE, _handleSourceClipManagerEvent);
			_sourceClipMgr.addEventListener(SourceClipManagerEvent.HIDE_COMPLETE, _handleSourceClipManagerEvent);
			
			s = new Shape();
			s.graphics.beginFill(0x1e1e1e);
			s.graphics.drawRect(0,0,Register.APP.WIDTH, 454);
			s.graphics.endFill();
			s.y = 66;
			this.addChild(s);
			_sourceClipMgr.mask = s;
			// ************************************************
			// ************************************************
			
			
			// ************* VideoPreviewArea *****************
			// ************************************************
			_previewArea = new VideoPreviewArea();
			_previewArea.x = 571;
			_previewArea.y = 98;
			this.addChild(_previewArea);
			_sourceClipMgr.previewArea = _previewArea;
			// ************************************************
			// ************************************************
			
			
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
			
			
			// *************** Storyboard area ****************
			// ************************************************
			_storyboard = new StoryboardManager();			
			_storyboard.y = 520;
			this.addChild(_storyboard);
			// ************************************************
			// ************************************************

			
			// ******************** Header ********************
			// ************************************************
			_header = new Header();
			this.addChild(_header);
			// ************************************************
			// ************************************************
			
			
			// ******************** Footer ********************
			// ************************************************
			_footer = new Footer();
			_footer.y = Register.APP.HEIGHT - _footer.height;
			this.addChild(_footer);
			_footer.addEventListener(UITransitionEvent.MUSIC, _handleUITransitionEvent);
			_footer.addEventListener(UITransitionEvent.VIDEO, _handleUITransitionEvent);
			// ************************************************
			// ************************************************
			
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _addClipMarker);

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
		
		public function addCustomClip($clip:CustomStoryboardClip):void {
			// check to see if a 5th clip can be added
			if (_storyboard.canAddClips) {
				this.addChild($clip); 
				// on add of this custom clip, stage dispatches a FIVE_CLIPS StoryboardManagerEvent which is listened for here and in the storyboard
					// here, the caught event adds the clipMarker to the storyboard
					// in storyboard, the caught event causes the existing soryboard clips to reposition
				// immediately storyboard tells its clips to reposition and a tempClipMarker is added in place and told to show with a delay of 0.2
				TweenMax.delayedCall(0, _moveCustomClipToStoryboard, [$clip]);
			}			
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
		
		private function _moveCustomClipToStoryboard($clip:CustomStoryboardClip):void {
			log('_moveCustomClipToStoryboard');
			var newClipX:Number = (Register.PROJECT_XML.content.editor.storyboard.clip[4].location[1].@position);
			var totalTime:Number = 0.7;
			var totalDistance:Number = GeomUtilities.getDistance(new Point(0,0), new Point((newClipX + 21), 590)); 
			var distance:Number = GeomUtilities.getDistance(new Point($clip.x,$clip.y), new Point((newClipX + 21), 590));
			var pct:Number = distance/totalDistance;
			log('\tdistance: '+distance);
			log('\tpct distance to cover: '+distance/1150);
			log('\ttime to move custom clip: '+totalTime * pct);
			_time = new Date().getTime();
			TweenMax.to($clip, (0.4 * totalTime), {scaleX:$clip.scaleX * 2, scaleY:$clip.scaleY * 2, ease:Cubic.easeIn});
			TweenMax.to($clip, (0.6 * totalTime), {scaleX:0, scaleY:0, x:newClipX + 21, y: 590, ease:Cubic.easeOut, delay:(0.4 * totalTime), onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});

			/*TweenMax.to($clip, 0.3, {width:160, height:90, x:210, y: 590, ease:Cubic.easeOut, delay:0.2});
			TweenMax.to($clip, 0.2, {width:176, height:99, ease:Cubic.easeOut, delay:0.4, onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});*/
		}
		
		private function _onClipMoveComplete($clip:CustomStoryboardClip):void {
			log('_onClipMoveComplete');
			log('\ttime elapsed: '+(new Date().getTime() - _time));
			$clip.prepareForReveal()
			_storyboard.addClip($clip);
			this.removeChild(_tempClipMarker);
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
					_sourceClipMgrTransitionStart = new Date().getTime();
					
					_sourceClipMgr.hide(); // starts immediately, multi-part, takes .55s to complete
					TweenMax.to(_storyboard, 0.7, {y:Register.APP.HEIGHT, ease:Circ.easeInOut}); // starts immediately, takes 0.7s to complete
					_previewArea.switchStates('music'); // starts immediately, takes 0.3s to complete
					
					_header.switchStates('music'); // starts immediately, takes 0.3s to complete
					
					TweenMax.delayedCall(0.6, _musicPreview.show); // 0.6s delay, multi-part, 1.4s to complete
					TweenMax.delayedCall(0.6, _musicMenu.show); // 0.6s delay, multi-part, 1.2s to complete
					break;
				
				case UITransitionEvent.VIDEO:
					log('UITransitionEvent - VIDEO');
					_musicPreview.hide(); // starts immediately, multi-part, takes .8s to complete
					_musicMenu.hide();  // starts immediately, multi-part, takes .8s to complete
					
					_header.switchStates('video'); // starts immediately, takes 0.3s to complete
					
					TweenMax.delayedCall(0.8, _sourceClipMgr.show); // 0.8s delay, 1.35s to complete
					TweenMax.to(_storyboard, 0.5, {y:520, ease:Circ.easeInOut, delay:0.8}); // 0.8s delay, 1.3s to complete
					_previewArea.switchStates('video'); // 1s delay, 1.3s to complete
					break;			
				
			}			
		}
		
		protected function _handleSourceClipManagerEvent($e:SourceClipManagerEvent):void {
			switch ($e.type) {
				case SourceClipManagerEvent.SHOW_COMPLETE:
					log('SourceClipManager - SHOW_COMPLETE');
					break;
				
				case SourceClipManagerEvent.HIDE_COMPLETE:
					log('SourceClipManager - HIDE_COMPLETE');
					log('time elapsed: '+(new Date().getTime() - _sourceClipMgrTransitionStart));
					break;			
				
			}
		}
		
		private function _addClipMarker($e:StoryboardManagerEvent):void {
			log('_addClipMarker');
			_tempClipMarker = new StoryboardClipMarker();
			_tempClipMarker.x = _storyboard.x + 20 + Number(Register.PROJECT_XML.content.editor.storyboard.clip[4].location[1].@position);
			_tempClipMarker.y = _storyboard.y + 70;
			this.addChild(_tempClipMarker);
			log('_tempMarker.stage: '+_tempClipMarker.stage);
			TweenMax.delayedCall(0.2, _tempClipMarker.show);
		}
	}
}