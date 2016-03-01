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
	import layout.Grid;
	import utils.Register;
	
	// Project
	import project.events.MediaLibraryGroupEvent;
	import project.events.ViewTransitionEvent;
	import project.views.MediaLibrary.ui.EventClipPreview;	
	
	
	
	public class MediaLibraryGroup extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XML;
		private var _num:uint;
		private var _clipsV:Vector.<EventClipPreview>;
		private var _titleLabel:Label;
		private var _menuIconNames:Array = ['mediaContentArea_OpenEventIcon','mediaContentArea_EditIcon','mediaContentArea_SelectAllIcon']
		private var _menuIconsV:Vector.<Sprite>;
		private var _menu:Sprite;
		private var _menuShowing:Boolean = false;
		private var _tooltip:Sprite;
		private var _allSelected:Boolean = false;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get menu():Sprite { return _menu; }

		public function get numClips():uint{ return _clipsV.length; }

		
		
		/******************** CONSTRUCTOR *********************/
		public function MediaLibraryGroup($num:uint) {
			super();
			verbose = true;
			_num = $num;
			id = String('Group'+_num);;
			_xml = Register.PROJECT_XML.content.mediaLibrary.content.event[_num];
			//trace();
			//log('_num: '+_num);
			//log('_xml: \r'+_xml);
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			log('show');
			TweenMax.to(this, 0, {autoAlpha:1});
		}
		
		public function hide():void {
			log('hide');
			TweenMax.to(this, 0, {autoAlpha:0}); 
		}
		
		public function showMenu($b:Boolean = true):void {
			if ($b && !_menuShowing) {
				//log('Show Menu');
				_menuShowing = true;
				TweenMax.to(_menu, 0.3, {autoAlpha:1, ease:Cubic.easeOut});	
			}
			if (!$b && _menuShowing) {
				//log('Hide Menu');
				_menuShowing = false;
				TweenMax.to(_menu, 0.3, {autoAlpha:0, ease:Cubic.easeOut});	
			}
		}
		
		public function showVideos($b:Boolean = true):void {
			var i:uint;
			for (i = 0; i < _clipsV.length; i++) {
				/*if (_allSelected && !_clipsV[i].isVideo) {
					_clipsV[i].soften($b)
				} 
				if (!_allSelected && _clipsV[i].isVideo) {
					_clipsV[i].select($b);
				}*/
				if (!_clipsV[i].isVideo) {
					_clipsV[i].soften($b)
				} 
				if (_clipsV[i].isVideo) {
					_clipsV[i].select($b);
				}
			}
		}
		
		public function deselectAll():void {
			_selectAll(false);
			TweenMax.to(_menuIconsV[2], 0.3, {tint:null, ease:Cubic.easeOut});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			var i:uint;
			
			// create the event title label
			_titleLabel = new Label();
			_titleLabel.text = _xml.@title;
			_titleLabel.autoSize = 'left';
			_titleLabel.textFormatName = 'media-event-title';
			this.addChild(_titleLabel);
			//log('_titleLabel.text: '+_titleLabel.text);
			
			// create the clips grid
			var gridAr:Array = Grid.create(4,3,240,180,10,10);
			_clipsV = new Vector.<EventClipPreview>();
			for (i = 0; i < _xml.clip.length(); i++) {
				var tClip:EventClipPreview = new EventClipPreview(_xml.clip[i]);
				tClip.x = gridAr[i].x;
				tClip.y = gridAr[i].y + _titleLabel.y + _titleLabel.height + 10;
				tClip.mouseChildren = false;
				tClip.mouseEnabled = false;

				_clipsV.push(tClip);
				this.addChild(tClip);
			}
			
			// create the menu
			_menuIconsV = new Vector.<Sprite>();
			_menu = new Sprite();
			for (i = 0; i < _menuIconNames.length; i++) {
				var tIconHolder:Sprite = new Sprite();
				tIconHolder.addChild(Register.ASSETS.getBitmap(_menuIconNames[i]));
				tIconHolder.x = (i == 0) ? 0 : _menuIconsV[i-1].x + _menuIconsV[i-1].width + 22;
				tIconHolder.y = (i == 0) ? 0 : _menuIconsV[i-1].y + _menuIconsV[i-1].height - tIconHolder.height;
				tIconHolder.id = _menuIconNames[i];
				
				tIconHolder.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuIcon);
				tIconHolder.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuIcon);
				tIconHolder.addEventListener(MouseEvent.CLICK, _handleMenuIcon);
				
				_menu.addChild(tIconHolder);
				_menuIconsV.push(tIconHolder);
			}
			_menu.x = 990 - _menu.width;
			_menu.y = _titleLabel.y - 5;
			TweenMax.to(_menu, 0, {autoAlpha:0});	
			this.addChild(_menu);
			
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0xFF00FF,0);
			bgShape.graphics.drawRect(0,0, this.width, this.height);
			bgShape.graphics.endFill();
			this.addChildAt(bgShape,0);
			
			_tooltip = new Sprite();
			var bmp:Bitmap = Register.ASSETS.getBitmap('mediaContentArea_OpenInEditorToolTip');
			bmp.x = -bmp.width * 0.5;
			bmp.y = -bmp.height;
			_tooltip.addChild(bmp);
			TweenMax.to(_tooltip, 0, {scaleX:0, scaleY:0, autoAlpha:0});
			_tooltip.x = _menu.x + (_menuIconsV[0].width * 0.5);
			_tooltip.y = _menu.y;

			this.addChild(_tooltip);
			
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		private function _showToolTip($b:Boolean = true):void {
			showVideos($b);
			if ($b) {
				TweenMax.to(_tooltip, 0.3, {scaleX:1, scaleY:1, autoAlpha:1, ease:Back.easeOut});
			} else {
				TweenMax.to(_tooltip, 0.3, {scaleX:0, scaleY:0, autoAlpha:0, ease:Back.easeIn});				
			}
		}
		
		private function _selectAll($b:Boolean = true):void {
			log('_selectAll: '+$b);
			_allSelected = $b;
			for (var i:uint = 0; i < _clipsV.length; i++) {
				TweenMax.delayedCall((i*0.03), _clipsV[i].select,[$b]);
			}
			
			dispatchEvent(new MediaLibraryGroupEvent(($b) ? MediaLibraryGroupEvent.SELECT_ALL : MediaLibraryGroupEvent.DESELECT_ALL));
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _handleMenuIcon($e:MouseEvent):void {
			
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to($e.target, 0, {tint:0x00A3DA});
					if (Sprite($e.target).id == _menuIconNames[0]) { _showToolTip(); }
					break;
				case MouseEvent.MOUSE_OUT:
					if (Sprite($e.target).id == _menuIconNames[2] && _allSelected) {
						// do nothing
					} else {
						TweenMax.to($e.target, 0.3, {tint:null, ease:Cubic.easeOut});
					}
					if (Sprite($e.target).id == _menuIconNames[0]) { _showToolTip(false); }
					break;
				case MouseEvent.CLICK:
					if (Sprite($e.target).id == _menuIconNames[0]) {
						// somehow trigger a transition to the editor adding the 2 clips
						this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.PREPARE_TO_ADD));
					}
					if (Sprite($e.target).id == _menuIconNames[2]) {
						_selectAll(!_allSelected);
					}
					break;
			}
		}
	}
}