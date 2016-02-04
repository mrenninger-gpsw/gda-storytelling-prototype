package project.views.MusicSelector {
	
	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.MusicMenuEvent;
	import project.views.MusicSelector.ui.MusicMenuItem;
	import project.views.MusicSelector.ui.MusicNavBtn;
	
	
	
	public class MusicMenu extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _musicXML:XMLList;
		private var _navBkgd:Shape;
		private var _menuBkgd:Shape;
		private var _itemHolder:Sprite;
		private var _navIndicatorBkgd:Shape;
		private var _navIndicator:Shape;
		private var _navItemsV:Vector.<MusicNavBtn>;
		private var _curNavItem:MusicNavBtn;
		private var _curMenuItem:MusicMenuItem;
		private var _menuItemsV:Vector.<MusicMenuItem>;
		private var _navHolder:Sprite;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get curMenuItem():MusicMenuItem { return _curMenuItem; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MusicMenu() {
			super();
			verbose = true;
			
			_musicXML = Register.PROJECT_XML.content.music;
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);

			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			log('show');
			_select(_menuItemsV[0]);
			TweenMax.to(this, 0, {autoAlpha:1});
			TweenMax.to(_navHolder, 0.5, {y:0, ease:Cubic.easeOut});
			TweenMax.to(_menuBkgd, 0.5, {autoAlpha:1, ease:Cubic.easeOut, delay:0.3});
			for (var i:uint = 0; i < _menuItemsV.length; i++) {
				//log('\titem: '+i+' | title: '+_menuItemsV[i].title);
				var onCompleteFunc:Function = (i == (_menuItemsV.length - 1)) ? _onShowComplete : null;
				TweenMax.to(_menuItemsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.5 + (i * 0.05), onComplete:onCompleteFunc});
			}
		}
		
		public function hide():void {
			TweenMax.to(_menuBkgd, 0.5, {autoAlpha:0, ease:Cubic.easeOut});
			for (var i:uint = 0; i < _menuItemsV.length; i++) {
				TweenMax.to(_menuItemsV[i], 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:(i * 0.05)});
			}
			TweenMax.to(_navHolder, 0.5, {y:-76, ease:Cubic.easeOut, delay:0.3, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			TweenMax.to(this, 0, {autoAlpha:0});
			_createNav();
			_createMenu();
		}
		
		private function _addListeners():void {
		
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		private function _createNav():void {
			log('_createNav');
			
			_navItemsV = new Vector.<MusicNavBtn>();
			
			// nav holder
			_navHolder = new Sprite();
			this.addChild(_navHolder);
			_navHolder.y = -74;
			
			// nav bkgd
			_navBkgd = new Shape();
			_navBkgd.graphics.beginFill(0x141414, 0.5);
			_navBkgd.graphics.drawRect(0,0,464,74);
			_navBkgd.graphics.endFill();
			_navHolder.addChild(_navBkgd);
			
			var totalNavItems:Number = _musicXML.nav.item.length();
			var navItemWidth:Number = (424/totalNavItems);
			
			log('\ttotalNavItems: '+totalNavItems);
			
			// nav items
			for (var i:uint = 0; i < totalNavItems; i++) {
				var tNavItem:MusicNavBtn = new MusicNavBtn(_musicXML.nav.item[i], navItemWidth);
				tNavItem.x = 20 + (i * navItemWidth);
				tNavItem.y = 20;
				
				tNavItem.addEventListener(MouseEvent.MOUSE_OVER, _handleNavItem);
				tNavItem.addEventListener(MouseEvent.MOUSE_OUT, _handleNavItem);
				tNavItem.addEventListener(MouseEvent.CLICK, _handleNavItem);
				
				if (i == 0) {
					_curNavItem = tNavItem;
					TweenMax.to(tNavItem.label, 0, {tint:0xFFFFFF});
				}
				
				_navItemsV.push(tNavItem);
				
				_navHolder.addChild(tNavItem);
			}
			
			// nav indicator bkgd
			_navIndicatorBkgd = new Shape();
			_navIndicatorBkgd.graphics.beginFill(0x353535);
			_navIndicatorBkgd.graphics.drawRect(0,0,424,3);
			_navIndicatorBkgd.graphics.endFill();
			_navIndicatorBkgd.x = 20;
			_navIndicatorBkgd.y = 71;
			_navHolder.addChild(_navIndicatorBkgd);
			
			// nav indicator
			_navIndicator = new Shape();
			_navIndicator.graphics.beginFill(0x00A3DA);
			_navIndicator.graphics.drawRect(0,0,212,3);
			_navIndicator.graphics.endFill();
			_navIndicator.x = 20;
			_navIndicator.y = 71;
			_navHolder.addChild(_navIndicator);
			
		}
		
		private function _createMenu():void {
			log('_createMenu');
			_menuItemsV = new Vector.<MusicMenuItem>();
			
			// menu items bkgd
			_menuBkgd = new Shape();
			_menuBkgd.graphics.beginFill(0x141414, 0.3);
			_menuBkgd.graphics.drawRect(0,0,464,640);
			_menuBkgd.graphics.endFill();
			_menuBkgd.y = 74;
			TweenMax.to(_menuBkgd, 0, {autoAlpha:0});
			this.addChild(_menuBkgd);			
			
			// menu items holder
			_itemHolder = new Sprite();
			_itemHolder.x = 20;
			_itemHolder.y = _menuBkgd.y;
			this.addChild(_itemHolder);	
			
			// menu items holder mask
			var _mask:Shape = new Shape();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.drawRect(0,0,424,640);
			_mask.graphics.endFill();
			_mask.x = 20;
			_mask.y = _menuBkgd.y;
			this.addChild(_mask);
			_itemHolder.mask = _mask;
			
			log('\tTotal Tracks: '+_musicXML.tracks.item.length());
			log('\tinitSongNum: '+_musicXML.@initSongNum);
			var i:uint;
			// all menu items
			for (i = 0; i < _musicXML.tracks.item.length(); i++) {
				var tMenuItem:MusicMenuItem = new MusicMenuItem(i);
				tMenuItem.y = i * 70;
				
				tMenuItem.mouseChildren = false;
				TweenMax.to(tMenuItem, 0, {autoAlpha:0});
				
				tMenuItem.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
				tMenuItem.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
				tMenuItem.addEventListener(MouseEvent.CLICK, _handleMenuItem);
				
				if (i == Number(_musicXML.@initSongNum)) {
					_curMenuItem = tMenuItem;
					tMenuItem.select(true,true);
				} else {
					tMenuItem.select(false,true);
				}
				
				_menuItemsV.push(tMenuItem);
				
				_itemHolder.addChild(tMenuItem);
			}
			
			var newItemCount:uint = 0;
			for (i = 0; i < _musicXML.tracks.item.length(); i++) {
				if (_musicXML.tracks.item[i].@newSong == 'true'){
					//log('\tnew song: '+i);
					var tNewMenuItem:MusicMenuItem = new MusicMenuItem(i);
					tNewMenuItem.x = 424;
					tNewMenuItem.y = newItemCount * 70;
					
					tNewMenuItem.mouseChildren = false;
					TweenMax.to(tNewMenuItem, 0, {autoAlpha:0});
					
					tNewMenuItem.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
					tNewMenuItem.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
					
					_menuItemsV.push(tNewMenuItem);
					_itemHolder.addChild(tNewMenuItem);
					newItemCount++;
				}
			}
			
			log('\t_menuItemsV.length: '+_menuItemsV.length);
		}
		
		private function _select($item:MusicMenuItem):void {
			log('_select');
			if (_curMenuItem && _curMenuItem != $item) {
				_curMenuItem.select(false);
				_curMenuItem.bpmMeter.activate(false);
			}
			
			_curMenuItem = $item;
			_curMenuItem.select(true);
			_curMenuItem.bpmMeter.activate(true);
			
			dispatchEvent(new MusicMenuEvent(MusicMenuEvent.CHANGE));

		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			log('_onAdded');
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			log('\tdispatching CHANGE event');
			dispatchEvent(new MusicMenuEvent(MusicMenuEvent.CHANGE));
			_addListeners();			
		}
		
		private function _handleNavItem($e:MouseEvent):void {
			var tNavItem:MusicNavBtn = $e.target as MusicNavBtn 
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					if (_curNavItem != tNavItem) {
						TweenMax.to(tNavItem.label, 0, {tint:0xFFFFFF});
					}
					break;
				
				case MouseEvent.MOUSE_OUT:
					if (_curNavItem != tNavItem) {
						TweenMax.to(tNavItem.label, 0.3, {tint:null});
					}					
					break;
				
				case MouseEvent.CLICK:					
					if (_curNavItem != tNavItem) {
						// update the nav
						TweenMax.to(_curNavItem.label, 0.3, {tint:null});
						_curNavItem = tNavItem;
						
						// move the indicator
						TweenMax.to(_navIndicator, 0.5, {x:_curNavItem.x, ease:Cubic.easeInOut});
						
						// move the items
						TweenMax.to(_itemHolder, 0.5, {x:20 - (((_curNavItem.x - 20)/212) * 424), ease:Cubic.easeInOut});
						
					}
					break;
			}
		}
		
		private function _handleMenuItem($e:MouseEvent):void {
			var tItem:MusicMenuItem = $e.target as MusicMenuItem;
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:					
					if (_curMenuItem != tItem) {
						TweenMax.to(tItem.label, 0, {tint:0x00A3DA});
						tItem.bpmMeter.animate()
					}
					break;
				
				case MouseEvent.MOUSE_OUT:
					if (_curMenuItem != tItem) {
						TweenMax.to(tItem.label, 0.3, {tint:null});
						tItem.bpmMeter.reset();
					}					
					break;
				
				case MouseEvent.CLICK:					
					if (_curMenuItem != tItem && !tItem.locked) {
						_select(tItem);
					}
					break;
			}
		}
		
	}
}