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

import project.events.PreviewEvent;

// Greensock
	import com.greensock.TweenMax;
    import com.greensock.easing.Expo;
    import com.greensock.easing.Back;
    import com.greensock.easing.Linear;

	// Subarashii Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;

	// Project
    import project.events.PreviewEvent;
	import project.events.StoryboardManagerEvent;
    import project.events.ViewTransitionEvent;
    import project.views.StoryBuilder.StoryboardClip;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;
    import project.views.StoryBuilder.ui.GrabbyMcGrabberson;
    import project.views.StoryBuilder.ui.StoryboardScrubber;



	public class StoryboardManager extends Sprite {

		/******************** PRIVATE VARS ********************/
		private var _waveform:Bitmap;
		private var _markerHolderMask:Bitmap;
		private var _timeline:Bitmap;
		private var _clipHolder:Sprite;// = new Sprite();
		private var _markerHolder:Sprite;
		private var _songTitleTF:Label;
		private var _markersV:Vector.<Shape>;
		private var _clipsV:Vector.<StoryboardClip>;// = new Vector.<StoryboardClip>();
		private var _clipsXML:XMLList;
		private var _musicXML:XMLList;
		private var _tempMarker:StoryboardClipMarker;
        private var _dragging:Boolean = false;
        private var _mouseIsDown:Boolean = false;
        private var _longPressTimer:Timer;
        private var _selectedClip:StoryboardClip;
        //private var _prevSelectedClip:StoryboardClip;
        private var _collidedClipIndex:uint;
        private var _repositioning:Boolean = false;
        private var _prevDragClipX:Number;
        private var _dragDirectionV:Vector.<String>;
        private var _curDragDirection:String;
        private var _curDragRect:Rectangle;
        private var _previewScrubber:StoryboardScrubber;
        private var _scrubberDrag:Boolean = false;
        private var _curScrubClip:StoryboardClip;
        private var _grabby:GrabbyMcGrabberson;
        private var _progressShape:Shape;
        private var _playbackTimer:Timer;
        private var _playbackDuration:Number = 30;
        //private var _curPlaybackPct:Number = 0;
        private var _previewIsPlaying:Boolean = false;
        private var _curPlayingClip:StoryboardClip = null;
        private var _curPlayingClipPlayheadTime:Number;




		/***************** GETTERS & SETTERS ******************/
		public function get canAddClips():Boolean { return (_clipHolder.numChildren == 4); }

        private function get _normalizedMaskW():Number {
            return (1240 - ((_clipsV.length - 1) * 10))/_clipsV.length;
        }

        private function get _selectedClipDragRect():Rectangle {
            return new Rectangle(_selectedClip.maskShape.width/2, _selectedClip.y, 1240 - _selectedClip.maskShape.width, 0);
        }

        private function get _curPlaybackPct():Number { return ((_previewScrubber.x - _clipHolder.x)/1082); }

        public function get curPlayingClipName():String { return _curPlayingClip.clipTitle; }
        public function get curPlayingClip():StoryboardClip{ return _curPlayingClip; }
        public function get curPlayingClipPlayheadTime():Number { return _curPlayingClip.getPlayheadTimeUnderObject(_previewScrubber); }




        /******************** CONSTRUCTOR *********************/
		public function StoryboardManager() {
			super();
			verbose = true;

			_clipsXML = Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip;
			_musicXML = Register.PROJECT_XML.content.editor.music;

            _markersV = new Vector.<Shape>();
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
            $clip.x = Number(_clipsXML[_clipHolder.numChildren].location[locationIndex].@position);
			$clip.y = 0;
            $clip.index = _clipHolder.numChildren;
            $clip.maskXML = _clipsXML[_clipHolder.numChildren].location[locationIndex].mask;
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
            __clip.x = Number(_clipsXML[_clipHolder.numChildren].location[__locationIndex].@position);
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
                log('createClip calling _selectClip'); _selectClip(__clip);
                _curPlayingClip = __clip;
                //_curPlayingClipPlayheadTime = _curPlayingClip.getPlayheadTimeUnderObject(_previewScrubber);
            }

            _markerHolder.addChild(tMarker);
            _markersV.push(tMarker);
        }

        public function resetScrubber($repositionAtStart:Boolean = false):void {
            log('ƒ resetScrubber');
            _scrubberDrag = false;
            _previewScrubber.stopDrag();

            if (_curScrubClip) _curScrubClip.showScrubber(false, false);

            if ($repositionAtStart) _previewScrubber.x = _clipHolder.x;

            for (var i:uint = 0; i < _clipsV.length; i++){
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber)){
                    //log('\tintersected clip'+i);
                    _curScrubClip = _clipsV[i];
                    if (!_previewIsPlaying) _selectClip(_curScrubClip);
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curScrubClip.getFrameUnderObject(_previewScrubber)}));
                } else {
                    //log('\tdid not intersect clip'+i);
                }
                //_clipsV[i].showScrubber(false,false)
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
                _progressShape.scaleX = _curPlaybackPct;
                TweenMax.to(_previewScrubber, __time, {x:1102, ease:Linear.easeNone, onUpdate:_checkForNewClip, onComplete:_onPlaybackComplete});
                TweenMax.to(_progressShape, __time, {scaleX:1, ease:Linear.easeNone});
            } else {
                _previewIsPlaying = false;
                TweenMax.killTweensOf([_previewScrubber, _progressShape]);
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


            // sprite to contain the StoryboardClips
			_clipHolder = new Sprite();
            TweenMax.to(_clipHolder, 0, {x:20, y:106});
			this.addChild(_clipHolder);
            // ***************


            //*********
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
            var __returnToZero:Sprite = new Sprite();
            __returnToZero.graphics.beginFill(0xFF00FF, 0);
            __returnToZero.graphics.drawRect(0, 0, 20, 98);
            __returnToZero.graphics.endFill();
            __returnToZero.y = 57;
            this.addChild(__returnToZero);
            __returnToZero.addEventListener(MouseEvent.MOUSE_DOWN, _handleReturnToZero);
            // ***************


            // waveform and waveform markers
			_waveform = Register.ASSETS.getBitmap('Storyboard-AudioWaves');
            TweenMax.to(_waveform, 0, {tint:0x353535, x:_clipHolder.x, y:175});
			this.addChild(_waveform);

			_markerHolder = new Sprite();
            TweenMax.to(_markerHolder, 0, {x:_clipHolder.x, y:175});
			this.addChild(_markerHolder);

            _progressShape = new Shape();
            _progressShape.graphics.beginFill(0x666666);
            _progressShape.graphics.drawRect(0,0,1082,70);
            _progressShape.graphics.endFill();
            _progressShape.scaleX = 0;
            _markerHolder.addChild(_progressShape);

			_markerHolderMask = Register.ASSETS.getBitmap('Storyboard-AudioWaves');
            TweenMax.to(_markerHolderMask, 0, {x:_clipHolder.x, y:175});
			this.addChild(_markerHolderMask);
			_markerHolderMask.cacheAsBitmap = true;
			_markerHolder.mask = _markerHolderMask;
            // ***************


            // clip length time indicator
			_timeline = Register.ASSETS.getBitmap('Storyboard-TimelineWithBumper');
            TweenMax.to(_timeline, 0, {x:17, y:57});
			this.addChild(_timeline);
            // ***************

            // GrabbyMcGrabberson
            _grabby = new GrabbyMcGrabberson();
            _grabby.mouseChildren = false;
            _grabby.mouseEnabled = false;
            this.addChild(_grabby);

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
				var tMarker:Shape = _markersV[i];
                //log ('\t clip num: '+tClip.index);
                tClip.maskXML = _clipsXML[tClip.index].location[($i == 4) ? 0 : 1].mask;

                var newX:Number = Number(_clipsXML[tClip.index].location[($i == 4) ? 0 : 1].@position);

                var __complete:Function = (i == 3) ? resetScrubber : null;
                var _params:Array = (i == 3) ? [true] : null;
                TweenMax.allTo([tClip,tMarker], 0.4, {x:newX, ease:Expo.easeInOut}, 0, __complete, _params);

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
                    var newX:Number = Number(_clipsXML[tClip.index].location[__locationIndex].@position);
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
                var r:Rectangle = new Rectangle(0, _selectedClip.y, 1240, 0);
                log('dragRect: '+r);
                _selectedClip.startDrag(true, r);
                //_selectedClip.startDrag(true, _selectedClipDragRect);


                for (i = 0; i < _clipsV.length; i++ ){
                    if (_clipsV[i] != _selectedClip) {
                        TweenMax.to(_clipsV[i], 0.3, {alpha:0.66, ease:Expo.easeOut});
                    } else {
                        TweenMax.to(_selectedClip, 0.3, {scaleX:1.2, scaleY:1.2, ease:Back.easeOut});
                        TweenMax.to(_selectedClip, 0, {x:mouseX, ease:Expo.easeOut});
                        TweenMax.to(_selectedClip.marker, 0.2, {autoAlpha:0, ease:Expo.easeOut});
                        //_selectedClip.outline.visible = true;
                    }
                }



            } else {
                _dragging = false;
                _revertAllClipWidths();

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

                //_selectedClip = null;

                TweenMax.to(_previewScrubber, 0.2, {autoAlpha:0.5, ease:Expo.easeOut});

                // detect
            }
        }

        private function _revertAllClipWidths():void {
            var __locationIndex:uint = (_clipHolder.numChildren < 5) ? 0 : 1;
            for (var i:uint = 0; i < _clipsV.length; i++){
                _clipsV[i].maskXML = _clipsXML[_clipsV[i].index].location[__locationIndex].mask;
                TweenMax.to(_clipsV[i], 0.2, {x:Number(_clipsXML[_clipsV[i].index].location[__locationIndex].@position), ease:Expo.easeOut});
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
                var r:Rectangle = new Rectangle(20, _previewScrubber.y, 1082, 0);
                _previewScrubber.startDrag(true, r);
                addEventListener(Event.ENTER_FRAME, _trackScrubber);
                TweenMax.to(_previewScrubber, 0, {tint:0xFFFFFF});
            } else {
                //log('mouse is over scrubber? '+_checkMouseOver(_previewScrubber));
                //if (!_checkMouseOver(_previewScrubber)) _previewScrubber.alpha = 0.5;
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
            _previewIsPlaying = false;
            dispatchEvent(new PreviewEvent(PreviewEvent.COMPLETE));
        }

        private function _updatePreviewLockImage():void {

            for (var i:uint = 0; i < _clipsV.length; i++){
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber)){
                    //log('\tintersected clip'+i);
                    //if(_curScrubClip != _clipsV[i]){
                    _curScrubClip = _clipsV[i];
                    _curPlayingClip = _curScrubClip;
                    //log('_updatePreviewLockImage calling _selectClip');

                    //if (!_previewIsPlaying) _selectClip(_curScrubClip);

                    //}
                    //var __filename:String = _curScrubClip.getFrameUnderObject(_previewScrubber);
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curScrubClip.getFrameUnderObject(_previewScrubber)}));
                }
            }
        }

        private function _checkForNewClip():void {
            if (_curPlayingClip) {
                //_curPlayingClipPlayheadTime = _curPlayingClip.getPlayheadTimeUnderObject(_previewScrubber);
                //dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curPlayingClip.getFrameUnderObject(_previewScrubber)}));
            }

            // need to take into account whether _previewIsPlaying is true or false
            // maybe on PAUSE, _curPlayingClip gets set to null?
            for (var i:uint = 0; i < _clipsV.length; i++) {
                if (_clipsV[i].maskShape.hitTestObject(_previewScrubber) && _clipsV[i] != _curPlayingClip) {
                    dispatchEvent(new PreviewEvent(PreviewEvent.LOCK, true, {filename:_curPlayingClip.getFrameUnderObject(_previewScrubber)}));
                    _curPlayingClip = _clipsV[i];
                    dispatchEvent(new PreviewEvent(PreviewEvent.CHANGE_VIDEO));
                    // determine where on the clips timeline the _previewScrubber is and tell the VideoPreview to play from that point

                }
            }
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
			_markerHolder.addChild(tMarker);
			TweenMax.to(tMarker, 0.3, {height:70, ease:Expo.easeOut});
			_markersV.push(tMarker)
		}

		private function _onClipAmountChange($e:StoryboardManagerEvent):void {
			log('_onClipAmountChange');
            switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					//_removeTempMarker();
					_repositionClips(4);
					break;

				case StoryboardManagerEvent.FIVE_CLIPS:
					_repositionClips(5);
					break;
			}
		}

        private function _handleAddDeleteEdit($e:StoryboardManagerEvent):void {
            log('_handleAddDeleteEdit: '+$e.type);
            var clip:StoryboardClip = $e.target as StoryboardClip;
            switch ($e.type){
                case StoryboardManagerEvent.ADD_CLIP:
                    log('\tADD_CLIP');
                    if (_clipHolder.numChildren == 5) {
                        this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FIVE_CLIPS));
                    }
                    break;

                case StoryboardManagerEvent.DELETE_CLIP:
                    log('\tDELETE_CLIP');
                    if (_clipHolder.numChildren == 5) {
                        clip.hilite.parent.removeChild(clip.hilite);

                        _clipsV.removeAt(clip.index);
                        _clipHolder.removeChild(clip);

                        _markerHolder.removeChild(_markersV[clip.index]);
                        _markersV.removeAt(clip.index);

                        _clipsV = new <StoryboardClip>[];

                        for (var i:uint = 0; i < _clipHolder.numChildren; i++) {
                            var tClip:StoryboardClip = _clipHolder.getChildAt(i) as StoryboardClip;
                            log ('\t\t\tclip index before: '+tClip.index);
                            if (tClip.index > clip.index){
                                tClip.index --;
                            }
                            log ('\t\t\tclip index after: '+tClip.index);
                            _clipsV.push(tClip);
                        }

                        this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FOUR_CLIPS));
                    }
                    break;

                case StoryboardManagerEvent.EDIT_CLIP:
                    log('\tEDIT_CLIP');
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

                                // evaluate user drag direction intent
                                if (_dragDirectionV.length == 5) { _dragDirectionV.shift();}
                                _dragDirectionV.push((_selectedClip.x < _prevDragClipX) ? 'left' : 'right');
                                _curDragDirection = _evalDragDirection();

                                // check for collision and swap indices here
                                for (var i:uint = 0; i < _clipsV.length; i++) {
                                    var tClip:StoryboardClip = _clipsV[i];
                                    if (tClip != _selectedClip) {
                                        var __intersection:Rectangle = _selectedClip.maskShape.getBounds(this).intersection(tClip.maskShape.getBounds(this));
                                        if (__intersection.width > 0){
                                            //log('__intersection.width: '+__intersection.width);

                                            // we determine successful intersection based on a threshhold of 80% of the narrower clip mask width...
                                            var __threshholdMet:Boolean = (_selectedClip.maskShape.width >= tClip.maskShape.width) ? __intersection.width > (tClip.maskShape.width * 0.8) : __intersection.width > (_selectedClip.maskShape.width * 0.8);

                                            // ... and based on if the clip potentially being swapped is in the direction of intended drag
                                            var __canSwap:Boolean = ((_curDragDirection == 'right' && _selectedClip.index < tClip.index) || (_curDragDirection == 'left' && _selectedClip.index > tClip.index));

                                            if (__threshholdMet && __canSwap) {
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
                        }

                        break;

                    case MouseEvent.MOUSE_DOWN:
                        log('MOUSE_DOWN');
                        // set a timer here to detect long press
                        _longPressTimer.start();
                        _mouseIsDown = true;
                        playTimeline(false); // to kill the tweens
                        _selectClip(__clip);
                        //_selectedClip = __clip;
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
                                    //_selectClip(_selectedClip);

                                    //_curPlaybackPct = (_previewScrubber.x - _clipHolder.x)/1082;
                                    _progressShape.scaleX = _curPlaybackPct;

                                    //playTimeline(false); // to kill the tweens
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
                                /*_scrubberDrag = false;
                                 _previewScrubber.stopDrag();
                                 _curScrubClip.showScrubber(false, false);*/
                                //resetScrubber();

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
                            /*_scrubberDrag = false;
                             _previewScrubber.stopDrag();
                             _curScrubClip.showScrubber(false, false);*/
                            //resetScrubber();

                            if ($e.currentTarget != _previewScrubber && $e.target != _previewScrubber) {
                                //log ('fade _previewScrubber');
                                TweenMax.to(_previewScrubber, 0.2, {alpha:0.5});

                            }


                            /*Mouse.show();
                            _grabby.show(false);*/
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

                    /*Mouse.hide();
                    _grabby.grab();*/
                    /*_scrubberDrag = true;
                    var r:Rectangle = new Rectangle(0, _previewScrubber.y, 1240, 0);
                    _previewScrubber.startDrag(true, r);*/
                    break;

            }
        }

        private function _trackScrubber($e:Event):void {
            _previewScrubber.alpha = 1;

            _grabby.x = this.mouseX;
            _grabby.y = this.mouseY;

            //_curPlaybackPct = (_previewScrubber.x - _clipHolder.x)/1082;
            _progressShape.scaleX = _curPlaybackPct;

            _updatePreviewLockImage();
        }

        private function _handleReturnToZero($e:MouseEvent):void {
            playTimeline(false);
            resetScrubber(true);
            _updatePreviewLockImage();
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
