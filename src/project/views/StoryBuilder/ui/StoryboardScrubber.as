/**
 * Created by mrenninger on 1/31/17.
 */
package project.views.StoryBuilder.ui {

    // Greensock
    import com.greensock.TweenMax;

    // Framework
    import display.Sprite;
    import utils.Register;


    public class StoryboardScrubber extends Sprite {

        /******************** PRIVATE VARS ********************/
        private var _handleTop:Sprite;
        private var _handleBtm:Sprite;



        /***************** GETTERS & SETTERS ******************/
        public function get handle():Sprite { return _handleTop; }



        /******************** CONSTRUCTOR *********************/
        public function StoryboardScrubber() {
            super();
            verbose = true;
            mouseChildren = false;
            _init();
        }



        /******************** PRIVATE API *********************/
        private function _init():void {
            var __line:Sprite = new Sprite();
            __line.graphics.lineStyle(1,0xFFFFFF);
            __line.graphics.moveTo(0,0);
            __line.graphics.lineTo(0,192);
            __line.y = -2;
            this.addChild(__line);

            _handleTop = new Sprite();
            _handleTop.addChild(Register.ASSETS.getBitmap('StoryboardScrubberHandle'));
            _handleTop.x = -_handleTop.width/2;
            _handleTop.y = -11;
            TweenMax.to(_handleTop, 0, {tint:0xFFFFFF});
            this.addChild(_handleTop);

        }
    }
}
