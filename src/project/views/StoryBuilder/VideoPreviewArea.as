package project.views.StoryBuilder {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	
	// Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// Framework
	import display.Sprite;
	import utils.Register;
	
	
	
	public class VideoPreviewArea extends Sprite {
		
		/******************* PRIVATE VARS *********************/
		private var _holder:Sprite;
		private var _bgShape:Shape;
		private var _ds:Bitmap;
		
		
		
		/******************** CONSTRUCTOR *********************/		
		public function VideoPreviewArea() {
			super();
			_init();
		}
		
		
		
		/******************** PUBLIC API *********************/
		public function update($filename:String):void {
			clear();
			_holder.addChild(Register.ASSETS.getBitmap($filename));
		}
		
		public function clear():void {
			_holder.removeChildren()
		}
		
		public function switchStates($id:String,$immediate:Boolean = false):void {
			log('_switchStates: '+$id);
			switch ($id) {
				case 'music':
					TweenMax.to(this, ($immediate) ? 0 : 0.3, {autoAlpha:0, y:'-20', ease:Cubic.easeOut});
					break;
				
				case 'video':
					TweenMax.to(this, ($immediate) ? 0 : 0.3, {autoAlpha:1, y:98, ease:Cubic.easeOut, delay:($immediate) ? 0 : 0.2});
					break;
			}
		}
		
		public function show($immediate:Boolean = false):void {
			TweenMax.to(this, ($immediate) ? 0 : 0.25, {autoAlpha:1, y:98, ease:Cubic.easeOut, onComplete:_onShowComplete});		
		}
		
		public function hide($immediate:Boolean = false):void {
			TweenMax.to(this, ($immediate) ? 0 : 0.25, {autoAlpha:0, y:'-20', ease:Cubic.easeOut, onComplete:_onHideComplete});
		}
		
		
		
		/******************** PRIVATE API *********************/
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
			
			TweenMax.to(this, 0, {autoAlpha:0, y:'-20'});

		}
		
		private function _onShowComplete():void {
			dispatchEvent(new Event('showComplete'));
		}

		private function _onHideComplete():void {
			dispatchEvent(new Event('hideComplete'));
		}
	}
}