class TsActionMusic extends TsCameraAction;

var(Action) string					Song;
var(Action) Actor.EMusicTransition	Transition;

function bool OnStart()
{
	// Go to music.
	PC.ClientSetMusic( Song, Transition );
	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

function string GetSummaryString()
{
	return Name@Song;
}

defaultproperties
{
	DName			="Play Music"
	Track			="Music"
	Help			="Play music for this player"

	Transition		=MTRAN_Fade
}

