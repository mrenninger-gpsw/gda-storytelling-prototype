/**
 * Created by mrenninger on 2/15/17.
 */
package project.views.StoryBuilder.ui {

    // Flash
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle

    // GreenSock
    import com.greensock.TweenMax;
    import com.greensock.easing.Expo;

    // Framework
    import display.Sprite;

    // Project
    import project.events.ScrollEvent;



    public class StoryboardScroller extends Sprite {

        private var _bar:Sprite;
        private var _barWidth:Number;
        private var _pct:Number = 0;
        private var _canDrag:Boolean = true;
        private var _dragging:Boolean = true;



        /***************** GETTERS & SETTERS ******************/
        public function get pct():Number { return _pct; }

        public function set canDrag($value:Boolean):void {
            _canDrag = $value;
            if (!_canDrag && _dragging) { _dragBar(false); }
            if (_canDrag && _dragging) { _dragBar(true); }
        }

        public function get canDrag():Boolean { return _canDrag;}



        /******************** CONSTRUCTOR *********************/
        public function StoryboardScroller($width:Number) {
            super();
            _barWidth = $width;
            verbose = true;
            addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _init();
        }



        /********************* PUBLIC API *********************/
        public function zoom($increment:Number):void {
            TweenMax.to(_bar, 0.2, {autoAlpha:($increment > 1)?1:0});
            _bar.scaleX = 1 / $increment;
            _bar.x = _pct * (_barWidth - _bar.width);
            if ($increment == 1) {
                _pct = 0;
            }
        }

        public function scrollTo($pct:Number, $speed:Number = 0, $throwing:Boolean = false):void {
            _pct = $pct;

            TweenMax.to(_bar, $speed, {x:$pct * (_barWidth - _bar.width), ease:($throwing) ? Expo.easeOut : Expo.easeInOut});
            //_bar.x = $pct * (_barWidth - _bar.width);
        }



        /********************* PRIVATE API *********************/
        private function _init():void {
            _bar = new Sprite();
            _bar.graphics.beginFill(0x353535);
            _bar.graphics.drawRect(0, 0, _barWidth, 8);
            _bar.graphics.endFill();
            TweenMax.to(_bar, 0, {autoAlpha:0});
            this.addChild(_bar);

            _bar.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);

        }

        private function _dragBar($b:Boolean = true):void {
            if ($b) {
                TweenMax.to(_bar, 0, {tint:0x454545});
                _bar.removeEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
                this.stage.addEventListener(MouseEvent.MOUSE_UP, _handleMouseUp);
                this.addEventListener(Event.ENTER_FRAME, _trackScrollPct);
                this.dispatchEvent(new ScrollEvent(ScrollEvent.START));
                _bar.startDrag(false, new Rectangle(0, 0, _barWidth - _bar.width, 0));
            } else {
                TweenMax.to(_bar, 0.2, {tint:null});
                _bar.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown);
                this.stage.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseUp);
                this.removeEventListener(Event.ENTER_FRAME, _trackScrollPct);
                this.dispatchEvent(new ScrollEvent(ScrollEvent.END));
                _bar.stopDrag();
            }
        }



        /******************* EVENT HANDLERS *******************/
        private function _onAdded($e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
        }

        private function _handleMouseDown($e:MouseEvent):void {
            switch ($e.type) {
                case MouseEvent.MOUSE_DOWN:
                    _dragging = true;
                    _dragBar();
                    break;
            }
        }

        private function _handleMouseUp($e:MouseEvent):void {
            switch ($e.type) {
                case MouseEvent.MOUSE_UP:
                    _dragging = false;
                    _dragBar(false);
                    break;
            }
        }

        private function _trackScrollPct($e:Event = null):void {
            var __pct:Number = Math.ceil(_bar.x)/ (_barWidth - Math.ceil(_bar.width));
            var __pct3:Number = _restrictDigits(__pct,3);

            if (__pct3 != _pct) {
                _pct = __pct3;
                this.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL, false, {pct: _pct}));
            }
        }



        /*********************** HELPERS **********************/
        private function _restrictDigits($num:Number, $restrict:Number):Number {
            return Math.round($num * Math.pow(10,$restrict))/Math.pow(10,$restrict);;
        }
    }
}
