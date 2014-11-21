class promodProjectileSniperRifle extends EquipmentClasses.ProjectileSniperRifle config(promod);

var config int SniperSensorDmg; // removes ability of light armour with speed pack to take out Sensor
var float energyModifier;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if(BaseObjectClasses.BaseSensor(Other) != None)
        {
		damageAmt = SniperSensorDmg;
	}

	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

overloaded function construct(Rook attacker, optional actor Owner, optional name Tag,
				  optional vector Location, optional rotator Rotation)
{
	energyModifier = Character(attacker).energy / Character(attacker).energyMaximum * 0.5;

	damageAmt = default.damageAmt * energyModifier;

	super.construct(attacker, Owner, Tag, Location, Rotation);
}


defaultproperties
{
SniperSensorDmg=0
damageAmt=38.000000
damageTypeClass=Class'promodSniperProjectileDamageType'
}
