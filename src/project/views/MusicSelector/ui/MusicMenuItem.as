package project.views.MusicSelector.ui {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;

	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;

	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;



	public class MusicMenuItem extends Sprite {

		/******************** PRIVATE VARS ********************/
		private var _bkgd:Shape;
		private var _num:uint;
		private var _xml:XML;
		private var _albumArt:MusicMenuItemIcon;
		private var _label:Label;
		private var _playIcon:Sprite;
		private var _pauseIcon:Sprite;
		private var _featuredIcon:Bitmap;
		private var _selected:Boolean = false;
		private var _locked:Boolean;
		private var _featured:Boolean = false;
		private var _title:String;
		private var _bpmMeter:BPMMeter;
		private var _initX:Number;



		/***************** GETTERS & SETTERS ******************/
		public function get num():Number{ return _num; }
		public function get label():Label { return _label; }
		public function get locked():Boolean{ return _locked; }
		public function get featured():Boolean { return _featured; }
		public function get title():String { return _title; }
		public function get bpmMeter():BPMMeter { return _bpmMeter; }
		public function get initX():Number{ return _initX; }
		public function set initX($value:Number):void { _initX = $value; }



		/******************** CONSTRUCTOR *********************/
		public function MusicMenuItem($num:uint) {
			super();
			verbose = true;

			_init($num);
		}



		/********************* PUBLIC API *********************/
		public function select($b:Boolean, $immediate:Boolean = false):void {

			if ($b && !_selected) {
				log('selecting item: '+_num);
				_selected = true;
				_albumArt.select(true);
				TweenMax.to(_bkgd, ($immediate) ? 0: 0.3, {alpha:1, ease:Cubic.easeOut});
				TweenMax.to(_playIcon, ($immediate) ? 0: 0.3, {alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn});
				TweenMax.to(_pauseIcon, ($immediate) ? 0: 0.3, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:($immediate) ? 0: 0.2});
				TweenMax.to(_label, ($immediate) ? 0: 0.3, {tint:0x00A3DA, ease:Cubic.easeOut});
			}

			if (!$b && _selected) {
				log('deselecting item: '+_num);
				_selected = false;
				_albumArt.select(false);
				TweenMax.to(_bkgd, ($immediate) ? 0: 0.3, {alpha:0, ease:Cubic.easeOut});
				TweenMax.to(_playIcon, ($immediate) ? 0: 0.3, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:($immediate) ? 0: 0.2});
				TweenMax.to(_pauseIcon, ($immediate) ? 0: 0.3, {alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn});
				TweenMax.to(_label, ($immediate) ? 0: 0.3, {tint:null, ease:Cubic.easeOut});

			}
		}



		/******************** PRIVATE API *********************/
		protected function _init($num:uint):void {
            _num = $num;
            _xml = Register.PROJECT_XML.content.editor.music.tracks.item[_num];
            _locked = (_xml.@locked == 'true');
            _featured = (_xml.@featured == 'true');
            _title = _xml.@title;

            // Selected Shape
			_bkgd = new Shape();
			_bkgd.graphics.beginFill(0x141414);
			_bkgd.graphics.drawRect(0,0,424,70);
			_bkgd.graphics.endFill();
			_bkgd.alpha = 0;
			this.addChild(_bkgd);

			// MusicMenuItemIcon
			_albumArt = new MusicMenuItemIcon(_xml.@genre.toUpperCase(), _locked);
			_albumArt.x = 14;
			_albumArt.y = 12;
			this.addChild(_albumArt);

			// Title Label
			_label = new Label();
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.text = _xml.@title.toUpperCase();
			_label.autoSize = 'left';
			_label.textFormatName = 'music-item-title';
			_label.x = 74
			_label.y = 16;
			this.addChild(_label);

			// Tags Label
			var tagStr:String = '';
			for (var i:uint = 0; i < _xml.tag.length(); i++) {
				if (i == _xml.tag.length() - 1) {
					tagStr += _xml.tag[i]
				} else {
					tagStr += (_xml.tag[i] + ', ');
				}
			}
			var tagLabel:Label = new Label();
			tagLabel.mouseEnabled = false;
			tagLabel.mouseChildren = false;
			tagLabel.text = tagStr;
			tagLabel.autoSize = 'left';
			tagLabel.textFormatName = 'music-item-tags';
			tagLabel.x = 74;
			tagLabel.y = 36;
			this.addChild(tagLabel);

			/************************************/
			/** parts for the moving bpm meter **/
			/************************************/
			_bpmMeter = new BPMMeter(Number(_xml.@bpm));
			_bpmMeter.scaleX = _bpmMeter.scaleY = 0.1;
			_bpmMeter.x = 338;
			_bpmMeter.y = this.height * 0.5 + 2;
			this.addChild(_bpmMeter);
			/************************************/

			// BPM Label
			var bpmLabel:Label = new Label();
			bpmLabel.mouseEnabled = false;
			bpmLabel.mouseChildren = false;
			bpmLabel.text = _xml.@bpm;
			bpmLabel.autoSize = 'left';
			bpmLabel.textFormatName = 'music-item-bpm';
			bpmLabel.x = _bpmMeter.x + (_bpmMeter.width * 0.5) + 4;
			bpmLabel.y = (this.height - bpmLabel.height) * 0.5;
			this.addChild(bpmLabel);

			// Play Icon
			_playIcon = new Sprite();
			var playIconBM:Bitmap = Register.ASSETS.getBitmap('musicItem_playIcon');
			playIconBM.x = -playIconBM.width * 0.5;
			playIconBM.y = -playIconBM.height * 0.5;
			_playIcon.addChild(playIconBM);
			_playIcon.x = 390 + (_playIcon.width * 0.5);
			_playIcon.y = this.height * 0.5;
			this.addChild(_playIcon);

			// Pause Icon
			_pauseIcon = new Sprite();
			var pauseIconBM:Bitmap = Register.ASSETS.getBitmap('musicItem_pauseIcon');
			pauseIconBM.x = -pauseIconBM.width * 0.5;
			pauseIconBM.y = -pauseIconBM.height * 0.5;
			_pauseIcon.addChild(pauseIconBM);
			_pauseIcon.x = 394 + (_pauseIcon.width * 0.5);
			_pauseIcon.y = this.height * 0.5;
			_pauseIcon.alpha = 0;
			TweenMax.to(_pauseIcon, 0, {alpha:0, scaleX:0, scaleY:0});
			this.addChild(_pauseIcon);

			// Featured Icon
			_featuredIcon = Register.ASSETS.getBitmap('musicItem_featuredIcon');
			_featuredIcon.x = this.width - _featuredIcon.width;
			_featuredIcon.y = 0;
			_featuredIcon.visible = _featured;
			this.addChild(_featuredIcon);

			// Bottom Line
			var line:Shape = new Shape();
			line.graphics.beginFill(0x353535);
			line.graphics.drawRect(0,0,424,1);
			line.graphics.endFill();
			line.y = 70
			this.addChild(line);
		}

		private function _addListeners():void {

		}



		/******************* EVENT HANDLERS *******************/
		protected function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();
		}
	}
}
