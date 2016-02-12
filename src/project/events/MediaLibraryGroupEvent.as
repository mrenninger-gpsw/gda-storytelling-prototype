package project.events {
	import flash.events.Event;
	
	public class MediaLibraryGroupEvent extends Event {
		
		public static const SELECT_ALL:String = 'selectAll';
		public static const DESELECT_ALL:String = 'deselectAll';
		
		public function MediaLibraryGroupEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}