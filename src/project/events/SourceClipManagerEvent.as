package project.events {
	import flash.events.Event;

	public class SourceClipManagerEvent extends Event {

		public static const SHOW_COMPLETE:String = 'showComplete';
		public static const HIDE_COMPLETE:String = 'hideComplete';
		public static const ADD_MEDIA:String = 'addMedia';
        public static const CREATE_INITIAL_CLIP:String = 'createInitialClip';
        public static const SHOW_HILITE:String = 'showHilite';

        public var data:Object = {};

        public function SourceClipManagerEvent($type:String, $data:Object=null) {
			data = $data;
            super($type, true, false);
		}
	}
}
