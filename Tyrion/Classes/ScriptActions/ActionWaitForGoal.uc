class ActionWaitForGoal extends TyrionScriptAction implements IGoalNotification;

var() editcombotype(enumTyrionTargets) Name target;
var() String goalName;
var() float timeout;
var private float beginTime;
var private int result;

function OnGoalCompleted(bool bAchieved)
{
	if (bAchieved)
		result = 0;
	else
		result = 1;
}

// execute
latent function Variable execute()
{
	local Actor a;
	local AI_Goal targetGoal;

	Super.execute();

	result = -1;

	// todo: use the list of pawns and make a list of squadinfos to speed up search
	targetGoal = None;
	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		targetGoal = class'AI_Goal'.static.findGoalByName( a, goalName );

		if (targetGoal != None && !targetGoal.hasCompleted())
			break;
	}

	if (targetGoal != None)
	{
		targetGoal.addNotificationRecipient(self);

		if (timeout > 0.0)
		{
			beginTime = parentScript.Level.TimeSeconds;

			while (result == -1)
			{
				Sleep(0.0);

				if (parentScript.Level.TimeSeconds - beginTime >= timeout)
					result = 2;
			}
		}
		else
			while (result == -1)
				Sleep(0.0);

		return newTemporaryVariable(class'VariableFloat', String(result));
	}

	return newTemporaryVariable(class'VariableFloat', "0");
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Wait for goal named " $ propertyDisplayString('goalName') $ " to finish";

	if (timeout > 0.0)
		s = s $ ", or timeout in " $ timeout $ " seconds";
}

defaultproperties
{
	returnType			= class'Variable'
	actionDisplayName	= "Wait For Goal"
	actionHelp			= "Waits for a goal to complete or fail, optional timeout period will stop the wait even if the goal has not completed. Returns 0 for success, 1 for failure and 2 for timedout"
	category			= "AI"
}