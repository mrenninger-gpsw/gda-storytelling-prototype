package project.managers {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
		
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	
	// CandyLizard Framework
	import components.controls.Label;
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.events.StoryboardManagerEvent;
	import project.views.StoryBuilder.CustomStoryboardClip;
	import project.views.StoryBuilder.TempStoryboardClip;
	import project.views.StoryBuilder.ui.StoryboardClipMarker;
	
	
	
	public class StoryboardManager extends Sprite {
		
		/******************** PRIVATE VARS ********************/
		private var _waveform:Bitmap;
		private var _markerHolderMask:Bitmap;
		private var _timeline:Bitmap;
		private var _clipHolder:Sprite;
		private var _markerHolder:Sprite;
		private var _songTitleTF:Label;
		private var _markersV:Vector.<Shape>;		
		private var _clipsV:Vector.<TempStoryboardClip>;
		private var _clipsXML:XMLList;
		private var _musicXML:XMLList;
		private var _tempMarker:StoryboardClipMarker;
		
		
		
		/***************** GETTERS & SETTERS ******************/		
		public function get canAddClips():Boolean { return (_clipHolder.numChildren == 4); }
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function StoryboardManager() {
			super();
			verbose = true;
			
			_clipsXML = Register.PROJECT_XML.content.editor.storyboard.clip;
			_musicXML = Register.PROJECT_XML.content.music;
			
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);

			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/
		public function addClip($clip:CustomStoryboardClip):void {
			$clip.x = Number(_clipsXML[4].location[1].@position);
			$clip.y = 0;
			_clipHolder.addChild($clip);
			$clip.showMarker(true);
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			var musicIcon:Bitmap = Register.ASSETS.getBitmap('footer_musicIcon');
			TweenMax.to(musicIcon, 0, {x:20, y:135, width:15, height:16, alpha:0.66});
			this.addChild(musicIcon);			
			
			_songTitleTF = new Label();
			_songTitleTF.mouseEnabled = false;
			_songTitleTF.mouseChildren = false;
			_songTitleTF.id = 'storyboard-song-title';
			_songTitleTF.text = _musicXML.tracks.item[Number(_musicXML.@initSongNum)].@title;
			_songTitleTF.autoSize = 'left';
			_songTitleTF.textFormatName = 'sourceclip-length';
			_songTitleTF.x = 44;
			_songTitleTF.y = 133;
			this.addChild(_songTitleTF);
			
			_clipHolder = new Sprite(); 
			_clipHolder.x = 20;
			_clipHolder.y = 70
			this.addChild(_clipHolder);
			
			_waveform = Register.ASSETS.getBitmap('audio_waveform');
			_waveform.x = 20;
			_waveform.y = 166;
			this.addChild(_waveform);
			
			_markerHolder = new Sprite();
			_markerHolder.x = 20;
			_markerHolder.y = 166;
			this.addChild(_markerHolder);
			
			_markerHolderMask = Register.ASSETS.getBitmap('audio_waveform');
			_markerHolderMask.x = 20;
			_markerHolderMask.y = 166;
			this.addChild(_markerHolderMask);
			_markerHolderMask.cacheAsBitmap = true;
			_markerHolder.mask = _markerHolderMask;
						
			_timeline = Register.ASSETS.getBitmap('timeline');
			_timeline.x = 17;
			_timeline.y = _waveform.y + _waveform.height;
			this.addChild(_timeline);
			
			_addTempClips();
		}
		
		private function _addTempClips():void {
			_markersV = new Vector.<Shape>();
			_clipsV = new Vector.<TempStoryboardClip>();
			
			// add 4 TempStoryboardClips and blue markers
			for (var i:uint = 0; i < 4; i++) {
				
				var tClip:TempStoryboardClip = new TempStoryboardClip(i);
				tClip.x = Number(_clipsXML[i].location[0].@position);
				//log('tClip.x: '+tClip.x);
				_clipHolder.addChild(tClip);
				_clipsV.push(tClip);
				
				// create temp blue clip marker
				var tMarker:Shape = new Shape();
				tMarker.graphics.beginFill(0x00A3DA);
				tMarker.graphics.drawRect(-1.5,0,3,35);
				tMarker.graphics.endFill();
				tMarker.x = _clipsV[i].x;
				_markerHolder.addChild(tMarker);
				_markersV.push(tMarker);
			}
		}
		
		private function _addListeners():void {
			this.stage.addEventListener(StoryboardManagerEvent.FOUR_CLIPS, _onClipAmountChange);
			this.stage.addEventListener(StoryboardManagerEvent.SHOW_MARKER, _showCustomMarker);			
			this.stage.addEventListener(StoryboardManagerEvent.FIVE_CLIPS, _onClipAmountChange);
		}
		
		private function _repositionClips($i:uint):void {
			for (var i:uint = 0; i < 4; i++) {
				var tClip:TempStoryboardClip = _clipsV[i];
				var tMarker:Shape = _markersV[i];
				var newX:Number = Number(_clipsXML[i].location[($i == 4) ? 0 : 1].@position);
				TweenMax.allTo([tClip,tMarker], 0.4, {x:newX, ease:Circ.easeInOut});
				/*TweenMax.to(tClip.maskShape, 0.3, {x:-50, width:100, ease:Cubic.easeOut});
				TweenMax.delayedCall(0.5, _onRepositionClipsComplete, [$i]);*/
				var newMaskW:Number = Number(_clipsXML[i].location[($i == 4) ? 0 : 1].mask.@width);
				var newMaskX:Number = Number(_clipsXML[i].location[($i == 4) ? 0 : 1].mask.@left);
				TweenMax.to(tClip.maskShape, 0.4, {x:newMaskX, width:newMaskW, ease:Circ.easeInOut});
			}	
		}

		private function _removeTempMarker():void {
			if (_markersV.length == 5) {
				_markerHolder.removeChild(_markersV[4]);
				_markersV.splice(4,1);
			}
		}
		
		private function _addClipMarker():void {
			_tempMarker = new StoryboardClipMarker();
			_tempMarker.x = 20 + Number(_clipsXML[4].location[1].@position);;
			_tempMarker.y = 70;
			this.addChild(_tempMarker);
			_tempMarker.show();
		}
		
		
		
		/******************* EVENT HANDLERS *******************/
		private function _onAdded($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			_addListeners();
		}
		
		private function _showCustomMarker($e:StoryboardManagerEvent):void {
			var tMarker:Shape = new Shape();
			tMarker.graphics.beginFill(0x00A3DA);
			tMarker.graphics.drawRect(-1.5,0,3,3);
			tMarker.graphics.endFill();
			tMarker.x = Number(_clipsXML[4].location[1].@position);
			_markerHolder.addChild(tMarker);
			TweenMax.to(tMarker, 0.3, {height:35, ease:Cubic.easeOut}); 
			_markersV.push(tMarker)
		}
		
		private function _onClipAmountChange($e:StoryboardManagerEvent):void {
			switch ($e.type) {
				case StoryboardManagerEvent.FOUR_CLIPS:
					_removeTempMarker();
					_repositionClips(4);
					break;
				
				case StoryboardManagerEvent.FIVE_CLIPS:
					//_createCustomMarker();
					//TweenMax.delayedCall(0.5, _addClipMarker)
					_repositionClips(5);
					break;
			}
		}
	}
	
}