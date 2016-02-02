package project.events {
	import flash.events.Event;
	
	public class SourceClipManagerEvent extends Event {
		
		public static const SHOW_COMPLETE:String = 'showComplete';
		public static const HIDE_COMPLETE:String = 'hideComplete';
		
		public function SourceClipManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}