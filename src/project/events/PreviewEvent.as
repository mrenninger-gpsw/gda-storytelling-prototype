package project.events {
	
	import flash.events.Event;
	
	public class PreviewEvent extends Event {
		
		public static const PREVIEW:String = 'preview';
		public static const CLEAR:String = 'clear';
		
		public function PreviewEvent($type:String, $bubbles:Boolean = false, $cancelable:Boolean = false) {
			super($type, $bubbles, $cancelable);
		}
	}
}