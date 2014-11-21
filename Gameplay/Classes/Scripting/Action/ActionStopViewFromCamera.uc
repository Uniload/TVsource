class ActionStopViewFromCamera extends Scripting.Action;

var() editcombotype(enumCameraLabels) name cameraLabel;

// execute
latent function Variable execute()
{
	local PlayerControllerCamera camera;

	Super.execute();

	camera = PlayerControllerCamera(findByLabel(class'Actor', cameraLabel));

	if (camera != None)
		camera.actionControlledReturn();
	else
		SLog("Couldn't find camera " $ cameraLabel);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Stop view from camera " $ propertyDisplayString('cameraLabel');
}

event function enumCameraLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local PlayerControllerCamera camera;
	
	ForEach level.AllActors(class'PlayerControllerCamera', camera)
	{
		if (camera.label != '')
		{
			s[s.Length] = camera.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Stop view From Camera"
	actionHelp			= "Stops the view from the camera"
	category			= "AudioVisual"
}