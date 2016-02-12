package project.events {
	import flash.events.Event;
	
	public class SelectionBannerEvent extends Event {
		
		public static const EDITOR_HOVER:String = 'editorHover';
		public static const EDITOR_NORMAL:String = 'editorNormal';
		public static const CLOSE:String = 'close';
		
		public function SelectionBannerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}