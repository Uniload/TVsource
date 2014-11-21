class TalkingHeadCamera extends Engine.GenericExternalCamera
	placeable;

function Initialize()
{
	CameraTexture = ScriptedTexture(DynamicLoadObject("HUD.TalkingHeadCameraView", class'ScriptedTexture'));

	super.Initialize();
	CameraTexture.Client = None;
}

function play()
{
	CameraTexture.Client = self;
}

function stop()
{
	CameraTexture.Client = None;
}

simulated function Timer()
{
	if (CameraTexture.Client != None)
		super.Timer();
}

defaultproperties
{
}