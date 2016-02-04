package project.views.MusicSelector {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	
	// CandyLizard Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.MusicMenuEvent;
	import project.events.StoryboardManagerEvent;
	import project.views.MusicSelector.MusicMenu;
	import project.views.MusicSelector.ui.MusicMenuItem;
	import project.views.MusicSelector.ui.MusicPreviewHighlightIcon;

	
	
	public class MusicPreviewArea extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _showComplete:Boolean;
		private var _hideComplete:Boolean;
		private var _numMarkers:int = 4;
		private var _ds:Bitmap;
		private var _previewMusicIcon:Bitmap;
		private var _previewAudioWaves:Bitmap;
		private var _previewTimeline:Bitmap;
		private var _markerHolderMask:Bitmap;
		private var _previewTitleLabel:Label;
		private var _bgShape:Shape;
		private var _previewFeaturedBanner:Sprite;
		private var _markerHolder:Sprite;
		private var _musicXML:XMLList;
		private var _markersV:Vector.<Shape>;		
		private var _highlightsV:Vector.<MusicPreviewHighlightIcon>;		
		private var _curMenuItem:MusicMenuItem;

		
		
		/******************** CONSTRUCTOR *********************/
		private var _progressBar:Shape;
		public function MusicPreviewArea() {
			super();
			verbose = true;
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function show():void {
			log('show');
			_showComplete = false;
			_progressBar.width = 0;
			TweenMax.allTo([_ds, _bgShape], 0.3, {autoAlpha:1, y:0, ease:Cubic.easeOut, delay:0.5});
			TweenMax.allTo([_previewMusicIcon, _previewTitleLabel], 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.7});
			if (_curMenuItem.featured) TweenMax.to(_previewFeaturedBanner, 0.3, {autoAlpha:1, ease:Cubic.easeOut, delay:0.75});			
			TweenMax.allTo([_previewAudioWaves,_markerHolder, _markerHolderMask], 0.3, {autoAlpha:1, y:503, ease:Cubic.easeOut, delay:0.8});
			TweenMax.to(_previewTimeline, 0.3, {autoAlpha:1, y:565, ease:Cubic.easeOut, delay:0.9, onComplete:_onShowComplete});
		}
		
		public function hide($immediate:Boolean = false):void {
			log('hide - immediate? '+$immediate);
			_hideComplete = false;
			_clearHighlights();
			TweenMax.killTweensOf(_progressBar);
			TweenMax.allTo([_previewMusicIcon, _previewTitleLabel], ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut});
			if (_curMenuItem) { if (_curMenuItem.featured) TweenMax.to(_previewFeaturedBanner, ($immediate) ? 0 : 0.3, {autoAlpha:0, ease:Cubic.easeOut, delay:0.05});}			
			TweenMax.allTo([_previewAudioWaves,_markerHolder, _markerHolderMask], ($immediate) ? 0 : 0.3, {autoAlpha:0, y:483, ease:Cubic.easeOut, delay:0.1});
			TweenMax.to(_previewTimeline, ($immediate) ? 0 : 0.3, {autoAlpha:0, y:585, ease:Cubic.easeOut, delay:0.2});
			TweenMax.allTo([_ds, _bgShape], ($immediate) ? 0 : 0.3, {autoAlpha:0, y:'-20', ease:Cubic.easeOut, delay:0.5, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			_ds = Register.ASSETS.getBitmap('preview_dropshadow');
			_ds.x = -24;
			_ds.y = -3;
			TweenMax.to(_ds, 0.3, {width:800, height:471, ease:Cubic.easeOut});
			this.addChild(_ds);
			
			_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x000000);
			_bgShape.graphics.drawRect(0,0,752,423);
			_bgShape.graphics.endFill();
			this.addChild(_bgShape);
			
			TweenMax.allTo([_ds, _bgShape], 0, {autoAlpha:0, y:'-20'});
			
			_musicXML = Register.PROJECT_XML.content.music;

			_createPreview();
		}
		
		private function _createPreview():void {
			// music icon
			_previewMusicIcon = Register.ASSETS.getBitmap('musicPreview_musicIcon');
			_previewMusicIcon.height = _previewMusicIcon.width = 14;
			_previewMusicIcon.x = 0;
			_previewMusicIcon.y = 462;
			TweenMax.to(_previewMusicIcon, 0, {autoAlpha:0});
			this.addChild(_previewMusicIcon);
			
			// cur song title
			_previewTitleLabel = new Label();
			_previewTitleLabel.mouseEnabled = false;
			_previewTitleLabel.mouseChildren = false;
			_previewTitleLabel.text = _musicXML.tracks.item[Number(_musicXML.@initSongNum)].@title;
			_previewTitleLabel.autoSize = 'left';
			_previewTitleLabel.textFormatName = 'music-preview-title';
			_previewTitleLabel.x = _previewMusicIcon.x + _previewMusicIcon.width + 8;
			_previewTitleLabel.y = _previewMusicIcon.y - 6;
			TweenMax.to(_previewTitleLabel, 0, {autoAlpha:0});
			this.addChild(_previewTitleLabel);
			
			// featured banner
			_previewFeaturedBanner = new Sprite(); 
			var featuredIcon:Bitmap = Register.ASSETS.getBitmap('musicPreview_featuredIcon');
			_previewFeaturedBanner.addChild(featuredIcon);
			var featuredLabel:Label = new Label();
			featuredLabel.mouseEnabled = false;
			featuredLabel.mouseChildren = false;
			featuredLabel.text = 'Featured GoPro Media';
			featuredLabel.autoSize = 'left';
			featuredLabel.textFormatName = 'music-preview-featured-text';
			featuredLabel.x = featuredIcon.x + featuredIcon.width + 8;
			featuredLabel.y = (_previewFeaturedBanner.height - featuredLabel.height) * 0.5;
			_previewFeaturedBanner.addChild(featuredLabel);			
			_previewFeaturedBanner.x = Register.APP.WIDTH - _previewFeaturedBanner.width - 41 - 487;
			_previewFeaturedBanner.y = _previewMusicIcon.y - 3;
			TweenMax.to(_previewFeaturedBanner, 0, {autoAlpha:0});
			this.addChild(_previewFeaturedBanner);
			
			// audio waveform
			_previewAudioWaves = Register.ASSETS.getBitmap('musicPreview_waveform');
			_previewAudioWaves.x = 0;
			_previewAudioWaves.y = 483;
			TweenMax.to(_previewAudioWaves, 0, {autoAlpha:0});
			this.addChild(_previewAudioWaves);
			
			_markerHolder = new Sprite();
			_markerHolder.x = _previewAudioWaves.x + 1;
			_markerHolder.y = _previewAudioWaves.y;
			this.addChild(_markerHolder);
			
			_markerHolderMask = Register.ASSETS.getBitmap('musicPreview_waveform');
			_markerHolderMask.x = _previewAudioWaves.x;
			_markerHolderMask.y = _previewAudioWaves.y;
			this.addChild(_markerHolderMask);
			_markerHolderMask.cacheAsBitmap = true;
			_markerHolder.mask = _markerHolderMask;
					
			_progressBar = new Shape();
			_progressBar.graphics.beginFill(0x666666);
			_progressBar.graphics.drawRect(0,0,_previewAudioWaves.width,55);
			_progressBar.graphics.endFill();
			TweenMax.to(_progressBar, 0, {autoAlpha:0, width:0});
			_markerHolder.addChild(_progressBar);
			
			_markersV = new Vector.<Shape>();
			for (var i:uint = 0; i < 5; i++) {
				var tMarker:Shape = new Shape();
				tMarker.graphics.beginFill(0x00A3DA);
				tMarker.graphics.drawRect(-1.5,0,3,55);
				tMarker.graphics.endFill();
				tMarker.x = -3;// look to music tracks item xml for positions 
				_markerHolder.addChild(tMarker);
				_markersV.push(tMarker);
			}
			
			_previewTimeline = Register.ASSETS.getBitmap('musicPreview_timeline');
			_previewTimeline.x = -2;
			_previewTimeline.y = 585;
			TweenMax.to(_previewTimeline, 0, {autoAlpha:0});
			this.addChild(_previewTimeline);
			
			_highlightsV = new Vector.<MusicPreviewHighlightIcon>();
			
			hide(true);

		}
		
		private function _switchTitleText():void {
			_previewTitleLabel.text = _curMenuItem.title;
			TweenMax.to(_previewTitleLabel, 0.3, {autoAlpha:1, ease:Cubic.easeOut});
		}
		
		private function _onShowComplete():void {
			log('_onShowComplete');
			_showComplete = true;
			//log('\t_markerHolder.y: '+_markerHolder.y+' | _markerHolderMask.y: '+_markerHolderMask.y);
			
			_startProgress();
		}
		
		private function _onHideComplete():void {
			_hideComplete = true;
			_clearHighlights();
		}
		
		private function _addListeners():void {
			this.stage.addEventListener(StoryboardManagerEvent.FOUR_CLIPS, _onClipAmountChange);
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _onClipAmountChange);
		}
		
		private function _repositionMarkers():void {
			log('_repositionMarkers');
			var positions:XML = _musicXML.tracks.item[_curMenuItem.num].markers.positions[(_numMarkers == 4) ? 0 : 1];
			//log('positions: \r'+positions);
			for (var i:uint = 0; i < 5; i++) {
				var tMarker:Shape = _markersV[i];
				var newX:Number = Number(positions.split(',')[i]);
				//var newX:Number = Number(positions.item[i]);//Number(_clipsXML[i].location[($i == 4) ? 0 : 1].@position);
				//log('\tmarker'+i+'.newX: '+newX);
				TweenMax.to(tMarker, 0.4, {x:newX, ease:Circ.easeInOut});
			}	
		}
		
		private function _startProgress():void {
			var str:String;
			for (var i:uint = 0; i < _markersV.length; i++) {
				str += (_markersV[i].x + ', ');
			}
			log('_startProgress - markers at: '+str);
			TweenMax.killTweensOf(_progressBar);
			TweenMax.to(_progressBar, 0, {width:0, autoAlpha:1});
			TweenMax.to(_progressBar, 30, {width:_previewAudioWaves.width, ease:Linear.easeNone, onUpdate:_onProgressBarUpdate});
		}
		
		private function _onProgressBarUpdate():void {
//			log('_onProgressBarUpdate - width: '+_progressBar.width);
			for (var i:uint = 0; i < _markersV.length; i++) {
			 	if (Math.round(_progressBar.width) == _markersV[i].x) {
					var highlight:MusicPreviewHighlightIcon = new MusicPreviewHighlightIcon();
					highlight.x = _previewAudioWaves.x + _markersV[i].x;
					highlight.y = _previewAudioWaves.y - 5;
					_highlightsV.push(highlight);
					this.addChild(highlight);
				}
			}
		}
		
		private function _clearHighlights():void{
			for (var i:uint = 0; i < _highlightsV.length; i++) {
				TweenMax.to(_highlightsV[i], 0.2, {scaleX:0, scaleY:0, ease:Cubic.easeOut, delay:(i * 0.05), onComplete:_onHighlightCleared, onCompleteParams:[i]});
			}
		}
		
		private function _onHighlightCleared($num:int):void {
			if (_highlightsV[$num]) this.removeChild(_highlightsV[$num]);
			if ($num == _highlightsV.length - 1) _highlightsV = new Vector.<MusicPreviewHighlightIcon>();
		}
		
						
		
		/******************* EVENT HANDLERS *******************/	
		protected function _onAdded($e:Event):void {
			log('_onAdded');
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();
		}
		
		public function updateUI($e:MusicMenuEvent):void {
			log('updateUI');
			_curMenuItem = ($e.target as MusicMenu).curMenuItem;
			_clearHighlights();
			_repositionMarkers();
			if (_showComplete) {
				TweenMax.to(_previewTitleLabel, 0.2, {autoAlpha:0, ease:Cubic.easeIn, onComplete:_switchTitleText});
				TweenMax.to(_previewFeaturedBanner, 0.3, {autoAlpha:(_curMenuItem.featured) ? 1 : 0, ease:Cubic.easeOut});
				// do something here to start the music preview bar and interactions with the markers
				_startProgress();
			}
		}
		
		private function _onClipAmountChange($e:StoryboardManagerEvent):void {
			switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					_numMarkers = 4;
					_repositionMarkers();
					break;
				
				case StoryboardManagerEvent.FIVE_CLIPS:
					_numMarkers = 5;
					_repositionMarkers();
					break;
			}
		}
	}
}