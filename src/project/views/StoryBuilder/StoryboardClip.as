package project.views.StoryBuilder {

	// Flash
import components.controls.Label;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
import flash.geom.Point;

import project.events.PreviewEvent;

// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;

	// Framework
    //import components.controls.Label;
	import display.Sprite;
	import utils.Register;

	// Project
	import project.events.StoryboardManagerEvent;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;
	import project.views.StoryBuilder.ui.SourceClipHighlight;



	public class StoryboardClip extends Sprite {

		/******************* PRIVATE VARS *********************/
		private var _holder:Sprite;
        private var _curFileName:String;
        private var _hiliteFileName:String;
        private var _firstFileName:String;
		private var _prevImageName:String;
		private var _nextImageName:String;
		private var _hiliteFrameNum:Number;
		private var _mask:Shape;
		private var _maskXML:XMLList;
		private var _marker:StoryboardClipMarker;
		private var _hilite:SourceClipHighlight;
        private var _index:uint;
        private var _scrubber:Shape;
        private var _deleteIcon:Sprite = new Sprite();
        private var _editIcon:Sprite = new Sprite();
        private var _tf:Label;
        private var _title:String;
        private var _outline:Sprite;

        private static const _timelineWidth:Number = 1082;
        private static const _timelineLength:Number = 30; // the fixed example length (in seconds) for the timeline



		/***************** GETTERS & SETTERS ******************/
        public function get curFileName():String { return _curFileName; }
        public function get hiliteFileName():String { return _hiliteFileName; }
        public function get firstFileName():String { return _firstFileName; }
        public function get outline():Sprite { return _outline; }
        public function get maskShape():Shape { return _mask; }
        public function get hilite():SourceClipHighlight { return _hilite; }
        public function get deleteIcon():Sprite { return _deleteIcon; }
        public function get editIcon():Sprite { return _editIcon; }
        public function get marker():StoryboardClipMarker { return _marker; }
        public function get hiliteFrameNum():Number { return _hiliteFrameNum; }

        public function set maskXML($value:XMLList):void { _maskXML = $value;  _updateClipUI()}

        public function get index():uint { return _index; }
        public function set index($value:uint):void { _index = $value; _updateIndexTF(); }

        public function get clipLength():Number { return (_mask.width/_timelineWidth) * _timelineLength; }
        public function get hiliteScrubPct():Number { return ((0 - _mask.x) / _mask.width); }// pct of scrub where the hilite is placed
        public function get clipStartFrame():Number { return (_hiliteFrameNum - Math.round((clipLength * hiliteScrubPct) * 4));}

        /******************** CONSTRUCTOR *********************/
		public function StoryboardClip($xml:XML, $frameNum:Number, $hilite:SourceClipHighlight) {
			super();

			verbose = true;

			_hilite = $hilite;
            _hiliteFrameNum = $frameNum;
            _title = $xml.@title;

            _hiliteFileName = _title + '_' + _addLeadingZeros(_hiliteFrameNum);
            log('_hiliteFrameNum: '+_hiliteFrameNum+' | _hiliteFileName: '+_hiliteFileName);

            _firstFileName = _title + '_' + _addLeadingZeros(1);

			var sourceClipLength:Number = Number($xml.@length);

			var _prevFrameNum:Number = _hiliteFrameNum - 20;
			if (_prevFrameNum < 1) _prevFrameNum = 1;
			_prevImageName = $xml.@title + '_' + _addLeadingZeros(_prevFrameNum);

			var _nextFrameNum:Number = _hiliteFrameNum + 20;
			if (_nextFrameNum > sourceClipLength) _nextFrameNum = sourceClipLength;
			_nextImageName = $xml.@title + '_' + _addLeadingZeros(_nextFrameNum);

			_holder = new Sprite();
            _holder.mouseEnabled = false;
            _holder.mouseChildren = false;
			addChild(_holder);

			_mask = new Shape();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.drawRect(0,0,1,94);
			_mask.graphics.endFill();
			addChild(_mask);
			_holder.mask = _mask;

            _outline = new Sprite();
            addChild (_outline);
            _outline.visible = false;

            addEventListener(Event.ADDED_TO_STAGE, _onAdded);

			_init();
		}



		/******************** PUBLIC API *********************/
		public function enable():void {
			//_addListeners();
		}

		public function prepareForReveal():void {
			_mask.width = 1;
			_mask.x = 0;
			TweenMax.to(this, 0, {scaleX:1, scaleY:1});
		}

		public function showMarker($immediate:Boolean = false):void {
			// show the marker
			_marker.show($immediate);
			_createAdditionalImages();
		}



		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');

			var tThumb:Bitmap = Register.ASSETS.getBitmap(_hiliteFileName);
			tThumb.width = 174;
			tThumb.height = 98;
			tThumb.x = -tThumb.width * 0.5;
			tThumb.y = -tThumb.height * 0.5;
			_holder.addChild(tThumb);

			_mask.width = tThumb.width;
			_mask.height = tThumb.height;
			_mask.x = tThumb.x;
			_mask.y = tThumb.y;

			_marker = new StoryboardClipMarker();
			addChild(_marker);
            _marker.mouseEnabled = false;
            _marker.mouseChildren = false;
            _marker.buttonMode = false;

            // create the scrubber
            _scrubber = new Shape();
            _scrubber.graphics.beginFill(0xFFFFFF);
            _scrubber.graphics.drawRect(0,0,1,98);
            _scrubber.graphics.endFill();
            _scrubber.x = 0;
            _scrubber.y = -_holder.height * 0.5;
            TweenMax.to(_scrubber, 0, {autoAlpha:0});
            addChild(_scrubber);

            // create the nav icons
            var __bg:Shape;
            var __icon:Bitmap;

            _editIcon = new Sprite();
            _editIcon.name = 'edit';
            __bg = new Shape();
            __bg.graphics.beginFill(0x000000);
            __bg.graphics.drawRect(0,0,24,24);
            __bg.graphics.endFill();
            __bg.alpha = 1;
            __bg.name = 'bg';
            _editIcon.addChild(__bg);
            __icon = Register.ASSETS.getBitmap('StoryboardClip_Edit');
            __icon.x = (__bg.width - __icon.width)/2;
            __icon.y = (__bg.height - __icon.height)/2;
            _editIcon.addChild(__icon);
            TweenMax.to(_editIcon, 0, {x:0, y:_mask.y ,autoAlpha:0});
            addChild(_editIcon);
            _editIcon.mouseEnabled = true;
            _editIcon.mouseChildren = false;
            _editIcon.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
            _editIcon.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
            _editIcon.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);

            _deleteIcon = new Sprite();
            _deleteIcon.name = 'delete';
            __bg = new Shape();
            __bg.graphics.beginFill(0x000000);
            __bg.graphics.drawRect(0,0,24,24);
            __bg.graphics.endFill();
            __bg.alpha = 1;
            __bg.name = 'bg';
            _deleteIcon.addChild(__bg);
            __icon = Register.ASSETS.getBitmap('StoryboardClip_Delete');
            __icon.x = (__bg.width - __icon.width)/2;
            __icon.y = (__bg.height - __icon.height)/2;x
            /*__icon.x = 2;
            __icon.y = 2;*/
            _deleteIcon.addChild(__icon);
            TweenMax.to(_deleteIcon, 0, {x:_editIcon.x, y:_editIcon.y + _editIcon.height + 1, autoAlpha:0});
            addChild(_deleteIcon);
            _deleteIcon.mouseEnabled = true;
            _deleteIcon.mouseChildren = false;
            _deleteIcon.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
            _deleteIcon.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
            _deleteIcon.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);

            log(' new icon x: '+_deleteIcon.x);

           /* _outline.graphics.lineStyle(2, 0x00A3DA, 1, false, 'none', 'square');
            _outline.graphics.moveTo(0,0);
            _outline.graphics.lineTo(_mask.width,0);
            _outline.graphics.lineTo(_mask.width,_mask.height);
            _outline.graphics.lineTo(0,_mask.height);
            _outline.graphics.lineTo(0,0);
            _outline.x = _mask.x;
            _outline.y = -_holder.height/2;*/

            _drawOutline();

            //_drawOutline();
            //_addListeners();

            _tf = new Label();
            _tf.mouseEnabled = false;
            _tf.mouseChildren = false;
            _tf.text = _index.toString();
            _tf.autoSize = 'left';
            _tf.textFormatName = 'media-content-title';
            _tf.visible = false;
            addChild(_tf);

        }

        private function _updateClipUI():void {
            /*log('_updateClipUI');
            log(' new icon x: '+(Number(_maskXML.@left) + Number(_maskXML.@width) - _deleteIcon.width));*/
            /*TweenMax.to(_deleteIcon, 0, {x:_editIcon.x, y:_editIcon.y + _editIcon.height + 1 ,autoAlpha:0});
            TweenMax.to(_editIcon, 0, {x:Number(_maskXML.@left) + Number(_maskXML.@width) - _editIcon.width, y:_mask.y, autoAlpha:0});*/

            TweenMax.to(_deleteIcon, 0, {x:Number(_maskXML.@left) + Number(_maskXML.@width) - _deleteIcon.width, y:_mask.y ,autoAlpha:0});
            TweenMax.to(_editIcon, 0, {x:_deleteIcon.x - _editIcon.width - 1, y:_mask.y, autoAlpha:0});

            //_drawOutline();
        }

        private function _updateIndexTF():void{
            _tf.text = _index.toString();
        }

        private function _drawOutline():void {
            log('_drawOutline');


            var __line:Sprite;

            __line = new Sprite();
            /*_outline.graphics.lineStyle(3, 0x00A3DA, 1, false, 'none');
            _outline.graphics.moveTo(0,0);
            _outline.graphics.lineTo(_mask.width,0);
            _outline.graphics.lineTo(_mask.width,_mask.height);
            _outline.graphics.lineTo(0,_mask.height);
            _outline.graphics.lineTo(0,0);*/
            //_outline.visible = false;
            //_outline.addChild(__line);

            // top
            __line = new Sprite();
            __line.name = 't';
            __line.graphics.beginFill(0x00A3DA);
            __line.graphics.drawRect(0,0,_mask.width,3);
            __line.graphics.endFill();
            _outline.addChild(__line);

            // btm
            __line = new Sprite();
            __line.name = 'b';
            __line.graphics.beginFill(0x00A3DA);
            __line.graphics.drawRect(0,0,_mask.width,3);
            __line.graphics.endFill();
            __line.y = _mask.height - 3;
            _outline.addChild(__line);

            // left
            __line = new Sprite();
            __line.name = 'l';
            __line.graphics.beginFill(0x00A3DA);
            __line.graphics.drawRect(0,0,3,_mask.height - 6);
            __line.graphics.endFill();
            __line.y = 3;
            _outline.addChild(__line);

            // right
            __line = new Sprite();
            __line.name = 'r';
            __line.graphics.beginFill(0x00A3DA);
            __line.graphics.drawRect(0,0,3,_mask.height - 6);
            __line.graphics.endFill();
            __line.x = _outline.width - 3;
            __line.y = 3;
            _outline.addChild(__line);

            _outline.x = _mask.x;
            _outline.y = -_holder.height/2;


        }

		private function _createAdditionalImages():void {
			// add the prev and next thumbs;
			var prevThumb:Bitmap = Register.ASSETS.getBitmap(_prevImageName);
			prevThumb.width = 174;
			prevThumb.height = 98;
			prevThumb.x = -prevThumb.width - (prevThumb.width * 0.5);
			prevThumb.y = -prevThumb.height * 0.5;
			_holder.addChild(prevThumb);

			var nextThumb:Bitmap = Register.ASSETS.getBitmap(_nextImageName);
			nextThumb.width = 174;
			nextThumb.height = 98;
			nextThumb.x = (nextThumb.width * 0.5);
			nextThumb.y = -nextThumb.height * 0.5;
			_holder.addChild(nextThumb);

            showAdditionalImages();
        }

        public function showAdditionalImages($speed:Number = 0.5):void {
            //log('ƒ showAdditionalImages: '+$speed);
            //log('\tmask - left: '+_maskXML.@left+' | width: '+_maskXML.@width);
            if (x != Number(_maskXML.@left) || width != Number(_maskXML.@width)) {
                TweenMax.to(_mask, $speed, {x:Number(_maskXML.@left), width:Number(_maskXML.@width), ease:Expo.easeInOut});
                TweenMax.to(_outline, $speed, {x:Number(_maskXML.@left), ease:Expo.easeInOut});
                TweenMax.to(_outline.getChildByName('t'), $speed, {width:Number(_maskXML.@width), ease:Expo.easeInOut});
                TweenMax.to(_outline.getChildByName('b'), $speed, {width:Number(_maskXML.@width), ease:Expo.easeInOut});
                TweenMax.to(_outline.getChildByName('r'), $speed, {x:Number(_maskXML.@width) - 3, ease:Expo.easeInOut});
            }
        }

        public function showNav($b:Boolean = true):void{
            var aTarg:Number = ($b) ? 1 : 0;
            TweenMax.to(_deleteIcon, 0.2, {autoAlpha:aTarg});
            TweenMax.to(_editIcon, 0.2, {autoAlpha:aTarg});
        }

        public function showScrubber($b:Boolean = true, $clear:Boolean = true, $visible:Boolean = true):void{
            if ($b){
                TweenMax.to(_scrubber, 0, {x:this.mouseX, autoAlpha:($visible)?1:0});

                /*
                var __timelineWidth:Number = 1082;
                var __timelineLength:Number = 60; // the fixed example length (in seconds) for the timeline
                var __clipLength:Number = (_mask.width/__timelineWidth) * __timelineLength;

                var __hiliteScrubPct:Number = (0 - _mask.x) / _mask.width; // pct of scrub where the hilite is placed
                var __clipStartFrame:Number = _hiliteFrameNum - Math.round((__clipLength * __hiliteScrubPct) * 4); // where 4 is the amount of fps in this prototype
                */


                /*
                //****************
                var __curScrubPct:Number = (_scrubber.x - _mask.x) / _mask.width; // pct relative to mask width
                var __curFrameNum:Number = clipStartFrame + Math.round((clipLength-1) * 4 * __curScrubPct);
                log('1 clipLength: '+clipLength+' | hiliteScrubPct: '+hiliteScrubPct+' | clipStartFrame: '+clipStartFrame+' | curScrubPct: '+__curScrubPct+' | curFrameNum: '+__curFrameNum);

                _curFileName = _title+'_'+_addLeadingZeros(__curFrameNum);
                //dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW, true, {filename:_curFileName}));
                */

                dispatchEvent(new PreviewEvent(PreviewEvent.PREVIEW, true, {filename:getFrameUnderObject(_scrubber, false)}));
            }

            if (!$b && _scrubber.alpha == 1) {
                TweenMax.to(_scrubber, 0, {autoAlpha:0});
                if ($clear) {
                    dispatchEvent(new PreviewEvent(PreviewEvent.CLEAR, true));
                }
            }

        }

        public function getFrameUnderObject($obj:DisplayObject, $convert:Boolean = true):String{
            var pt:Point = ($convert) ? globalToLocal(new Point($obj.x,$obj.y)) : new Point($obj.x,$obj.y);
            //log('getFrameUnderObject: '+pt);

            /*
            var __timelineWidth:Number = 1082;
            var __timelineLength:Number = 60; // the fixed example length (in seconds) for the timeline
            var __clipLength:Number = (_mask.width/__timelineWidth) * __timelineLength;

            var __hiliteScrubPct:Number = (0 - _mask.x) / _mask.width; // pct of scrub where the hilite is placed
            var __clipStartFrame:Number = _hiliteFrameNum - Math.round((__clipLength * __hiliteScrubPct) * 4); // where 4 is the amount of fps in this prototype
            */

            var __curScrubPct:Number = (pt.x - _mask.x) / _mask.width; // pct relative to mask width
            var __curFrameNum:Number = clipStartFrame + Math.round((clipLength-1) * 4 * __curScrubPct);
            log('clipLength: '+clipLength+' | hiliteScrubPct: '+hiliteScrubPct+' | clipStartFrame: '+clipStartFrame+' | curScrubPct: '+__curScrubPct+' | curFrameNum: '+__curFrameNum);

            _curFileName = _title+'_'+_addLeadingZeros(__curFrameNum);

            return _curFileName;
        }



        /****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
            dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.ADD_CLIP));
		}

		protected function _handleMouseEvent($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					log('MOUSE_OVER');
                    Sprite($e.target).getChildByName('bg').alpha = 1;
					break;

				case MouseEvent.MOUSE_OUT:
                    log('MOUSE_OUT');
                    Sprite($e.target).getChildByName('bg').alpha = 0.7;
                    break;

				case MouseEvent.MOUSE_UP:
					log('MOUSE_UP');
					break;
			}
		}



		/********************* HELPERS ***********************/
        private static function _addLeadingZeros($num:Number):String {
			var str:String = ($num < 10) ?  '00' + $num.toString() : ($num < 100) ? '0' + $num.toString() : $num.toString();
			return str;
		}
	}
}
