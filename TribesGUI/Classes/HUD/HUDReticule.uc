//
// class: HUDReticule
//
// Element to paint the targetting reticule onto the HUD
// different reticules are supported, which can be changed via
// the current selected weapon/deployable in ClientSideCharacter
//
class HUDReticule extends HUDContainer;

var config HUDMaterial	reticuleMaterial;
var float			retWidth;
var float			retHeight;
var float			hotspotX;
var float			hotspotY;

function InitElement()
{
	super.InitElement();
}

function UpdateReticule(ClientSideCharacter c);

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);
	UpdateReticule(c);
}

function RenderElement(Canvas c)
{
	super.RenderElement(c);

	// render the reticule
	c.CurX = ((Width - retWidth) / 2) + ((retWidth / 2) - hotspotX);
	c.CurY = ((Height - retHeight) / 2) + ((retHeight / 2) - hotspotY);

	RenderHUDMaterial(c, reticuleMaterial, retWidth, retHeight);
}