/**
 * Created by mrenninger on 2/15/17.
 */
package project.views.StoryBuilder.ui {
    import com.greensock.TweenMax;

    import display.Sprite;

    import flash.display.Bitmap;
import flash.display.Shape;
import flash.geom.Rectangle

import flash.events.Event;
    import utils.Register;

    public class AudioWaveformDisplay extends Sprite {

        private var _waveform:Bitmap;
        private var _markerHolderMask:Bitmap;
        private var _markerHolder:Sprite;
        private var _progressShape:Shape;
        private var _markersV:Vector.<Shape>;
        private var _initBounds:Rectangle;

        public function get markers():Vector.<Shape> { return _markersV; }
        public function get progressShape():Shape { return _progressShape; }
        public function get initBounds():Rectangle { return _initBounds; }




        public function AudioWaveformDisplay() {
            super();
            verbose = true;
            addEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _init();
        }



        public function zoom($increment:Number):void {
            this.scaleX = $increment;
        }

        public function addMarker($marker:Shape):void {
            _markerHolder.addChild($marker);
            _markersV.push($marker);
        }

        public function removeMarker($index:uint):void {
            _markerHolder.removeChild(_markersV[$index]);
            _markersV.removeAt($index);
        }



        private function _init():void {
            _markersV = new <Shape>[];

            // waveform and waveform markers
            _waveform = Register.ASSETS.getBitmap('Storyboard-AudioWavesNoBumper');
            TweenMax.to(_waveform, 0, {tint:0x353535});
            this.addChild(_waveform);

            _markerHolder = new Sprite();
            this.addChild(_markerHolder);

            _progressShape = new Shape();
            _progressShape.graphics.beginFill(0x666666);
            _progressShape.graphics.drawRect(0,0,1240,70);
            _progressShape.graphics.endFill();
            _progressShape.scaleX = 0;
            _markerHolder.addChild(_progressShape);

            _markerHolderMask = Register.ASSETS.getBitmap('Storyboard-AudioWavesNoBumper');
            this.addChild(_markerHolderMask);
            _markerHolderMask.cacheAsBitmap = true;
            _markerHolder.mask = _markerHolderMask;
            // ***************
        }



        private function _onAdded($e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
            _initBounds = this.getBounds(this.parent);
        }

    }
}
