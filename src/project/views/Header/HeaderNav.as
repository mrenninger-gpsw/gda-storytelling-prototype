package project.views.Header {
	
	// Flash
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import display.Sprite;
	
	import project.events.ViewTransitionEvent;
	import project.views.Header.ui.HeaderNavBtn;
	
	import utils.Register;
	
	
		
	public class HeaderNav extends Sprite {

		/********************* CONSTANTS **********************/	
		
		/******************** PRIVATE VARS ********************/
		private var _xml:XMLList;
		private var _activeShape:Shape;
		private var _curNavItem:HeaderNavBtn;
		private var _navItemsV:Vector.<HeaderNavBtn>;
		
		
		
		/***************** GETTERS & SETTERS ******************/			
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function HeaderNav() {
			super();
			verbose = true;
			_xml = Register.PROJECT_XML.content.header.nav;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}

	
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			
		}
		
		public function hide():void {
			
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			//log('items: '+_xml.item.length());
			
			_navItemsV = new Vector.<HeaderNavBtn>();
			
			var bgShape1:Shape = new Shape();
			bgShape1.graphics.beginFill(0x222222);
			bgShape1.graphics.drawRect(0,0,_xml.item.length()*134,36);
			bgShape1.graphics.endFill();
			this.addChild(bgShape1);
			
			var bgShape2:Shape = new Shape();
			bgShape2.graphics.beginFill(0x141414);
			bgShape2.graphics.drawRect(3,3,(_xml.item.length()*134) - 6,30);
			bgShape2.graphics.endFill();
			this.addChild(bgShape2);
			
			_activeShape = new Shape();
			_activeShape.graphics.beginFill(0x222222);
			_activeShape.graphics.drawRect(0,0,134,36);
			_activeShape.graphics.endFill();
			addChild(_activeShape);
			
			for(var i:uint = 0; i < _xml.item.length(); i++) {
				var tNavBtn:HeaderNavBtn = new HeaderNavBtn(_xml.item[i]);
				tNavBtn.x = i * 134;
				tNavBtn.addEventListener(MouseEvent.MOUSE_OVER, _handleNav);
				tNavBtn.addEventListener(MouseEvent.MOUSE_OUT, _handleNav);
				tNavBtn.addEventListener(MouseEvent.CLICK, _handleNav);
				_navItemsV.push(tNavBtn);
				this.addChild(tNavBtn);
			}
			_select(_navItemsV[1]);
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		private function _select($btn:HeaderNavBtn):void {
			_curNavItem = $btn;
			TweenMax.to(_activeShape, 0.3, {x:_curNavItem.x, ease:Cubic.easeInOut});
			TweenMax.to(_curNavItem.label, 0, {tint:0xFFFFFF});

		}
		
		private function _deselect($btn:HeaderNavBtn):void {
			
		}
		
		
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _handleNav($e:MouseEvent):void {
			var tNavItem:HeaderNavBtn = $e.target as HeaderNavBtn;
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					if (_curNavItem != tNavItem) {
						TweenMax.to(tNavItem.label, 0, {tint:0xFFFFFF});
					}
					break;
				
				case MouseEvent.MOUSE_OUT:
					if (_curNavItem != tNavItem) {
						TweenMax.to(tNavItem.label, 0.3, {tint:null, ease:Cubic.easeOut});
					}
					break;
				
				case MouseEvent.CLICK:
					if (_curNavItem != tNavItem) {
						TweenMax.to(_curNavItem.label, 0.3, {tint:null, ease:Cubic.easeOut});
						_select(tNavItem);
						this.stage.dispatchEvent(new ViewTransitionEvent(tNavItem.label.text.toLowerCase()));
					}
					break;
				
			}
		}
	}
}