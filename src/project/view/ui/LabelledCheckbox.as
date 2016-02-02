package project.view.ui{
	
	// Flash
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	// CandyLizard
	import display.Sprite;
	import text.TextFormat;
	import text.TextUtilities;
	import utils.Register;
	
	
	
	public class LabelledCheckbox extends Sprite{

		/********************* CONSTANTS **********************/
		
		
		
		/******************* PRIVATE VARS *********************/
		private var _showing:Boolean = true;
		private var _selected:Boolean = false;
		
		private var _labelText:String;
		
		private var _fmt:TextFormat;
		private var _tf:TextField;
		
		private var _defaultImg:Bitmap;
		private var _checkedImg:Bitmap;
		
		private var _container:Sprite;

		
		
		/***************** GETTERS & SETTERS ******************/
		public function get showing():Boolean { return _showing; }
		
		public function get labelText():String { return _labelText; }

		public function get selected():Boolean { return _selected; }
		public function set selected($value:Boolean):void { _select($value); }

		
				
		/******************** CONSTRUCTOR *********************/
		public function LabelledCheckbox($id:String, $labelText:String){
			super();
			verbose = true;
			
			id = $id;
			
			_labelText = $labelText;
			
			_container = new Sprite();
			addChild(_container);
			
			_fmt = new TextFormat();
			_fmt.name = 'settings-text';
		
			_draw();
		}		
		
		
		
		/******************** PRIVATE API *********************/
		private function _draw():void{
			log('ƒ _draw');
			
			_defaultImg = Register.ASSETS.getBitmap('checkbox_default');
			_checkedImg = Register.ASSETS.getBitmap('checkbox_checked');
			
			_tf = TextUtilities.dynamicTextField({textFormat: _fmt, autoSize:'center', wordWrap:false, multiline:false, embedFonts:true});
			_tf.antiAliasType = 'normal';
			_tf.text = _labelText;			
			_tf.x = _defaultImg.x + _defaultImg.width + 5;
			addChild(_tf);
			
			_defaultImg.y = (_tf.height - _defaultImg.height) * 0.5 - 3;
			
			_checkedImg.x = _defaultImg.x;
			_checkedImg.y = _defaultImg.y;
			
			_container.addChild(_defaultImg);
			_container.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
		}
		
		private function _select($b:Boolean):void {
			if ($b && !_selected) {
				_selected = true;
				_container.addChild(_checkedImg);
				_container.removeChild(_defaultImg);
			} 
			if (!$b && _selected) {
				_selected = false;
				_container.addChild(_defaultImg);
				_container.removeChild(_checkedImg);
			}
		}
		
		
		
		/******************** PUBLIC API *********************/
		
		

		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);			
			_draw();
		}		
		
		protected function _mouseHandler($e:MouseEvent):void{
			switch($e.type){
				case MouseEvent.MOUSE_DOWN:
					_select(!_selected);
					break;
				
			}
		}	
		
		
		
		
		/********************* HELPERS ***********************/	
	}
}