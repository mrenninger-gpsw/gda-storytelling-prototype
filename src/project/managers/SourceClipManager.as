package project.managers {
	
	// Flash
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	
	import display.Sprite;
	
	import project.events.PreviewEvent;
	import project.events.SourceClipManagerEvent;
	import project.view.SourceClip;
	import project.view.VideoPreviewArea;
	
	import utils.Register;
	
	
	
	public class SourceClipManager extends Sprite {
		
		// Vars
		private var _xml:XMLList;
		private var _bgShape:Shape;
		private var _scrollbar:Shape;
		private var _shadow:Bitmap;
		private var _sourceClipsV:Vector.<SourceClip>;
		private var _previewArea:VideoPreviewArea;
		
		// Getters & Setters
		public function set previewArea($value:VideoPreviewArea):void { _previewArea = $value; }

		
		
		// Constructor
		public function SourceClipManager() {
			super();
			
			_xml = Register.PROJECT_XML.content.editor.sourceClips;
			
			_sourceClipsV = new Vector.<SourceClip>();
			
			_init();
		}
		
		
		
		// Public API
		public function show():void {
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				var onComplete:Function = (i == _sourceClipsV.length - 1) ? _onShowComplete : null;
				TweenMax.to(_sourceClipsV[i], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:i * 0.05, onComplete:onComplete});
			}
			TweenMax.to(_scrollbar, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
			TweenMax.to(_bgShape, 0.4, {autoAlpha:1, ease:Cubic.easeOut});
			TweenMax.to(_shadow, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.25});
		}
		
		public function hide():void {
			for (var i:uint = 0; i < _sourceClipsV.length; i++) {
				var onComplete:Function = (i == _sourceClipsV.length - 1) ? _onHideComplete : null;				
				TweenMax.to(_sourceClipsV[i], 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:i * 0.05, onComplete:onComplete});
			}			
			TweenMax.to(_scrollbar, 0.3, {autoAlpha:0, ease:Cubic.easeOut});		
			TweenMax.to(_bgShape, 0.4, {autoAlpha:0, ease:Cubic.easeOut});			
			TweenMax.to(_shadow, 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.25});			
		}
		
		
		
		// Private API
		private function _init():void {
			// create the _bgShape
			_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x1e1e1e);
			_bgShape.graphics.drawRect(0,0,Register.APP.WIDTH, 454);
			_bgShape.graphics.endFill();
			_bgShape.alpha = 0;
			this.addChild(_bgShape);
			
			// create the source clips
			for (var i:uint = 0; i < _xml.item.length(); i++) {
				var tSourceClip:SourceClip = new SourceClip(i);
				
				tSourceClip.x = 20;
				tSourceClip.y = 16 + (i * 80);
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
			
			show();
		}
		
		private function _onShowComplete():void {
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.SHOW_COMPLETE));
		}
		
		private function _onHideComplete():void {
			dispatchEvent(new SourceClipManagerEvent(SourceClipManagerEvent.HIDE_COMPLETE));
		}
		
		
		
		// Event Handlers
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
		
	}
}