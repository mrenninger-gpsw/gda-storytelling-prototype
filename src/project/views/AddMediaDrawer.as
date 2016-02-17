package project.views {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Expo;
	
	// Framework
	import components.controls.Label;	
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.AddMediaDrawerEvent;
	import project.events.ViewTransitionEvent;
	import project.views.AddMediaDrawer.AddMediaClipGroup;	
	
	
	
	public class AddMediaDrawer extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _titleLabel:Label;
		private var _closeBtn:Sprite;
		private var _bg:Shape;
		private var _showing:Boolean = false;
		private var _mouseIsOver:Boolean = false;
		private var _xml:XMLList
		private var _clipGroupV:Vector.<AddMediaClipGroup>;
		private var _filterBy:Bitmap;
		private var _canAddSourceClips:Boolean = false;;
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _titleLabel; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function AddMediaDrawer() {
			super();
			verbose = true;
			_xml = Register.PROJECT_XML.content.mediaLibrary.addMediaDrawer;
			log('xml: '+_xml);
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			_showing = true;
			TweenMax.to(this, 0, {autoAlpha:1});
			TweenMax.to(_closeBtn, 0.4, {x:_bg.width - _closeBtn.width - 24, ease:Expo.easeInOut});
			TweenMax.to(_filterBy, 0.4, {autoAlpha:1, x:_bg.width - _filterBy.width - 32, ease:Expo.easeInOut});
			TweenMax.to(_bg, 0.4, {x:0, ease:Expo.easeInOut, onComplete:_onShowComplete});
			
			for (var i:uint = 0; i < _clipGroupV.length; i++) {				
				TweenMax.to(_clipGroupV[i], 0.3, {x:_clipGroupV[i].initX, autoAlpha:1, ease:Back.easeOut, delay:0.3 + (i * 0.05)});
			}

		}
		
		public function hide():void {
			_showing = false;
			if (_canAddSourceClips) {
				this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.PREPARE_TO_ADD));
				_canAddSourceClips = false;
			}
			
			this.dispatchEvent(new AddMediaDrawerEvent(AddMediaDrawerEvent.ADD_MEDIA_DRAWER_HIDE));
			_removeListeners();
			TweenMax.to(_closeBtn, 0.3, {tint:null, ease:Cubic.easeOut});
			TweenMax.to(_bg, 0.4, {x:-_bg.width, ease:Expo.easeInOut});
			TweenMax.to(_closeBtn, 0.4, {x:-_closeBtn.width - 24, ease:Expo.easeInOut});
			TweenMax.to(_filterBy, 0.4, {autoAlpha:0, x:-_filterBy.width - 32, ease:Expo.easeInOut});
			for (var i:uint = 0; i < _clipGroupV.length; i++) {
				var func:Function = (i == _clipGroupV.length - 1) ? _onHideComplete : null;
				_clipGroupV[i].hide();
				TweenMax.to(_clipGroupV[i], 0.4, {x:_titleLabel.x-_bg.width, ease:Expo.easeInOut, onComplete:func});
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_bg = new Shape();
			_bg.graphics.beginFill(0x000000);
			_bg.graphics.drawRoundRectComplex(0,0,560,860,10,0,0,0);
			_bg.graphics.endFill();
			_bg.x = -_bg.width
			this.addChild(_bg);
			
			_titleLabel = new Label();
			_titleLabel.text = Register.PROJECT_XML.content.editor.storybuilder.sourceClips.@title;
			_titleLabel.autoSize = 'left';
			_titleLabel.textFormatName = 'sourceclip-title';
			_titleLabel.x = 26;
			_titleLabel.y = 86;
			this.addChild(_titleLabel);
			
			_closeBtn = new Sprite();
			_closeBtn.addChild(Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlertClose'));
			_closeBtn.x = _bg.width - _closeBtn.width - 24 - _bg.width;
			_closeBtn.y = 24;
			this.addChild(_closeBtn);
			
			_clipGroupV = new Vector.<AddMediaClipGroup>();
			for (var i:uint = 0; i < _xml.item.length(); i++) {
				var tGroup:AddMediaClipGroup = new AddMediaClipGroup(_xml.item[i]);
				tGroup.x = tGroup.initX = _titleLabel.x;
				tGroup.y = (i == 0) ? _titleLabel.y + _titleLabel.height + 40 : _clipGroupV[(i-1)].y + _clipGroupV[(i-1)].height + 31;
				tGroup.addEventListener(AddMediaDrawerEvent.SELECT_ALL, _onAddMediaDrawerEvent); 
				tGroup.addEventListener(AddMediaDrawerEvent.DESELECT_ALL, _onAddMediaDrawerEvent); 

				_clipGroupV.push(tGroup);
				this.addChild(tGroup);
				
			}
			
			_filterBy = Register.ASSETS.getBitmap('addMediaDrawer_FilterBy');
			_filterBy.x = -_filterBy.width - 32;
			_filterBy.y = _titleLabel.y + _titleLabel.height - _filterBy.height;
			TweenMax.to(_filterBy, 0, {autoAlpha:0});
			this.addChild(_filterBy);
			
			hide();
		}
		
		private function _onShowComplete():void {
			_addListeners();
			for (var i:uint = 0; i < _clipGroupV.length; i++) { _clipGroupV[i].show(); }
			this.stage.dispatchEvent(new AddMediaDrawerEvent(AddMediaDrawerEvent.ADD_MEDIA_DRAWER_SHOW));

		}
		
		private function _onHideComplete():void {
			TweenMax.to(this, 0, {autoAlpha:0});
			for (var i:uint = 0; i < _clipGroupV.length; i++) {				
				TweenMax.to(_clipGroupV[i], 0, {x:_clipGroupV[i].initX - 20, autoAlpha:0});
			}
		}
		
		private function _addListeners():void {
			if (this.stage) {
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			}
			
			_closeBtn.addEventListener(MouseEvent.MOUSE_OVER, _handleCloseBtn);
			_closeBtn.addEventListener(MouseEvent.MOUSE_OUT, _handleCloseBtn);
			_closeBtn.addEventListener(MouseEvent.CLICK, _handleCloseBtn);
		}
		
		private function _removeListeners():void {
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			}
			
			_closeBtn.removeEventListener(MouseEvent.MOUSE_OVER, _handleCloseBtn);
			_closeBtn.removeEventListener(MouseEvent.MOUSE_OUT, _handleCloseBtn);
			_closeBtn.removeEventListener(MouseEvent.CLICK, _handleCloseBtn);
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}

		private function _onMouseEvent($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					break;
				
				case MouseEvent.MOUSE_OUT:
					break;
				
				case MouseEvent.CLICK:
					break;
			}
		}
		
		private function _handleCloseBtn($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(_closeBtn, 0, {tint:0x00A3DA});
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(_closeBtn, 0.3, {tint:null, ease:Cubic.easeOut});
					break;
				
				case MouseEvent.CLICK:
					if (_showing) hide();
					break;
			}		
		}
		
		private function _handleMouseDown($e:MouseEvent):void {
			if (!_mouseIsOver) {
				if (_showing) hide();
			}
		}
		
		private function _handleMouseMove($e:MouseEvent):void {
			var p:Point = localToGlobal(new Point(mouseX, mouseY));
			_mouseIsOver = this.hitTestPoint(p.x,p.y);
		}
		
		private function _onAddMediaDrawerEvent($e:AddMediaDrawerEvent):void {
			switch ($e.type) {
				case AddMediaDrawerEvent.SELECT_ALL:
					if ($e.target == _clipGroupV[0]) {
						_canAddSourceClips = true;
					}
					break;
				case AddMediaDrawerEvent.DESELECT_ALL:
					if ($e.target == _clipGroupV[0]) {
						_canAddSourceClips = false;	
					}
					break;			
			}
		}
	}
}