//
// A HUDValueBar that can be of any length, useful for
// health and energy bars which can be different lengths
//
class HUDExtendableValueBar extends HUDValueBar;

var() config float		pixValueRatio	"Ratio of a pixel to the bar value units";

var() config MatCoords	iconCoords		"texture coordinates (in pixels) of the icon at the start of the bar";
var() config MatCoords	tileCoords		"texture coordinates (in pixels) of the section to tile in the middle of the bar";
var() config MatCoords	capCoords		"texture coordinates (in pixels) of the cap on the end of the bar";

var float oldMaximumValue;

//
// We need to check each time the data changes, because
// if the max value has changed a new layout must be calculated
//
function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);
/*
	if(oldMaximumValue != maximumValue)
	{
		SetNeedsLayout();
		oldMaximumValue = maximumValue;
	}
	*/
}
/*
//
// Layout the component
// Overridden to set the width based on the max value and
// the ratio of pixels to value units
//
event DoLayout(Canvas c)
{
	if(ParentElement != None)
		Width = (maximumValue * pixValueRatio);
	else // should never go to the else, but cover it anyway:
		Width = (maximumValue * pixValueRatio);
	initialWidth = Width;

	super.DoLayout(c);
}
*/
//
// Override RenderBarLayer to handle the extended texture
//
function RenderBarLayer(Canvas C, out HUDMaterial mat)
{
	local float capWidth, iconWidth, tileWidth;
	local float oldClipX;

	iconWidth = iconCoords.UL * Height / mat.material.GetVSize();
	capWidth = capCoords.UL * Height / mat.material.GetVSize();
	tileWidth = tileCoords.UL * Height / mat.material.GetVSize();

	// render the start icon
	oldClipX = C.ClipX;
	if(C.ClipX >= iconWidth)
		C.ClipX = iconWidth;
	C.CurX = 0;
	C.CurY = 0;
	mat.coords = iconCoords;
	RenderHUDMaterial(C, mat, iconWidth, Height);
	C.ClipX = oldClipX;

	//
	// Tile the actual bar section as far as it needs to go
	oldClipX = C.ClipX;
	if(C.ClipX >= (Width - capWidth))
		C.ClipX = (Width - capWidth);
	C.CurX = iconWidth;
	C.CurY = 0;
	SetColor(c, mat.drawColor);
	mat.coords = tileCoords;
	RenderHUDMaterial(C, mat, tileWidth, Height, Width, 0); // tile to the width

	//
	// Draw the cap on the end of the bar
	C.ClipX = oldClipX;
	if(C.ClipX >= Width - capWidth)
	{
		C.CurX = Width - capWidth;
		C.CurY = 0;

		// set texture co-ords and render
		mat.coords = capCoords;
		RenderHUDMaterial(C, mat, capWidth, Height);
	}

	mat.coords.U = 0;
	mat.coords.V = 0;
	mat.coords.UL = 0;
	mat.coords.VL = 0;

	C.CurX = 0;
	C.CurY = 0;
}

defaultproperties
{
	iconCoords=(U=0,V=0,UL=60,VL=64)
	tileCoords=(U=60,V=0,UL=800,VL=64)
	capCoords=(U=1000,V=0,UL=24,VL=64)

	pixValueRatio	= 2.1		// 1.25 pixels to a unit
}