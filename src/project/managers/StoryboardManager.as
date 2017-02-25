package project.managers {

	// Flash
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Shape;
	import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Mouse;
    import flash.utils.Timer;


    // Greensock
	import com.greensock.TweenMax;
    import com.greensock.easing.Expo;
    import com.greensock.easing.Back;
    import com.greensock.easing.Linear;

	// Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;

	// Project
    import project.events.PreviewEvent;
    import project.events.ScrollEvent;
	import project.events.StoryboardManagerEvent;
    import project.events.ViewTransitionEvent;
    import project.events.ZoomEvent;
    import project.views.StoryBuilder.StoryboardClip;
    import project.views.StoryBuilder.ui.AudioWaveformDisplay;
    import project.views.StoryBuilder.ui.GrabbyMcGrabberson;
    import project.views.StoryBuilder.ui.StoryboardScroller;
    import project.views.StoryBuilder.ui.StoryboardScrubber;
    import project.views.StoryBuilder.ui.Timeline;
    import project.views.StoryBuilder.ui.ZoomSlider;



	public class StoryboardManager extends Sprite {

		/******************** PRIVATE VARS ********************/
		//private var _waveform:Bitmap;
        private var _waveform:AudioWaveformDisplay;
		private var _timeline:Timeline;
		private var _clipHolder:Sprite;
		private var _clipsV:Vector.<StoryboardClip>;
		private var _clipsXML:XMLList;
		private var _musicXML:XMLList;
        private var _dragging:Boolean = false;
        private var _mouseIsDown:Boolean = false;
        private var _longPressTimer:Timer;
        private var _selectedClip:StoryboardClip;
        private var _collidedClipIndex:uint;
        private var _prevDragClipX:Number;
        private var _dragDirectionV:Vector.<String>;
        private var _curDragDirection:String;
        private var _previewScrubber:StoryboardScrubber;
        private var _scrubberDrag:Boolean = false;
        private var _curScrubClip:StoryboardClip;
        private var _grabby:GrabbyMcGrabberson;
        private var _playbackDuration:Number = 30;
        private var _previewIsPlaying:Boolean = false;
        private var _previewWasPlaying:Boolean = false;
        private var _curPlayingClip:StoryboardClip = null;
        private var _zoomMultiplier:Number = 2;
        private var _curZoomLevel:Number = 1;
        private var _scrollbar:StoryboardScroller;
        private var _returnToZero:Sprite;
        private static const WIDTH:Number = 1240; //1104
        private var _lastScrubbedPct:Number;
        private var _curScrollPct:Number = 0;
        private var _curScrubClipVisibleInViewport:Boolean = true;
        private var _zoomSlider:ZoomSlider;



        /***************** GETTERS & SETTERS ******************/
		public function get canAddClips():Boolean { return (_clipHolder.numChildren == 4); }

        private function get _normalizedMaskW():Number {
            return (1240 - ((_clipsV.length - 1) * 10))/_clipsV.length;
        }

        private function get _selectedClipDragRect():Rectangle {
            return new Rectangle(_selectedClip.maskShape.width/2, _selectedClip.y, 1240 - _selectedClip.maskShape.width, 0);
        }

        private function get _curPlaybackPct():Number { return ((_previewScrubber.x - _clipHolder.x)/widthAtCurZoom); }

        public function get curPlayingClipName():String { return _curPlayingClip.clipTitle; }
        public function get curPlayingClip():StoryboardClip{ return _curPlayingClip; }
        public function get curPlayingClipPlayheadTime():Number { return _curPlayingClip.getPlayheadTimeUnderObject(_previewScrubber); }
        public function get widthAtCurZoom():Number { return (_curZoomLevel * WIDTH); }
        public function get curZoomLevel():Number { return _curZoomLevel; }
        public function get clipHolder():Sprite { return _clipHolder; }




        /******************** CONSTRUCTOR *********************/
		public function StoryboardManager() {
			super();
			verbose = true;

			_clipsXML = Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip;
			_musicXML = Register.PROJECT_XML.content.editor.music;

            //_markersV = new Vector.<Shape>();
            _clipsV = new Vector.<StoryboardClip>();
            _dragDirectionV = new Vector.<String>();

			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            addEventListener(StoryboardManagerEvent.ADD_CLIP, _handleAddDeleteEdit);
            addEventListener(StoryboardManagerEvent.DELETE_CLIP, _handleAddDeleteEdit);
            addEventListener(StoryboardManagerEvent.EDIT_CLIP, _handleAddDeleteEdit);

            _longPressTimer = new Timer(500, 1);
            _longPressTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onLongPressTimerComplete);

            _init();
		}



		/********************* PUBLIC API *********************/
		public function addClip($clip:StoryboardClip):void {
            log('ƒ_addClip');
            var locationIndex:uint = (_clipHolder.numChildren < 4) ? 0 : 1;
            log('\t_clipHolder.numChildren: '+_clipHolder.numChildren);
            log('\tlocationIndex: '+locationIndex);
            $clip.x = _curZoomLevel * Number(_clipsXML[_clipHolder.numChildren].location[locationIndex].@position);
			$clip.y = 0;
            $clip.index = _clipHolder.numChildren;
            $clip.maskXML = _clipsXML[_clipHolder.numChildren].location[locationIndex].mask;
            $clip.curZoomLevel = _curZoomLevel;
			_clipsV.push($clip);
            _clipHolder.addChild($clip);
			$clip.showMarker(true);

            _addClipListeners($clip);
		}

        public function createClip($data:Object):void {
            trace('');
            log('ƒ createInitialClip');
            for (var i:Object in $data) {
                log('\t'+i+': '+$data[i]);
                if ($data[i] is XML){
                    for each (var a:Object in $data[i].attributes()) {
                        log('\t\t'+String(a.name())+': '+String(a.valueOf()));
                    }
                }
            }
            trace('');

            var __clip:StoryboardClip = new StoryboardClip($data.xml, $data.curFrameNum, $data.hilite);
            var __locationIndex:uint = (_clipHolder.numChildren < 5) ? 0 : 1;
            __clip.x = _curZoomLevel * Number(_clipsXML[_clipHolder.numChildren].location[__locationIndex].@position);
            log('\tclip x|y: '+__clip.x+' | : '+__clip.y);
            __clip.y = 0;
            __clip.index = _clipHolder.numChildren;
            __clip.maskXML = _clipsXML[__clip.index].location[__locationIndex].mask;
            __clip.showMarker(true);
            _clipsV.push(__clip);
            _clipHolder.addChild(__clip);

            _addClipListeners(__clip);

            var tMarker:Shape = new Shape();
            tMarker.graphics.beginFill(0x00A3DA);
            tMarker.graphics.drawRect(-1,0,2,70);
            tMarker.graphics.endFill();
            tMarker.x = _clipsV[_clipHolder.numChildren - 1].x;

            if (__clip.index == 0) {
                log('createClip calling _selectClip');
                _selectClip(__clip);
                _curPlayingClip = __clip;
            }

            /*_markerHolder.addChild(tMarker);
            _markersV.push(tMarker);*/
            _waveform.addMarker(tMarker);
        }

        public function resetScrubber($repositionAtStart:Boolean = false):void {
            log('ƒ resetScrubber');
            _scrubberDrag = false;
            _previewScrubber.stopDrag();

            if (_curScrubClip) _curScrubClip.showScrubber(false, false);

            if ($repositionAtStart) {
                _previewScrubber.x = _clipHolder.x;

                TweenMax.to([_previewScrubber,_clipHolder,_timeline,_waveform], _curScrollPct * 0.5, {x:20, ease:Expo.easeInOut, delay:0.2});
                TweenMax.to(_returnToZero, _curScrollPct * 0.5, {x:0, ease:Expo.easeInOut});
                TweenMax.delayedCall(0.2, _scrollbar.scrollTo, [0, _curScrollPct * 0.5]);

                /*_previewScrubber.x = _clipHolder.x = _timeline.x = _waveform.x = 20;
                _returnToZero.x = 0;*/
            }

            _lastScrubbedPct = _curPlaybackPct;

            for (var i:uint = 0; i < _clipsV.length; i++){
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber)){
                    //log('\tintersected clip'+i);
                    _curScrubClip = _clipsV[i];
                    if (!_previewIsPlaying) _selectClip(_curScrubClip);
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curScrubClip.getFrameUnderObject(_previewScrubber)}));
                }
            }
        }

        public function playTimeline($b:Boolean = true):void {
            if ($b) {
                _previewIsPlaying = true;
                //_curPlaybackPct = (_previewScrubber.x - _clipHolder.x)/1082;
                log('_curPlaybackPct: '+_curPlaybackPct);
                if (_curPlaybackPct >= 1) {
                    //_curPlaybackPct = 0;
                    _previewScrubber.x = _clipHolder.x;
                }
                _deselectAllClips();
                var __time:Number = (1 - _curPlaybackPct) * _playbackDuration;
                //_progressShape.scaleX = _curPlaybackPct;
                _waveform.progressShape.scaleX = _curPlaybackPct;

                TweenMax.to(_previewScrubber, __time, {x:_clipHolder.x + widthAtCurZoom, ease:Linear.easeNone, onUpdate:_checkForNewClip, onComplete:_onPlaybackComplete});
                //TweenMax.to(_progressShape, __time, {scaleX:1, ease:Linear.easeNone});
                TweenMax.to(_waveform.progressShape, __time, {scaleX:1, ease:Linear.easeNone});
            } else {
                _previewIsPlaying = false;
                _lastScrubbedPct = _curPlaybackPct;

                //TweenMax.killTweensOf([_previewScrubber, _progressShape]);
                TweenMax.killTweensOf([_previewScrubber, _waveform.progressShape]);
                dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curPlayingClip.getFrameUnderObject(_previewScrubber)}));
            }
        }



		/******************** PRIVATE API *********************/
		private function _init():void {

            // new top controls 2/8/17
            var __topControls:Bitmap = Register.ASSETS.getBitmap('Storyboard-TopControls');
            TweenMax.to(__topControls, 0, {x:20, y:15});
            this.addChild(__topControls);
            // ***************


            // ZoomSlider
            _zoomSlider = new ZoomSlider();
            _zoomSlider.x = 1010;
            _zoomSlider.y = 28;
            this.addChild(_zoomSlider);
            _zoomSlider.addEventListener(ZoomEvent.START, _handleZoomEvent);
            _zoomSlider.addEventListener(ZoomEvent.END, _handleZoomEvent);
            _zoomSlider.addEventListener(ZoomEvent.CHANGE, _handleZoomEvent);
            // ***************


            // sprite to contain the StoryboardClips
			_clipHolder = new Sprite();
            TweenMax.to(_clipHolder, 0, {x:20, y:106});
			this.addChild(_clipHolder);
            // ***************


            // main preview playhead
            _previewScrubber = new StoryboardScrubber();
            TweenMax.to(_previewScrubber, 0, {x: _clipHolder.x, y:_clipHolder.y - 49, alpha:0.5});
            this.addChild(_previewScrubber);
            _previewScrubber.mouseEnabled = true;
            _previewScrubber.useHandCursor = true;
            _previewScrubber.addEventListener(MouseEvent.MOUSE_OVER, _handlePreviewScrubberInteraction);
            _previewScrubber.addEventListener(MouseEvent.MOUSE_OUT, _handlePreviewScrubberInteraction);
            _previewScrubber.addEventListener(MouseEvent.MOUSE_DOWN, _handlePreviewScrubberInteraction);
            // ***************


            // return to 0
            _returnToZero = new Sprite();
            _returnToZero.graphics.beginFill(0xFF00FF, 0);
            _returnToZero.graphics.drawRect(0, 0, 20, 98);
            _returnToZero.graphics.endFill();
            _returnToZero.y = 57;
            this.addChild(_returnToZero);
            _returnToZero.addEventListener(MouseEvent.MOUSE_DOWN, _handleReturnToZero);
            // ***************


            // waveform and waveform markers
            _waveform = new AudioWaveformDisplay();
            TweenMax.to(_waveform, 0, {x:_clipHolder.x, y:175});
            this.addChild(_waveform);
            // ***************

            // clip length time indicator
			//_timeline = Register.ASSETS.getBitmap('Storyboard-TimelineNoBumper');
            _timeline = new Timeline();
            TweenMax.to(_timeline, 0, {x:20, y:260});
			this.addChild(_timeline);
            // ***************


            // GrabbyMcGrabberson
            _grabby = new GrabbyMcGrabberson();
            _grabby.mouseChildren = false;
            _grabby.mouseEnabled = false;
            this.addChild(_grabby);
            // ***************


            // ScrollBar
            _scrollbar = new StoryboardScroller(1240);
            _scrollbar.x = 20;
            _scrollbar.y = _timeline.y + _timeline.height + 10;
            _scrollbar.addEventListener(ScrollEvent.SCROLL, _handleScroll);
            _scrollbar.addEventListener(ScrollEvent.START, _handleScroll);
            _scrollbar.addEventListener(ScrollEvent.END, _handleScroll);
            this.addChild(_scrollbar);
            // ***************
        }

		private function _addListeners():void {
			this.stage.addEventListener(StoryboardManagerEvent.FOUR_CLIPS, _onClipAmountChange);
			this.stage.addEventListener(StoryboardManagerEvent.SHOW_MARKER, _showCustomMarker);
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _onClipAmountChange);
		}

        private function _addClipListeners($clip:StoryboardClip):void {
            log('_addClipListeners: '+$clip);
            $clip.mouseChildren = false;
            $clip.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvent);
            $clip.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvent);
            $clip.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseEvent);
            $clip.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseEvent);
            $clip.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
            $clip.doubleClickEnabled = true;
            $clip.addEventListener(MouseEvent.DOUBLE_CLICK, _handleMouseEvent);
        }

		private function _repositionClips($i:uint):void {
            log('ƒ _repositionClips: '+$i);
            //_repositioning = true;
			for (var i:uint = 0; i < 4; i++) {
				var tClip:StoryboardClip = _clipsV[i];
				var tMarker:Shape = _waveform.markers[i];//_markersV[i];
                //log ('\t clip num: '+tClip.index);
                tClip.maskXML = _clipsXML[tClip.index].location[($i == 4) ? 0 : 1].mask;

                var newX:Number = Number(_clipsXML[tClip.index].location[($i == 4) ? 0 : 1].@position);

                var __complete:Function = (i == 3) ? resetScrubber : null;
                var _params:Array = (i == 3) ? [(Register.DATA.autoScrollToStartOnClipAddDelete) ? true : false] : null;
                //TweenMax.allTo([tClip,tMarker], 0.4, {x:newX, ease:Expo.easeInOut}, 0, __complete, _params);
                TweenMax.to(tClip, 0.4, {x:(_curZoomLevel * newX), ease:Expo.easeInOut, onComplete: __complete, onCompleteParams:_params});
                TweenMax.to(tMarker, 0.4, {x:newX, ease:Expo.easeInOut}); // because markers are scaled when zoomed

                tClip.showAdditionalImages(0.4);

                if (tClip.index == 0){
                    log('_repositionClips calling _selectClip');
                    _selectClip(tClip);
                }
			}

		}

        private function _selectClip($clip:StoryboardClip = null):void {
            //log('ƒ _selectClip - _selectedClip == $clip? '+(_selectedClip == $clip));

            if (_selectedClip != $clip){
                log ('selecting new clip: '+$clip.index);
                _selectedClip = $clip;
                for (var i:uint = 0; i < _clipsV.length; i++) {
                    _clipsV[i].outline.visible = (_clipsV[i] == $clip);
                }

                if (_previewIsPlaying) {
                    // do something here to begin video playback of the clip according to the width & x of the mask
                    _curPlayingClip = $clip;
                    dispatchEvent(new PreviewEvent(PreviewEvent.CHANGE_VIDEO));

                }
            }
        }

        private function _deselectAllClips():void {
            _selectedClip = null;
            for (var i:uint = 0; i < _clipsV.length; i++) {
                _clipsV[i].outline.visible = false;
            }
        }

        private function _shiftClipsOnCollisionDetect():void {
            log('ƒ _shiftClipsOnCollisionDetect');
            //_repositioning = true;
            var __locationIndex:uint = (_clipsV.length == 4) ? 0 : 1;
            for (var i:uint = 0; i < _clipsV.length; i++) {
                var tClip:StoryboardClip = _clipsV[i];

                /*
                // for normalized clip widths
                var newX:Number = _normalizedMaskW/2 + (_clipsV[i].index * (_normalizedMaskW + 10));
                if (_clipsV[i] != _selectedClip) TweenMax.to(tClip, 0.4, {x:newX, ease:Expo.easeInOut, onComplete:_repositionComplete});
                */

                // for non normalized widths
                // resize all of the masks according to the clip index
                var __newMaskXML:XMLList = _clipsXML[tClip.index].location[__locationIndex].mask;
                tClip.maskXML = __newMaskXML;//_clipsXML[tClip.index].location[__locationIndex].mask;
                tClip.showAdditionalImages(0.25);

                /*var r:Rectangle = new Rectangle(Number(__newMaskXML.@left), _selectedClip.y, 1240 - Number(__newMaskXML.@width), 0);
                _selectedClip.startDrag(true, r);*/

                // move all the clips according to clip index
                if (_clipsV[i] != _selectedClip) {
                    var newX:Number = _curZoomLevel * Number(_clipsXML[tClip.index].location[__locationIndex].@position);
                    if (newX != tClip.x) TweenMax.to(tClip, 0.25, {x:newX, ease:Expo.easeInOut});
                }
            }

        }

        /*private function _repositionComplete():void {
            log('ƒ _repositionComplete');
            //_repositioning = false;
            resetScrubber();
        }*/

        private function _dragClip($b:Boolean = true):void {
            log('_dragClip: '+$b);
            var i:uint = 0;
            if ($b) {
                _dragging = true;
                log('this.parent: '+this.parent);
                log('this: '+this);
                _clipHolder.addChild(_selectedClip);
                //_normalizeAllClipWidths();

                _prevDragClipX = _selectedClip.x;

                _selectedClip.showScrubber(false);
                _selectedClip.showNav(false);

                _previewScrubber.alpha = 0.1;

                log('_mask.width: '+_selectedClip.maskShape.width);
                log('_mask.x: '+_selectedClip.maskShape.x);

                //var r:Rectangle = new Rectangle(_normalizedMaskW/2, _selectedClip.y, 1240 - _normalizedMaskW, 0);
                //var r:Rectangle = new Rectangle(_selectedClip.maskShape.width/2, _selectedClip.y, 1240 - _selectedClip.maskShape.width, 0);
                var r:Rectangle = new Rectangle(-widthAtCurZoom, _selectedClip.y, widthAtCurZoom * 2, 0);
                log('dragRect: '+r);

                /*if (_clipHolder.getChildByName('dragRect')){
                    _clipHolder.removeChild(_clipHolder.getChildByName('dragRect'));
                }
                var __dragRect:Shape = new Shape();
                __dragRect.graphics.beginFill(0xFF00FF, 0.3);
                __dragRect.graphics.drawRect(r.x, r.y, r.width, 10);
                __dragRect.graphics.endFill();
                __dragRect.name = 'dragRect';
                _clipHolder.addChildAt(__dragRect,_clipHolder.numChildren-1);*/

                //_selectedClip.startDrag(true, r);

                this.addEventListener(Event.ENTER_FRAME, _evalForClipDragScrolling);

                for (i = 0; i < _clipsV.length; i++ ){
                    if (_clipsV[i] != _selectedClip) {
                        TweenMax.to(_clipsV[i], 0.3, {alpha:0.66, ease:Expo.easeOut});
                    } else {
                        TweenMax.to(_selectedClip, 0.3, {scaleX:1.2, scaleY:1.2, ease:Back.easeOut});
                        TweenMax.to(_selectedClip, 0, {x:mouseX, ease:Expo.easeOut});
                        TweenMax.to(_selectedClip.marker, 0.2, {autoAlpha:0, ease:Expo.easeOut});
                    }
                }

            } else {
                _dragging = false;
                _revertAllClipWidths();

                this.removeEventListener(Event.ENTER_FRAME, _evalForClipDragScrolling);

                _selectedClip.stopDrag();

                for (i = 0; i < _clipsV.length; i++ ){
                    if (_clipsV[i] != _selectedClip) {
                        TweenMax.to(_clipsV[i], 0.3, {alpha:1, ease:Expo.easeOut});
                    } else {
                        TweenMax.to(_selectedClip, 0.3, {scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:resetScrubber});
                        TweenMax.to(_selectedClip, 0, {x:mouseX, ease:Expo.easeOut});
                        TweenMax.to(_selectedClip.marker, 0.2, {autoAlpha:1, ease:Expo.easeOut});
                        _selectedClip.outline.visible = false;
                    }
                }
                log('_dragClip(false) calling _selectClip');
                _selectClip(_selectedClip);

                TweenMax.to(_previewScrubber, 0.2, {autoAlpha:0.5, ease:Expo.easeOut});

                // detect
            }
        }

        private function _revertAllClipWidths():void {
            var __locationIndex:uint = (_clipHolder.numChildren < 5) ? 0 : 1;
            for (var i:uint = 0; i < _clipsV.length; i++){
                _clipsV[i].maskXML = _clipsXML[_clipsV[i].index].location[__locationIndex].mask;
                TweenMax.to(_clipsV[i], 0.2, {x:_curZoomLevel * Number(_clipsXML[_clipsV[i].index].location[__locationIndex].@position), ease:Expo.easeOut});
                _clipsV[i].showAdditionalImages(0.2);
            }

        }

        private function _checkClipChildRollover($clip:StoryboardClip):void {
            if (_checkMouseOver($clip.deleteIcon)){
                TweenMax.to($clip.deleteIcon.getChildByName('bg'), 0, {tint:0x00A3DA, alpha:1});
                TweenMax.to($clip.editIcon.getChildByName('bg'), 0, {tint:null, alpha:0.7});
            } else if (_checkMouseOver($clip.editIcon)) {
                TweenMax.to($clip.editIcon.getChildByName('bg'), 0, {tint:0x00A3DA, alpha:1});
                TweenMax.to($clip.deleteIcon.getChildByName('bg'), 0, {tint:null, alpha:0.7});
            } else if (_checkMouseOver($clip.marker.icon)) {
                $clip.marker.activate();
            } else {
                TweenMax.to($clip.editIcon.getChildByName('bg'), 0, {tint:null, alpha:0.7});
                TweenMax.to($clip.deleteIcon.getChildByName('bg'), 0, {tint:null, alpha:0.7});
                $clip.marker.activate(false);
                $clip.hilite.hide();
            }
        }

        private function _dragScrubber($b:Boolean = true):void {
            log('_dragScrubber: '+$b);
            _scrubberDrag = $b;
            _grabby.grab($b);
            if ($b) {
                var r:Rectangle = new Rectangle(20, _previewScrubber.y, widthAtCurZoom, 0);
                _previewScrubber.startDrag(true, r);
                addEventListener(Event.ENTER_FRAME, _trackScrubber);
                TweenMax.to(_previewScrubber, 0, {tint:0xFFFFFF});
            } else {
                TweenMax.to(_previewScrubber, 0, {tint:null});
                resetScrubber();
                removeEventListener(Event.ENTER_FRAME, _trackScrubber);
                if (!_checkMouseOver(_previewScrubber)) {
                    _grabby.show(false);
                    Mouse.show();
                }
            }
        }

        private function _onPlaybackComplete():void {
            log('playbackComplete!!! - scrubber.x: '+_previewScrubber.x+' | clipHolder.x: '+_clipHolder.x+' | widthAtCurZoom: '+widthAtCurZoom);
            _previewIsPlaying = false;
            _curPlaybackPct;// = 1;
            dispatchEvent(new PreviewEvent(PreviewEvent.COMPLETE));
        }

        private function _updatePreviewLockImage():void {
            _lastScrubbedPct = _curPlaybackPct;
            for (var i:uint = 0; i < _clipsV.length; i++){
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber)){
                    _curScrubClip = _clipsV[i];
                    _curPlayingClip = _curScrubClip;
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curScrubClip.getFrameUnderObject(_previewScrubber)}));
                }
            }
        }

        private function _checkForNewClip():void {
            for (var i:uint = 0; i < _clipsV.length; i++) {
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber) && _clipsV[i] != _curPlayingClip) {
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curPlayingClip.getFrameUnderObject(_previewScrubber)}));
                    _curPlayingClip = _clipsV[i];
                    dispatchEvent(new PreviewEvent(PreviewEvent.CHANGE_VIDEO));
                }
            }
        }

        private function _scrollElementsByPercent($pct:Number, $speed:Number = 0):void {
            //log('_scrollElementsByPercent: '+$pct+' | _previewIsPlaying: '+_previewIsPlaying);
            _curScrollPct = $pct;
            TweenMax.to(_timeline, $speed, {x:20 - ((_timeline.tickWidth - 1240) * _curScrollPct)});//_timeline.x = 20 - ((_timeline.tickWidth - 1240) * _curScrollPct);
            TweenMax.to(_waveform, $speed, {x:20 - ((_waveform.width - 1238) * _curScrollPct)});//_waveform.x = 20 - ((_waveform.width - 1238) * _curScrollPct);
            TweenMax.to(_clipHolder, $speed, {x:20 - ((widthAtCurZoom - 1240) * _curScrollPct)});//_clipHolder.x = 20 - (_curScrollPct * (widthAtCurZoom - 1240));
            TweenMax.to(_returnToZero, $speed, {x:0 - ((widthAtCurZoom - 1240) * _curScrollPct)});

            // problem: _previewScrubber is the only thing that needs to be able to move independently during zoom/scrub
            if (!_previewIsPlaying) {
                TweenMax.to(_previewScrubber, $speed, {x:(20 - ((widthAtCurZoom - 1240) * _curScrollPct)) + (widthAtCurZoom * _lastScrubbedPct)});//_previewScrubber.x = _clipHolder.x + (widthAtCurZoom * _lastScrubbedPct);
            } else {
                // if the preview is playing and you change the zoom level, the the distance the _previewScrubber has to cover (and subsequently, the speed at which it moves b/c of the fixed timeline length of 30s) changes

                // stop the movement of _previewScrubber & progressShape
                //TweenMax.killTweensOf([_previewScrubber, _waveform.progressShape]);

                // recalculate the time to complete based on _curPlaybackPct & widthAtCurZoom
                /*
                var __remainingDistance:Number = (1-_curPlaybackPct) * widthAtCurZoom;
                var _remainingTime:Number = (1 - _curPlaybackPct) * _playbackDuration;

                _waveform.progressShape.scaleX = _curPlaybackPct;

                TweenMax.to(_previewScrubber, _remainingTime, {x:(20 - ((widthAtCurZoom - 1240) * _curScrollPct)) + widthAtCurZoom, ease:Linear.easeNone, onUpdate:_checkForNewClip, onComplete:_onPlaybackComplete});
                TweenMax.to(_waveform.progressShape, _remainingTime, {scaleX:1, ease:Linear.easeNone});
                */

            }
        }

        private function _evalClipCollision():void {
            //og('_evalClipCollision');
            for (var i:uint = 0; i < _clipsV.length; i++) {
                var tClip:StoryboardClip = _clipsV[i];
                if (tClip != _selectedClip) {
                    var __intersection:Rectangle = _selectedClip.maskShape.getBounds(this).intersection(tClip.maskShape.getBounds(this));
                    if (__intersection.width > 0){
                        /*log('* clip'+_selectedClip.index+' x clip'+tClip.index);
                        log('\tintersection.width: '+__intersection.width);*/

                        // we determine successful intersection based on a threshhold of 80% of the narrower clip mask width...
                        var __threshholdMet:Boolean = (_selectedClip.maskShape.width >= tClip.maskShape.width) ? __intersection.width > (tClip.maskShape.width * 0.8) : __intersection.width > (_selectedClip.maskShape.width * 0.8);

                        // ... and based on if the clip potentially being swapped is in the direction of intended drag
                        var __canSwap:Boolean = ((_curDragDirection == 'right' && _selectedClip.index < tClip.index) || (_curDragDirection == 'left' && _selectedClip.index > tClip.index));

                        /*
                        log('\t__threshholdMet: '+__threshholdMet);
                        log('\t_selectedClip.x: '+_selectedClip.x+' | _prevDragClipX: '+_prevDragClipX);
                        log('\t_curDragDirection: '+_curDragDirection);
                        log('\t__canSwap: '+__canSwap);
                        */

                        if (__threshholdMet && __canSwap) {
                            log('!!!!!! COLLISION DETECTED AND CAN SWAP !!!!!!');
                            _collidedClipIndex = tClip.index;
                            tClip.index = _selectedClip.index;
                            _selectedClip.index = _collidedClipIndex;
                            _shiftClipsOnCollisionDetect();
                        }
                    }
                }
            }

            _prevDragClipX = _selectedClip.x;
        }




		/******************* EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();
		}

		private function _showCustomMarker($e:StoryboardManagerEvent):void {
			var tMarker:Shape = new Shape();
			tMarker.graphics.beginFill(0x00A3DA);
			tMarker.graphics.drawRect(-1,0,2,2);
			tMarker.graphics.endFill();
			tMarker.x = Number(_clipsXML[4].location[1].@position);
			TweenMax.to(tMarker, 0.3, {height:70, ease:Expo.easeOut});
            _waveform.addMarker(tMarker);
		}

		private function _onClipAmountChange($e:StoryboardManagerEvent):void {
			log('_onClipAmountChange');
            var __delay:Number = (_curZoomLevel > 1 && Register.DATA.resetZoomOnClipAddDelete) ? 0.15: 0;
            switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					//_removeTempMarker();
                    if (Register.DATA.resetZoomOnClipAddDelete) _zoomSlider.zoomTo(1, __delay);
                    TweenMax.delayedCall(__delay, _repositionClips, [4]);
					break;

				case StoryboardManagerEvent.FIVE_CLIPS:
                    if (Register.DATA.resetZoomOnClipAddDelete) _zoomSlider.zoomTo(1, __delay);
                    TweenMax.delayedCall(__delay, _repositionClips, [5]);
					break;
			}
		}

        private function _handleAddDeleteEdit($e:StoryboardManagerEvent):void {
            log('_handleAddDeleteEdit: '+$e.type);
            var clip:StoryboardClip = $e.target as StoryboardClip;
            switch ($e.type){
                case StoryboardManagerEvent.ADD_CLIP:
                    //log('\tADD_CLIP');
                    if (_clipHolder.numChildren == 5) {
                        this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FIVE_CLIPS));
                    }
                    break;

                case StoryboardManagerEvent.DELETE_CLIP:
                    //log('\tDELETE_CLIP');
                    if (_clipHolder.numChildren == 5) {
                        clip.hilite.parent.removeChild(clip.hilite);

                        _clipsV.removeAt(clip.index);
                        _clipHolder.removeChild(clip);

                        _waveform.removeMarker(clip.index);

                        _clipsV = new <StoryboardClip>[];

                        for (var i:uint = 0; i < _clipHolder.numChildren; i++) {
                            var tClip:StoryboardClip = _clipHolder.getChildAt(i) as StoryboardClip;
                            //log ('\t\t\tclip index before: '+tClip.index);
                            if (tClip.index > clip.index){
                                tClip.index --;
                            }
                            //log ('\t\t\tclip index after: '+tClip.index);
                            _clipsV.push(tClip);
                        }

                        this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FOUR_CLIPS));
                    }
                    break;

                case StoryboardManagerEvent.EDIT_CLIP:
                    //log('\tEDIT_CLIP');
                    this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.ADV_EDITOR));
                    break;
            }
        }

        protected function _handleMouseEvent($e:MouseEvent):void {
            //log('_handleMouseEvent - type: ' + $e.type + ' | clip: ' + $e.target);
            if ($e.target is StoryboardClip) {
                var __clip:StoryboardClip = $e.target as StoryboardClip;
                switch ($e.type) {
                    case MouseEvent.MOUSE_OVER:
                        //log('MOUSE_OVER: ' + __clip.index);
                        __clip.showNav();
                        //__clip.hilite.show();
                        _checkClipChildRollover(__clip);
                        break;

                    case MouseEvent.MOUSE_OUT:
                        //log('MOUSE_OUT');
                        __clip.showNav(false);
                        __clip.showScrubber(false);
                        __clip.hilite.hide();
                        __clip.marker.activate(false);
                        break;

                    case MouseEvent.MOUSE_MOVE:
                        //log('MOUSE_MOVE');
                        if (_mouseIsDown && !_dragging) {
                            __clip.showScrubber(false);
                            __clip.showNav(false);
                            if (_longPressTimer.running) _longPressTimer.reset();
                            _dragClip();
                        } else {
                            if (!_dragging) {
                                __clip.showScrubber(true);
                                __clip.showNav(true);
                                _checkClipChildRollover(__clip);
                            } else {
                                __clip.showScrubber(false);
                                __clip.showNav(false);

                                /*// evaluate user drag direction intent
                                if (_dragDirectionV.length == 5) { _dragDirectionV.shift();}
                                _dragDirectionV.push((_selectedClip.x < _prevDragClipX) ? 'left' : 'right');
                                _curDragDirection = _evalDragDirection();

                                // check for collision and swap indices here
                                _evalClipCollision();*/
                            }
                        }

                        break;

                    case MouseEvent.MOUSE_DOWN:
                        log('MOUSE_DOWN');
                        // set a timer here to detect long press
                        _longPressTimer.start();
                        _mouseIsDown = true;
                        //playTimeline(false); // to kill the tweens
                        _selectClip(__clip);
                        //_selectedClip = __clip;
                        dispatchEvent(new PreviewEvent(PreviewEvent.PAUSE));
                        this.stage.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
                        break;

                    case MouseEvent.DOUBLE_CLICK:
                        log('open AdvancedEditor');
                        __clip.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.EDIT_CLIP, true));
                        break;

                    case MouseEvent.MOUSE_UP:
                        this.stage.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
                        log ('MOUSE_UP');
                        _mouseIsDown = false;
                        if (_selectedClip) {
                            if (!_dragging) {
                                if (_longPressTimer.running) _longPressTimer.reset();

                                if (_checkMouseOver(_selectedClip.deleteIcon)) {
                                    log('delete the clip if possible');
                                    __clip.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.DELETE_CLIP, true));
                                } else

                                if (_checkMouseOver(_selectedClip.editIcon)) {
                                    log('open AdvancedEditor');
                                    __clip.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.EDIT_CLIP, true));
                                } else

                                if (_checkMouseOver(_selectedClip.marker.icon)) {
                                    log('activate SourceCLipHilite');
                                    __clip.hilite.show();
                                } else

                                {
                                    log('lock the VideoPreviewArea');
                                    _previewScrubber.x = mouseX;
                                    _lastScrubbedPct = _curPlaybackPct;

                                    _waveform.progressShape.scaleX = _curPlaybackPct;

                                    _onPlaybackComplete(); // to reset playback boolean and tell the VideoPreviewArea to resetControls

                                    Mouse.show();
                                    _grabby.show(false);
                                    _grabby.grab(false);
                                    _dragScrubber(false);

                                    // do something here to alert the preview window to lock on to this location
                                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_selectedClip.curFileName}));


                                }

                            } else {
                                _dragClip(false);
                            }
                        } else {
                            log('is StoryboadClip - currentTarget: '+$e.currentTarget+' | target: '+$e.target+' | type: '+$e.type);
                            if (_scrubberDrag) {
                                log('°°°°°°°°°°°°°°°°°°°°°°°');

                                if ($e.currentTarget != _previewScrubber && $e.target != _previewScrubber) {
                                    //log ('fade _previewScrubber');
                                    TweenMax.to(_previewScrubber, 0.2, {alpha:0.5});
                                }
                                _dragScrubber(false);
                            } else {

                            }
                        }
                        break;
                }
            } else {
                switch ($e.type) {
                    case MouseEvent.MOUSE_UP:
                        this.stage.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
                        log('not StoryboadClip - currentTarget: '+$e.currentTarget+' | target: '+$e.target+' | type: '+$e.type);
                        if (_scrubberDrag) {
                            log('##########################');

                            if ($e.currentTarget != _previewScrubber && $e.target != _previewScrubber) {
                                //log ('fade _previewScrubber');
                                TweenMax.to(_previewScrubber, 0.2, {alpha:0.5});

                            }


                            _grabby.grab(false);
                            _dragScrubber(false);
                        }
                        break;
                }
            }
        }

        private function _onLongPressTimerComplete($e:TimerEvent):void {
            log('_onLongPressTimerComplete');
            if (_selectedClip) {
                _selectedClip.showScrubber(false);
                _selectedClip.showNav(false);
                _dragClip();
            }
        }

        private function _handlePreviewScrubberInteraction($e:MouseEvent):void {
            //log('_handlePreviewScrubberInteraction: '+$e.type);
            switch ($e.type) {
                case MouseEvent.MOUSE_OVER:
                    _previewScrubber.alpha = 1;

                    Mouse.hide();

                    _grabby.show();
                    _grabby.x = this.mouseX;
                    _grabby.y = this.mouseY;
                    _grabby.startDrag();

                    break;

                case MouseEvent.MOUSE_OUT:
                    TweenMax.to(_previewScrubber, 0.2, {alpha:0.5});
                    if (!_scrubberDrag) {
                        Mouse.show();
                        _grabby.show(false);
                        _grabby.stopDrag();
                    } else {
                        // handled on MouseUp
                    }
                    break;

                case MouseEvent.MOUSE_DOWN:
                    this.stage.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);
                    //log('_previewScrubber MOUSE_DOWN');
                    _dragScrubber();

                    playTimeline(false); // to kill the tweens
                    _onPlaybackComplete(); // to reset playback boolean and tell the VideoPreviewArea to resetControls

                    break;

            }
        }

        private function _trackScrubber($e:Event):void {
            _previewScrubber.alpha = 1;

            _grabby.x = this.mouseX;
            _grabby.y = this.mouseY;

            //_curPlaybackPct = (_previewScrubber.x - _clipHolder.x)/1082;
            //_progressShape.scaleX = _curPlaybackPct;
            _waveform.progressShape.scaleX = _curPlaybackPct;

            _updatePreviewLockImage();
        }

        private function _handleReturnToZero($e:MouseEvent):void {
            playTimeline(false);
            resetScrubber(true);

            _updatePreviewLockImage();
        }

        private function _handleZoomEvent($e:ZoomEvent):void {
            $e.stopImmediatePropagation();
            switch ($e.type) {
                case ZoomEvent.START:
                    _curScrubClipVisibleInViewport = (_curScrubClip.maskShape.getBounds(this).right > 0  && _curScrubClip.maskShape.getBounds(this).left < 1280);
                    if (_previewIsPlaying){
                        dispatchEvent(new PreviewEvent(PreviewEvent.PAUSE));// pauses playback here and in the preview window
                        _previewWasPlaying = true;
                    }
                    break;

                case ZoomEvent.END:
                    if (_previewWasPlaying){
                        _previewWasPlaying = false;
                        dispatchEvent(new PreviewEvent(PreviewEvent.PLAY));
                    }
                    break;

                case ZoomEvent.CHANGE:
                    //var _curZoomLevel:Number = 1 + ((_zoomMultiplier - 1) * $e.data.pct); // returns a number between 1 and (pct * _zoomMultiplier)
                    //log('Zooming to: '+__newZoomLevel);

                    _curZoomLevel = 1 + ((_zoomMultiplier - 1) * $e.data.pct); // returns a number between 1 and (pct * _zoomMultiplier)

                    if (_curZoomLevel == 1) _curScrollPct = 0;

                    /*log ('_curZoomLevel: '+_curZoomLevel);
                    log ('_curScrollPct (before): '+_curScrollPct);*/

                    // zoom the different components
                    _timeline.zoom(_curZoomLevel);
                    _waveform.zoom(_curZoomLevel);
                    _scrollbar.zoom(_curZoomLevel);

                    // zoom all of the clips in the _clipHolder
                    for (var i:uint = 0; i < _clipsV.length; i++){
                        var tClip:StoryboardClip = _clipsV[i];
                        tClip.x = _curZoomLevel * Number(_clipsXML[tClip.index].location[(_clipsV.length == 4) ? 0 : 1].@position);
                        tClip.zoom(_curZoomLevel);
                    }

                    var __deltaX:Number = 0;
                    var __newX:Number;

                    // when paused - ensure that _curScrubClip is visible on the timeline and update _curScrollPct accordingly
                    if (!_previewIsPlaying){
                        if (_curScrubClipVisibleInViewport && (_curScrubClip.maskShape.getBounds(this).right > 1280 || _curScrubClip.maskShape.getBounds(this).left < 0)) {
                            if (_curScrubClip.maskShape.getBounds(this).right > 1260) {
                                log ('#### _curScrubClip is beyond right limit ####');
                                //log('_curScrubClip.right: '+_curScrubClip.maskShape.getBounds(this).right);
                                __deltaX = _curScrubClip.maskShape.getBounds(this).right - 1260;
                            } else {
                                log ('#### _curScrubClip is beyond left limit ####');
                                //log('_curScrubClip.left: '+_curScrubClip.maskShape.getBounds(this).left);
                                __deltaX = _curScrubClip.maskShape.getBounds(this).left - 20;
                            }

                            __newX = _clipHolder.x - __deltaX;
                            _curScrollPct = (20 - __newX) / (widthAtCurZoom - 1240);
                        }

                    }
                    //log ('__deltaX: '+__deltaX);
                    //log ('_curScrollPct (before): '+_curScrollPct);
                    if (_curScrollPct > 1) _curScrollPct = 1;
                    if (_curScrollPct < 0) _curScrollPct = 0;
                    //log ('_curScrollPct (after): '+_curScrollPct);

                    var __scrollSpeed:Number = (Math.abs(__deltaX) > 0) ? 0.2 : 0;

                    // position the different components based on _curScrollPct
                    _scrollbar.scrollTo(_curScrollPct);
                    _scrollElementsByPercent(_curScrollPct, __scrollSpeed);

                    //log(' ');
                    break;
            }
        }

        private function _handleScroll($e:ScrollEvent):void {
            $e.stopImmediatePropagation();
            switch ($e.type) {
                case ScrollEvent.START:
                    if (_previewIsPlaying){
                        dispatchEvent(new PreviewEvent(PreviewEvent.PAUSE));// pauses playback here and in the preview window
                        _previewWasPlaying = true;
                    }
                    break;

                case ScrollEvent.END:
                    if (_previewWasPlaying){
                        _previewWasPlaying = false;
                        dispatchEvent(new PreviewEvent(PreviewEvent.PLAY));
                    }
                    break;

                case ScrollEvent.SCROLL:

                    _curScrollPct = $e.data.pct;
                    //log('_curScrollPct: '+_curScrollPct);

                    _scrollElementsByPercent(_curScrollPct);//, 0.3);
                    break;
            }
        }

        private function _evalForClipDragScrolling($e:Event):void {
            _selectedClip.x = mouseX - _clipHolder.x;

            if (_curZoomLevel > 1) {

                if (mouseX > 1260){
                    //log('@@@@@@@@ scroll everything left!');
                    _curScrollPct += 0.005;
                    if (_curScrollPct > 1) _curScrollPct = 1;
                }

                if (mouseX < 20){
                    //log('@@@@@@@@ scroll everything right!');
                    _curScrollPct -= 0.005;
                    if (_curScrollPct < 0) _curScrollPct = 0;
                }

                _scrollbar.scrollTo(_curScrollPct);
                _scrollElementsByPercent(_curScrollPct);

            }

            if (_dragDirectionV.length == 5) { _dragDirectionV.shift();}

            if (_selectedClip.x != _prevDragClipX) {
                _dragDirectionV.push((_selectedClip.x < _prevDragClipX) ? 'left' : 'right');
            }

            _curDragDirection = _evalDragDirection();

            _evalClipCollision();
        }


        /*********************** HELPERS **********************/

        private static function _checkMouseOver($obj:DisplayObject):Boolean {
            var pt:Point = $obj.localToGlobal(new Point($obj.mouseX, $obj.mouseY));
            return $obj.hitTestPoint(pt.x, pt.y, true);
        }

        private function _evalDragDirection():String {
            var s:String = '';
            var l:uint = 0;
            var r:uint = 0;
            if (_dragDirectionV.length % 2 > 0) {
                for (var i:uint = 0; i < _dragDirectionV.length; i++) {
                    if (_dragDirectionV[i] == 'left') l++;
                    if (_dragDirectionV[i] == 'right') r++;
                }

                if (l > r) s = 'left';
                if (r > l) s = 'right';
            }
            return s;
        }


    }

}
