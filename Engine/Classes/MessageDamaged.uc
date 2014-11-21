class MessageDamaged extends Message
	editinlinenew;

var() Name damager;
var() Name damagersTeam;
var Name victim;
var float damage;

// construct
overloaded function construct(Name _damager, Name _damagersTeam, Name _victim, float _damage)
{
	damager = _damager;
	damagersTeam = _damagersTeam;
	victim = _victim;
	damage = _damage;

	if (damagersTeam == '')
		damagersTeam = 'Neutral';

	SLog(damager $ " on the " $ damagersTeam $ " team, just did " $ damage $ " points of damage to " $ victim);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" is damaged";
}

defaultproperties
{
     specificTo=Class'Pawn'
}
