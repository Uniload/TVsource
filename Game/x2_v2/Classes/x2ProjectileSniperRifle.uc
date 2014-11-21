class x2ProjectileSniperRifle extends EquipmentClasses.ProjectileSniperRifle;

var config int SniperSensorDmg; // removes ability of light armour with speed pack to take out Sensor

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		damageAmt = SniperSensorDmg;
	}

	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
SniperSensorDmg = 70
}
