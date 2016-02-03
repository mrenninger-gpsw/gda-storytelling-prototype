package project.view.ui {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// CandyLizard Framework
	import display.Sprite;
	import utils.Register;

	
	
	public class BPMMeter extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _bpm:Number;
		private var _isActive:Boolean;
		private var _r:int;
		private var _arcMask:Sprite;
		private var _needle:Sprite;
		private var _arc:Sprite;
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function BPMMeter($bpm:Number) {
			super();
			//verbose = true;
			_bpm = $bpm;
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function animate():void {
			var prepTime:Number = ((_bpm - 60) / 80) * 0.3;
			TweenMax.allTo([_arcMask,_needle], prepTime, {rotation:-100, ease:Cubic.easeOut});
			TweenMax.allTo([_arcMask,_needle], 0.5, {rotation:_r, ease:Back.easeOut, delay:prepTime + 0.1});
		}
		
		public function reset():void {
			TweenMax.allTo([_arcMask,_needle], 0, {rotation:_r});
		}
		
		public function activate($b:Boolean):void {
			if ($b && !_isActive) {
				_isActive = true;
				TweenMax.to(_arcMask, 0, {tint:0x181818});
			}
			
			if (!$b && _isActive) {
				_isActive = true;
				TweenMax.to(_arcMask, 0, {tint:null});				
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			log('_init');
			_arc = new Sprite();
			var _arcBM:Bitmap = Register.ASSETS.getBitmap('musicItem_bpmIcon_arc10x');
			_arcBM.x = -_arcBM.width * 0.5;
			_arcBM.y = -_arcBM.height * 0.5;
			_arc.addChild(_arcBM);
			
			_needle = new Sprite();
			var _needleBM:Bitmap = Register.ASSETS.getBitmap('musicItem_bpmIcon_needle10x');
			_needleBM.x = -_needleBM.width * 0.5;
			_needleBM.y = -_needleBM.height * 0.5;
			_needle.addChild(_needleBM);
			
			_arcMask = new Sprite();
			var _maskShape:Shape = new Shape();
			_maskShape.graphics.beginFill(0x1e1e1e);
			_maskShape.graphics.drawRect(0,0,60,120);
			_maskShape.graphics.endFill();
			_maskShape.x = -_maskShape.width * 0.5;
			_maskShape.y = -_maskShape.height;
			_arcMask.addChild(_maskShape);
			
			this.addChild(_arc);
			this.addChild(_arcMask);
			this.addChild(_needle);
			
			var pct:Number = (140 - _bpm) / 80;
			_r = 90 - (pct * 180)
			log('\t_bpm: '+_bpm+' | pct: '+pct+' | r: '+_r);
			
			TweenMax.allTo([_arcMask,_needle], 0, {rotation:_r});
		}
	}
}