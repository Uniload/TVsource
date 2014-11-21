class MessageCarryableReturned extends Engine.Message
	editinlinenew;

var Name carryable;


// construct
overloaded function construct(Name _carryable)
{
	carryable = _carryable;

	SLog(carryable $ " was returned");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" carryable is returned";
}


defaultproperties
{
	specificTo	= class'MPCarryable'
}