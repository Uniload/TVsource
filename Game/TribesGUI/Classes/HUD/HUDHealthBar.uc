class HUDHealthBar extends HUDValueBar;

var() config HUDMaterial	healthInjectionMaterial;
var() config HUDMaterial	healthInjectionRemainingMaterial;
var() config HUDMaterial	lowHealthAlertMaterial;
var() config float			lowHealthThreshold;

var float	healthInjectionAmount;

//
// Updates the data
function UpdateData(ClientSideCharacter c)
{
	value = c.health;
	maximumValue = c.healthMaximum;
	healthInjectionAmount = c.healthInjectionAmount;

	super.UpdateData(c);
}

//
// Renders the element. Overridden here due to the special requirements
// of the effects on the health bar when healing & losing health
//
function RenderElement(Canvas C)
{
	local float oldClipX;
	local float injectionRatio;

	// calc the actual health ratio
	CalculateRatio();

	// draw the empty bar
	RenderHUDMaterial(C, activeEmptyTexture, Width, Height);
	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;

	// want to render the usual full texture here,
	// only clipped to the point that the healthInjection
	// will finish
	oldClipX = C.ClipX;	
	if(healthInjectionAmount > 0)
	{
		injectionRatio = FClamp((healthInjectionAmount / maximumValue) + ratio, 0.0, 1.0);
		ClipToValue(C, healthInjectionRemainingMaterial, injectionRatio);
		// draw the empty bar
		RenderHUDMaterial(C, healthInjectionRemainingMaterial, Width, Height);
		// DrawTile sets CurX, CurY
		C.CurX = 0;
		C.CurY = 0;
	}

	// Clip to the current bar value
	ClipToValue(C, activeFullTexture, ratio);

	// draw the full bar, clipped to the ratio
	if(healthInjectionAmount > 0)
		// health injection pulsing thingy
		RenderHUDMaterial(C, healthInjectionMaterial, Width, Height);
	else if(ratio < lowHealthThreshold && healthInjectionAmount <= 0)
		// low health flashy warning alert thingy
		RenderHUDMaterial(C, lowHealthAlertMaterial, Width, Height);
	else
		// low health flashy warning alert thingy
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