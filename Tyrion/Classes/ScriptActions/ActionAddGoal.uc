class ActionAddGoal extends ActionGoalAction;

var() actionnoresolve editinline deepcopy AI_Goal goal;

// execute
latent function Variable execute()
{
	local Actor a;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		postGoal(a, goal);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Add goal " $ goal.class $ " named " $ goal.goalName $ " to " $ propertyDisplayString('target');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Add Goal"
	actionHelp			= "Adds a goal to a rook"
	category			= "AI"
}