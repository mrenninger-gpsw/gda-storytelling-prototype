package project{
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Quad;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import components.controls.Label;
	import components.controls.TextArea;
	
	import display.Sprite;
	
	import utils.Register;
	
	public class About extends Sprite{
		public static const TF_WIDTH:uint = 300;
		public static const TF_HEIGHT:uint = 300;
		
		
		
		//display objects
		private var _content:Sprite;
		private var _titleTf:Label;
		private var _versionTf:Label;
		private var _textArea:TextArea;
		private var _aboutBitmap:Bitmap;
		
		//reference
		private var _setUpComplete:Boolean = false;
		
		//nav
		private var _aboutList:XMLList;
		private var _nav:Sprite;
		private var _items:Vector.<Sprite>;
		private var _curItem:Sprite;
		
		private var _layout:Sprite;
		
		public function About(){
			super();
			this.visible = false;
			this.alpha = 0;
			this.verbose = false;
			
			_aboutList = Register.PROJECT_XML.about;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		}
		
		
		
		/******************** PRIVATE API *********************/
		
		private function initialize():void{
			log('initialize');
			
			_aboutBitmap = new Register.APP.ABOUT();
			addChild(_aboutBitmap);
			
			_layout = new Sprite();
			_layout.graphics.beginFill(0xFF0000,0);
			_layout.graphics.drawRect(0,0,428,514);
			_layout.graphics.endFill();
			_layout.cacheAsBitmap = true;
			addChild(_layout);
			
			
			
			_content = new Sprite();
			_layout.addChild(_content);
			
			_nav = new Sprite();
			_layout.addChild(_nav);
			
			_items = new Vector.<Sprite>();
			
			
			_titleTf = new Label();
			_titleTf.id = 'aboutTitle';
			_titleTf.text = Register.PROJECT_XML.title;
			
			_titleTf.autoSize = 'left';
			_titleTf.textFormatName = 'splashTitle';
			var ds:DropShadowFilter = new DropShadowFilter(4,45,0,1,4,4,1,3);
			_titleTf.filters = [ds];

			_layout.addChild(_titleTf);
			
			
			_versionTf = new Label();
			_versionTf.id = 'versionTitle';
			_versionTf.text = 'v.'+Register.APP.version;
			
			_versionTf.autoSize = 'left';
			_versionTf.textFormatName = 'aboutVersion';
			_versionTf.filters = [ds];
			
			_layout.addChild(_versionTf);
			
			_textArea = new TextArea();
			_textArea.textFormatName = 'about';
			_textArea.setWidth = TF_WIDTH;
			_textArea.setHeight = TF_HEIGHT;
			
			_content.addChild(_textArea);
			
			var mask:flash.display.Sprite = utils.Utilities.createGradientBox(TF_WIDTH, TF_HEIGHT, 0xFF0000,1, 0xFF0000,0,225,255);
			mask.cacheAsBitmap = true;
			_textArea.mask = mask;
			_content.addChild(mask);
			
		
			createNavigation();
			reset();
			_setUpComplete = true;
			dispatchEvent(new Event('setUpComplete'));
		}
		
		private function createNavigation():void{
			for(var i:uint = 0; i < _aboutList.length(); i++){
				var item:Sprite = createNavItem(_aboutList[i]);
				_nav.addChild(item);
				if(i > 0){
					var prevItem:Sprite = _items[_items.length - 1];
					item.x = (prevItem.x + prevItem.width + 32);
				}
				
				if(i < _aboutList.length() - 1){
					var divider:Shape = getDivider();
					divider.x = item.x + item.width +16;
					divider.y = item.height * .5;
					_nav.addChild(divider);
				}
				
				_items.push(item);
				
			}
			
			addEventListener(Event.SELECT, onSelection);
			
		}
		
		private function getDivider():Shape{
			var s:Shape = new Shape();
			s.graphics.beginFill(0x656565);
			s.graphics.drawCircle(0,0,2);
			s.graphics.endFill();
			return s;
		}
		
		private function onSelection(e:Event):void{
			var id:String = Label(Sprite(e.target).getChildAt(0)).id;
			var xml:XML = _aboutList.(@title == id)[0];
			log(xml.@method);
			if(xml.@method.toString() == ''){
				_textArea.update(_aboutList.(@title == id));
			}else{
				_textArea.update(this[xml.@method]());
			}
			
			activate(Sprite(e.target));
		}
		
		private function activate($item:Sprite):void{
			_curItem = $item;
			TweenMax.to($item, .2, {tint:0x17A7C0, ease:Cubic.easeOut});
			for(var i:uint = 0; i < _items.length; i++){
				if(_items[i] !== $item)
					TweenMax.to(_items[i], .5, {removeTint:true, ease:Quad.easeInOut});
			}
		}
		
		private function createNavItem($xml:XML):Sprite{
			var s:Sprite = new Sprite();
			s.mouseChildren = false;
			s.buttonMode = true;
			var label:Label = new Label();
			label.text = label.id = $xml.@title;
			label.autoSize = 'left';
			label.textFormatName = 'aboutMenu';
			s.addEventListener(MouseEvent.MOUSE_OVER, onNavItem);
			s.addEventListener(MouseEvent.MOUSE_OUT, onNavItem);
			s.addEventListener(MouseEvent.MOUSE_UP, onNavItem);
			s.addChild(label);
			
			return s;
		}
		
		private function onNavItem(e:MouseEvent):void{
			var s:Sprite = e.target as Sprite;
			log(s.getChildAt(0));
			var id:String = Label(s.getChildAt(0)).id;
			if(_curItem !== s){
				switch(e.type){
					case MouseEvent.MOUSE_OVER:
						TweenMax.to(s, 0,{tint:0xCCCCCC});
						break;
					
					case MouseEvent.MOUSE_OUT:
						TweenMax.to(s, 1,{removeTint:true, ease:Quad.easeInOut});
						break;
					
					case MouseEvent.MOUSE_UP:
						s.dispatchEvent(new Event(Event.SELECT, true));
						break;
			
				}
			}
			
		}
		
		
		//FETCHING LIBRARY INFO
		private function getLibraryInfo():String{
			var str:String = 'LIBRARIES:\n\n';
			str+='\tCANDYLIZARD FRAMEWORK v'+Register.CANDYLIZARD_VERSION+'\n';
			str+='\tGREENSOCK ANIMATION LIB v'+TweenMax.version+'\n';
			
			for(var i:uint = 0; i < Register.CONFIG_XML.lib.length() > 0; i++){
				switch(String(Register.CONFIG_XML.lib[i].@id)){
					case 'gestouch':
						str+='\tGESTOUCH FRAMEWORK\n';
						break;
					
					default:
						
						log('ƒ getLibraryInfo - CHECK FOR VERSIONS ON: '+Register.CONFIG_XML.lib[i].@id);
				}
			}
			
			
			
			return str;
		}
		
		private function lostFocus(e:Event):void{
			hide();
			
		}
		
		private function reset():void{
			_textArea.text = Register.PROJECT_XML.about[0];
			activate(_items[0]);
		}
		
		/******************** PUBLIC API *********************/
		protected function onAddedToStage(event:Event):void{
			draw();
		}		
		
		
		public function draw(e:Event = null):void{
			if(_setUpComplete){
				_layout.x = 37;
				_layout.y = 21;
				
				log('draw');
				//_titleTf.x = (_layout.width - _titleTf.width)*.5;
				_titleTf.x = 356 - _titleTf.width;
				_titleTf.y = 115;
				
				_versionTf.x = _titleTf.x + _titleTf.width - _versionTf.width;
				_versionTf.y = _titleTf.y + Number(_titleTf.textFormat.size);
				
				
				_content.y = _titleTf.y + _titleTf.height + 20;
				_content.x = (_layout.width - TF_WIDTH)*.5;
				
				_nav.x = (_layout.width - _nav.width)*.5;
				_nav.y = _layout.height - _nav.height - 30;
				
			}else{
				log('waiting _seUpComplete: '+_setUpComplete);
				addEventListener('setUpComplete', draw);
				
			}
		}
		
		
		public function show():void{
			log('show');
			stage.nativeWindow.visible = true;
			TweenMax.to(this, .3, {autoAlpha:1, ease:Cubic.easeOut, delay:.5, onComplete:onShowComplete});
		}
		
		public function onShowComplete():void{
			stage.addEventListener(Event.MOUSE_LEAVE, lostFocus);
		}
		
		
		public function hide():void{
			TweenMax.to(this, .3, {autoAlpha:0, ease:Cubic.easeOut, onComplete:onHideComplete});
		}
		
		public function onHideComplete():void{
			stage.nativeWindow.visible = false;
			reset();
		}
		
		
		//Do not remove.  Overriden when using a custom Splash
		public function init():void{
			initialize();
		}
		
		
		
		
	}
}



