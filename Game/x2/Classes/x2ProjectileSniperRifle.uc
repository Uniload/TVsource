class x2ProjectileSniperRifle extends EquipmentClasses.ProjectileSniperRifle;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		damageAmt = 0;
	}

	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
}
