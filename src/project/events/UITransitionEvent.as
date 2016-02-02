package project.events {
	import flash.events.Event;
	
	public class UITransitionEvent extends Event {
		
		public static const MUSIC:String = 'music';
		public static const VIDEO:String = 'video';
		
		public function UITransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}