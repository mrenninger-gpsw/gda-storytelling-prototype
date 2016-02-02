package project.events {
	import flash.events.Event;
	
	public class StoryboardManagerEvent extends Event {
		
		public static const FOUR_CLIPS:String = 'fourClips';
		public static const FIVE_CLIPS:String = 'fiveClips';
		public static const SHOW_MARKER:String = 'showMarker';
		
		public function StoryboardManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}