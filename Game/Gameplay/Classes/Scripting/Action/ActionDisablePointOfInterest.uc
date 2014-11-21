class ActionDisablePointOfInterest extends Scripting.Action;

var() name	PointOfInterestName	"Name of the point of interest to disable";

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
				pcc.PointsOfInterest[i].bPointEnabled = false;
				return None;
			}
		}
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Disable the Point of Interest named '" $PointOfInterestName $"'.";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Disable Point of Interest"
	actionHelp			= "Disables a Point of Interest"
	category			= "Other"
}