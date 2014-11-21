// A bar that could be an energy bar or a health bar.
// The 'maximum value' of the bar is user-defined. 
class HUDValueBar extends HUDContainer
	native;

var() config HUDMaterial	emptyTexture	"Default Texture for the empty bar";
var() config HUDMaterial	fullTexture		"Default Texture for the full bar";

var() config float		barStartOffset	"X offset (in texture co-ords) of the start of the bar region";
var() config float		barEndOffset	"X offset (in texture co-ords) of the end of the bar region";

var() config float		value			"current value of the bar";
var() config float		maximumValue	"max value for the bar";

var() config HUDMaterial	activeEmptyTexture	"Texture for the empty bar";
var() config HUDMaterial	activeFullTexture	"Texture for the full bar";

var() config String			LabelConfigName		"Name of the config item for the label";
var() config int			MaxDisplayDigits	"Maximum number of digitd to display";
var HUDNumericTextureLabel	ValueLabel			"Value label";

var float barStart;			// will contain the offset from the start of the texture to the actual value region
var float barEnd;			// will contain the offset from the end of the texture to the end of the actual value region
var float barWidth;			// will contain the width of the actual bar region
var float ratio;			// current ratio of value/maximumValue
var bool bReverse;			// whether to reverse the direction of the value

CPPTEXT
{
	// Internal NativeRender function.
	virtual void RenderElement(UCanvas *canvas);

	void ClipToValue(UCanvas *canvas, FHUDMaterial mat, float clipRatio);
}

native function ClipToValue(Canvas C, HUDMaterial mat, float clipRatio);

function InitElement()
{
	super.InitElement();
	activeEmptyTexture = emptyTexture;
	activeFullTexture = fullTexture;

	if(LabelConfigName != "" && ValueLabel == None)
	{
		ValueLabel = HUDNumericTextureLabel(AddClonedElement("TribesGUI.HUDNumericTextureLabel", LabelConfigName));
	}
}

function UpdateData(ClientSideCharacter c)
{
	local String ValueString;
	local int IntValue, paddingCount, i;

	// calc the ratio
	CalculateRatio();

	// set the value of the label before it gets rendered
	if(ValueLabel != None)
	{
		IntValue = int(value);
		if(IntValue < value)
			IntValue += 1;
		ValueString $= IntValue;
		paddingCount = MaxDisplayDigits - Len(ValueString);
		for(i = 0; i < paddingCount; ++i)
			ValueString = "0" $ValueString;
		ValueLabel.SetDataString(valueString);
	}
}

//
// Calculates the current ratio
//
function CalculateRatio()
{
	if(value > maximumValue)
		ratio = 1;
	else
		ratio = value / maximumValue;

	if(bReverse)
		ratio = 1.0 - ratio;
}
/*
//
// Clips the passed cavas to the current ratio
//
function ClipToValue(Canvas canvas, HUDMaterial mat, float clipRatio)
{
	local float textureElementSizeRatio;
	
	if(mat.material == None)
		return;

	if(mat.coords.UL > 0)
		textureElementSizeRatio = Width / mat.coords.UL;
	else
		textureElementSizeRatio = Width / mat.material.GetUSize();

	// clip the texture for the full bar
	barStart = barStartOffset * textureElementSizeRatio;
	barEnd = barEndOffset * textureElementSizeRatio;
	barWidth = Width - (barStart + barEnd);
	C.ClipX = barStart + (clipRatio * barWidth);
}


//
// Renders the element
//
function RenderElement(Canvas C)
{
	local float oldClipX;

	super.RenderElement(C);


	// draw the empty bar
	RenderHUDMaterial(C, activeEmptyTexture, Width, Height);
	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;

	// Clip to the current bar value
	oldClipX = C.ClipX;	
	ClipToValue(C, activeFullTexture, ratio);

	// draw the full bar, clipped to the ratio
	RenderHUDMaterial(C, activeFullTexture, Width, Height);
	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;
	
	// return to the old clip
	C.ClipX = oldClipX;
}
*/
defaultproperties
{
	barStartOffset	= 0
	maximumValue	= 500
	MaxDisplayDigits = 3
}