package project.views {
	
	// Flash
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	
	// Framework
	import display.Sprite;
	import utils.GeomUtilities;
	import utils.Register;
	
	// Project
	import project.events.SourceClipManagerEvent;
	import project.events.StoryboardManagerEvent;
	import project.managers.SourceClipManager;
	import project.managers.StoryboardManager;
	import project.views.StoryBuilder.CustomStoryboardClip;
	import project.views.StoryBuilder.VideoPreviewArea;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;
	
	
	
	public class StoryBuilder extends Sprite {

		/******************** PRIVATE VARS ********************/	
		private var _sourceClipMgr:SourceClipManager;
		private var _previewArea:VideoPreviewArea;
		private var _storyboard:StoryboardManager;
		private var _sourceClipMgrTransitionStart:Number;
		private var _time:Number;
		private var _tempClipMarker:StoryboardClipMarker;
		private var _isActive:Boolean = false;
			

		
		/***************** GETTERS & SETTERS ******************/			
		public function get storyboard():StoryboardManager { return _storyboard; }

		public function get isActive():Boolean { return _isActive; }
		
		public function set addFromLibrary($value:Boolean):void { _sourceClipMgr.addFromLibrary = $value; }

		
		
		/******************** CONSTRUCTOR *********************/
		public function StoryBuilder() {
			super();
			verbose = true;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();			
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function addCustomClip($clip:CustomStoryboardClip):void {
			// check to see if a 5th clip can be added
			if (_storyboard.canAddClips) {
				this.addChild($clip); 
				// on add of this custom clip to the stage, stage dispatches a FIVE_CLIPS StoryboardManagerEvent which is listened for here and in the storyboard
				// here, the caught event adds the clipMarker to the storyboard
				// in storyboard, the caught event causes the existing soryboard clips to reposition
				// immediately storyboard tells its clips to reposition and a tempClipMarker is added in place and told to show with a delay of 0.2
				TweenMax.delayedCall(0, _moveCustomClipToStoryboard, [$clip]);
			}			
		}
		
		public function show():void {
			_isActive = true;
			_sourceClipMgr.show(); // 0.55s to complete
			TweenMax.to(_storyboard, 0.5, {y:520, ease:Circ.easeInOut}); // 0.5s to complete
			_previewArea.show(); // 0.2s delay, 0.5s to complete
		}
		
		public function hide($immediate:Boolean = false):void {
			_isActive = false;
			_sourceClipMgrTransitionStart = new Date().getTime();
			
			_sourceClipMgr.hide($immediate); // starts immediately, multi-part, takes .55s to complete
			TweenMax.to(_storyboard, ($immediate) ? 0 : 0.5, {y:Register.APP.HEIGHT, ease:Circ.easeInOut}); // starts immediately, takes 0.5s to complete
			_previewArea.hide($immediate); // starts immediately, takes 0.3s to complete
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			// ********* SourceClipManager & Mask ***********
			// ************************************************
			_sourceClipMgr = new SourceClipManager();
			_sourceClipMgr.y = 66;
			this.addChild(_sourceClipMgr);
			_sourceClipMgr.addEventListener(SourceClipManagerEvent.SHOW_COMPLETE, _handleSourceClipManagerEvent);
			_sourceClipMgr.addEventListener(SourceClipManagerEvent.HIDE_COMPLETE, _handleSourceClipManagerEvent);
			
			var s:Shape = new Shape();
			s.graphics.beginFill(0x1e1e1e);
			s.graphics.drawRect(0,0,Register.APP.WIDTH, 454);
			s.graphics.endFill();
			s.y = 66;
			this.addChild(s);
			_sourceClipMgr.mask = s;
			// ************************************************
			// ************************************************
			
			
			// ************* VideoPreviewArea *****************
			// ************************************************
			_previewArea = new VideoPreviewArea();
			_previewArea.x = 571;
			_previewArea.y = 98;
			this.addChild(_previewArea);
			_sourceClipMgr.previewArea = _previewArea;
			// ************************************************
			// ************************************************
			
			
			// *************** Storyboard area ****************
			// ************************************************
			_storyboard = new StoryboardManager();			
			_storyboard.y = 520;
			this.addChild(_storyboard);
			// ************************************************
			// ************************************************	
			
			hide(true);
		}
		
		private function _onShowComplete():void {
			
		}
		
		private function _onHideComplete():void {
			
		}
		
		private function _moveCustomClipToStoryboard($clip:CustomStoryboardClip):void {
			log('_moveCustomClipToStoryboard');
			var newClipX:Number = (Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip[4].location[1].@position);
			var totalTime:Number = 0.7;
			var distance:Number = GeomUtilities.getDistance(new Point($clip.x,$clip.y), new Point((newClipX + 21), 590));
			var totalDistance:Number = GeomUtilities.getDistance(new Point(0,0), new Point((newClipX + 21), 590)); 
			var pct:Number = distance/totalDistance;
			var normalizedTime:Number = totalTime * pct
			log('\tdistance: '+distance);
			log('\tpct distance to cover: '+distance/totalDistance);
			log('\ttime to move custom clip: '+normalizedTime);
			_time = new Date().getTime();
			TweenMax.to($clip, (0.4 * normalizedTime), {scaleX:$clip.scaleX * 2, scaleY:$clip.scaleY * 2, ease:Cubic.easeIn});
			TweenMax.to($clip, (0.6 * normalizedTime), {scaleX:0, scaleY:0, ease:Cubic.easeOut, delay:(0.4 * totalTime)});
			TweenMax.to($clip, normalizedTime, {x:newClipX + 21, y: 590, ease:Cubic.easeInOut, onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});
			
			/*TweenMax.to($clip, 0.3, {width:160, height:90, x:210, y: 590, ease:Cubic.easeOut, delay:0.2});
			TweenMax.to($clip, 0.2, {width:176, height:99, ease:Cubic.easeOut, delay:0.4, onComplete:_onClipMoveComplete, onCompleteParams:[$clip]});*/
		}
		
		private function _onClipMoveComplete($clip:CustomStoryboardClip):void {
			log('_onClipMoveComplete');
			log('\ttime elapsed: '+(new Date().getTime() - _time));
			$clip.prepareForReveal()
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
					break;
				
				case SourceClipManagerEvent.HIDE_COMPLETE:
					log('SourceClipManager - HIDE_COMPLETE');
					log('time elapsed: '+(new Date().getTime() - _sourceClipMgrTransitionStart));
					break;			
				
				case SourceClipManagerEvent.ADD_MEDIA:
					log('SourceClipManager - ADD_MEDIA');
					break;
			}
		}
		
		private function _addClipMarker($e:StoryboardManagerEvent):void {
			log('_addClipMarker');
			_tempClipMarker = new StoryboardClipMarker();
			_tempClipMarker.x = _storyboard.x + 20 + Number(Register.PROJECT_XML.content.editor.storybuilder.storyboard.clip[4].location[1].@position);
			_tempClipMarker.y = _storyboard.y + 70;
			this.addChild(_tempClipMarker);
			log('_tempMarker.stage: '+_tempClipMarker.stage);
			TweenMax.delayedCall(0.2, _tempClipMarker.show);
		}
	}
}