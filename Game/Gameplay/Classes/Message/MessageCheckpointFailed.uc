class MessageCheckpointFailed extends Engine.Message
	editinlinenew;

var Name checkpoint;
var() Name runner;
var() Name team;


// construct
overloaded function construct(Name _checkpoint, Name _runner, Name _team)
{
	checkpoint = _checkpoint;
	runner = _runner;
	team = _team;

	SLog(runner $ " failed checkpoint " $ checkpoint);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" checkpoint is failed";
}


defaultproperties
{
	specificTo	= class'MPCheckpoint'
}