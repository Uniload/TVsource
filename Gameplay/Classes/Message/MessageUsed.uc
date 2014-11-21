class MessageUsed extends Engine.Message
	editinlinenew;

var Name object;
var() Name user;


// construct
overloaded function construct(Name _object, Name _user)
{
	object = _object;
	user = _user;

	SLog(user $ " used " $ object);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" is used";
}


defaultproperties
{
	specificTo	= class'Actor'
}