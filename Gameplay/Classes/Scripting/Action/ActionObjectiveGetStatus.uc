class ActionObjectiveGetStatus extends ActionObjectiveBase
	dependsOn(ObjectiveInfo);


// execute
latent function Variable execute()
{
	local TeamInfo ti;
	local Character c;
	local ObjectiveInfo.EObjectiveStatus status;

	super.execute();

	if (player == 'all')
	{
		logError("You cannot use 'all' as a parameter to Objective Get Status. You must specify a single team or player.");
		return None;
	}

	if (team == 'all')
	{
		logError("You cannot use 'all' as a parameter to Objective Get Status. You must specify a single team or player");
		return None;
	}

	if (player != '' && team != '')
	{
		logError("You must specify either a player or a team, but not both");
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
			status = PlayerCharacterController(c.controller).objectives.getStatus(objectiveName);
			return newTemporaryVariable(returnType, class'ObjectiveInfo'.static.statusText(status));
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
			status = ti.objectives.getStatus(objectiveName);
			return newTemporaryVariable(returnType, class'ObjectiveInfo'.static.statusText(status));
		}
	}


	logError("No player or team specified.");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Get Objective Status for " $ propertyDisplayString('objectiveName');
}


defaultproperties
{
	returnType			= class'VariableName'
	actionDisplayName	= "Objective Get Status"
	actionHelp			= "Gets the status of an objective for either everyone, a team or a player."
	category			= "Objective"

	team				= ""
	player				= ""
}