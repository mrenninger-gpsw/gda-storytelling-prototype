package project.events {
	import flash.events.Event;
	
	public class MediaMenuEvent extends Event {
		
		public static const CHANGE:String = 'change';
		
		public function MediaMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}