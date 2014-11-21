class ActionPlaySpeech extends Scripting.Action;

var() actionnoresolve Sound soundObject "The name of the sound object to play.";

var() String	speech			"An alternative to the 'soundObject' field that allows the return value from a script action to be used, specify <package>.<soundname>";
var() bool		waitForSpeech	"If true the script will block until the speech has finished";
var() Character	speaker			"Character who will be speaking";
var() bool		bPlayerSpeaker	"whether the speaker is the player";
var() bool		bPositional		"Whether the speech is to be positional or not";

// execute
latent function Variable execute()
{
/*
	local Sound speechSound;
	local Controller c;
	*/
	local float duration;

	Super.execute();
	
	if(bPlayerSpeaker)
		speaker = PlayerCharacterController(parentScript.Level.GetLocalPlayerController()).character;

	if(speaker != None && speaker.IsA('AICharacter'))
	{

	}
	else
	{
		duration = parentScript.Level.speechManager.PlayScriptedSpeech(speaker, Name(speech), bPositional);
		if(waitForSpeech)
			Sleep(duration);
	}
/*
	if (speech != "")
		speechSound = Sound(DynamicLoadObject(speech, class'Sound', true));
	else
		speechSound = soundObject;

	if (speechSound != None)
	{
		c = parentScript.Level.GetLocalPlayerController();

		if (c != None)
		{
			if (c.pawn != None)
				c.pawn.PlaySound(speechSound, SLOT_Talk, 1.0,,, 1000);
			else
				c.PlaySound(speechSound, SLOT_Talk, 1.0,,, 1000);
		}

		if (waitForSpeech)
			Sleep(parentScript.GetSoundDuration(speechSound));
	}
	else
	{
		if (speech != "")
			logError("Couldn't find speech sound " $ speech);
		else 
			logError("Couldn't find speech sound " $ soundObject);
	}
*/
	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	if (speech != "")
		s = "Play speech " $ propertyDisplayString('speech');
	else
		s = "Play speech " $ soundObject;
}

defaultproperties
{
	waitForSpeech		= true
	speaker				= None
	bPositional			= false

	returnType			= None
	actionDisplayName	= "Play speech"
	actionHelp			= "Plays some dialogue"
	category			= "AudioVisual"
}