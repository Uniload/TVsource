class HUDHealthBarVehicle extends HUDValueBar;

var() config HUDMaterial	lowHealthAlertMaterial;
var() config float			lowHealthThreshold;

//
// Updates the data
function UpdateData(ClientSideCharacter c)
{
	value = c.vehicleHealth;
	maximumValue = c.vehicleHealthMaximum;

	super.UpdateData(c);
}

//
// Renders the element. Overridden here due to the special requirements
// of the effects on the health bar when healing & losing health
//
function RenderElement(Canvas C)
{
	local float oldClipX;

	// calc the actual health ratio
	CalculateRatio();

	// draw the empty bar
	RenderHUDMaterial(C, activeEmptyTexture, Width, Height);
	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;

	// Clip to the current bar value
	ClipToValue(C, activeFullTexture, ratio);

	if(ratio < lowHealthThreshold)
		// low health flashy warning alert thingy
		RenderHUDMaterial(C, lowHealthAlertMaterial, Width, Height);
	else
		// normal bar
		RenderHUDMaterial(C, activeFullTexture, Width, Height);

	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;
	
	// return to the old clip
	C.ClipX = oldClipX;
}

defaultproperties
{
	lowHealthThreshold = 0.25
}