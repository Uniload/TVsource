class MessageSquadDeath extends Engine.Message
	editinlinenew;

var Name squad;

// construct
overloaded function construct(Name _squad)
{
	squad = _squad;

	SLog("All members of squad " $ squad $ " have died");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "All members of squad "$triggeredBy$" dies";
}


defaultproperties
{
	specificTo	= class'SquadInfo'
}