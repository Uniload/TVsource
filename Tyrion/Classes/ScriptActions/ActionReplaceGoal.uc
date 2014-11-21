class ActionReplaceGoal extends ActionGoalAction;

var() String nameOfGoalToReplace;
var() actionnoresolve editinline deepcopy AI_Goal goal;

// execute
latent function Variable execute()
{
	local Actor a;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		unpostGoal(a, nameOfGoalToReplace);
		postGoal(a, goal);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Remove goal named " $ nameOfGoalToReplace $ " from " $ propertyDisplayString('target') $ " and add the new goal named " $ goal.goalName;
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Replace Goal"
	actionHelp			= "Removes a goal from a rook and adds a new goal"
	category			= "AI"
}