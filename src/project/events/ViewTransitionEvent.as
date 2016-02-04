package project.events {
	import flash.events.Event;
	
	public class ViewTransitionEvent extends Event {
		
		public static const MEDIA:String = 'media';
		public static const EDITOR:String = 'editor';
		
		public function ViewTransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}