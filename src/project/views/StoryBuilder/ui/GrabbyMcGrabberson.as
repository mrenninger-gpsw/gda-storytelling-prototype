/**
 * Created by mrenninger on 2/7/17.
 */
package project.views.StoryBuilder.ui {
import display.Sprite;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import utils.Register;

public class GrabbyMcGrabberson extends Sprite {
    private var _open:Bitmap;
    private var _closed:Bitmap;

    public function GrabbyMcGrabberson() {
        super();
        //verbose = true;
        addEventListener(Event.ADDED_TO_STAGE, _onAdded);
        this.visible = false;
        _init();
    }

    public function show($b:Boolean = true):void {
        log('show: '+$b);
        this.visible = $b;
    }

    public function grab($b:Boolean = true):void {
        _open.visible = !$b;
        _closed.visible = $b;
    }

    private function _init():void {
        _open = Register.ASSETS.getBitmap('HandCursor_Open');
        _open.x = -_open.width/2;
        _open.y = -_open.height/2;
        this.addChild(_open);

        _closed = Register.ASSETS.getBitmap('HandCursor_Closed');
        _closed.x = -_closed.width/2;
        _closed.y = -_closed.height/2;
        _closed.visible = false;
        this.addChild(_closed);
    }

    private function _onAdded($e:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
    }


}
}
