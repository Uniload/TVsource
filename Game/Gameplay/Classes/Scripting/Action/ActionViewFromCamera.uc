class ActionViewFromCamera extends Scripting.Action;

var() editcombotype(enumCameraLabels) name cameraLabel;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;
	local PlayerControllerCamera camera;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());

	if (pcc != None)
	{
		camera = PlayerControllerCamera(findByLabel(class'Actor', cameraLabel));

		if (camera != None)
			camera.takeControl(pcc);
		else
			SLog("Couldn't find camera " $ cameraLabel);
	}
	else
	{
		SLog("Couldn't get the players controller");
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "View from camera " $ propertyDisplayString('cameraLabel');
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
	actionDisplayName	= "View From Camera"
	actionHelp			= "Sets the players view to the named camera"
	category			= "AudioVisual"
}