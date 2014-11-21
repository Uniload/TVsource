class jelaxx extends Gameplay.Mutator config(jelaxx);

var config float spinfusorProjectileVelocity;

const VERSION_NAME = "Jelaxx_v16";

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
	ModifyStats();

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
	if(Other.IsA('WeaponMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'FailProjectileMortar';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).spread = 1.5;
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
		FailWeaponEnergyBlade(Other).damageTypeClass = class'FailBladeDamageType';
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
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.100000;
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


//Thanks X2

function ModifyStats()
{
	local ModeInfo M;
	local int i, statCount;

	M = ModeInfo(Level.Game);

	//X2Log.Logf("Modifying stats");
	//X2Log.Logf("Mode is "$M);

	if(M != None)
	{

                // search for the spinfusor stat and set it's extended stat
		for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			// find by damageType
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSpinfusor')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statMA';
				log("MA stat modified");
			}
		}



		// ### EXTENDED DAMAGE STATS ###

		statCount = M.extendedProjectileDamageStats.Length;
		//X2Log.Logf(statCount$" extendedProjectileDamageStats already there");

		M.extendedProjectileDamageStats.Insert(statCount, 5); // we have 13 new stats


		// statMAPlus
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMAPlus';
		++statCount;

		// statMAPlusPlus
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMAPlusPlus';
		++statCount;

		// StatMAKnife
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'FailBladeDamageType';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'StatMAKnife';
		++statCount;
		
		// GLMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statGLMA';
		++statCount;

		// MMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMMA';
		++statCount;


		
		//X2Log.Logf("now there are "$M.projectileDamageStats.Length$" projectileDamageStats and "$M.extendedProjectileDamageStats.Length$" extendedProjectileDamageStats");
	}
}

defaultproperties
{
     spinfusorProjectileVelocity=6000.000000
     EnableVehicles=True
     GrapplerAmmo=20
     GrapplerRPS=2.000000
}
