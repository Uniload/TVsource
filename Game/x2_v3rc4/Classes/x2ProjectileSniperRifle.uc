class x2ProjectileSniperRifle extends EquipmentClasses.ProjectileSniperRifle config(x2);

var config int SniperSensorDmg; // removes ability of light armour with speed pack to take out Sensor

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if(BaseObjectClasses.BaseSensor(Other) != None)
        {
		damageAmt = SniperSensorDmg;
	}

	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
}
