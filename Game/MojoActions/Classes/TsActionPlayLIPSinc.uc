class TsActionPlayLIPSinc extends TsPawnAction
	native;

cpptext
{
	virtual void PrecacheSound(AActor* actor);
}

var(Localization) string Filename			"Name of the localization file (do not include the .int)";
var(Localization) string SectionName		"SectionName under which the text resides";
var(Localization) string TextName			"The name of the text to display";
var(Localization) string Path				"The path of the localization file. You don't usually need to change this.";
var(Action)	name LIPSincAnimName;
var(Action)	float Volume;
var(Action)	float Radius;
var(Action) float Pitch;
var(Action) bool  bAttenuate;

native function PauseLIPSinc();
native function StopLIPSinc();
native function ResumeLIPSinc();

function bool OnStart()
{
    local CinematicOverlay c;

	Pawn.PlayLIPSincAnim(LIPSincAnimName, Volume, Radius, Pitch, bAttenuate);

	if (ShouldShowSubtitles())
	{
		c = CinematicOverlay(GUIController(Actor.Level.GetLocalPlayerController().Player.GUIController).ActivePage);
		if (c != None)
		{
			c.AddSubtitle(Localize(SectionName, TextName, Path $ "/" $ Filename), Actor.GetLIPSincAnimDuration(LIPSincAnimName));
		}
	}

	return true;
}

function bool OnTick(float delta)
{
	return Pawn.IsPlayingLIPSincAnim();
}

function OnFinish()
{
}

/////////////////////////////////////////////////////////////////////////////////////////////
function Interrupt()
{
    local CinematicOverlay c;

	StopLIPSinc();
	
	if (ShouldShowSubtitles())
	{
		c = CinematicOverlay(GUIController(Actor.Level.GetLocalPlayerController().Player.GUIController).ActivePage);
		if (c != None)
		{
			c.ClearSubtitle();
		}
	}
}

function Pause()
{
	PauseLIPSinc();
}

function Resume()
{
	ResumeLIPSinc();
}
/////////////////////////////////////////////////////////////////////////////////////////////

function bool CanGenerateOutputKeys()
{
	return false;
}


defaultproperties
{
	Volume			=1.0
	Radius			=1000.0
	Pitch			=1.0
	bAttenuate		=false

	SectionName		="Cutscenes"
	Path			="Localisation/Cutscenes/text files"

	DName			="Play LIPSinc"
	Track			="Animation"
	Help			="Run a particular LIPSinc animation"
	FastForwardSkip = true
}