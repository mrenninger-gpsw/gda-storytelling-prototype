/**
 * Created by mrenninger on 1/31/17.
 */
package project.views.StoryBuilder.ui {
import com.greensock.TweenMax;

import display.Sprite;

    import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.Mouse;

import utils.Register;

    public class StoryboardScrubber extends Sprite {

        private var _handleTop:Sprite;
        private var _handleBtm:Sprite;
        public function get handle():Sprite { return _handleTop; }

        public function StoryboardScrubber() {
            super();
            verbose = true;
            mouseChildren = false;
            _init();
        }

        private function _init():void {
            var __line:Sprite = new Sprite();
            __line.graphics.lineStyle(1,0xFFFFFF);
            __line.graphics.moveTo(0,0);
            __line.graphics.lineTo(0,192);
            /*__line.mouseEnabled = false;
            __line.mouseChildren = false;*/
            __line.y = -2;
            this.addChild(__line);

            _handleTop = new Sprite();
            _handleTop.addChild(Register.ASSETS.getBitmap('StoryboardScrubberHandle'));
            _handleTop.x = -_handleTop.width/2;
            _handleTop.y = -11;
            TweenMax.to(_handleTop, 0, {tint:0xFFFFFF});
            /*_handle.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseEvent);
            _handle.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);*/
            this.addChild(_handleTop);

            /*_handleBtm = new Sprite();
            _handleBtm.addChild(Register.ASSETS.getBitmap('StoryboardScrubberHandle'));
            _handleBtm.x = _handleBtm.width/2 + 0.5;
            _handleBtm.y = 107;
            TweenMax.to(_handleBtm, 0, {tint:0xF5A700, rotation:180});
            /!*_handle.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseEvent);
             _handle.addEventListener(MouseEvent.MOUSE_UP, _handleMouseEvent);*!/
            this.addChild(_handleBtm);*/

        }

        /*private function _handleMouseEvent($e:MouseEvent):void {
            switch ($e.type) {
                case MouseEvent.MOUSE_DOWN:
                    var r:Rectangle = new Rectangle(0, this.y, 1240, 0);
                    this.startDrag(true, r);
                    break;

                case MouseEvent.MOUSE_UP:
                    this.stopDrag();
                    break;
            }
        }*/

    }
}
