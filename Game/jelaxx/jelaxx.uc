class jelaxx extends Gameplay.Mutator config(jelaxx);

var config float spinfusorProjectileVelocity;

const VERSION_NAME = "Jelaxx_v9";

var config bool EnableVehicles; // Enabling of vehicles.
var config int GrapplerAmmo; // Grappler ammo count.
var config float GrapplerReelRate; // Grappler reel in rate.
var config float GrapplerRPS; // Grappler rounds per second.
var config float ShieldActive; // Active shield pack damage reduction.
var config float ShieldPassive; // Passive shield pack damage reduction.

function PreBeginPlay()
{
	ModifyFlagStands();
	ModifyVehiclePads();
	ModifyPlayerStart();
	ModifyGameInfo();

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

//Thank you Stryker
function ModifyFlagStands()
{
	local Gameplay.MpCapturePoint flagStand;
	foreach AllActors(class'Gameplay.MPCapturePoint', flagStand)
		if (flagStand != None)
		{ 
			flagStand.capturableClass =	class'FailMPFlag';
		}
}


function	ModifyGameInfo(){
	local Gameplay.GameInfo game;

	ForEach AllActors(class'Gameplay.GameInfo', game){
		game.default.defaultPlayerClassName = VERSION_NAME $ ".FailMultiplayerCharacter";
		game.defaultPlayerClassName = VERSION_NAME $ ".FailMultiplayerCharacter";

		//game.PlayerControllerClassName = VERSION_NAME $ ".FailPlayerCharacterController";
		//game.default.PlayerControllerClassName = VERSION_NAME $ ".FailPlayerCharacterController";
	}
}

function ModifyPlayerStart(){
	local Gameplay.MultiplayerStart s;

	ForEach AllActors(class'Gameplay.MultiplayerStart', s){
		if (s != None)
		{ 
			s.combatRole = class'EquipmentClasses.CombatRoleLight';
			s.invincibleDelay = 2;
		}
	}
}



function Actor ReplaceActor(Actor Other)
{
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'FailProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).spread = 1.9;
		WeaponBlaster(Other).projectileClass = Class'FailProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'FailProjectileSpinfusor';
		WeaponSpinfusor(Other).projectileVelocity = spinfusorProjectileVelocity;
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".FailWeaponEnergyBlade");
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'FailProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'FailProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'FailProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).lostReturnDelay = 2.0;
		return Super.ReplaceActor(Other);
	}

	if(Other.IsA('WeaponBurner'))
	{
		WeaponBurner(Other).projectileClass = Class'FailProjectileBurner';
		return Super.ReplaceActor(Other);

	}
	
	if(Other.IsA('Grappler'))
	{
			Gameplay.Grappler(Other).projectileClass = Class'FailDegrappleProjectile';
		
		Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;
                Gameplay.Grappler(Other).ropeNonCollisionLength = 3000;
		Gameplay.Grappler(Other).roundsPerSecond = GrapplerRPS;
	}
		

	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = 0.500000;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.0500000;
		return Super.ReplaceActor(Other);
	}

        if(Other.IsA('PackRepair'))
	{
                Gameplay.RepairPack(Other).passiveHealthPerPeriod = 1;
                Gameplay.RepairPack(Other).activeHealthPerPeriod = 3;
                Gameplay.RepairPack(Other).radius = 3000;
		return Super.ReplaceActor(Other);
	}

	return Super.ReplaceActor(Other);
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

defaultproperties
{
     spinfusorProjectileVelocity=6000.000000
     EnableVehicles=True
     GrapplerAmmo=20
     GrapplerRPS=2.000000
}
