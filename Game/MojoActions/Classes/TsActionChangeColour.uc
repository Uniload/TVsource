class TsActionChangeColour extends TsCameraAction;

var(Action) color NewColour;
var(Action) vector SaturationFraction;

function bool OnStart()
{
	// set flash fog to new colour
	PC.FlashFog.X = float(NewColour.R) / 255;
	PC.FlashFog.Y = float(NewColour.G) / 255;
	PC.FlashFog.Z = float(NewColour.B) / 255;

	// set flash scale
	PC.FlashScale = SaturationFraction;

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

function OnFinish()
{

}

defaultproperties
{
	DName			="Change Colour"
	Track			="Effects"
	Help			="Changes the current view colour."

	NewColour=(R=255,G=255,B=255)
	SaturationFraction=(X=1,Y=1,Z=1)
}