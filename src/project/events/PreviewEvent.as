package project.events {

	import flash.events.Event;

	public class PreviewEvent extends Event {

		public static const PREVIEW:String = 'preview';
        public static const CLEAR:String = 'clear';
        public static const LOCK:String = 'lock';

        public var data:Object = {};

        public function PreviewEvent($type:String, $bubbles:Boolean = false, $data:Object = null) {
			data = $data;
            super($type, $bubbles, false);
		}
	}
}
