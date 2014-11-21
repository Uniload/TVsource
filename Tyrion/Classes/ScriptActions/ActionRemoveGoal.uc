class ActionRemoveGoal extends ActionGoalAction;

var() String goalName;

// execute
latent function Variable execute()
{
	local Actor a;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		unpostGoal(a, goalName);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Remove goal named " $ goalName $ " from " $ propertyDisplayString('target');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Remove Goal"
	actionHelp			= "Removes a goal from a rook"
	category			= "AI"
}