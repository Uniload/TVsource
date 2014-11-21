class MessageLostBuckler extends Engine.Message
	editinlinenew;

var Name carrier;

// construct
overloaded function construct(Name _carrier)
{
	carrier = _carrier;

	SLog(carrier $ " just lost their buckler");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy $ " loses buckler";
}


defaultproperties
{
	specificTo	= class'Character'
}