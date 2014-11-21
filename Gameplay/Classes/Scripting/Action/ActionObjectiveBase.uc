class ActionObjectiveBase extends Scripting.Action
	abstract;

var() name	objectiveName;
var() name	player;
var() name	team;


// getListObjects
function getListObjects(out Array<ObjectivesList> l)
{
	local PlayerCharacterController localController;

	localController = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if(localController != None)
		l[l.Length] = localController.objectives;

/*	local TeamInfo ti;
	local Character c;

	if (player != 'all')
	{
		c = Character(findByLabel(class'Character', player));
		if (c == None || PlayerCharacterController(c.controller) == None)
		{
			logError("Could not find player "$player);
		}
		else
		{
			l[l.Length] = PlayerCharacterController(c.controller).objectives;
		}
	}
	else if (team != 'all')
	{
		ti = TeamInfo(findByLabel(class'TeamInfo', team));
		if (ti == None)
		{
			logError("Could not find team "$team);
		}
		else
		{
			l[l.Length] = ti.objectives;
		}
	}
	else
	{
		ForEach parentScript.DynamicActors(class'TeamInfo', ti)
		{
			l[l.Length] = ti.objectives;
		}

		ForEach parentScript.DynamicActors(class'Character', c)
		{
			if (c.team() == None)
			{
				l[l.Length] = PlayerCharacterController(c.controller).objectives;
			}
		}
	}
*/
}

defaultproperties
{
	player				= "all"
	team				= "all"
}