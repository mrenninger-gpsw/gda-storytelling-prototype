package project.managers {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// Subarashii Framework
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.PreviewEvent;
	import project.events.SourceClipManagerEvent;
	import project.events.StoryboardManagerEvent;
	import project.views.StoryBuilder.SourceClip;
	import project.views.StoryBuilder.VideoPreviewArea;
	
	
	
	public class SourceClipManager extends Sprite {
		
		// Vars
		private var _xml:XMLList;
		private var _bgShape:Shape;
		private var _scrollbar:Shape;
		private var _shadow:Bitmap;
		private var _sourceClipsV:Vector.<SourceClip>;
		private var _previewArea:VideoPreviewArea;
		private var _addFromLibrary:Boolean = false;

		
		
		/***************** GETTERS & SETTERS ******************/		
		public function set previewArea($value:VideoPreviewArea):void { _previewArea = $value; }
		
		public function set addFromLibrary($value:Boolean):void { _addFromLibrary = $value; }

		
		
		/******************** CONSTRUCTOR *********************/
		public function SourceClipManager() {
			super();
			
			_xml = Register.PROJECT_XML.content.editor.storybuilder.sourceClips;
			
			_sourceClipsV = new Vector.<SourceClip>();
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			
			_init();
		}
		
		
		
		/******************** PUBLIC API *********************/
		public function show():void {
			// position the source clips based on _addFromLibrary value and fade them up
			var startIndex:uint = 2;//(_addFromLibrary) ? 0 : 2;
			for (var i:uint = startIndex; i < _sourceClipsV.length; i++) {
				_sourceClipsV[i].y = (i == startIndex) ? 16 : _sourceClipsV[i - 1].y + 80;
				var onComplete:Function = (i == _sourceClipsV.length - 1) ? _checkforLibraryAdd : null;
				TweenMax.to(_sourceClipsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:i * 0.05, onComplete:onComplete});
			}
			
			//TweenMax.to(_scrollbar, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			TweenMax.to(_bgShape, 0.4, {autoAlpha:1, ease:Cubic.easeOut});
			//TweenMax.to(_shadow, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.25});
		}
		
		public function hide($immediate:Boolean = false):void {
			var startIndex:uint = 0;//(_addFromLibrary) ? 0 : 2;
			for (var i:uint = startIndex; i < _sourceClipsV.length; i++) {
				var onComplete:Function = (i == _sourceClipsV.length - 1) ? _onHideComplete : null;				
				TweenMax.to(_sourceClipsV[i], ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:($immediate) ? 0 : (i * 0.05), onComplete:onComplete});
			}			
			TweenMax.to(_scrollbar, ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut});		
			TweenMax.to(_bgShape, ($immediate) ? 0 : 0.4, {autoAlpha:0, ease:Cubic.easeOut});			
			TweenMax.to(_shadow, ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:($immediate) ? 0 : 0.25});			
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			// create the _bgShape
			_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x1e1e1e);
			_bgShape.graphics.drawRect(0,0,Register.APP.WIDTH, 454);
			_bgShape.graphics.endFill();
			_bgShape.alpha = 0;
			this.addChild(_bgShape);
			
			var i:uint;
			var tSourceClip:SourceClip; 
			
			// create the source clips from the media library
			for (i = 0; i < _xml.library.item.length(); i++) {
				tSourceClip = new SourceClip(i, _xml.library.item[i]);
				
				tSourceClip.x = 20;
				tSourceClip.y = (i == 0) ? 16 : _sourceClipsV[_sourceClipsV.length - 1].y + 80;
				tSourceClip.alpha = 0;
				
				//_addListeners(tSourceClip);
				
				tSourceClip.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
				tSourceClip.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);
				
				_sourceClipsV.push(tSourceClip);
				
				this.addChild(tSourceClip);
				
			}
			
			// create the default editor source clips
			for (i = 0; i < _xml.editor.item.length(); i++) {
				tSourceClip = new SourceClip(i, _xml.editor.item[i]);
				
				tSourceClip.x = 20;
				tSourceClip.y = _sourceClipsV[_sourceClipsV.length - 1].y + 80;
				tSourceClip.alpha = 0;
				
				//_addListeners(tSourceClip);
				
				tSourceClip.addEventListener(PreviewEvent.PREVIEW, _handlePreviewEvent);
				tSourceClip.addEventListener(PreviewEvent.CLEAR, _handlePreviewEvent);
				
				_sourceClipsV.push(tSourceClip);
				
				this.addChild(tSourceClip);
			}
			
			// create the shadow gradient and faux scrollbar here
			_scrollbar = new Shape();
			_scrollbar.graphics.beginFill(0x353535);
			_scrollbar.graphics.drawRect(0,0,5,98);
			_scrollbar.graphics.endFill();
			_scrollbar.x = 547;
			_scrollbar.y = 16;
			_scrollbar.alpha = 0;
			this.addChild(_scrollbar);
			
			_shadow = Register.ASSETS.getBitmap('sourceclip_gradient');
			_shadow.x = 20;
			_shadow.y = 440;
			_shadow.alpha = 0;
			this.addChild(_shadow);
			
			//show();
		}
		
		private function _checkforLibraryAdd():void {
			log('_checkforLibraryAdd: '+_addFromLibrary);
			if (_addFromLibrary) {
				var i:uint;
				for (i = (_sourceClipsV.length - 1); i > 1; i--) {
					TweenMax.to(_sourceClipsV[i], 0.3, {y:_sourceClipsV[i].y + 160, ease:Cubic.easeInOut, delay:((_sourceClipsV.length-1) - i) * 0.05});					
				}
				for (i = 0; i < 2; i++) {
					var onComplete:Function = (i == 1) ? _onShowComplete : null;
					TweenMax.to(_sourceClipsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.45 + (i * 0.05), onComplete:onComplete});
				}
				TweenMax.to(_shadow, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
				TweenMax.to(_scrollbar, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			} else {
				_onShowComplete();
			}
		}
		
		private function _onShowComplete():void {
			log('_onShowComplete');
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.SHOW_COMPLETE));
		}
		
		private function _onHideComplete():void {
			log('_onHideComplete');
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.HIDE_COMPLETE));
		}
		
		private function _enableSourceClips($b:Boolean = true):void {
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				_sourceClipsV[i].canAddToStoryboard = $b;
			}
		}
		
		
		
		/****************** EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _handleStoryboardManagerEvent);
			this.stage.addEventListener(StoryboardManagerEvent.FOUR_CLIPS, _handleStoryboardManagerEvent);			
		}
		
		private function _handlePreviewEvent($e:PreviewEvent):void {
			switch ($e.type) {
				case PreviewEvent.PREVIEW:
					var tSourceClip:SourceClip = $e.target as SourceClip;
					_previewArea.update(tSourceClip.curFileName);
					break;
				case PreviewEvent.CLEAR:
					_previewArea.clear();
					break;
			}
		}
		
		private function _handleStoryboardManagerEvent($e:StoryboardManagerEvent):void {
			switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					_enableSourceClips();
					break;
				
				case StoryboardManagerEvent.FIVE_CLIPS:
					_enableSourceClips(false);
					break;
			}
		}
		
	}
} 