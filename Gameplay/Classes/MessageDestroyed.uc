class MessageDestroyed extends Engine.Message
	editinlinenew;

var() Name killer;
var() Name squad;
var Name victim;


// construct
overloaded function construct(Name _killer, Name _victim)
{
	killer = _killer;
	victim = _victim;

	if(killer != victim)
		SLog(killer $ " destroyed " $ victim);
	else
		SLog(victim $ " was destroyed");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" was destroyed";
}

defaultproperties
{
     specificTo=Class'DynamicObject'
}
