package project.view {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import display.Sprite;
	import utils.Register;
	
	
	
	public class VideoPreviewArea extends Sprite {
		
		// vars
		private var _holder:Sprite;
		private var _bgShape:Shape;
		private var _ds:Bitmap;
		
		
		
		// Constructor
		public function VideoPreviewArea() {
			super();
			_init();
		}
		
		
		
		// Public API
		public function update($filename:String):void {
			clear();
			_holder.addChild(Register.ASSETS.getBitmap($filename));
		}
		
		public function clear():void {
			_holder.removeChildren()
		}
		
		public function switchStates($id:String):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					//TweenMax.to(_holder, 0.3, {width:752, height:423, ease:Cubic.easeOut});
					/*TweenMax.to(_bgShape, 0.3, {width:752, height:423, ease:Cubic.easeOut});
					TweenMax.to(_ds, 0.3, {width:800, height:471, ease:Cubic.easeOut});
					TweenMax.to(this, 0.3, {x:487, y:111, ease:Cubic.easeOut});*/
					TweenMax.to(this, 0.3, {autoAlpha:0, y:'-20', ease:Cubic.easeOut});
					break;
				
				case 'video':
					//TweenMax.to(_holder, 0.3, {width:688, height:387, ease:Cubic.easeOut});
					/*TweenMax.to(_bgShape, 0.3, {width:688, height:387, ease:Cubic.easeOut});
					TweenMax.to(_ds, 0.3, {width:752, height:423, ease:Cubic.easeOut});
					TweenMax.to(this, 0.3, {x:571, y:98, ease:Cubic.easeOut});*/
					TweenMax.to(this, 0.3, {autoAlpha:1, y:98, ease:Cubic.easeOut, delay:1});
					break;
			}
		}
		
		
		
		// Private API
		private function _init():void {
			
			_ds = Register.ASSETS.getBitmap('preview_dropshadow');
			_ds.x = -24;
			_ds.y = -3;
			this.addChild(_ds);
			
			_bgShape = new Shape();
			_bgShape.graphics.beginFill(0x000000);
			_bgShape.graphics.drawRect(0,0,688,387);
			_bgShape.graphics.endFill();
			this.addChild(_bgShape);
			
			_holder = new Sprite();
			this.addChild(_holder);
		}
	}
}