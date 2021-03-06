package project.events {

	import flash.events.Event;

	public class PreviewEvent extends Event {

		public static const PREVIEW:String = 'preview';
        public static const CLEAR:String = 'clear';
        public static const LOCK:String = 'lock';
        public static const PAUSE:String = 'pause';
        public static const PLAY:String = 'play';
        public static const COMPLETE:String = 'complete';
        public static const PLAY_VIDEO:String = 'playVideo';
        public static const PAUSE_VIDEO:String = 'pauseVideo';
        public static const CHANGE_VIDEO:String = 'changeVideo'

        public var data:Object = {};

        public function PreviewEvent($type:String, $bubbles:Boolean = false, $data:Object = null) {
			data = $data;
            super($type, $bubbles, false);
		}
	}
}
