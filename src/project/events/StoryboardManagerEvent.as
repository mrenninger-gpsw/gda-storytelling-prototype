package project.events {
	import flash.events.Event;

	public class StoryboardManagerEvent extends Event {

		public static const FOUR_CLIPS:String = 'fourClips';
		public static const FIVE_CLIPS:String = 'fiveClips';
		public static const SHOW_MARKER:String = 'showMarker';
        public static const ADD_CLIP:String = 'addClip';
        public static const DELETE_CLIP:String = 'deleteClip';
        public static const EDIT_CLIP:String = 'editClip';

        public var data:Object = {};

        public function StoryboardManagerEvent($type:String, $bubbles:Boolean = false, $data:Object = null) {
            data = $data;
            super($type, $bubbles, false);
		}
	}
}
