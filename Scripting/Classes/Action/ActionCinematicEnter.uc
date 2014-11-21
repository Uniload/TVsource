class ActionCinematicEnter extends Action
	native;

// execute
latent function Variable execute()
{
	Super.execute();
#if IG_TRIBES3 // dbeswick:
	cinematicEnter(parentScript.Level);
#else
	cinematicEnter();
#endif
	PlayerController(parentScript.Level.GetLocalPlayerController().Pawn.Controller).SetCinematicMode(true);
	PlayerController(parentScript.Level.GetLocalPlayerController().Pawn.Controller).myHud.bHideHud = true;

	return None;
}

#if IG_TRIBES3 // dbeswick:
native static function cinematicEnter(LevelInfo Level);
#else
native static function cinematicEnter();
#endif

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Enter cinematic mode";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Cinematic Mode: Enter"
	actionHelp			= "Enter cinematic mode"
	category			= "Cinematic"
}