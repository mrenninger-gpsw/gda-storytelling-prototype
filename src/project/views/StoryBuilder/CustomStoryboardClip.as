package project.views.StoryBuilder {
		
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.StoryboardManagerEvent;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;
	import project.views.StoryBuilder.ui.SourceClipHighlight;
	
		
	
	public class CustomStoryboardClip extends Sprite {
		
		/******************* PRIVATE VARS *********************/
		private var _holder:Sprite;
		private var _curImageName:String;
		private var _prevImageName:String;
		private var _nextImageName:String;
		private var _sourceClipNum:Number;
		private var _frameNum:Number;
		private var _markerIcon:Sprite;
		private var _markerLine:Shape;
		private var _mask:Shape;
		private var _maskXML:XMLList;
		private var _marker:StoryboardClipMarker;
		private var _hilite:SourceClipHighlight;

		
		
		/***************** GETTERS & SETTERS ******************/		
		public function get curFileName():String { return _curImageName; }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function CustomStoryboardClip($sourceClipNum:Number, $frameNum:Number, $hilite:SourceClipHighlight) {
			super();
			
			verbose = true;
			
			_hilite = $hilite;
			_sourceClipNum = $sourceClipNum;
			_frameNum = $frameNum;
			
			var tXML:XML = Register.PROJECT_XML.content.editor.sourceClips.item[_sourceClipNum];
			
			_curImageName = tXML.@title + '_' + _addLeadingZeros(_frameNum);
			
			var sourceClipLength:Number = Number(tXML.@length);
			
			var _prevFrameNum:Number = _frameNum - 20;
			if (_prevFrameNum < 1) _prevFrameNum = 1;
			_prevImageName = tXML.@title + '_' + _addLeadingZeros(_prevFrameNum);
			
			var _nextFrameNum:Number = _frameNum + 20;
			if (_nextFrameNum > sourceClipLength) _nextFrameNum = sourceClipLength;
			_nextImageName = tXML.@title + '_' + _addLeadingZeros(_nextFrameNum);
			
			_holder = new Sprite();			
			addChild(_holder);
			
			_mask = new Shape();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.drawRect(0,0,1,99);
			_mask.graphics.endFill();
			addChild(_mask);
			_holder.mask = _mask;
			
			_maskXML = Register.PROJECT_XML.content.editor.storyboard.clip[4].location[1].mask;
			
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			
			_init();
		}
		
		
		
		/******************** PUBLIC API *********************/
		public function enable():void {
			_addListeners();
		}
		
		public function prepareForReveal():void {
			_mask.width = 1;
			_mask.x = 0;
			TweenMax.to(this, 0, {scaleX:1, scaleY:1});
		}
		
		public function showMarker($immediate:Boolean = false):void {
			// show the marker
			_marker.show($immediate);
			_showAdditionalImages();
		}
		

		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			
			var tThumb:Bitmap = Register.ASSETS.getBitmap(_curImageName);
			tThumb.width = 176;
			tThumb.height = 99;
			tThumb.x = -tThumb.width * 0.5;
			tThumb.y = -tThumb.height * 0.5;			
			_holder.addChild(tThumb);
			
			_mask.width = tThumb.width;
			_mask.height = tThumb.height;
			_mask.x = tThumb.x;
			_mask.y = tThumb.y;
			
			_marker = new StoryboardClipMarker();
			addChild(_marker);

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
		
		private function _showAdditionalImages():void {
			// add the prev and next thumbs;
			var prevThumb:Bitmap = Register.ASSETS.getBitmap(_prevImageName);
			prevThumb.width = 176;
			prevThumb.height = 99;
			prevThumb.x = -prevThumb.width - (prevThumb.width * 0.5);
			prevThumb.y = -prevThumb.height * 0.5;			
			_holder.addChild(prevThumb);
			
			var nextThumb:Bitmap = Register.ASSETS.getBitmap(_nextImageName);
			nextThumb.width = 176;
			nextThumb.height = 99;
			nextThumb.x = (nextThumb.width * 0.5);
			nextThumb.y = -nextThumb.height * 0.5;			
			_holder.addChild(nextThumb);		
			
			log ('mask left: '+_maskXML.@left+' | '+_maskXML.@width);
			TweenMax.to(_mask, 0.5, {x:Number(_maskXML.@left), width:Number(_maskXML.@width), ease:Expo.easeInOut});
		}
		
		
		
		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FIVE_CLIPS));
		}
		
		protected function _handleMouseEvent($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					//log('MOUSE_OVER')
					break;
				
				case MouseEvent.MOUSE_OUT:
					
					break;

				case MouseEvent.MOUSE_MOVE:					

					break;
				
				case MouseEvent.MOUSE_DOWN:
					//log('MOUSE_DOWN')
					break;
				
				case MouseEvent.MOUSE_UP:
					log('MOUSE_UP')
					log('this.parent: '+this.parent)
					
					// delete the related SourceClipHighlight
					_hilite.parent.removeChild(_hilite);
					
					this.stage.dispatchEvent(new StoryboardManagerEvent(StoryboardManagerEvent.FOUR_CLIPS));
					this.parent.removeChild(this);
					// dispatch an event for the storyboard to revert to 4 clips
					break;
			}
		}
		
		
		
		/********************* HELPERS ***********************/
		private function _addLeadingZeros($num:Number):String {
			var str:String = ($num < 10) ?  '00' + $num.toString() : ($num < 100) ? '0' + $num.toString() : $num.toString();
			return str;
		}
	}
}