/**
 * Created by mrenninger on 2/14/17.
 */
package project.events {
    import flash.events.Event;

    public class ZoomEvent extends Event {

        public static const START:String = 'zoomStart';
        public static const END:String = 'zoomEnd';
        public static const CHANGE:String = 'zoomChange';
        public static const AUTO:String = 'zoomAuto';

        public var data:Object = {};

        public function ZoomEvent($type:String, $bubbles:Boolean = false, $data:Object = null) {
            data = $data;
            super($type, $bubbles, false);
        }
    }
}
