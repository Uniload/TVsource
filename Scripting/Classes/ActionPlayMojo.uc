class ActionPlayMojo extends Action
	native;

var() editcombotype(enumCutscenes) Name cutscene;

// execute
latent function Variable execute()
{
	parentScript.Level.PlayMojoCutscene(cutscene);

	while (parentScript.Level.bIsMojoPlaying)
		Sleep(0.5);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Play cutscene " $ propertyDisplayString('cutscene');
}

// enumCutscenes
native function enumCutscenes(Engine.LevelInfo l, out Array<Name> s);

defaultproperties
{
     actionDisplayName="Play Mojo Cutscene"
     actionHelp="Plays a cutscene"
     category="AudioVisual"
}
