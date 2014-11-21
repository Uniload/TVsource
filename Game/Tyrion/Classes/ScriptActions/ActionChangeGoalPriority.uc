class ActionChangeGoalPriority extends TyrionScriptAction;

var() editcombotype(enumTyrionTargets) Name target;
var() String goalName;
var() int newPriority;

// execute
latent function Variable execute()
{
	local Actor a;
	local AI_Goal goal;

	Super.execute();

	// todo: use the list of pawns and make a list of squadinfos to speed up search
	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		goal = class'AI_Goal'.static.findGoalByName( a, goalName );
		if ( goal != None )
			goal.changePriority( newPriority );
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Change priority of goal named " $ goalName $ " in " $ propertyDisplayString('target') $ " to " $ newPriority;
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Change Goal Priority"
	actionHelp			= "Changes a goal's priority"
	category			= "AI"
}