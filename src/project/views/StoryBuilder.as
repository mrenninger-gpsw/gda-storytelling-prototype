package project.views {

	// Flash
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;

	import display.Sprite;

import project.events.PreviewEvent;

import project.events.SourceClipManagerEvent;
	import project.events.StoryboardManagerEvent;
	import project.managers.SourceClipManager;
	import project.managers.StoryboardManager;
	import project.views.StoryBuilder.CustomStoryboardClip;
import project.views.StoryBuilder.StoryboardClip;
import project.views.StoryBuilder.VideoPreviewArea;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;

	import utils.GeomUtilities;
	import utils.Register;



	public class StoryBuilder extends Sprite {

		/******************** PRIVATE VARS ********************/
		private var _sourceClipMgr:SourceClipManager;
		private var _previewArea:VideoPreviewArea;
		private var _storyboard:StoryboardManager;
		private var _sourceClipMgrTransitionStart:Number;
		private var _transitionStart:Number;
		private var _time:Number;
		private var _tempClipMarker:StoryboardClipMarker;
		private var _isActive:Boolean = false;
		private var _transitionCompleteCount:uint = 0;
        private var _bgShape:Shape;



		/***************** GETTERS & SETTERS ******************/
		public function get storyboard():StoryboardManager { return _storyboard; }

		public function get isActive():Boolean { return _isActive; }

		public function set addFromLibrary($value:Boolean):void { _sourceClipMgr.addFromLibrary = $value; }



		/******************** CONSTRUCTOR *********************/
		public function StoryBuilder() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            log('STORYBUILDER!!!')
			_init();
		}



		/********************* PUBLIC API *********************/
		public function addClip($clip:StoryboardClip):void {
			// check to see if a 5th clip can be added
			if (_storyboard.canAddClips) {
				this.addChild($clip);
                this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FIVE_CLIPS));
				// on add of this custom clip to the stage, stage dispatches a FIVE_CLIPS StoryboardManagerEvent which is listened for here and in the storyboard
				// here, the caught event adds the clipMarker to the storyboard
				// in storyboard, the caught event causes the existing soryboard clips to reposition
				// immediately storyboard tells its clips to reposition and a tempClipMarker is added in place and told to show with a delay of 0.2
				TweenMax.delayedCall(0, _moveClipToStoryboard, [$clip]);
			}
		}

		public function show():void {
			_isActive = true;
			_transitionStart = new Date().getTime();
			_transitionCompleteCount = 0;
            TweenMax.to(_bgShape, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			_sourceClipMgr.show(); // 0.55s to complete
            _storyboard.resetScrubber();
			TweenMax.to(_storyboard, 0.4, {y:465, ease:Circ.easeInOut, onComplete:function():void{_storyboard.dispatchEvent(new Event('showComplete'));}}); // 0.4s to complete
			_previewArea.show(); // 0.1s delay, 0.35s to complete
		}

		public function hide($immediate:Boolean = false):void {
			_isActive = false;
			_transitionCompleteCount = 0;
			_sourceClipMgrTransitionStart = new Date().getTime();
			_transitionStart = new Date().getTime();
            TweenMax.to(_bgShape, ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut});
			_sourceClipMgr.hide($immediate); // starts immediately, multi-part, takes .55s to complete
			TweenMax.to(_storyboard, ($immediate) ? 0 : 0.5, {y:Register.APP.HEIGHT, ease:Circ.easeInOut, onComplete:function():void{_storyboard.dispatchEvent(new Event('hideComplete'));}}); // starts immediately, takes 0.5s to complete
			_previewArea.hide($immediate); // starts immediately, takes 0.3s to complete
		}



		/******************** PRIVATE API *********************/
		private function _init():void {
			// ********* SourceClipManager & Mask ***********
			// ************************************************
            addEventListener(SourceClipManagerEvent.CREATE_INITIAL_CLIP, _handleInitialClipCreation);

            _bgShape = new Shape();
            _bgShape.graphics.beginFill(0x1e1e1e);
            _bgShape.graphics.drawRect(0,66,Register.APP.WIDTH, 399);
            _bgShape.graphics.endFill();
            this.addChild(_bgShape);

            /*var s:Shape = new Shape();
			s.graphics.beginFill(0x1e1e1e);
			s.graphics.drawRect(0,0,Register.APP.WIDTH, 454);
			s.graphics.endFill();
			s.y = 66;
			this.addChild(s);
			_sourceClipMgr.mask = s;*/
			// ************************************************
			// ************************************************


			// ************* VideoPreviewArea *****************
			// ************************************************
			_previewArea = new VideoPreviewArea();
			/*_previewArea.x = 571;
			_previewArea.y = 98;*/
            _previewArea.x = 676;//627;
            _previewArea.y = 77;
			this.addChild(_previewArea);
			_previewArea.addEventListener('showComplete', _handleTransitionCompleteEvent);
            _previewArea.addEventListener('hideComplete', _handleTransitionCompleteEvent);
            _previewArea.addEventListener(PreviewEvent.PLAY, _handlePreviewEvent);
            _previewArea.addEventListener(PreviewEvent.PAUSE, _handlePreviewEvent);

            //_sourceClipMgr.previewArea = _previewArea;
			// ************************************************
			// ************************************************


            // ************* SourceClipManager *****************
            // ************************************************
            _sourceClipMgr = new SourceClipManager();
            _sourceClipMgr.y = 66;
            _sourceClipMgr.addEventListener('showComplete', _handleTransitionCompleteEvent);
            _sourceClipMgr.addEventListener('hideComplete', _handleTransitionCompleteEvent);
            _sourceClipMgr.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
            _sourceClipMgr.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);
            this.addChild(_sourceClipMgr);
            // ************************************************
            // ************************************************


            // *************** Storyboard area ****************
			// ************************************************
			_storyboard = new StoryboardManager();
			_storyboard.y = 465;//520;
			this.addChild(_storyboard);
			_storyboard.addEventListener('showComplete', _handleTransitionCompleteEvent);
			_storyboard.addEventListener('hideComplete', _handleTransitionCompleteEvent);
            _storyboard.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.LOCK, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.COMPLETE, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.CHANGE_VIDEO, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.PAUSE, _handlePreviewEvent);
            _storyboard.addEventListener(PreviewEvent.PLAY, _handlePreviewEvent);

            // ************************************************
			// ************************************************

			hide(true);
		}

		private function _onShowComplete():void {

		}

		private function _onHideComplete():void {

		}

		private function _moveClipToStoryboard($clip:StoryboardClip):void {
			log('_moveClipToStoryboard');
            var clip5X:Number = Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip[4].location[1].@position;
            var newClipX:Number = (Register.DATA.resetZoomOnClipAddDelete) ? clip5X : _storyboard.clipHolder.x + (_storyboard.curZoomLevel * clip5X);
			var totalTime:Number = 0.7;
			var distance:Number = GeomUtilities.getDistance(new Point($clip.x,$clip.y), new Point((newClipX + 21), 570));
			var totalDistance:Number = GeomUtilities.getDistance(new Point(0,0), new Point((newClipX + 21), 570));
			var pct:Number = distance/totalDistance;
			var normalizedTime:Number = totalTime * pct;
			log('\tdistance: '+distance);
			log('\tpct distance to cover: '+distance/totalDistance);
			log('\ttime to move custom clip: '+normalizedTime);
			_time = new Date().getTime();
			TweenMax.to($clip, (0.4 * normalizedTime), {scaleX:$clip.scaleX * 2, scaleY:$clip.scaleY * 2, ease:Cubic.easeIn});
			TweenMax.to($clip, (0.6 * normalizedTime), {scaleX:0, scaleY:0, ease:Cubic.easeOut, delay:(0.4 * normalizedTime)});
			TweenMax.to($clip, normalizedTime, {x:newClipX + 21, y: 570, ease:Cubic.easeInOut, onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});

			/*TweenMax.to($clip, 0.3, {width:160, height:90, x:210, y: 590, ease:Cubic.easeOut, delay:0.2});
			TweenMax.to($clip, 0.2, {width:176, height:99, ease:Cubic.easeOut, delay:0.4, onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});*/
		}

		private function _onClipMoveComplete($clip:StoryboardClip):void {
			log('_onClipMoveComplete');
			log('\ttime elapsed: '+(new Date().getTime() - _time));
			$clip.prepareForReveal();
			_storyboard.addClip($clip);
			this.removeChild(_tempClipMarker);
		}



		/******************* EVENT HANDLERS *******************/
		protected function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _addClipMarker);
		}

		protected function _handleSourceClipManagerEvent($e:SourceClipManagerEvent):void {
			switch ($e.type) {
				case SourceClipManagerEvent.SHOW_COMPLETE:
					log('SourceClipManager - SHOW_COMPLETE');
					log('time elapsed: '+(new Date().getTime() - _transitionStart));
					break;

				case SourceClipManagerEvent.HIDE_COMPLETE:
					log('SourceClipManager - HIDE_COMPLETE');
					//log('time elapsed: '+(new Date().getTime() - _transitionStart));
					break;

				case SourceClipManagerEvent.ADD_MEDIA:
					log('SourceClipManager - ADD_MEDIA');
					break;
			}
		}

        private function _handlePreviewEvent($e:PreviewEvent):void {
            $e.stopImmediatePropagation();
            //log('_handlePreviewEvent');
            switch ($e.type) {
                case PreviewEvent.PREVIEW:
                    //if ($e.data) log ('filename: '+$e.data.filename);
                    _previewArea.update($e.data.filename);
                    break;

                case PreviewEvent.CLEAR:
                    _previewArea.clear();
                    break;

                case PreviewEvent.LOCK:
                    //log('_handlePreviewEvent: lock the VideoPreviewArea to '+$e.data.filename);
                    _previewArea.lock(true, $e.data.filename);
                    break;

                case PreviewEvent.PLAY:
                    _storyboard.playTimeline();
                    _previewArea.playVideo(_storyboard.curPlayingClip.clipTitle, _storyboard.curPlayingClipPlayheadTime);
                    break;

                case PreviewEvent.PAUSE:
                    _storyboard.playTimeline(false);
                    _previewArea.pauseVideo();
                    break;

                case PreviewEvent.COMPLETE:
                    _previewArea.resetControls();
                    break;

                case PreviewEvent.CHANGE_VIDEO:
                    _previewArea.playVideo(_storyboard.curPlayingClip.clipTitle, _storyboard.curPlayingClip.clipStartTime);
                    break;
            }
        }

        private function _handleTransitionCompleteEvent($e:Event):void {
			switch ($e.type) {
				case 'showComplete':
					_transitionCompleteCount++;
					if (_transitionCompleteCount == 3){
						log('showComplete - elapsed: '+(new Date().getTime() - _transitionStart));
						dispatchEvent(new Event('showComplete'));
					}
					break;

				case 'hideComplete':
					_transitionCompleteCount++;
					if (_transitionCompleteCount == 3){
						log('hideComplete - elapsed: '+(new Date().getTime() - _transitionStart));
						dispatchEvent(new Event('hideComplete'));
					}
					break;
			}
		}

        private function _handleInitialClipCreation($e:SourceClipManagerEvent):void {
            log('ƒ _handleInitialClipCreation');
            $e.stopImmediatePropagation();
            _storyboard.createClip($e.data);
        }

		private function _addClipMarker($e:StoryboardManagerEvent):void {
			log('_addClipMarker');
			_tempClipMarker = new StoryboardClipMarker();
			_tempClipMarker.x = _storyboard.x + 20 + (_storyboard.curZoomLevel * Number(Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip[4].location[1].@position));
			_tempClipMarker.y = 570;
			this.addChild(_tempClipMarker);
			log('_tempMarker.stage: '+_tempClipMarker.stage);
			TweenMax.delayedCall(0.2, _tempClipMarker.show);
		}
	}
}
