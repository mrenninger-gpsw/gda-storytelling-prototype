package project.events {
	import flash.events.Event;
	
	public class AddMediaDrawerEvent extends Event {
		
		public static const SELECT_ALL:String = 'selectAll';
		public static const DESELECT_ALL:String = 'deselectAll';
		public static const ADD_MEDIA_DRAWER_SHOW:String = 'addMediaDrawerShow'
		public static const ADD_MEDIA_DRAWER_HIDE:String = 'addMediaDrawerHide'
		
		public function AddMediaDrawerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}