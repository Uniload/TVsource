class ActionObjectiveGetNumActors extends ActionObjectiveBase
	dependsOn(ObjectiveInfo);


// execute
latent function Variable execute()
{
	local TeamInfo ti;
	local Character c;

	super.execute();

	if (player == 'all')
	{
		logError("You cannot use 'all' as a parameter to Objective Get Num Actors. You must specify a single team or player.");
		return None;
	}

	if (team == 'all')
	{
		logError("You cannot use 'all' as a parameter to Objective Get Num Actors. You must specify a single team or player");
		return None;
	}

	if (player != '' && team != '')
	{
		logError("Objective Num Actors: You must specify either a player or a team, but not both");
		return None;
	}

	if (player != '')
	{
		c = Character(findByLabel(class'Character', player));
		if (c == None)
		{
			logError("Could not find player "$player);
		}
		else
		{
			return newTemporaryVariable(returnType, string(PlayerCharacterController(c.controller).objectives.getNumActors(objectiveName)));
		}
	}

	if (team != '')
	{
		ti = TeamInfo(findByLabel(class'TeamInfo', team));
		if (ti == None)
		{
			logError("Could not find team "$team);
		}
		else
		{
			return newTemporaryVariable(returnType, string(ti.objectives.getNumActors(objectiveName)));
		}
	}


	logError("No player or team specified.");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Get number of Objective Actors for " $ propertyDisplayString('objectiveName');
}


defaultproperties
{
	returnType			= class'VariableFloat'
	actionDisplayName	= "Objective Get Actors Count"
	actionHelp			= "Gets the number of actors in the objective's actor list."
	category			= "Objective"

	team				= ""
	player				= ""
}