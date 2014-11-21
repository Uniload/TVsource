class MessageCapturableCaptured extends Engine.Message
	editinlinenew;

var Name capturable;
var() Name capturer;
var() Name team;


// construct
overloaded function construct(Name _capturable, Name _capturer, Name _team)
{
	capturable = _capturable;
	capturer = _capturer;
	team = _team;

	SLog(capturer $ " captured capturable " $ capturable);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" capturable is captured";
}


defaultproperties
{
	specificTo	= class'MPCapturable'
}