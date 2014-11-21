class MessageContainerFull extends Engine.Message
	editinlinenew;

var Name container;
var() Name team;
var() int amount;


// construct
overloaded function construct(Name _container, Name _team)
{
	container = _container;
	team = _team;

	SLog(container $ " is now full.");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" container becomes full.";
}


defaultproperties
{
	specificTo	= class'MPCarryableContainer'
}