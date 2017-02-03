package project.views.StoryBuilder {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
	import flash.geom.Point;

import project.events.SourceClipManagerEvent;

// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;

	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;

	// Project
	import project.events.PreviewEvent;
	import project.views.StoryBuilder;
	import project.views.StoryBuilder.ui.SourceClipHighlight;



	public class SourceClip extends Sprite {

		/******************* PRIVATE VARS *********************/
		private var _num:uint;
		private var _curFrameNum:Number;
		private var _filename:String;
		private var _title:String;
		private var _length:String;
		private var _curFileName:String;
		private var _labels:Array;
		private var _xml:XML;
		private var _holder:Sprite;
		private var _scrubber:Sprite;
		private var _preview:Sprite;
		private var _highlightsV:Vector.<SourceClipHighlight>
		private var _nameTF:Label;
		private var _lengthTF:Label;
		private var _canAddToStoryboard:Boolean = true;



		/***************** GETTERS & SETTERS ******************/
		public function get curFileName():String { return _curFileName; }
		public function set canAddToStoryboard($value):void { _canAddToStoryboard = $value; }



		/******************** CONSTRUCTOR *********************/
		public function SourceClip($num:uint, $xml:XML) {
			super();

			verbose = true;

            addEventListener(Event.ADDED_TO_STAGE, _onAdded);

			_num = $num;

			_xml = $xml;
			_filename = _xml.@filename;
			_title = _xml.@title;
			_length = _xml.@length;

			//log('_filename: '+_filename+' | _title: '+_title+' | _length: '+_length);

			_holder = new Sprite();
			_holder.alpha = 0.2;
			addChild(_holder);

			_init();
		}



		/******************** PUBLIC API *********************/
		public function enable():void {
			_addListeners();
		}



		/******************** PRIVATE API *********************/
		private function _init():void {
			//log('_init');
			_createTimelineThumbs();
		}

		private function _createTimelineThumbs():void {
			//log('_createTimelineThumbs');

			for (var i:uint = 0; i < 4; i++) {

				var frameNum:Number = (i == 0) ? 1 : i * Math.round((Number(_xml.@length) * 4)/4);

				var tThumb:Bitmap = Register.ASSETS.getBitmap(_title+'_'+_addLeadingZeros(frameNum));
				tThumb.width = 128;
				tThumb.height = 72;
				tThumb.x = i * 130;

				_holder.addChild(tThumb);

				//log ('this.width: '+this.width);
			}

			var _bkgdShape:Shape = new Shape();
			_bkgdShape.graphics.beginFill(0xFF00FF,0);
			_bkgdShape.graphics.drawRect(0,0,this.width,this.height);
			_bkgdShape.graphics.endFill();
			_holder.addChildAt(_bkgdShape,0);

			_addLabels();
		}

		private function _addLabels():void {
			//log('_addLabels');

			_nameTF = new Label();
			_nameTF.mouseEnabled = false;
			_nameTF.mouseChildren = false;
			_nameTF.id = 'sourceclip-name';
			_nameTF.text = _title+'.MP4';
			_nameTF.autoSize = 'left';
			_nameTF.textFormatName = 'sourceclip-name';
			_nameTF.x = 10;
			_nameTF.y = 50;
			this.addChild(_nameTF);

			_lengthTF = new Label();
			_lengthTF.mouseEnabled = false;
			_lengthTF.mouseChildren = false;
			_lengthTF.id = 'sourceclip-length';
			_lengthTF.text = _formatDurationString(Number(_xml.@length));;
			_lengthTF.autoSize = 'left';
			_lengthTF.textFormatName = 'sourceclip-length';
			_lengthTF.x = _holder.width - 10 - _lengthTF.width;
			_lengthTF.y = 48;
			this.addChild(_lengthTF);

			_labels = [_nameTF,_lengthTF];

			_createPreview();
		}

		private function _createPreview():void {
			// preview
			_preview = new Sprite();
			_preview.mouseEnabled = false;
			_preview.mouseChildren = false;
			_preview.graphics.beginFill(0xFF00FF,0.2);
			_preview.graphics.drawRect(-64,-36,128,72);
			_preview.graphics.endFill();
			_preview.x = 60;
			_preview.y = 36;
			this.addChild(_preview);
			_preview.alpha = 0;

			// scrubber
			_scrubber = new Sprite();
			_scrubber.mouseEnabled = false;
			_scrubber.mouseChildren = false;
			_scrubber.graphics.beginFill(0xFFFFFF);
			_scrubber.graphics.drawRect(-1.5, 0, 3, 81);
			_scrubber.graphics.endFill();
			_scrubber.alpha = 0;
			_scrubber.x = 132;
			_scrubber.y = -4;
			this.addChild(_scrubber);

			//_addHighlights();

		}

		private function _addHighlights():void {
            log('ƒ _addHighlights');
			_highlightsV = new Vector.<SourceClipHighlight>();
			var highlights:Array = _xml.@highlights.split(',');
			var tHighlight:SourceClipHighlight;
			var tHighlightX:Number;
			for (var i:uint = 0; i < highlights.length; i++) {
				if (Number(highlights[i]) !== 0) {
					tHighlightX = Math.round((Number(highlights[i])/Number(_xml.@length)) * this.width);
					_createSourceClipHighlightAt(tHighlightX);
				}
			}

			if (Number(_xml.@storyboard) !== 0) {
				tHighlightX = Math.round((Number(_xml.@storyboard)/Number(_xml.@length)) * this.width);
				var h:SourceClipHighlight = _createSourceClipHighlightAt(tHighlightX,'blue');
                var frameNum:Number = 1 + Math.round((Number(_length)-1) * 4 * (tHighlightX/_holder.width));
                log('\t dispatching a CREATE_INITIAL_CLIP event');
                dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.CREATE_INITIAL_CLIP, {xml:_xml, curFrameNum:frameNum, hilite:h}));
			}

			_addListeners();
		}

		private function _addListeners():void {
			if (!_holder.hasEventListener(MouseEvent.MOUSE_OVER)) {
				_holder.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
				_holder.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
				_holder.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseEvent);
				_holder.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseEvent);
				_holder.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
			}
		}

		private function _removeListeners():void {
			if (_holder.hasEventListener(MouseEvent.MOUSE_OVER)) {
				_holder.removeEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
				_holder.removeEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
				_holder.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseEvent);
				_holder.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseEvent);
				_holder.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
			}
		}

		private function _addLeadingZeros($num:Number):String {
			var str:String = ($num < 10) ?  '00' + $num.toString() : ($num < 100) ? '0' + $num.toString() : $num.toString();
			return str;
		}

		private function _formatDurationString($num:Number):String {
			var minutes:Number = Math.floor($num/60);
			var minStr:String = (minutes < 10) ? '0' + minutes :  (minutes == 0) ? '00' : minutes.toString();
			var seconds:Number = Math.round($num%60);
			var secStr:String = (seconds < 10) ? '0' + seconds : (seconds == 0) ? '00' : seconds.toString();
			return minStr + ':' + secStr;
		}

		private function _updatePreviewElements():void {
			_scrubber.x = mouseX;

			if (mouseX < (_preview.width * 0.5)) {
				_preview.x = (_preview.width * 0.5);
			} else if (mouseX > _holder.width - (_preview.width * 0.5)) {
				_preview.x = _holder.width - (_preview.width * 0.5);
			} else {
				_preview.x = mouseX;
			}

			var pct:Number = mouseX / _holder.width;
			_curFrameNum = 1 + Math.round((Number(_length)-1) * 4 * pct);

			_curFileName = _title+'_'+_addLeadingZeros(_curFrameNum);

			//log('\tpct: '+pct+' | frameNum: '+ frameNum + ' | _curFileName: '+_curFileName);

			var previewThumb:Bitmap = Register.ASSETS.getBitmap(_curFileName);
			previewThumb.width = 128;
			previewThumb.height = 72;
			previewThumb.x = -64;
			previewThumb.y = -36;

			_preview.removeChildren();
			_preview.addChild(previewThumb);

			dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW,true,{filename:_curFileName}));

		}

		private function _createSourceClipHighlightAt($x:Number, $str:String = 'yellow', $show:Boolean = false):SourceClipHighlight {
			var tHighlight:SourceClipHighlight = new SourceClipHighlight($str);
			tHighlight.x = $x;
			//log('tHighlight.x: '+tHighlight.x);
			tHighlight.y = 36;
			tHighlight.mouseEnabled = false;
			tHighlight.mouseChildren = false;
			this.addChild(tHighlight);
			_highlightsV.push(tHighlight);
			if ($show) tHighlight.show();
			return tHighlight;
		}



		/****************** EVENT HANDLERS *******************/
        protected function _onAdded($e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _addHighlights();
        }

		protected function _handleMouseEvent($e:MouseEvent):void {
            var i:uint;
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					TweenMax.to(_holder, 0, {alpha: 0.65});
					TweenMax.allTo(_labels, 0, {alpha: 0});
					TweenMax.to(_scrubber, 0, {alpha:1});
					TweenMax.to(_preview, 0.3, {alpha:1, scaleX:1.125, scaleY:1.125, ease:Back.easeOut});
					_updatePreviewElements();
					break;

				case MouseEvent.MOUSE_OUT:
					TweenMax.to(_holder, 0.3, {alpha: 0.2, ease:Cubic.easeOut});
					TweenMax.allTo(_labels, 0.3, {alpha: 1, ease:Cubic.easeOut});
					TweenMax.to(_scrubber, 0.3, {alpha:0, ease:Cubic.easeOut});
					TweenMax.to(_preview, 0.2, {alpha:0, scaleX:1, scaleY:1, ease:Cubic.easeIn});
					_curFileName = '';
					for (i = 0; i < _highlightsV.length; i++){ _highlightsV[i].hide(); }
					dispatchEvent(new PreviewEvent(PreviewEvent.CLEAR,true));
					break;

				case MouseEvent.MOUSE_MOVE:
					_scrubber.alpha = 1;
					if (_preview.alpha < 1 && !TweenMax.isTweening(_preview)) TweenMax.to(_preview, 0.3, {alpha:1, scaleX:1.125, scaleY:1.125, ease:Back.easeOut});

					for (i = 0; i < _highlightsV.length; i++){
						if (Math.round(_scrubber.x) >  Math.round(_highlightsV[i].x) - 3 && Math.round(_scrubber.x) < Math.round(_highlightsV[i].x) + 3) {
							_highlightsV[i].show();
						} else {
							_highlightsV[i].hide();
						}
					}
					_updatePreviewElements();
					$e.updateAfterEvent();

					break;

				case MouseEvent.MOUSE_DOWN:
					if (_canAddToStoryboard) TweenMax.to(_preview, 0.2, {scaleX:1, scaleY:1, ease:Cubic.easeOut});
					break;

				case MouseEvent.MOUSE_UP:
					//log('mouseup');
					// duplicate the preview frame and add it to Register.APP at the relative coordinates

					if (_canAddToStoryboard) {
						var p:Point = new Point(_preview.x, _preview.y);

						//log('loc p: '+p);
						//log('l2g p: '+localToGlobal(p));

						var hilight:SourceClipHighlight = _createSourceClipHighlightAt(_scrubber.x,'blue',true);

						var sbClip:StoryboardClip = new StoryboardClip(_xml, _curFrameNum, hilight);
						sbClip.width = 128;
						sbClip.height = 72;
						sbClip.x = localToGlobal(p).x;
						sbClip.y = localToGlobal(p).y;
						(this.parent.parent.parent as StoryBuilder).addClip(sbClip);

						TweenMax.to(_scrubber, 0, {alpha:0});
						TweenMax.to(_preview, 0, {alpha:0});
						_removeListeners();

						TweenMax.delayedCall(0.6, _addListeners);
					}
					break;
			}
		}
	}
}
