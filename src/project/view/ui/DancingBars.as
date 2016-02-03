package project.view.ui {
	
	// Flash
	import flash.display.Shape;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	// CandyLizard Framework
	import display.Sprite;
	


	public class DancingBars extends Sprite {
		
		/******************** PRIVATE VARS ********************/	
		private var _barsV:Vector.<Sprite>;
		private var _isActive:Boolean;
		private var _initBarHeightsV:Vector.<Number>;
		
		

		/******************** CONSTRUCTOR *********************/
		public function DancingBars() {
			super();
			_init();
		}
		
		
		
		/********************* PUBLIC API *********************/	
		public function activate():void {
			if (!_isActive){
				_isActive = true;
				for (var i:uint = 0; i < _barsV.length; i++){
					_barsV[i].height = _initBarHeightsV[i];
					var pctToTop:Number = (_barsV[i].height - 4)/10;
					var initTime:Number = (1 - pctToTop) * 0.3;
					TweenMax.to(_barsV[i], initTime, {height:14, ease:Cubic.easeIn, onComplete:_shrink, onCompleteParams:[_barsV[i]]});
				}
			}
		}
		
		public function deactivate():void {
			if (_isActive) {
				_isActive = false;;
				for (var i:uint = 0; i < _barsV.length; i++){
					TweenMax.killTweensOf(_barsV[i]);
				}
			}
		}
		
		
		
		/******************** PRIVATE API *********************/
		private function _init():void {
			_initBarHeightsV = new <Number>[8,14,10];
			
			_barsV = new Vector.<Sprite>();
			
			for (var i:uint = 0; i < 3; i++){
				var bar:Sprite = new Sprite();
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xFFFFFF);
				shape.graphics.drawRect(-1,-14,2,14);
				shape.graphics.endFill();
				bar.addChild(shape);
				bar.x = (i * 3);
				bar.y = 14;
				bar.height = _initBarHeightsV[i];//4 + Math.round(Math.random() * 10)
				this.addChild(bar);
				_barsV.push(bar);				
			}			
		}
		
		private function _shrink($bar:Sprite):void {
			TweenMax.to($bar, 0.5, {height:4, ease:Cubic.easeOut, onComplete:_grow, onCompleteParams:[$bar]});
		}
		
		private function _grow($bar:Sprite):void {
			TweenMax.to($bar, 0.3, {height:14, ease:Cubic.easeIn, onComplete:_shrink, onCompleteParams:[$bar]});
		}
	}
}
