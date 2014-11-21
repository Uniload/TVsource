class ActionPlayMusic extends Action;

var() actionnoresolve String song;
var() float stopFade;
var() float startFade;

// execute
latent function Variable execute()
{
	Super.execute();

	if (parentScript.Level.MusicMgr != None)
		parentScript.Level.MusicMgr.TriggerScriptMusic(song, startFade);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Play song " $ song;
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Play Music"
	actionHelp			= "Starts playing a piece of music"
	category			= "AudioVisual"
}