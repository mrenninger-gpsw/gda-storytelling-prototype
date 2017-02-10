/**
 * Created by mrenninger on 2/3/17.
 */
package project.views {
    import com.greensock.TweenMax;
    import com.greensock.easing.Circ;

    import display.Sprite;

import flash.display.Shape;

import flash.events.Event;

import project.events.ViewTransitionEvent;

import project.views.Footer.ui.FooterBtn;

import utils.Register;

    public class AdvancedEditor extends Sprite {

        /******************** PRIVATE VARS ********************/
        private var _transitionStart:Number;
        private var _time:Number;
        private var _isActive:Boolean = false;
        private var _transitionCompleteCount:uint = 0;



        /***************** GETTERS & SETTERS ******************/
        public function get isActive():Boolean { return _isActive; }


        /******************** CONSTRUCTOR *********************/
        public function AdvancedEditor() {
            super();
            verbose = true;
            this.addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            TweenMax.to(this, 0, {autoAlpha:0});
            _init();
        }



        /********************* PUBLIC API *********************/
        public function show():void {
            _isActive = true;
            _transitionStart = new Date().getTime();
            _transitionCompleteCount = 0;
            TweenMax.to(this, 0.3, {autoAlpha:1});
        }

        public function hide($immediate:Boolean = false):void {
            _isActive = false;
            _transitionCompleteCount = 0;
            _transitionStart = new Date().getTime();
            TweenMax.to(this, ($immediate) ? 0 : 0.3, {autoAlpha:0});
        }



        /******************** PRIVATE API *********************/
        private function _init():void {

            var __bg:Shape;
            __bg = new Shape();
            __bg.graphics.beginFill(0x222222);
            __bg.graphics.drawRect(0,0,Register.APP.WIDTH, Register.APP.HEIGHT);
            __bg.graphics.endFill();
            __bg.alpha = 1;
            this.addChild(__bg);

            __bg = new Shape();
            __bg.graphics.beginFill(0x1D1D1D);
            __bg.graphics.drawRect(0,0,Register.APP.WIDTH, 203);
            __bg.graphics.endFill();
            __bg.alpha = 1;
            __bg.y = 582;
            this.addChild(__bg);

            __bg = new Shape();
            __bg.graphics.beginFill(0x141414);
            __bg.graphics.drawRect(0,0,Register.APP.WIDTH, 80);
            __bg.graphics.endFill();
            __bg.alpha = 1;
            __bg.y = Register.APP.HEIGHT - __bg.height;
            this.addChild(__bg);

            var __btn:FooterBtn;
            __btn = new FooterBtn(115,44,Register.ASSETS.getBitmap('AdvEditor_Text-Apply'));
            __btn.name = 'apply';
            __btn.x = Register.APP.WIDTH - __btn.width - 19;
            __btn.y = Register.APP.HEIGHT - __btn.height - 19;
            __btn.addEventListener('clicked', _handleClick);
            this.addChild(__btn);

            __btn = new FooterBtn(115,44,Register.ASSETS.getBitmap('AdvEditor_Text-Cancel'),false);
            __btn.name = 'cancel';
            __btn.x = Register.APP.WIDTH - (__btn.width * 2) - 38;
            __btn.y = Register.APP.HEIGHT - __btn.height - 19;
            __btn.addEventListener('clicked', _handleClick);
            this.addChild(__btn);
        }



        /******************* EVENT HANDLERS *******************/
        protected function _onAdded($e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
        }

        private function _handleClick($e:Event):void {
            switch ($e.target.name){
                case 'apply':
                    this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.EDITOR));
                    break;

                case 'cancel':
                    this.stage.dispatchEvent(new ViewTransitionEvent(ViewTransitionEvent.EDITOR));
                    break;
            }
        }

        private function _handleTransitionCompleteEvent($e:Event):void {
            switch ($e.type) {
                case 'showComplete':
                    _transitionCompleteCount++;
                    if (_transitionCompleteCount == 3){
                        log('showComplete - elapsed: '+(new Date().getTime() - _transitionStart));
                        dispatchEvent(new Event('showComplete'));
                    }
                    break;

                case 'hideComplete':
                    _transitionCompleteCount++;
                    if (_transitionCompleteCount == 3){
                        log('hideComplete - elapsed: '+(new Date().getTime() - _transitionStart));
                        dispatchEvent(new Event('hideComplete'));
                    }
                    break;
            }
        }

    }
}
