class TsActionCinematicMode extends TsCameraAction;

var(Action) enum ECINEMATICS
{
	ECINEMATICS_On,
	ECINEMATICS_Off
} cinematicsState;

function bool OnStart()
{
	// set cinematics mode
	if (cinematicsState == ECINEMATICS_On)
	{
		PC.ConsoleCommand("CINEMATICS 1");
	}
	else
	{
		PC.ConsoleCommand("CINEMATICS 0");
	}

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

function OnFinish()
{

}

defaultproperties
{
	DName			="Cinematics Mode"
	Track			="Effects"
	Help			="Set cinematics mode."

	cinematicsState =ECINEMATICS_On
}