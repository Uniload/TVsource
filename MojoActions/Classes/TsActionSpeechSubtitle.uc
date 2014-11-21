class TsActionSpeechSubtitle extends TsCameraAction;

var(Localization) string Filename			"Name of the localization file (do not include the .int)";
var(Localization) string SectionName		"SectionName under which the text resides";
var(Localization) string TextName			"The name of the text to display";
var(Localization) string Path				"The path of the localization file. You don't usually need to change this.";
var() float duration;

var float elapsed_duration;

function bool OnStart()
{
    local CinematicOverlay c;

	if (ShouldShowSubtitles())
	{
		c = CinematicOverlay(GUIController(PlayerController(Actor).Player.GUIController).ActivePage);
		if (c != None)
		{
			c.AddSubtitle(Localize(SectionName, TextName, Path $ "/" $ Filename), duration);
		}
	}

	elapsed_duration = 0;

	return true;
}

function bool OnTick(float delta)
{
	elapsed_duration += delta;

	return (elapsed_duration < duration);
}

function OnFinish()
{
}

function Interrupt()
{
    local CinematicOverlay c;

	if (ShouldShowSubtitles())
	{
		c = CinematicOverlay(GUIController(PlayerController(Actor).Player.GUIController).ActivePage);
		if (c != None)
		{
			c.ClearSubtitle();
		}
	}
}

event bool SetDuration(float _duration)
{
	duration = _duration;
	return true;
}

event float GetDuration()
{
	return Duration;
}


defaultproperties
{
	SectionName		="Cutscenes"
	Path			="Localisation/Cutscenes/text files"

	DName			="Show Speech Subtitle"
	Track			="Effects"
	Help			="Shows a subtitle in the manner of the LipSinc action."

	UsesDuration	=true
	duration		=3.0
}