package project.events {
	import flash.events.Event;
	
	public class ViewTransitionEvent extends Event {
		
		public static const MEDIA:String = 'media';
		public static const EDITOR:String = 'editor';
		public static const ADD_LIBRARY_CLIPS:String = 'addLibraryClips';
		public static const PREPARE_TO_ADD:String = 'prepareToAdd';
		
		public function ViewTransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}