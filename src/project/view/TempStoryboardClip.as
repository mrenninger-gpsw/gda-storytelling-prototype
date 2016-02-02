package project.view {
	
	// Flash
	import flash.display.Bitmap;
	import flash.display.Shape;
	
	// CandyLizard
	import display.Sprite;
	import utils.Register;
	
	// Project
	import project.view.ui.StoryboardClipMarker;
	
	
	
	
	public class TempStoryboardClip extends Sprite {
		
		// vars
		private var _holder:Sprite;
		private var _curImageName:String;
		private var _markerIcon:Sprite;
		private var _markerLine:Shape;
		private var _mask:Shape;
		private var _xml:XML;
		private var _num:uint
		private var _marker:StoryboardClipMarker;

		
		
		// Getters & Setters
		public function get curFileName():String { return _curImageName; }		
		public function get maskShape():Shape { return _mask; }
		
		
		
		// Constructor
		public function TempStoryboardClip($num:uint) {
			super();
			
			verbose = true;
			
			_xml = Register.PROJECT_XML.content.editor.storyboard.clip[$num];
			//log('_xml: '+_xml);
			_curImageName = _xml.@src;
			//log('_curImageName: '+_curImageName);
			
			_holder = new Sprite();			
			addChild(_holder);
			
			_mask = new Shape();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.drawRect(0,0,1,99);
			_mask.graphics.endFill();
			addChild(_mask);
			_holder.mask = _mask;
			
			_init();
		}
		

		
		// Private API
		private function _init():void {
			//log('_init');
			
			var tThumb:Bitmap = Register.ASSETS.getBitmap(_curImageName);
			tThumb.x = -tThumb.width * 0.5;
			tThumb.y = -tThumb.height * 0.5;			
			_holder.addChild(tThumb);
			
			_mask.x = Number(_xml.location[0].mask.@left)
			_mask.y = tThumb.y;
			_mask.width = Number(_xml.location[0].mask.@width) 
			
			_marker = new StoryboardClipMarker();
			_marker.show(true);
			addChild(_marker);
			
		}
	}
}