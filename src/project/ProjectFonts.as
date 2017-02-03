package project {
	import flash.text.Font;

	import air.fonts.Fonts;

	import text.TextUtilities;

	public class ProjectFonts extends Fonts{


		// UNICODE RANGE REFERENCE
		/*


		if you really want to embed fonts...



		Default ranges
		U+0020-U+0040, // Punctuation, Numbers
		U+0041-U+005A, // Upper-Case A-Z
		U+005B-U+0060, // Punctuation and Symbols
		U+0061-U+007A, // Lower-Case a-z
		U+007B-U+007E, // Punctuation and Symbols

		Extended ranges (if multi-lingual required)
		U+0080-U+00FF, // Latin I
		U+0100-U+017F, // Latin Extended A
		U+0400-U+04FF, // Cyrillic
		U+0370-U+03FF, // Greek
		U+1E00-U+1EFF, // Latin Extended Additional
		*/




		/*


		[Embed(	source 		 = '../../../../assets/fonts/GillSansMTPro/GillSansMTPro-MediumItalic.otf',
		fontName 	 = 'GillSansProMediumItalic',
		unicodeRange = 'U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E',
		mimeType 	 = 'application/x-font',
		embedAsCFF	 = 'false'
		)]

		public var GillSansProMediumItalic:Class;*/





		/******************** CONSTRUCTOR *********************/


		public function ProjectFonts($iOS:Boolean = true):void {
			super();

		}







		/******************** PUBLIC API *********************/


		public override function onFontLoadComplete():void{
			verbose = false;
			/*Font.registerFont(GillSansProMedium);
			Font.registerFont(GillSansProLight);
			Font.registerFont(GillSansProBook);
			Font.registerFont(GillSansProLightItalic);
			Font.registerFont(GillSansProBold);
			Font.registerFont(GillSansProMediumItalic);*/

			Font.registerFont(ProximaNovaBlack);
			Font.registerFont(ProximaNovaBold);
			Font.registerFont(ProximaNovaBoldItalic);
			Font.registerFont(ProximaNovaExtrabold);
			Font.registerFont(ProximaNovaLight);
			Font.registerFont(ProximaNovaLightItalic);
			Font.registerFont(ProximaNovaRegular);
			Font.registerFont(ProximaNovaRegularItalic);
			Font.registerFont(ProximaNovaSemibold);
			Font.registerFont(ProximaNovaSemiboldItalic);

			if(verbose) TextUtilities.fontCheck();
		}

	}
}

