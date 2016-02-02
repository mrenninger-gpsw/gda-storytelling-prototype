package project.events {
	import flash.events.Event;
	
	public class MusicMenuEvent extends Event {
		
		public static const CHANGE:String = 'change';
		
		public function MusicMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}