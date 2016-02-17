package project.views.SettingsOverlay{
	
	// Flash
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	// Greensock
	import com.greensock.TweenMax;
	
	// Framework
	import display.Sprite;
	import text.TextFormat;
	import text.TextUtilities;
	import utils.Register;	
	
	
	
	public class NumericStepper extends Sprite {

		/********************* CONSTANTS **********************/
		
		
		
		/******************* PRIVATE VARS *********************/
		private var _showing:Boolean = true;
		private var _selected:Boolean = false;
		private var _incrementing:Boolean = false;
		
		private var _amount:Number;
		private var _increment:Number = 10;
		
		private var _labelText:String;
		
		private var _fmt:TextFormat;
		private var _tf:TextField;
		
		private var _plusDefault:Bitmap;
		private var _plusActive:Bitmap;
		private var _minusDefault:Bitmap;
		private var _minusActive:Bitmap;
		
		private var _plusBtn:Sprite;
		private var _minusBtn:Sprite;
		
		private var _timer:Timer = new Timer(50)

		
		
		/***************** GETTERS & SETTERS ******************/
		public function get showing():Boolean { return _showing; }
		
		public function get labelText():String { return _tf.text; }
		public function set labelText($value):void { _tf.text = $value; }


		
				
		/******************** CONSTRUCTOR *********************/
		public function NumericStepper($id:String, $value:Number){
			super();
			verbose = true;
			
			id = $id;
			
			_amount = $value;
						
			_fmt = new TextFormat();
			_fmt.name = 'settings-text';
			
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
		
			_draw();
		}		
		
		
		
		/******************** PRIVATE API *********************/
		private function _draw():void{
			log('ƒ _draw');
			
			var _border:Sprite = new Sprite();
			_border.graphics.beginFill(0xB6B6B6);
			_border.graphics.drawRect(0,0,150,26);
			_border.graphics.endFill();
			addChild(_border);
			
			var _bkgd:Sprite = new Sprite();
			_bkgd.graphics.beginFill(0xFFFFFF);
			_bkgd.graphics.drawRect(1,1,148,24);
			_bkgd.graphics.endFill();
			addChild(_bkgd);
			
			_tf = TextUtilities.dynamicTextField({width:150, textFormat:_fmt, autoSize:'none', wordWrap:false, multiline:false, embedFonts:true});
			_tf.text = String(_amount);
			_tf.height = 26;
			_tf.y = 4;
			_tf.selectable = true;
			_tf.type = 'input';
			_tf.restrict = '0-9';
			_tf.addEventListener(Event.CHANGE, _onValueChanged);
			addChild(_tf);
			
			_plusDefault = Register.ASSETS.getBitmap('plus_default');
			_plusActive = Register.ASSETS.getBitmap('plus_active');
			
			_minusDefault = Register.ASSETS.getBitmap('minus_default');
			_minusActive = Register.ASSETS.getBitmap('minus_active');
			
			_plusBtn = new Sprite();
			_plusBtn.id = 'plus';
			addChild(_plusBtn);
			_plusBtn.addChild(_plusDefault);
			_mouseEnable(_plusBtn);
			
			_minusBtn = new Sprite();
			_minusBtn.id = 'minus';
			addChild(_minusBtn);
			_minusBtn.addChild(_minusDefault);
			_mouseEnable(_minusBtn);			
			
			_plusBtn.x = _tf.x + _tf.width - _plusBtn.width - 1;
			_plusBtn.y = (_tf.height * 0.5) - _plusBtn.height + 1;
			_minusBtn.x = _plusBtn.x; 
			_minusBtn.y = (_tf.height * 0.5) - 2;
		}				
		
		private function _mouseEnable($obj:Object):void {
			$obj.buttonMode = true;
			$obj.mouseChildren = false;
			$obj.addEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
			$obj.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
			$obj.addEventListener(MouseEvent.MOUSE_OVER, _mouseHandler);
			$obj.addEventListener(MouseEvent.MOUSE_OUT, _mouseHandler);
		}
		
		private function _incrementValue():void {
			_incrementing = true;
			_amount += _increment;
			_tf.text = String(_amount);
			TweenMax.delayedCall(1, _startTimer);
		}

		private function _decrementValue():void {
			_incrementing = true;
			_amount -= _increment;
			_tf.text = String(_amount);
			TweenMax.delayedCall(1, _startTimer);
		}
		
		private function _startTimer():void {
			_timer.reset();
			_timer.start();
		}

		
		
		/******************** PUBLIC API *********************/
		
		

		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);			
			_draw();
		}		
		
		protected function _mouseHandler($e:MouseEvent):void {
			var btn:Sprite = Sprite($e.target);
			switch($e.type){
				case MouseEvent.MOUSE_DOWN:
					btn.removeChildren();
					btn.addChild(this['_'+btn.id+'Active']);
					if ($e.target.id == 'plus') {
						_incrementValue();
					} else {
						_decrementValue();
					}
					stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
					break;
			}
		}	
		
		private function _onMouseUp($e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			var btn:Sprite = (_incrementing) ? _plusBtn : _minusBtn;
			btn.removeChildren();
			btn.addChild(this['_'+btn.id+'Default']);
			
			TweenMax.killDelayedCallsTo(_startTimer);
			
			_timer.stop();
		}
		
		private function _onTimer($e:TimerEvent):void {
			if (_incrementing) {
				_incrementValue()
			} else {
				_decrementValue();
			}
		}
		
		private function _onValueChanged($e:Event):void {
			log('ƒ_onValueChanged'); 
		}
		
		
		
		/********************* HELPERS ***********************/	
	}
}