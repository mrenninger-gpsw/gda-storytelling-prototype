package project.views.MediaLibrary {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// Framework
	import components.controls.Label;	
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.MediaLibraryGroupEvent;
	import project.events.SelectionBannerEvent;
	import project.views.MediaLibrary.ui.SelectionBanner;
	
		
		
	public class MediaLibraryContentArea extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XMLList;
		private var _menu:MediaLibraryMenu;
		private var _titleLabel:Label;
		private var _sortByIcon:Bitmap;
		private var _eventLabel:Label;
		private var _eventGroupsV:Vector.<MediaLibraryGroup>;
		private var _filterIcon:Bitmap;
		private var _gridIcon:Bitmap;
		private var _divider:Shape;
		private var _transitionStart:Number;
		private var _recentlyAddedEG:MediaLibraryGroup;
		private var _curGroupNum:uint = 0;
		private var _selectionBanner:SelectionBanner;
		private var _curGroup:MediaLibraryGroup;
		
		/***************** GETTERS & SETTERS ******************/			
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function MediaLibraryContentArea() {
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
			_curGroupNum = 0;
			_titleLabel.text = _xml.menu[0].item[_curGroupNum];
			TweenMax.to(_titleLabel, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			TweenMax.to(_sortByIcon, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.05});
			TweenMax.to(_filterIcon, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.1});
			TweenMax.to(_gridIcon, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.15});
			TweenMax.to(_divider, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			TweenMax.to(_eventLabel, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.05});
			for (var i:uint = 0; i < _eventGroupsV.length - 1; i++) {
				var func:Function = (i == (_eventGroupsV.length - 2)) ? _onShowComplete : null;
				TweenMax.to(_eventGroupsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.1 + (i * 0.05), onComplete:func});
			}
		}
		
		public function hide():void {
			log('hide');
			this.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			//TweenMax.to(this, 0, {autoAlpha:0, onComplete:_onHideComplete});
			_transitionStart = new Date().getTime();
			TweenMax.to(_titleLabel, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
			TweenMax.to(_sortByIcon, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.05});
			TweenMax.to(_filterIcon, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.1});
			TweenMax.to(_gridIcon, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.15});
			TweenMax.to(_divider, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
			TweenMax.to(_eventLabel, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.05});
			for (var i:uint = 0; i < _eventGroupsV.length; i++) {
				var func:Function = (i == (_eventGroupsV.length - 1)) ? _onHideComplete : null;
				TweenMax.to(_eventGroupsV[i], 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.1 + (i * 0.05), onComplete:func});
			}
		}
		
		public function update($num:uint):void {
			TweenMax.to(_titleLabel, 0.2, {y:'5', alpha:0, onComplete:_onUpdate, onCompleteParams:[$num]});
			if (_curGroupNum != $num) {
				_curGroupNum = $num;
				var i:uint;
				var func:Function;
				this.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
				switch (_curGroupNum){
					case 0:
						TweenMax.to(_eventGroupsV[2], 0.3, {autoAlpha:0, ease:Cubic.easeOut});
						
						for (i = 0; i < _eventGroupsV.length-1; i++) {
							func = (i == (_eventGroupsV.length - 2)) ? _onShowComplete : null;
							TweenMax.to(_eventGroupsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.3 + (i * 0.05), onComplete:func});
						}
						
						TweenMax.to(_eventLabel, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.25});
						TweenMax.to(_sortByIcon, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.3});

						break;
					case 1:
						TweenMax.to(_eventLabel, 0.3, {autoAlpha:0, ease:Cubic.easeOut});
						TweenMax.to(_sortByIcon, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.05});

						for (i = 0; i < _eventGroupsV.length-1; i++) {
							func = (i == (_eventGroupsV.length - 2)) ? _onShowComplete : null;
							TweenMax.to(_eventGroupsV[i], 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:(i * 0.05)});
						}
						
						TweenMax.to(_eventGroupsV[2], 0, {autoAlpha:0, x:33, y:_divider.y + _divider.height + 26});
						TweenMax.to(_eventGroupsV[2], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.3, onComplete:_onShowComplete});
						break;
				}
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			
			var bg:Shape = new Shape();
			with (bg.graphics) {
				beginFill(0xFF00FF,0);
				drawRect(0,0,1056,794);
				endFill();
			}
			this.addChild(bg);
			
			_titleLabel = new Label();
			_titleLabel.text = _xml.menu[0].item[0];
			_titleLabel.autoSize = 'left';
			_titleLabel.textFormatName = 'media-content-title';
			_titleLabel.x = 33;
			_titleLabel.y = (70 - _titleLabel.height) * 0.5;
			this.addChild(_titleLabel);
			
			_gridIcon = Register.ASSETS.getBitmap('mediaContentArea_GridSize');
			_gridIcon.x = 1056 - 35 - _gridIcon.width;
			_gridIcon.y = (70 - _gridIcon.height) * 0.5;
			this.addChild(_gridIcon);
			
			_filterIcon = Register.ASSETS.getBitmap('mediaContentArea_Filter');
			_filterIcon.x = _gridIcon.x - 30 - _filterIcon.width
			_filterIcon.y = (70 - _filterIcon.height) * 0.5;
			this.addChild(_filterIcon);
			
			_sortByIcon = Register.ASSETS.getBitmap('mediaContentArea_sortByMenu');
			_sortByIcon.x = _filterIcon.x - 30 - _sortByIcon.width
			_sortByIcon.y = (70 - _sortByIcon.height) * 0.5;
			this.addChild(_sortByIcon);
			
			_divider = new Shape();
			with (_divider.graphics) {
				beginFill(0x353535);
				drawRect(0,0,990,1);
				endFill();
			}
			_divider.x = 33;
			_divider.y = 69;
			this.addChild(_divider);
			
			_eventLabel = new Label();
			_eventLabel.text = _xml.content.@title;
			_eventLabel.autoSize = 'left';
			_eventLabel.textFormatName = 'media-event-group-title';
			_eventLabel.x = 33;
			_eventLabel.y = _divider.y + _divider.height + 26;
			this.addChild(_eventLabel);
			
			_eventGroupsV = new Vector.<MediaLibraryGroup>();
			for (var i:uint = 0; i < _xml.content.event.length(); i++) {
				//log('i: '+i);
				var tEventGroup:MediaLibraryGroup = new MediaLibraryGroup(i);
				tEventGroup.x = 33;
				tEventGroup.y = (i == 0) ? _eventLabel.y + _eventLabel.height + 3 : _eventGroupsV[i-1].y + _eventGroupsV[i-1].height + 20;
				tEventGroup.name = 'Group'+i;
				tEventGroup.addEventListener(MediaLibraryGroupEvent.SELECT_ALL, _onMediaLibraryGroupEvent); 
				tEventGroup.addEventListener(MediaLibraryGroupEvent.DESELECT_ALL, _onMediaLibraryGroupEvent); 
				_eventGroupsV.push(tEventGroup);
				this.addChild(tEventGroup);
			}
			
			// add the selectionBanner here
			_selectionBanner = new SelectionBanner();
			_selectionBanner.addEventListener(SelectionBannerEvent.EDITOR_HOVER, _onSelectionBannerEvent); 
			_selectionBanner.addEventListener(SelectionBannerEvent.EDITOR_NORMAL, _onSelectionBannerEvent); 
			_selectionBanner.addEventListener(SelectionBannerEvent.CLOSE, _onSelectionBannerEvent); 
			this.addChild(_selectionBanner);

		}
		
		private function _onShowComplete():void {
			log('_onShowComplete - transitionTime: '+(new Date().getTime() - _transitionStart))
			this.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);			
		}
		
		private function _onHideComplete():void {
			log('_onHideComplete - transitionTime: '+(new Date().getTime() - _transitionStart));
			//TweenMax.to(this, 0, {autoAlpha:0});
			//_reset();
		}
		
		private function _onUpdate($num):void {
			_titleLabel.text = _xml.menu[0].item[$num];
			TweenMax.to(_titleLabel, 0, {y:'-10'});
			TweenMax.to(_titleLabel, 0.3, {y:'5', alpha:1});
		}
		
		private function _reset():void {
			_curGroupNum = 0;
			_titleLabel.text = _xml.menu[0].item[0];
			
			TweenMax.to(_eventGroupsV[2], 0, {autoAlpha:0});
			
			for (var i:uint = 0; i < _eventGroupsV.length-1; i++) {
				TweenMax.to(_eventGroupsV[i], 0, {autoAlpha:1});
			}
			
			TweenMax.to(_eventLabel, 0, {autoAlpha:1});
			TweenMax.to(_sortByIcon, 0, {autoAlpha:1});
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _handleMouseMove($e:MouseEvent):void {			
			//log('_handleMouseMove');
			var p:Point = localToGlobal(new Point(mouseX,mouseY));
			for (var i:uint = 0; i< _eventGroupsV.length; i++) {
				if (_eventGroupsV[i].hitTestPoint(p.x,p.y)){
					_eventGroupsV[i].showMenu();
				} else {
					_eventGroupsV[i].showMenu(false);
				}
			}
		}
		
		private function _onMediaLibraryGroupEvent($e:MediaLibraryGroupEvent):void {
			switch ($e.type){
				case MediaLibraryGroupEvent.SELECT_ALL:
					if (_curGroup) _curGroup.deselectAll();
					_curGroup = MediaLibraryGroup($e.target);
					_selectionBanner.show(_curGroup.numClips);
					break;
				case MediaLibraryGroupEvent.DESELECT_ALL:
					_curGroup = null;
					_selectionBanner.hide();
					break;			
			}
		}
		
		private function _onSelectionBannerEvent($e:SelectionBannerEvent):void {
			switch ($e.type){
				case SelectionBannerEvent.EDITOR_HOVER:
					if (_curGroup) _curGroup.showVideos();
					break;
				case SelectionBannerEvent.EDITOR_NORMAL:
					if (_curGroup) _curGroup.showVideos(false);
					break;
				case SelectionBannerEvent.CLOSE:
					var p:Point = localToGlobal(new Point(mouseX, mouseY));
					var mouseOverGroup:Boolean = false;
					for (var i:uint = 0; i < _eventGroupsV.length-1; i++) {
						if (_eventGroupsV[i].hitTestPoint(p.x,p.y)) mouseOverGroup = true;
					}
					if (_curGroup && !mouseOverGroup) {
						_selectionBanner.hide();
						_curGroup.deselectAll();
					}
					break;
			}
		}
	}
}