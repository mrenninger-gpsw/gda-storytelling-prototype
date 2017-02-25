package project.views {

	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;

	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;

	// Framework
	import display.Sprite;
	import text.TextFormat;
	import text.TextUtilities;
    import utils.Register;

	// Project
	import project.Project;
	import project.views.SettingsOverlay.LabelledCheckbox;
	import project.views.SettingsOverlay.NumericStepper;



	public class SettingsOverlay extends Sprite {

		/******************* PRIVATE VARS *********************/
		private var _bkgd:Sprite;
		private var _panel:Sprite;
		private var _closeBtn:Sprite;
		private var _saveBtn:Sprite;
		private var _closeIcon:Sprite;

		private var _resetZoomCB:LabelledCheckbox;
		private var _zoomPersistCB:LabelledCheckbox;

		private var _diagonalStepper:NumericStepper;
		private var _deltaStepper:NumericStepper;

		private var _curZoomTF:TextField;

		private var _view:Project;

        private var _checkBoxesV:Vector.<LabelledCheckbox>;



		/******************** CONSTRUCTOR *********************/
		public function SettingsOverlay($view:Project){
			super();
			verbose = true;
			log('instantiated');

			_view = $view;

			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}



		/******************** PRIVATE API *********************/
		private function _addListeners():void {
			stage.addEventListener(Event.RESIZE, _onResize);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
			_create();
		}

		private function _create():void {
			log('_create');

			TweenMax.to(this, 0, {autoAlpha:0});

			var _fmt:TextFormat;
			var _tf:TextField;

			_bkgd = new Sprite();
			_bkgd.graphics.beginFill(0x000000, 0.5);
			_bkgd.graphics.drawRect(0, 0, _view.window.width, _view.window.height);
			_bkgd.graphics.endFill();
			addChild(_bkgd);

			_mouseEnable(_bkgd);


			// *********** PANEL ***********
			_panel = new Sprite();
			addChild(_panel);

			var _panelOutline:Shape = new Shape();
			_panelOutline.graphics.beginFill(0x4D4D4D);
			_panelOutline.graphics.drawRoundRect(0, 0, 450, 350, 6, 6);
			_panelOutline.graphics.endFill();
			_panel.addChild(_panelOutline);

			var _panelBkgd:Shape = new Shape();
			_panelBkgd.graphics.beginFill(0xFFFFFF);
			_panelBkgd.graphics.drawRoundRect(1, 1, 449, 349, 5, 5);
			_panelBkgd.graphics.endFill();
			_panel.addChild(_panelBkgd);

			var _ds:DropShadowFilter = new DropShadowFilter(0, 0, 0, 0.8, 16, 16);
			var _filters:Array = new Array();
			_filters.push(_ds);
			_panel.filters = _filters;

			var topBorder:Shape = new Shape;
			topBorder.graphics.lineStyle(1, 0xE5E5E5);
			topBorder.graphics.moveTo(0,0);
			topBorder.graphics.lineTo(_panelBkgd.width, 0);
			topBorder.x = 1;
			topBorder.y = 56;
			_panel.addChild(topBorder);

			var btmBorder:Shape = new Shape;
			btmBorder.graphics.lineStyle(1, 0xE5E5E5);
			btmBorder.graphics.moveTo(0,0);
			btmBorder.graphics.lineTo(_panelBkgd.width, 0);
			btmBorder.x = 1;
			btmBorder.y = _panelBkgd.height - 56;
			_panel.addChild(btmBorder);
			// *****************************


			// ********* CLOSE ICON ********
			_closeIcon = new Sprite();
			_fmt = new TextFormat();
			_fmt.name = 'settings-closeIcon';
			_tf = TextUtilities.dynamicTextField({width:20, textFormat:_fmt, wordWrap:false, multiline:false, embedFonts:true});
			_tf.text = 'x';
			_closeIcon.addChild(_tf);

			var bgshape:Shape = new Shape();
			bgshape.graphics.beginFill(0xFF00FF, 0);
			bgshape.graphics.drawRect(0, 0, _closeIcon.width, _closeIcon.height);
			bgshape.graphics.endFill();
			_closeIcon.addChild(bgshape);

			_closeIcon.x = _panel.width - _closeIcon.width - 20;
			_closeIcon.y = 20;
			_closeIcon.alpha = 0.5;

			_panel.addChild(_closeIcon);
			_mouseEnable(_closeIcon);
			// *****************************


			// *********** TITLE ***********
			_fmt = new TextFormat();
			_fmt.name = 'settings-title';
			_tf = TextUtilities.dynamicTextField({textFormat:_fmt, wordWrap:false, multiline:false, embedFonts:true});
			_tf.text = 'Settings';
			_tf.x = 20;
			_tf.y = (56 - _tf.height) * 0.5 + 3;
			_panel.addChild(_tf);
			// *****************************


			// ********** SAVE BTN *********
			_saveBtn = new Sprite();
			_fmt = new TextFormat();
			_fmt.name = 'settings-save';
			_tf = TextUtilities.dynamicTextField({textFormat:_fmt, wordWrap:false, multiline:false, embedFonts:true});
			_tf.text = 'Save Settings';

			_saveBtn.graphics.beginFill(0x3580BB);
			_saveBtn.graphics.drawRoundRect(0, 0, _tf.width + 20, _tf.height + 10, 6, 6);
			_saveBtn.graphics.endFill();

			var saveBtnBkgd:Shape = new Shape();
			saveBtnBkgd.graphics.beginFill(0x428DC8);
			saveBtnBkgd.graphics.drawRoundRect(0, 0, _tf.width + 18, _tf.height + 8, 5, 5);
			saveBtnBkgd.graphics.endFill();
			saveBtnBkgd.x = saveBtnBkgd.y = 1;
			_saveBtn.addChild(saveBtnBkgd);

			_tf.x = (_saveBtn.width - _tf.width) * 0.5;
			_tf.y = (_saveBtn.height - _tf.height) * 0.5 + 2;
			_saveBtn.addChild(_tf);

			_saveBtn.x = _panel.width - _saveBtn.width - 20;
			_saveBtn.y = btmBorder.y + (56 - _saveBtn.height) * 0.5;

			_panel.addChild(_saveBtn);
			_mouseEnable(_saveBtn);
			// *****************************


			// ********* CLOSE BTN *********
			_closeBtn = new Sprite();
			_fmt = new TextFormat();
			_fmt.name = 'settings-text';
			_tf = TextUtilities.dynamicTextField({textFormat:_fmt, wordWrap:false, multiline:false, embedFonts:true});
			_tf.text = 'Close';

			_closeBtn.graphics.beginFill(0xCCCCCC);
			_closeBtn.graphics.drawRoundRect(0, 0, _tf.width + 20, _tf.height + 10, 6, 6);
			_closeBtn.graphics.endFill();

			var closeBtnBkgd:Shape = new Shape();
			closeBtnBkgd.graphics.beginFill(0xFFFFFF);
			closeBtnBkgd.graphics.drawRoundRect(0, 0, _tf.width + 18, _tf.height + 8, 5, 5);
			closeBtnBkgd.graphics.endFill();
			closeBtnBkgd.x = closeBtnBkgd.y = 1;
			_closeBtn.addChild(closeBtnBkgd);

			_tf.x = (_closeBtn.width - _tf.width) * 0.5;
			_tf.y = (_closeBtn.height - _tf.height) * 0.5 + 2;
			_closeBtn.addChild(_tf);

			_closeBtn.x = _saveBtn.x - _closeBtn.width - 10;
			_closeBtn.y = _saveBtn.y;

			_panel.addChild(_closeBtn);
			_mouseEnable(_closeBtn);
			// *****************************

            _checkBoxesV = new <LabelledCheckbox>[];
            var __cb:LabelledCheckbox;
            __cb = new LabelledCheckbox('resetZoomOnClipAddDelete', 'AutoZoom to 100% when adding/deleting Moments');
            __cb.x = 20;
            __cb.y = topBorder.y + 20;
            __cb.selected = Register.DATA[__cb.id];
            _panel.addChild(__cb);
            _checkBoxesV.push(__cb);

            __cb = new LabelledCheckbox('autoScrollToStartOnClipAddDelete', 'AutoScroll to :00 when adding/deleting Moments');
            __cb.x = 20;
            __cb.y = _checkBoxesV[_checkBoxesV.length - 1].y + _checkBoxesV[_checkBoxesV.length - 1].height + 20;
            __cb.selected = Register.DATA[__cb.id];
            _panel.addChild(__cb);
            _checkBoxesV.push(__cb);

            /*__cb = new LabelledCheckbox('autoScrollToEndOnClipAdd', 'AutoScroll to end when adding Moments', true);
            __cb.x = 20;
            __cb.y = _checkBoxesV[_checkBoxesV.length - 1].y + 20;
            __cb.selected = Register.DATA[__cb.id];
            _panel.addChild(__cb);
            _checkBoxesV.push(__cb);*/

			_onResize();

			_show();
		}

		private function _mouseEnable($obj:Object, $b:Boolean = true):void {
			$obj.buttonMode = $b;
			if ($b) {
				$obj.mouseChildren = false;

				$obj.addEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
				$obj.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
				$obj.addEventListener(MouseEvent.MOUSE_OVER, _mouseHandler);
				$obj.addEventListener(MouseEvent.MOUSE_OUT, _mouseHandler);
			} else {
				$obj.removeEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
				$obj.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
				$obj.removeEventListener(MouseEvent.MOUSE_OVER, _mouseHandler);
				$obj.removeEventListener(MouseEvent.MOUSE_OUT, _mouseHandler);
			}
		}

		private function _show():void {
			TweenMax.to(this, 0.5, {autoAlpha:1, ease:Cubic.easeOut, onComplete:_onShowComplete});
		}

		private function _onShowComplete():void {
			dispatchEvent(new Event('Showing'));
		}

		private function _hide():void {
			//stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
			TweenMax.to(this, 0.3, {autoAlpha:0, ease:Cubic.easeOut, onComplete:_onHideComplete});
		}

		private function _onHideComplete():void {
			dispatchEvent(new Event('Hidden'));
            log('DATA')
            for (var i:Object in Register.DATA){
                log('\t'+i+': '+Register.DATA[i]);
            }
		}

		private function _save():void {
			log('ƒsave');
            for (var i:uint = 0; i < _checkBoxesV.length; i++){
                Register.DATA[_checkBoxesV[i].id] =  _checkBoxesV[i].selected;
            }
            _hide();
		}



		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();
		}

		private function _onResize($e:Event = null):void{
			_bkgd.x = 0;
			_bkgd.y = 0;
			_bkgd.width = _view.window.width;
			_bkgd.height = _view.window.height;

			_panel.x = (_view.window.width - _panel.width) * 0.5;
			_panel.y = (_view.window.height- _panel.height) * 0.5;

		}

		/*private function _keyDownHandler($e:KeyboardEvent):void {
			log('ƒ _keyDownHandler: ' + $e.keyCode);
			switch ($e.keyCode) {
				case Keyboard.ESCAPE:
					_hide();
					break;
			}
		}*/

		protected function _mouseHandler($e:MouseEvent):void {
			switch($e.type){
				case MouseEvent.MOUSE_OVER:
					log($e.target);
					switch ($e.target) {
						case _closeIcon:
							$e.target.alpha = 1;
							break;

						case _closeBtn:
							TweenMax.to($e.target.getChildAt(0), 0, {tint:0xE6E6E6});
							break;

						case _saveBtn:
							TweenMax.to($e.target.getChildAt(0), 0, {tint:0x3073A8});
							break;
					}
					break;

				case MouseEvent.MOUSE_OUT:
					switch ($e.target) {
						case _closeIcon:
							$e.target.alpha = 0.5;
							break;

						case _closeBtn:
							TweenMax.to($e.target.getChildAt(0), 0, {tint:null});
							break;

						case _saveBtn:
							TweenMax.to($e.target.getChildAt(0), 0, {tint:null});
							break;
					}
					break;

				case MouseEvent.MOUSE_DOWN:
					_mouseEnable($e.target, false);
					switch ($e.target) {
						case _saveBtn:
							_save();
							break;

						default:
							_hide();
							break;
					}
					break;

				case MouseEvent.MOUSE_UP:
					switch ($e.target) {

					}
					break;

			}
		}




		/********************* HELPERS ***********************/
	}
}
