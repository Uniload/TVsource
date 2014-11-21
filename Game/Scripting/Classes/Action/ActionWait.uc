class ActionWait extends Action;

var() float seconds;

// execute
latent function Variable execute()
{
	local float startTime;

	Super.execute();

	startTime = parentScript.Level.TimeSeconds;

	while (parentScript.Level.TimeSeconds - startTime < seconds && parentScript.continueExecution())
		Sleep(0.0);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Wait " $ propertyDisplayString('seconds') $ " second";

	if (seconds != 1.0)
		s = s $ "s";
}

defaultproperties
{
	seconds				= 1.0
	returnType			= None
	actionDisplayName	= "Wait n seconds"
	actionHelp			= "Suspends this script for n seconds"
	category			= "Script"
}