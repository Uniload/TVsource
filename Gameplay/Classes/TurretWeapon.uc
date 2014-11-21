class TurretWeapon extends Weapon
	native;

simulated function onThirdPersonFireCount()
{
	Super.onThirdPersonFireCount();
	
	if (Mesh != None)
		PlayAnim(fireAnimation);
}

// Want to be in Held state initially so as the "equip" event will be correctly replicated.
auto simulated state TurretHeld extends Held
{

}

defaultproperties
{
     ammoUsage=0
     firstPersonOffset=(Y=20.000000,Z=-18.000000)
     bFirstPersonUseTrace=False
}
