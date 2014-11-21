class ProjectileDamageType extends Engine.DamageType
	abstract;

var() float headDamageModifier;
var() float backDamageModifier;
var() float vehicleDamageModifier;

static function bool doesPositionDamage()
{
	return true;
}

static function float getHeadDamageModifier()
{
	return default.headDamageModifier;
}

static function float getBackDamageModifier()
{
	return default.backDamageModifier;
}

defaultproperties
{
     headDamageModifier=1.200000
     backDamageModifier=1.100000
     vehicleDamageModifier=1.000000
}
