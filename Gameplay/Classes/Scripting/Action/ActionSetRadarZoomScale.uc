class ActionSetRadarZoomScale extends Scripting.Action;

var() int index;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;
	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	pcc.serverSetRadarZoomScale(pcc.radarZoomScales[index]);
	pcc.radarZoomIndex = index;
	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Set player's radar zoom scale index to "$index;
}


defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set Radar Zoom Scale"
	actionHelp			= "Sets the player's radar zoom scale index"
	category			= "Other"
}