class MessageLoadProgress extends Message
	editinlinenew;

var() String progressString;

// construct
overloaded function construct(String str)
{
	progressString = str;

	SLog("Load progress message: "$str);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Load progress message";
}


defaultproperties
{
	specificTo	= class'PlayerController'
}
