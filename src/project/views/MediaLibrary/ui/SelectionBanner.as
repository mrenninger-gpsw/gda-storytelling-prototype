package project.views.MediaLibrary.ui {
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import components.controls.Label;
	
	import display.Sprite;
	
	import project.events.SelectionBannerEvent;
	import project.events.ViewTransitionEvent;
	
	import utils.Register;

	
	public class SelectionBanner extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _numSelected:uint = 0;
		private var _closeBtn:Sprite;
		private var _divider:Shape;
		private var _numLabel:Label;
		private var _textLabel:Label;
		private var _shareBtn:Sprite;
		private var _editorBtn:Sprite;
		private var _trashBtn:Sprite;
		private var _gridIcon:Sprite;
		private var _btnsV:Vector.<Sprite>;
		private var _isShowing:Boolean = true;
		private var _tooltip:Sprite;
		private var _mouseIsOver:Boolean = false;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _numLabel; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function SelectionBanner() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_btnsV = new Vector.<Sprite>();
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show($numSelected:uint):void {
				_isShowing = true;
				_numSelected = $numSelected;
				_numLabel.text = _numSelected.toString();
				TweenMax.to(this, 0.3, {autoAlpha:1, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}
		
		public function hide():void {
			if (_isShowing) {
				_isShowing = false;
				_removeListeners();
				TweenMax.to(this, 0.3, {autoAlpha:0, ease:Cubic.easeOut, onComplete:_onHideComplete});
			}
		}
		
		
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0x00A3DA);
			s.graphics.drawRect(0,0,1056,70);
			s.graphics.endFill();
			this.addChild(s);
			
			_closeBtn = new Sprite();
			_closeBtn.addChild(Register.ASSETS.getBitmap('mediaContentArea_recentlyAddedAlertClose'));
			TweenMax.to(_closeBtn, 0, {x:34, y:(this.height - _closeBtn.height) * 0.5, alpha:0.5, tint:0xFFFFFF});
			this.addChild(_closeBtn);
			_btnsV.push(_closeBtn)
			
			_divider = new Shape();
			_divider.graphics.beginFill(0xFFFFFF, 0.3);
			_divider.graphics.drawRect(0,0,1,24);
			_divider.graphics.endFill();
			TweenMax.to(_divider, 0, {x:_closeBtn.x + _closeBtn.width + 14, y:(this.height - _divider.height) * 0.5});
			this.addChild(_divider);
			
			_numLabel = new Label();
			_numLabel.text = _numSelected.toString();
			_numLabel.autoSize = 'left';
			_numLabel.textFormatName = 'selection-banner-num-selected';
			_numLabel.x = _divider.x + _divider.width + 13;
			_numLabel.y = (this.height - _numLabel.height) * 0.5 + 1;
			this.addChild(_numLabel);
			
			_textLabel = new Label();
			_textLabel.text = 'ITEMS SELECTED';
			_textLabel.autoSize = 'left';
			_textLabel.textFormatName = 'selection-banner-default';
			_textLabel.x = _numLabel.x + _numLabel.width + 6
			_textLabel.y = (this.height - _textLabel.height) * 0.5 + 1;
			this.addChild(_textLabel);
			
			_shareBtn = new Sprite();
			_shareBtn.addChild(Register.ASSETS.getBitmap('selectionBanner_ShareIcon'));
			TweenMax.to(_shareBtn, 0, {x:703, y:(this.height - _shareBtn.height) * 0.5, tint:0x025977});
			this.addChild(_shareBtn);
			_btnsV.push(_shareBtn)
			
			_editorBtn = new Sprite();
			_editorBtn.addChild(Register.ASSETS.getBitmap('mediaContentArea_OpenEventIcon'));
			TweenMax.to(_editorBtn, 0, {x:_shareBtn.x + _shareBtn.width + 21, y:(this.height - _editorBtn.height) * 0.5, tint:0x025977});
			this.addChild(_editorBtn);
			_btnsV.push(_editorBtn)
			
			_trashBtn = new Sprite();
			_trashBtn.addChild(Register.ASSETS.getBitmap('selectionBanner_TrashIcon'));
			TweenMax.to(_trashBtn, 0, {x:_editorBtn.x + _editorBtn.width + 21, y:(this.height - _trashBtn.height) * 0.5, tint:0x025977});
			this.addChild(_trashBtn);
			_btnsV.push(_trashBtn)
			
			_gridIcon = new Sprite();
			_gridIcon.addChild(Register.ASSETS.getBitmap('selectionBanner_GridSize'));
			TweenMax.to(_gridIcon, 0, {x:this.width - _gridIcon.width - 35, y:(this.height - _gridIcon.height) * 0.5});
			this.addChild(_gridIcon);
			
			_tooltip = new Sprite();
			var bmp:Bitmap = Register.ASSETS.getBitmap('mediaContentArea_OpenInEditorToolTip');
			bmp.x = -bmp.width * 0.5;
			bmp.y = -bmp.height;
			_tooltip.addChild(bmp);
			TweenMax.to(_tooltip, 0, {scaleX:0, scaleY:0, autoAlpha:0});
			_tooltip.x = _editorBtn.x + (_editorBtn.width * 0.5);
			_tooltip.y = _editorBtn.y;
			
			this.addChild(_tooltip);
			
			hide();
		}
		
		private function _onShowComplete():void {
			_addListeners();
		}
		
		private function _onHideComplete():void {
		
		}
		
		private function _addListeners():void {
			for (var i:uint = 0; i < _btnsV.length; i++) {
				_btnsV[i].addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
				_btnsV[i].addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
				_btnsV[i].addEventListener(MouseEvent.CLICK, _handleMouseEvent);
			}
			if (this.stage) {
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			}
		}
		
		private function _removeListeners():void {
			for (var i:uint = 0; i < _btnsV.length; i++) {
				_btnsV[i].removeEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
				_btnsV[i].removeEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
				_btnsV[i].removeEventListener(MouseEvent.CLICK, _handleMouseEvent);
			}
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			}
		}
		
		private function _showToolTip($b:Boolean = true):void {
			if ($b) {
				var p:Point = localToGlobal(new Point(_editorBtn.x + (_editorBtn.width * 0.5), _editorBtn.y));
				_tooltip.x = p.x;
				_tooltip.y = p.y;
				Register.PROJECT.addChild(_tooltip);
				TweenMax.to(_tooltip, 0.3, {scaleX:1, scaleY:1, autoAlpha:1, ease:Back.easeOut});
			} else {
				TweenMax.to(_tooltip, 0.3, {scaleX:0, scaleY:0, autoAlpha:0, ease:Back.easeIn, onComplete:_onHideToolTip});				
			}
		}
		
		private function _onHideToolTip():void {
			this.addChild(_tooltip);
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _handleMouseEvent($e:MouseEvent):void {
			var tBtn:Sprite;
			for (var i:uint = 0; i < _btnsV.length; i++) {
				if ($e.target == _btnsV[i]) tBtn = _btnsV[i];
			}
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					if (tBtn == _closeBtn) {
						TweenMax.to(tBtn, 0, {alpha:1});
					} else {
						TweenMax.to(tBtn, 0, {tint:0xFFFFFF});
						if (tBtn == _editorBtn) {
							_showToolTip()
							this.dispatchEvent(new SelectionBannerEvent(SelectionBannerEvent.EDITOR_HOVER));
						}
					}
					break;
				
				case MouseEvent.MOUSE_OUT:
					if (tBtn == _closeBtn) {
						TweenMax.to(tBtn, 0.3, {alpha:0.5, ease:Cubic.easeOut});
					} else {
						TweenMax.to(tBtn, 0.3, {tint:0x025977, ease:Cubic.easeOut});
						if (tBtn == _editorBtn) {
							_showToolTip(false);
							this.dispatchEvent(new SelectionBannerEvent(SelectionBannerEvent.EDITOR_NORMAL));
						}
					}
					break;
				
				case MouseEvent.CLICK:
					hide();	
					if (tBtn == _editorBtn) {
						this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.PREPARE_TO_ADD));
					}
					if (tBtn == _closeBtn) {
						this.dispatchEvent(new SelectionBannerEvent(SelectionBannerEvent.CLOSE));
					}
					break;
			}
		}
		
		private function _handleMouseDown($e:MouseEvent):void {
			if (!_mouseIsOver) {
				if (_isShowing) {
					hide();
					this.dispatchEvent(new SelectionBannerEvent(SelectionBannerEvent.CLOSE));
				}
			}
		}
		
		private function _handleMouseMove($e:MouseEvent):void {
			var p:Point = localToGlobal(new Point(mouseX, mouseY));
			_mouseIsOver = this.hitTestPoint(p.x,p.y);
		}
	}
}