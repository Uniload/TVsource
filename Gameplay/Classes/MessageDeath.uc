class MessageDeath extends Engine.Message
	editinlinenew;

var() Name killer;
var Name victim;
var() Name squad;

var PlayerReplicationInfo killerPRI;
var PlayerReplicationInfo victimPRI;

// construct
overloaded function construct(Name _killer, Name _victim, PlayerReplicationInfo _killerPRI, PlayerReplicationInfo _victimPRI, optional Name _squad)
{
	killer = _killer;
	victim = _victim;
	killerPRI = _killerPRI;
	victimPRI = _victimPRI;

	squad = _squad;

	SLog(killer $ " just killed " $ victim);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" dies";
}

defaultproperties
{
     specificTo=Class'Rook'
}
