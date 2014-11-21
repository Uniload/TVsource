class vanilla extends Gameplay.Mutator config(vanilla);

var config bool EnableDegrapple; // Enabling of degrapple.
var config bool EnableVehicles; // Enabling of vehicles.
var config int GrapplerAmmo; // Grappler ammo count.
var config float GrapplerReelRate; // Grappler reel in rate.
var config float GrapplerRPS; // Grappler rounds per second.
var config float ShieldActive; // Active shield pack damage reduction.
var config float ShieldPassive; // Passive shield pack damage reduction.

function PreBeginPlay()
{
	ModifyVehiclePads();
}

function ModifyVehiclePads()
{
    local Gameplay.VehicleSpawnPoint vehiclePad;
    local Gameplay.Vehicle vehicle;

    ForEach AllActors(Class'Gameplay.VehicleSpawnPoint', vehiclePad)
        if(vehiclePad != None)
			vehiclePad.setSwitchedOn(EnableVehicles);
		
	ForEach AllActors(Class'Gameplay.Vehicle', vehicle)
		if(vehicle != None && !EnableVehicles)
			vehicle.Destroy();
}

function string MutateSpawnCombatRoleClass(Character c)
{
	local int i, j;
	
	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++)
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = GrapplerAmmo;
				
	ModifyVehiclePads();
				
	return Super.MutateSpawnCombatRoleClass(c);
}

function Actor ReplaceActor(Actor Other)
{
	if(Other.IsA('Grappler'))
	{
		if(EnableDegrapple)
			Gameplay.Grappler(Other).projectileClass = Class'DegrappleProjectile';
		else
			Gameplay.Grappler(Other).projectileClass = Class'Gameplay.GrapplerProjectile';
		
		Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;	
		Gameplay.Grappler(Other).roundsPerSecond = GrapplerRPS;
	}
		
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive;
	}
	
	return Super.ReplaceActor(Other);
}

defaultproperties
{
	EnableDegrapple = true
	EnableVehicles = false
	GrapplerAmmo = 5
	GrapplerReelRate = 0.5
	GrapplerRPS = 1.0
	ShieldActive = 0.500000
	ShieldPassive = 0.1000000
}