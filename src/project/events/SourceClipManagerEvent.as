package project.events {
	import flash.events.Event;
	
	public class SourceClipManagerEvent extends Event {
		
		public static const SHOW_COMPLETE:String = 'showComplete';
		public static const HIDE_COMPLETE:String = 'hideComplete';
		public static const ADD_MEDIA:String = 'addMedia';
		
		public function SourceClipManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}