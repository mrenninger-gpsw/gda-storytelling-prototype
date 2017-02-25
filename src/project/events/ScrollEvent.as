package project.events{

	// Flash
	import flash.events.Event;



	public class ScrollEvent extends Event {

		/********************* CONSTANTS **********************/
        public static const START:String = 'scrollStart';
        public static const END:String = 'scrollEnd';
		public static const SCROLL:String = 'scroll';
		public static const SCROLL_V:String = 'scrollH';
		public static const SCROLL_H:String = 'scrollV';

        public var data:Object = {};



        /******************* PRIVATE VARS *********************/



		/***************** GETTERS & SETTERS ******************/



		/******************** CONSTRUCTOR *********************/
        public function ScrollEvent($type:String, $bubbles:Boolean = false, $data:Object = null) {
            data = $data;
            super($type, $bubbles, false);
        }



		/******************** PRIVATE API *********************/



		/******************** PUBLIC API *********************/




	}
}
