class HUDUseableMarker extends HUDElement;

var() config HUDMaterial MarkerMaterial;
var() config HUDMaterial UseableMaterial;
var() config HUDMaterial UnUseableMaterial;
var() config HUDMaterial PowerDownMaterial;
var() config int DrawSize;

var Vector CurrentScreenPos;
var bool bPlayerCanUse;
var bool bEnabledForUse;
var bool bUnpowered;

function UpdateData(ClientSideCharacter c)
{
	CurrentScreenPos = c.useableObjectLocation;

	// visibility:
	bVisible = true;
	if(currentScreenPos.X < 0 || currentScreenPos.X > screenWidth ||
	   currentScreenPos.Y < 0 || currentScreenPos.Y > screenHeight)
			bVisible = false;

	bPlayerCanUse = c.bCanBeUsed;
	bEnabledForUse = c.bEnabledForUse;
	bUnpowered = ! c.bUseableObjectPowered;
}

//
//
function RenderElement(Canvas c)
{
	c.CurX = currentScreenPos.X - (DrawSize / 2);
	c.CurY = currentScreenPos.Y - (DrawSize / 2);

	if(bPlayerCanUse)
		RenderHUDMaterial(c, UseableMaterial, DrawSize, DrawSize);
	else
	{
		RenderHUDMaterial(c, MarkerMaterial, DrawSize, DrawSize);

		if(bUnpowered)
			RenderHUDMaterial(c, PowerDownMaterial, DrawSize, DrawSize);
		else if(! bEnabledForUse)
			RenderHUDMaterial(c, UnUseableMaterial, DrawSize, DrawSize);
	}
}

defaultproperties
{
	MarkerMaterial=(Material=Texture'HUD.UseCorners',drawColor=(R=255,G=255,B=255,A=170),style=1,bStretched=true)
	UseableMaterial=(Material=Texture'HUD.UseCorners',drawColor=(R=50,G=255,B=50,A=255),style=1,bStretched=true)
	UnUseableMaterial=(Material=texture'HUD.ReticuleCross',drawColor=(R=255,G=255,B=255,A=255),style=1)
	PowerDownMaterial=(Material=texture'HUD.UseNoPower',drawColor=(R=255,G=255,B=255,A=255),style=1)
	DrawSize=50
}