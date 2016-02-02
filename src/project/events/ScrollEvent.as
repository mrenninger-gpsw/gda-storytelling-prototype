package project.events{
	
	// Flash
	import flash.events.Event;
	
	
	
	public class ScrollEvent extends Event {

		/********************* CONSTANTS **********************/
		public static const SCROLL:String = 'scroll';
		public static const SCROLL_V:String = 'scrollH';
		public static const SCROLL_H:String = 'scrollV';

		
		
		/******************* PRIVATE VARS *********************/

		
		
		/***************** GETTERS & SETTERS ******************/
		
		
		
		/******************** CONSTRUCTOR *********************/
		public function ScrollEvent($type:String, $bubbles:Boolean = false, $cancelable:Boolean = false) {
			super($type, $bubbles, $cancelable);
		}		
		
		
		
		/******************** PRIVATE API *********************/		
		
		
		
		/******************** PUBLIC API *********************/
		
		
		
		
	}
}