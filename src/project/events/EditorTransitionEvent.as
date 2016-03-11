package project.events {
	import flash.events.Event;
	
	public class EditorTransitionEvent extends Event {
		
		public static const MUSIC:String = 'music';
		public static const VIDEO:String = 'video';
		
		public function EditorTransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}