package project.views.Footer.ui {

	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.events.Event;

    // Greensock
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	// Framework
	import display.Sprite;



	public class FooterBtn extends Sprite {

		/******************** PRIVATE VARS ********************/
		private var _width:Number;
		private var _height:Number;
		private var _icon:Bitmap;
		private var _bgShape:Shape;
        private var _hasBkgd:Boolean;



		/******************** CONSTRUCTOR *********************/
		public function FooterBtn($w:Number, $h:Number, $icon:Bitmap, $hasBkgd:Boolean = true) {
			super();

			_width = $w;
			_height = $h;
			_icon = $icon;
            _hasBkgd = $hasBkgd;

			_init();
		}



		/******************** PRIVATE API *********************/
		private function _init():void {
            _bgShape = new Shape();
            _bgShape.graphics.beginFill(0x353535);
            _bgShape.graphics.drawRect(0,0,_width,_height);
            _bgShape.graphics.endFill();
            addChild(_bgShape);
            if (!_hasBkgd) TweenMax.to(_bgShape, 0, {autoAlpha:0.01});

            _icon.x = (_width - _icon.width) * 0.5;
			_icon.y = (_height- _icon.height) * 0.5;
			addChild(_icon);

			this.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseEvents);
			this.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseEvents);
			this.addEventListener(MouseEvent.CLICK, _handleMouseEvents);
		}



		/******************* EVENT HANDLERS *******************/
		protected function _handleMouseEvents($e:MouseEvent):void {
			switch ($e.type) {
				case MouseEvent.MOUSE_OVER:
					if (_hasBkgd) TweenMax.to(_bgShape, 0, {tint:0x00A3DA});
					TweenMax.to(_icon, 0, {tint:0xFFFFFF});
					break;

				case MouseEvent.MOUSE_OUT:
                    if (_hasBkgd) TweenMax.to(_bgShape, 0.3, {tint:null, ease:Cubic.easeOut});
					TweenMax.to(_icon, 0.3, {tint:null, ease:Cubic.easeOut});
					break;

				case MouseEvent.CLICK:
					dispatchEvent(new Event('clicked'));
					break;

			}

		}
	}
}
