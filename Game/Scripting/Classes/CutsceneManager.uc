class CutsceneManager extends Core.Object;

var Script playingCutscene;

//
// Cancels the currently playing opening cutscene
//
simulated function bool CancelOpeningCutscence()
{
	if(playingCutscene.scriptType == TYPE_OpeningCutscene)
	{
		playingCutscene.exit();
		return true;
	}

	return false;
}

simulated function ScriptEnded(Script script)
{
	if(script.scriptType != TYPE_Normal && playingCutscene != None && playingCutscene == script)
	{
		playingCutscene.Level.SpeechManager.EnableChannel("Dynamic");
		playingCutscene = None;
	}
}


//
// Processes the script and return whether the passed script
// can execute. This will update the playingCutscene variable
// if necessary.
//
function bool CanExecute(Script script)
{
	// normal scripts can always execute
	if(script.scriptType == TYPE_Normal)
		return true;

	// if there is no existing cutscene, or the playing cutscene 
	// is no longer executing,  just play the new one
	if(playingCutscene == None || ! playingCutscene.bIsExecuting)
	{
		playingCutscene = script;
		playingCutscene.Level.SpeechManager.DisableChannel("Dynamic");
		return true;
	}

	// check the priority of the existing cutscene
	if(playingCutscene.cutscenePriority <= script.cutscenePriority)
	{
		playingCutscene.exit();
		playingCutscene = script;
		playingCutscene.Level.SpeechManager.DisableChannel("Dynamic");

		return true;
	}

	return false;
}

