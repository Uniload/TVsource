class ActionCinematicExit extends Action
	native;

// execute
latent function Variable execute()
{
	Super.execute();
#if IG_TRIBES3 // dbeswick:
	cinematicExit(parentScript.Level);
#else
	cinematicExit();
#endif
	PlayerController(parentScript.Level.GetLocalPlayerController().Pawn.Controller).SetCinematicMode(false);
	PlayerController(parentScript.Level.GetLocalPlayerController().Pawn.Controller).myHud.bHideHud = false;

	return None;
}

#if IG_TRIBES3 // dbeswick:
native static function cinematicExit(LevelInfo Level);
#else
native static function cinematicExit();
#endif

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Exit cinematic mode";
}

defaultproperties
{
     actionDisplayName="Cinematic Mode: Exit"
     actionHelp="Exit cinematic mode"
     category="Cinematic"
}
