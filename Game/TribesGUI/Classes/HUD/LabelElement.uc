//================================================================
// Class: LabelElement
//
// A convenience HUDElement for displaying text labels 
//
//================================================================

class LabelElement extends HUDElement
	native;

enum ETextAlignment
{
	ALIGN_Left,
	ALIGN_Center,
	ALIGN_Right
};

var(Label) config private String text		"The text for the label";

var(Label) config bool	bCentered			"Whether the label is centered";
var(Label) config bool	bShadowed			"Whether the text of the label should be shadowed";
var(Label) config bool	bAutoWrapText		"Whether the text in the label should be auto wrapped";
var(Label) config bool	bAutoScrollText		"Whether the text should be scrolled to the left autmatically if it is too long";
var(Label) config int	shadowPixelOffset	"Offset of the shadowed text";
var(Label) config float	textInsetX			"absolute text inset X";
var(Label) config float	textInsetY			"absolute text inset Y";
var(Label) config int	hangingIndent		"Hanging indent value (in pixels)";
var(Label) config bool	bHTMLEncoded		"Whether the string could be HTML encoded";

var(Label) config Color	shadowColor			"Color to use for the shadow text, if shadowed";
var(Label) config ETextAlignment justification	"justification to use";

var bool bAutoSize;

var Array<string>	textLineArray;
var int				firstVisibleLineIndex;

//native function RenderLabel(Canvas c);

cpptext
{
	void DoTextWrap(UCanvas *canvas);
	virtual void ResizeForWidth(UCanvas *canvas, INT pixelWidth);

	// Internal Render function.
	virtual void RenderElement(UCanvas *canvas);

	// native layout function
	virtual void Layout(UCanvas *canvas);
}

///
///
function String GetText()
{
	return text;
}

///
///
function SetText(String newText)
{
	if(text != newText)
	{
		text = newText;
//		if(bAutoWrapText)
			textLineArray.Length = 0;
		if(bAutoSize)
			SetNeedsLayout();
	}
}

defaultproperties
{
	text				= ""
	textFont			= font'Engine_res.SmallFont'
	bShadowed			= false
	shadowPixelOffset	= 1
	bAutoWrapText		= true
	bAutoScrollText		= false
	bAutoSize			= true
	bHTMLEncoded		= false

	textColor			= (R=255,G=255,B=255,A=255)
	shadowColor			= (R=120,G=120,B=120,A=120)
}