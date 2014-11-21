class ActionEnablePointOfInterest extends Scripting.Action;

var() name	PointOfInterestName	"Name of the point of interest to enable";

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;
	local int i;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.level.getLocalPlayerController());

	if (pcc != None)
	{
		for(i = 0; i < pcc.PointsOfInterest.Length; ++i)
		{
			if(pcc.PointsOfInterest[i].Name == PointOfInterestName)
			{
				pcc.PointsOfInterest[i].bPointEnabled = true;
				return None;
			}
		}
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Enable the Point of Interest named '" $PointOfInterestName $"'.";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enable Point of Interest"
	actionHelp			= "Enables a Point of Interest"
	category			= "Other"
}