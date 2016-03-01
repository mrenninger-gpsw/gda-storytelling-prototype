package project.views.MediaLibrary {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	
	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.MediaMenuEvent;
	import project.views.MediaLibrary.ui.MediaLibraryMenuItem;
	

	
	public class MediaLibraryMenu extends Sprite {
		
		
		
		/********************* CONSTANTS **********************/	
		
		
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XMLList;
		private var _menu:MediaLibraryMenu;
		private var _menuItemsV:Vector.<MediaLibraryMenuItem>;
		private var _menuBkgd:Shape;
		private var _curMenuItem:MediaLibraryMenuItem;
		private var _selector:Shape;
		private var _transitionStart:Number;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get curMenuItem():MediaLibraryMenuItem { return _curMenuItem; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MediaLibraryMenu() {
			super();
			verbose = true;
			_xml = Register.PROJECT_XML.content.mediaLibrary;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			log('show');
			//TweenMax.to(this, 0, {autoAlpha:1, onComplete:_onShowComplete}); 
			_transitionStart = new Date().getTime();
			TweenMax.to(this, 0.3, {x:0, ease:Cubic.easeInOut});
			
			for (var i:uint = 0; i < _menuItemsV.length; i++){
				var func:Function = (i == _menuItemsV.length - 1) ? _onShowComplete : null; 
				TweenMax.to(_menuItemsV[i], 0.3, {autoAlpha:1, x:0, ease:Back.easeOut, delay:0.1+(i * 0.05), onComplete:func});
				if (_menuItemsV[i] == _curMenuItem) {
					TweenMax.to(_selector, 0.3, {autoAlpha:1, x:0, ease:Back.easeOut, delay:0.1+(i * 0.05)});
				}
			}
		}
		
		public function hide():void {
			log('hide');
			_transitionStart = new Date().getTime();
			//TweenMax.to(this, 0, {autoAlpha:0, onComplete:_onHideComplete});
			TweenMax.to(this, 0.3, {x:(0 - this.width), ease:Cubic.easeInOut, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			//TweenMax.to(this, 0, {autoAlpha:0});
			
			_createMenu();
			
		}
		
		private function _addListeners():void {
			
		}
		
		private function _onShowComplete():void {
			log('_onShowComplete - transitionTime: '+(new Date().getTime() - _transitionStart))
		}
		
		private function _onHideComplete():void {
			log('_onHideComplete - transitionTime: '+(new Date().getTime() - _transitionStart));
			
			// reset the menu without dispatching
			if (_curMenuItem && _curMenuItem != _menuItemsV[0]) _curMenuItem.select(false);
			
			_curMenuItem = _menuItemsV[0];
			_curMenuItem.select(true);
			
			this.addChild(_selector);
			TweenMax.to(_selector, 0, {autoAlpha:0, x:-20, y:_curMenuItem.y});
			
			for (var i:uint = 0; i < _menuItemsV.length; i++){
				TweenMax.to(_menuItemsV[i], 0, {autoAlpha:0, x:-20});
			}
		}
		
		private function _createMenu():void {
			//log('_createMenu');
			_menuItemsV = new Vector.<MediaLibraryMenuItem>();
			
			// menu items bkgd
			_menuBkgd = new Shape();
			with (_menuBkgd.graphics) {
				beginFill(0x141414, 0.3);
				drawRect(0,0,224,794);
				endFill();
			}
			//TweenMax.to(_menuBkgd, 0, {autoAlpha:0});
			this.addChild(_menuBkgd);
			
			// Media menu title Label
			var _label:Label = new Label();
			_label.text = _xml.menu[0].@title;
			_label.autoSize = 'left';
			_label.textFormatName = 'media-menu-title';
			_label.x = 21;
			_label.y = 24;
			this.addChild(_label);

			_selector = new Shape();
			with (_selector.graphics) {
				beginFill(0x00A3DA);
				drawRect(0,0,4,40);
				endFill();
			}
			
			// Media menu items
			for (var i:uint = 0; i < _xml.menu[0].item.length(); i++) {
				var tMenuItem:MediaLibraryMenuItem = new MediaLibraryMenuItem(i, _xml.menu[0]);
				tMenuItem.y = (_label.y + _label.height + 15) + (i * 40);
				
				tMenuItem.mouseChildren = false;
				//TweenMax.to(tMenuItem, 0, {autoAlpha:0});
				
				tMenuItem.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
				tMenuItem.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
				tMenuItem.addEventListener(MouseEvent.CLICK, _handleMenuItem);
				
				if (i == Number(_xml.@initItemNum)) {
					_curMenuItem = tMenuItem;
					tMenuItem.select(true,true);
				} else {
					tMenuItem.select(false,true);
				}
				
				_menuItemsV.push(tMenuItem);
				
				this.addChild(tMenuItem);
			}
			
			//log('\t_menuItemsV.length: '+_menuItemsV.length);
			
			// Divider
			var divider:Shape = new Shape();
			with (divider.graphics) {
				beginFill(0x353535);
				drawRect(0,0,186,2);
				endFill();
			}
			divider.x = (this.width - divider.width) * 0.5;
			divider.y = _menuItemsV[_menuItemsV.length - 1].y + _menuItemsV[_menuItemsV.length - 1].height + 22;
			this.addChild(divider)
			
			// Camera menu title Label
			_label = new Label();
			_label.text = _xml.menu[1].@title;
			_label.autoSize = 'left';
			_label.textFormatName = 'media-menu-title';
			_label.x = 21;
			_label.y = divider.y + divider.height +36;
			this.addChild(_label);
			
			// Camera menu items
			for (i = 0; i < _xml.menu[1].item.length(); i++) {
				tMenuItem  = new MediaLibraryMenuItem(i, _xml.menu[1]);
				tMenuItem.y = (_label.y + _label.height + 15) + (i * 40);
				
				this.addChild(tMenuItem);
				_menuItemsV.push(tMenuItem);

			}
			
			//log('\t_menuItemsV.length: '+_menuItemsV.length);
			
			this.addChild(_selector);
			_selector.y = _curMenuItem.y;
			
			// Deleted
			var trashIcon:Bitmap = Register.ASSETS.getBitmap('mediaMenuItem_deletedIcon');
			trashIcon.x = 21;
			trashIcon.y = this.height - 40;
			this.addChild(trashIcon);

			_label = new Label();
			_label.text = 'DELETED';
			_label.autoSize = 'left';
			_label.textFormatName = 'media-menuitem-default';
			_label.x = 48;
			_label.y = this.height - 41;
			this.addChild(_label);
		}
		
		private function _select($item:MediaLibraryMenuItem):void {
			log('_select');
			if (_curMenuItem && _curMenuItem != $item) {
				_curMenuItem.select(false);
			}
			
			_curMenuItem = $item;
			_curMenuItem.select(true);
			
			this.addChild(_selector);
			TweenMax.to(_selector, 0.3, {y:_curMenuItem.y, ease:Cubic.easeInOut});
			
			dispatchEvent(new MediaMenuEvent(MediaMenuEvent.CHANGE));
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			log('_onAdded');
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			//log('\tdispatching CHANGE event');
			//dispatchEvent(new MusicMenuEvent(MusicMenuEvent.CHANGE));
			_addListeners();			
		}
		
		private function _handleMenuItem($e:MouseEvent):void {
			var tItem:MediaLibraryMenuItem = $e.target as MediaLibraryMenuItem;
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:					
					if (_curMenuItem != tItem) {
						TweenMax.to(tItem.label, 0, {tint:0xFFFFFF});
					}
					break;
				
				case MouseEvent.MOUSE_OUT:
					if (_curMenuItem != tItem) {
						TweenMax.to(tItem.label, 0.3, {tint:null});
					}					
					break;
				
				case MouseEvent.CLICK:					
					if (_curMenuItem != tItem) {
						_select(tItem);
					}
					break;
			}
		}
		
	}
}