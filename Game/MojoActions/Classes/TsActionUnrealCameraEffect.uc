class TsActionUnrealCameraEffect extends TsCameraAction;

var() editinline CameraEffect Effect;

function bool OnStart()
{
	PC.AddCameraEffect(Effect);

	return true;
}

function bool OnTick(float delta)
{
	return false;
}


defaultproperties
{
	DName			="Unreal Camera Effect"
	Track			="Effects"
	Help			="Apply an Unreal camera effect to the camera."
}