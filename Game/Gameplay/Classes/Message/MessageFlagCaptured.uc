class MessageFlagCaptured extends Engine.Message
	editinlinenew;

var Name flag;
var() Name capturer;
var() Name team;


// construct
overloaded function construct(Name _flag, Name _capturer, Name _team)
{
	flag = _flag;
	capturer = _capturer;
	team = _team;

	SLog(capturer $ " captured flag " $ flag);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" flag is captured";
}


defaultproperties
{
	specificTo	= class'MPFlag'
}