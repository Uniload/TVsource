class HUDEnergyBar extends HUDValueBar;

var() config HUDMaterial	depletionMaterial;
var() config float			depletionFadeTime;

var float energyWeaponDepleted;
var float depletionAlpha;
var float depletionStartTime;
var float depletionStartRatio;

function UpdateData(ClientSideCharacter c)
{
	bVisible = c.bShowEnergyBar;
	if(bVisible)
	{
		value = c.energy;
		maximumValue = c.energyMaximum;

		if(c.energyWeaponDepleted > 0)
		{
			energyWeaponDepleted = c.energyWeaponDepleted;
			depletionStartRatio = FClamp(value / maximumValue, 0.0, 1.0);

			depletionMaterial.fadeStartTime = c.levelTimeSeconds;
			depletionMaterial.fadeProgress = 0;
		}
	}

	super.UpdateData(c);
}

//
// Renders the element. Overridden here due to the special requirements
// of the effects on the health bar when healing & losing health
//
function RenderElement(Canvas C)
{
	local float oldClipX;
	local float depletionRatio;

	// dont want to call the super render, otherwise we 
	// will get extra layuers rendering that we dont want
//	super.RenderElement(C);

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
	if(energyWeaponDepleted > 0)
	{
		depletionRatio = FClamp((energyWeaponDepleted / maximumValue) + depletionStartRatio, 0.0, 1.0);
		ClipToValue(C, depletionMaterial, depletionRatio);
		RenderHUDMaterial(C, depletionMaterial, Width, Height);
		// DrawTile sets CurX, CurY
		C.CurX = 0;
		C.CurY = 0;
	}

	// Clip to the current bar value
	ClipToValue(C, activeFullTexture, ratio);

	// draw the full bar, clipped to the ratio
	RenderHUDMaterial(C, activeFullTexture, Width, Height);
	// DrawTile sets CurX, CurY
	C.CurX = 0;
	C.CurY = 0;
	
	// return to the old clip
	C.ClipX = oldClipX;
}
