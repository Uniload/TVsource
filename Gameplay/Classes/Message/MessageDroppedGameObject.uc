class MessageDroppedGameObject extends Engine.Message
	editinlinenew;

var Name object;
var() Name dropper;


// construct
overloaded function construct(Name _object, Name _dropper)
{
	object = _object;
	dropper = _dropper;

	SLog(dropper $ " dropped " $ object);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" is dropped";
}


defaultproperties
{
	specificTo	= class'MPCarryable'
}