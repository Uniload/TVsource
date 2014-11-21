class MessagePickedUpGameObject extends Engine.Message
	editinlinenew;

var Name object;
var() Name carrier;


// construct
overloaded function construct(Name _object, Name _carrier)
{
	object = _object;
	carrier = _carrier;

	SLog(carrier $ " picked up " $ object);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" is picked up";
}


defaultproperties
{
	specificTo	= class'MPCarryable'
}