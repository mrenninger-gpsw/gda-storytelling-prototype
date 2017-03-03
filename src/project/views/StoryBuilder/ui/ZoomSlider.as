/**
 * Created by mrenninger on 2/14/17.
 */
package project.views.StoryBuilder.ui {

    // Flash
    import flash.display.Bitmap;
    import flash.display.Shape;
    import flash.geom.Rectangle
    import flash.events.Event;
    import flash.events.MouseEvent;

    // Greensock
    import com.greensock.TweenMax;
    import com.greensock.easing.Expo;

    // Framework
    import display.Sprite;
    import utils.Register;

    // Project
    import project.events.ZoomEvent;



    public class ZoomSlider extends Sprite {

        /******************* PRIVATE VARS *********************/
        private var _track:Shape;
        private var _nubbin:Sprite;
        private var _bg:Sprite;
        private var _pct:Number = 0;



        /***************** GETTERS & SETTERS ******************/
        public function get pct():Number { return _pct; }



        /******************** CONSTRUCTOR *********************/
        public function ZoomSlider() {
            super();
            verbose = true;
            addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _init();
        }



        /******************** PUBLIC API *********************/
        public function zoomTo($pct:Number, $speed:Number = 0):void {
            this.dispatchEvent(new ZoomEvent(ZoomEvent.START));
            var __newX:Number = (($pct - 1) * 140) + 5;
            TweenMax.to(_nubbin, $speed, {x:__newX, ease:Expo.easeOut, onUpdate:_trackZoomPct, onComplete:_zoomComplete})
        }


        /******************** PRIVATE API *********************/
        private function _init():void {
            var __text:Bitmap = Register.ASSETS.getBitmap('Storyboard-ZoomText');
            __text.x = 0 - __text.width - 14;
            __text.y = 0 - Math.round(__text.height * 0.5);
            this.addChild(__text);

            _bg = new Sprite();
            _bg.graphics.beginFill(0xFF00FF, 0);
            _bg.graphics.drawRect(0,-5,150,10);
            _bg.graphics.endFill();
            this.addChild(_bg);

            _track = new Shape();
            _track.graphics.lineStyle(1,0xD8D8D8);
            _track.graphics.moveTo(0,0);
            _track.graphics.lineTo(150,0);
            this.addChild(_track);

            _nubbin = new Sprite();
            _nubbin.graphics.beginFill(0xD8D8D8);
            _nubbin.graphics.drawCircle(0,0,5);
            _nubbin.graphics.endFill();
            _nubbin.x = 5;
            this.addChild(_nubbin);

            _bg.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
            _nubbin.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
        }

        private function _dragNubbin($b:Boolean = true):void {
            if ($b) {
                _nubbin.startDrag(true, new Rectangle(5,0,140,0));
                this.addEventListener(Event.ENTER_FRAME, _trackZoomPct);
            } else {
                this.removeEventListener(Event.ENTER_FRAME, _trackZoomPct);
                _nubbin.stopDrag();
            }

        }

        private function _zoomComplete():void {
            this.dispatchEvent(new ZoomEvent(ZoomEvent.END));
        }



        /****************** EVENT HANDLERS *******************/
        private function _onAdded($e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, _onAdded);

            // additional/stage-dependent setup goes here
        }

        private function _handleMouseDown($e:MouseEvent):void {
            switch ($e.type) {
                case MouseEvent.MOUSE_DOWN:
                    this.dispatchEvent(new ZoomEvent(ZoomEvent.START));
                    this.stage.addEventListener(MouseEvent.MOUSE_UP, _handleMouseUp);
                    if ($e.target == _nubbin){
                        _nubbin.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
                        _dragNubbin();
                    }
                    if ($e.target == _bg) {
                        _nubbin.x = this.mouseX;
                        _trackZoomPct();
                    }
                    break;
            }
        }

        private function _handleMouseUp($e:MouseEvent):void {
            switch ($e.type) {
                case MouseEvent.MOUSE_UP:
                    this.dispatchEvent(new ZoomEvent(ZoomEvent.END));
                    _nubbin.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
                    this.stage.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseUp);
                    _dragNubbin(false);
                    break;
            }
        }

        private function _trackZoomPct($e:Event = null):void {
            var __pct:Number = (_nubbin.x - 5)/140;
            if (__pct != _pct) {
                _pct = __pct;
                this.dispatchEvent(new ZoomEvent(ZoomEvent.CHANGE, true, {pct:_pct}))
            }
        }

    }
}
