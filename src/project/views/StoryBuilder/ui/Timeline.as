/**
 * Created by mrenninger on 2/15/17.
 */
package project.views.StoryBuilder.ui {
import com.greensock.TweenMax;

import components.controls.Label;

import display.Sprite;

import flash.display.Shape;

import flash.events.Event;
import flash.geom.Rectangle;

import utils.Register;

public class Timeline extends Sprite {

    private var _length:Number;
    private var _ticksV:Vector.<Sprite>;
    private var _tlWidth:Number = 1240;
    private var _initBounds:Rectangle;
    public function get initBounds():Rectangle { return _initBounds; }

    public function set tlWidth($value:Number):void { _tlWidth = $value; }
    public function get tickWidth():Number { return (_ticksV[_ticksV.length - 1].x - _ticksV[0].x); }



    public function Timeline($length:Number = 30) {
        super();
        verbose = true;
        _length = $length;
        addEventListener(Event.ADDED_TO_STAGE, _onAdded);
        _init();
    }

    public function zoom($increment:Number):void {
        for (var i:uint = 0; i < _ticksV.length; i++) {
            _ticksV[i].x = i * ((_tlWidth/_length)/4) * $increment;
        }
        log
    }

    private function _init():void {
        //var __tl = Register.ASSETS.getBitmap('Storyboard-TimelineNoBumper');
        //this.addChild(__tl);
        _ticksV = new <Sprite>[];

        var __tick:Sprite;
        var __line:Shape;

        for (var i:uint = 0; i <= _length; i++) {
            // create a long tick
            __tick = new Sprite();

            __line = new Shape();
            __line.graphics.beginFill(0x353535);
            __line.graphics.drawRect(0,0,1,14);
            __line.graphics.endFill();
            __tick.addChild(__line);

            if (i == 0 || i == (_length/2) || i == _length){
                // create a seconds indicator
                var __tf:Label = new Label();
                __tf.mouseEnabled = false;
                __tf.mouseChildren = false;
                __tf.text = ':'+_addLeadingZeros(i);
                __tf.autoSize = 'left';
                __tf.textFormatName = 'storyboard-timeline';
                __tf.x = 0 - Math.round(__tf.width * 0.5);
                __tf.y = 14;
                __tick.addChild(__tf);
            }
            __tick.x = (i == 0) ? 0 : _ticksV[_ticksV.length-1].x + (_tlWidth/_length)/4;
            this.addChild(__tick);
            // add it to _ticksV
            _ticksV.push(__tick);

            if (i < _length){
                for (var j:uint = 0; j < 3; j++){
                    // create 4 short ticks and add them to _ticksV
                    var __subtick:Sprite = new Sprite();
                    __line = new Shape();
                    __line.graphics.beginFill(0x353535);
                    __line.graphics.drawRect(0,0,1,4);
                    __line.graphics.endFill();
                    __subtick.addChild(__line);

                    __subtick.x = _ticksV[_ticksV.length-1].x + (_tlWidth/_length)/4;
                    this.addChild(__subtick);
                    // add it to _ticksV
                    _ticksV.push(__subtick);
                }
            }
        }

        zoom(1);
    }



    private function _onAdded($e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
        _initBounds = this.getBounds(this.parent);
    }



    private static function _addLeadingZeros($num:Number):String {
        var str:String = ($num < 10) ?  '0' + $num.toString() : $num.toString();
        return str;
    }
}
}
