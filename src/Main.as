package{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import air.desktop.Application;
	import air.desktop.ApplicationMenu;
	import air.desktop.stage.Window;
	
	import data.Settings;
	
	import project.About;
	import project.Project;
	import project.ProjectFonts;
	
	import utils.Register;
	
	
	
	[SWF(frameRate = '60', width = '800', height = '600', backgroundColor = '0xCCCCCC')]
	
	
	public class Main extends Application {
		
		
		/******************** EMBEDS *********************/
		
		[Embed(source="../resources/splash/splashBackground.png")]
		public	 	const		SPLASH:Class;
		
		[Embed(source="../resources/splash/aboutBackground.png")]
		public	 	const		ABOUT:Class;
		
		
		[Embed(source="../resources/xml/config.xml", mimeType = "application/octet-stream")]
		protected 	const		CONFIG:Class;
		
		[Embed(source="../resources/xml/textFormats.xml", mimeType = "application/octet-stream")]
		protected 	const 		TEXTFORMATS_XML:Class;
		
		//>>>>>>>>>			STEP ONE:       change the CONTENT string to the name of your project class
		public 		const 		CONTENT:String	 = 	'Project';
		
		
		//>>>>>>>>>			STEP TWO:       embed your project's xml
		[Embed(source="../resources/xml/project.xml", mimeType = "application/octet-stream")]
		protected 	const 		PROJECT_XML:Class;
		
		//settings
		private 	var			_settings:Settings;
		
		private 	var			_fonts:ProjectFonts;
		
		private		var			_project:Project;
		
		
		
		
		
		public function Main(){
			super();
			
			
			
			//REGISTER
			verbose = true;
			Register.APP = this;	
			Register.CONFIG_XML = XML(new CONFIG());
			Register.TEXTFORMATS_XML = XML(new TEXTFORMATS_XML());
			Register.PROJECT_XML = XML(new PROJECT_XML());
			Register.KEYS = Register.CONFIG_XML.keys.key;
			Register.NATIVE_EXTENSION = new Object();
			
			_getSettings();
					
			/*
			FONTS ------>>> Fonts are instantiated here so you can have 
			ultimate control over the fonts installed rather than
			globally adding a ton of unused fonts
			*/
			
			_fonts = new ProjectFonts();
			//PROJECT CLASS REFEERENCE
			projectClassReference = getDefinitionByName('project.'+CONTENT) as Class;
			
			//APPLICATION MENU
			applicationMenu = new ApplicationMenu(this.stage, _appMenuHandler);
			applicationMenu.verbose = true;
			
		}
		
		override protected function _createProjectWindow():Window {
			var projectWin:Window;
			if (initialized) {
				var projectClassRef:Class = projectClassReference;
				Register.PROJECT = new projectClassRef();
				projectWin = windowManager.createWindow(Register.PROJECT, 'project', (Register.CONFIG_XML.chrome == 'true'));
				projectWin.verbose = true;
				projectWin.title = Register.PROJECT.windowTitle;
				projectWin.x = projectWin.y = 0;
				Register.PROJECT.init();
			} else {
				projectWin = windowManager.createWindow(Register.PROJECT, 'project', (Register.CONFIG_XML.chrome == 'true'));
				projectWin.verbose = true;
				projectWin.title = Register.PROJECT.windowTitle;
				projectWin.x = projectWin.y = 0;
			}
			return projectWin;
		}
		
		override protected function _createAboutWindow():void{
			var about:About = new About();
			about.init();
			about.alpha = 0;
			windowManager.createAboutWindow(about);
		}
		
		
		private function _appMenuHandler($e:Event):void{
			log('ƒ appMenuHandler: '+$e.target.label);
			log('curWindow: '+((windowManager.currentWindow) ? windowManager.currentWindow.id : windowManager.currentWindow));
			switch($e.target.label){
				case 'Close':
					windowManager.closeCurrentWindow();
					log('############### Register.ASSETS: '+Register.ASSETS);
					//windowManager.currentWindow.close();
					//if (windowManager.currentWindow.visible) windowManager.currentWindow.visible = false;
					break;
				
				case 'New':
					if (!windowManager.currentWindow) {
						var win:Window = _createProjectWindow();
						win.verbose = true;
						windowManager.activateWindow('project');
					}
					//if (!windowManager.currentWindow.visible) windowManager.currentWindow.visible = true;
					break;
				
				case 'Open File':
					//if(Object(windowManager.currentWindow.view).open) Object(windowManager.currentWindow.view).open();
					
					break;
				
				case 'Import...':
					//if(Object(windowManager.currentWindow.view).importData) Object(windowManager.currentWindow.view).importData();
					
					break;
				
				
				case 'Quit':
					log('quit');
					NativeApplication.nativeApplication.exit(); 
					break;
				
				case 'Preferences...':
					//updateState(Constants.SETTINGS);
					//settings(new ContextMenuEvent(ContextMenuEvent.MENU_ITEM_SELECT));
					break;
				
				case 'About':
					windowManager.activateWindow('about');
					
					break;
				
				case 'Console':
					windowManager.activateWindow('console');
				
			}
		}
		
		//SETTINGS
		private function _getSettings():void{
			_settings = new Settings();
			_settings.addEventListener(Settings.EXISTS, _settingsInit);
			_settings.addEventListener(Settings.MISSING, _settingsInit);
			_settings.init();
		}
		
		
		private function _settingsInit(e:Event):void{
			log('ƒ settings init');
			_settings.removeEventListener(Settings.EXISTS, _settingsInit);
			_settings.removeEventListener(Settings.MISSING, _settingsInit);
			switch(e.type){
				case Settings.EXISTS:
					log('\tFOUND USER SETTINGS');
					break;
				
				case Settings.MISSING:
					try{	
						_settings.addEventListener(Settings.LAST_MODIFIED, onSettingsCreation);
						_settings.clone('templates/.settingsTemplate.xml');
					}catch(e:Error){
						log('#### ERROR: '+e.message);
					}
					break;
			}
		}
		
		
		
		private function onSettingsCreation(e:Event):void{
			import flash.filesystem.File;
			log('ƒ onSettingsCreation - path: '+File(Settings(e.target).file).nativePath);
		}
			
		
		
		//HELPER FUNCTIONS
		
	}
}