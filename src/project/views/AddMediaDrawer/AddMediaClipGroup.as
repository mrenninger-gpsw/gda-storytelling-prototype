package project.views.AddMediaDrawer {
	
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
	import layout.Grid;
	import utils.Register;
	
	// Project
	import project.events.AddMediaDrawerEvent;	

	
	
	public class AddMediaClipGroup extends Sprite {
		
		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XML;
		private var _label:Label;
		private var _thumbGroup:Bitmap;
		private var _initX:Number;
		private var _highlightsV:Vector.<Sprite>;
		private var _menu:Sprite;
		private var _menuShowing:Boolean = false;
		private var _allSelected:Boolean = false;
		private var _addAll:Sprite;
		private var _removeAll:Sprite;

		/***************** GETTERS & SETTERS ******************/			
		public function get label():Label { return _label; }
		
		public function get thumbGroup():Bitmap { return _thumbGroup; }
		
		public function get initX():Number { return _initX; }
		public function set initX($value:Number):void { _initX = $value; }
		
		
		/******************** CONSTRUCTOR *********************/
		public function AddMediaClipGroup($xml:XML) {
			super();
			verbose = true;
			_xml = $xml
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			if (_xml.@selected == 'true') _selectAll();
			_onShowComplete();
		}
		
		public function hide():void {
			_selectAll(false);
			_removeListeners()
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0xFF00FF,0);
			s.graphics.drawRect(0,0,504,1);
			s.graphics.endFill();
			this.addChild(s);
			
			_label = new Label();
			_label.text = _xml.@title;
			_label.autoSize = 'left';
			_label.textFormatName = 'media-event-title';
			this.addChild(_label);
			
			_thumbGroup = Register.ASSETS.getBitmap(_xml.@file) 
			_thumbGroup.y = _label.y + _label.height + 12;
			_thumbGroup.alpha = 0.5;
			this.addChild(_thumbGroup);
			
			_highlightsV = new Vector.<Sprite>();
			var gridAr:Array = Grid.create(5,3,100,56,1,1);
			for (var i:uint = 0; i < Number(_xml.@total); i++) {
				//00A3DA
				var tHighlight:Sprite = _createHighlight();
				tHighlight.x = gridAr[i].x;
				tHighlight.y = gridAr[i].y + _thumbGroup.y;
				TweenMax.to(tHighlight, 0, {autoAlpha:0, x:gridAr[i].x, y:gridAr[i].y + _thumbGroup.y});
				_highlightsV.push(tHighlight);
				this.addChild(tHighlight);
			}
			
			// create menu here
			_menu = new Sprite();
			_removeAll = new Sprite();
			_removeAll.addChild(Register.ASSETS.getBitmap('addMediaDrawer_RemoveAll'));
			TweenMax.to(_removeAll, 0, {autoAlpha:0});
			_menu.addChild(_removeAll);
			
			_addAll = new Sprite();
			_addAll.addChild(Register.ASSETS.getBitmap('addMediaDrawer_AddAll'));
			_addAll.x = _removeAll.width - _addAll.width;
			_menu.addChild(_addAll);
			
			_menu.x = this.width - _menu.width;
			TweenMax.to(_menu, 0, {autoAlpha:0});	
			this.addChild(_menu);
		}
		
		private function _onShowComplete():void {
			_addListeners();
		}
		
		private function _onHideComplete():void {
			
		}
		
		private function _addListeners():void {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			
			_addAll.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
			_addAll.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
			_addAll.addEventListener(MouseEvent.CLICK, _handleMenuItem);
			
			_removeAll.addEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
			_removeAll.addEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
			_removeAll.addEventListener(MouseEvent.CLICK, _handleMenuItem);
		}
		
		private function _removeListeners():void {
			if (this.stage) this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove);
			
			_addAll.removeEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
			_addAll.removeEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
			_addAll.removeEventListener(MouseEvent.CLICK, _handleMenuItem);
			
			_removeAll.removeEventListener(MouseEvent.MOUSE_OVER, _handleMenuItem);
			_removeAll.removeEventListener(MouseEvent.MOUSE_OUT, _handleMenuItem);
			_removeAll.removeEventListener(MouseEvent.CLICK, _handleMenuItem);
		}
		
		private function _showMenu($b:Boolean = true):void {
			if ($b && !_menuShowing) {
				log('Show Menu');
				_menuShowing = true;
				TweenMax.to(_menu, 0.3, {autoAlpha:1, ease:Cubic.easeOut});	
			}
			if (!$b && _menuShowing) {
				log('Hide Menu');
				_menuShowing = false;
				TweenMax.to(_menu, 0.3, {autoAlpha:0, ease:Cubic.easeOut});	
			}
		}
		
		private function _selectAll($b:Boolean = true):void {
			_allSelected = $b;
			for (var i:uint = 0; i < _highlightsV.length; i++) {
				TweenMax.to(_highlightsV[i], 0.3, {autoAlpha:($b) ? 1 : 0, delay:(i * 0.03)});
			}
			
			TweenMax.to(_addAll, 0.3, {tint:null, autoAlpha:($b) ? 0 : 1, ease:Cubic.easeOut});	
			TweenMax.to(_removeAll, 0.3, {tint:null, autoAlpha:($b) ? 1 : 0, ease:Cubic.easeOut});				
			
			dispatchEvent(new AddMediaDrawerEvent(($b) ? AddMediaDrawerEvent.SELECT_ALL : AddMediaDrawerEvent.DESELECT_ALL));
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			//_addListeners();
		}
		
		private function _handleMouseMove($e:MouseEvent):void {			
			//log('_handleMouseMove');
			var p:Point = localToGlobal(new Point(mouseX,mouseY));
			//log('hit test: '+this.hitTestPoint(p.x,p.y));
			if (this.hitTestPoint(p.x,p.y)){
				_showMenu();
				TweenMax.to(_thumbGroup, 0.3, {alpha:1, ease:Cubic.easeOut});
				TweenMax.to(_label, 0.3, {tint:0xFFFFFF, ease:Cubic.easeOut});
				
			} else {
				_showMenu(false);
				TweenMax.to(_thumbGroup, 0.3, {alpha:0.5, ease:Cubic.easeOut});
				TweenMax.to(_label, 0.3, {tint:null, ease:Cubic.easeOut});
			}
		}
		
		private function _handleMenuItem($e:MouseEvent):void {
			var tMenuItem:Sprite = Sprite($e.target);
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(tMenuItem, 0, {tint:0x00A3DA});	
					break;
				
				case MouseEvent.MOUSE_OUT:
					TweenMax.to(tMenuItem, 0.3, {tint:null, ease:Cubic.easeOut});	
					break;
				
				case MouseEvent.CLICK:
					if (tMenuItem == _addAll){
						log('Add All!');
						/*TweenMax.to(tMenuItem, 0.3, {tint:null, autoAlpha:0, ease:Cubic.easeOut});	
						TweenMax.to(_removeAll, 0.3, {tint:null, autoAlpha:1, ease:Cubic.easeOut});*/
						_selectAll();
					} else {
						log('Remove All!');
						/*TweenMax.to(tMenuItem, 0.3, {tint:null, autoAlpha:0, ease:Cubic.easeOut});	
						TweenMax.to(_addAll, 0.3, {tint:null, autoAlpha:1, ease:Cubic.easeOut});*/
						_selectAll(false);
					}
					break;
			}
		}
		
		
		/*********************** HELPERS **********************/
		private function _createHighlight():Sprite {
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x00A3DA, 0.5);
			s.graphics.drawRect(0,0,100,56);
			s.graphics.endFill();
			
			var check:Bitmap = Register.ASSETS.getBitmap('addMediaDrawer_Check');
			check.x = (s.width - check.width) * 0.5;
			check.y = (s.height - check.height) * 0.5;
			s.addChild(check);
			
			return s;
		}

	}
}