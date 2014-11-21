class x2 extends Gameplay.Mutator config(x2);

//Thank you rapher, waterbottle, Stryker and schlieperich.

var config bool EnableVehicles; // Enabling of vehicles.

var FileLog X2Log; // for logging

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	X2Log = spawn(class 'FileLog');
	assert(X2Log != None);
	X2Log.OpenLog ("x2log");
	X2Log.Logf(self$": PreBeginPlay");

	ModifyVehiclePads();
	ModifyCharacters();
	ModifyStats();
	
	X2Log.Logf("========== END OF LOG ==========");
	X2Log.CloseLog();
}

function ModifyCharacters()
{
         local Gameplay.GameInfo C;
         foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               {
			C.Default.DefaultPlayerClassName = "x2v2.x2Character";
			C.DefaultPlayerClassName = "x2v2.x2Character";
			C.PlayerControllerClassName = "x2v2.x2PlayerCharacterController";
			C.Default.PlayerControllerClassName = "x2v2.x2PlayerCharacterController";
               }
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

function ModifyStats()
{
	local ModeInfo M;
	local int i, statCount;
	
	M = ModeInfo(Level.Game);
	
	X2Log.Logf("Modifying stats");
	X2Log.Logf("Mode is "$M);
	
	if(M != None)
	{		
		// ### DAMAGE STATS ###
		
		statCount = M.projectileDamageStats.Length;
		X2Log.Logf(statCount$" projectileDamageStats already there");
		
		M.projectileDamageStats.Insert(statCount, 1);
		
		// Lobotomy
		M.projectileDamageStats[statCount].damageTypeClass = Class'x2BladeProjectileDamageType';
		M.projectileDamageStats[statCount].headShotStatClass = Class'statLobotomy';
		M.projectileDamageStats[statCount].playerDamageStatClass = Class'Gameplay.Stat';
		++statCount;
		
		
		
		// ### EXTENDED DAMAGE STATS ###
		
		statCount = M.extendedProjectileDamageStats.Length;
		X2Log.Logf(statCount$" extendedProjectileDamageStats already there");		
		
		M.extendedProjectileDamageStats.Insert(statCount, 4); // we have 4 new stats
		
		// GLMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statGLMA';
		++statCount;
		
		// MMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMMA';
		++statCount;
		
		// statMAPlus
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMAPlus';
		++statCount;
		
		// statMASupreme
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMASupreme';
		++statCount;
		
		X2Log.Logf("now there are "$M.projectileDamageStats.Length$" projectileDamageStats and "$M.extendedProjectileDamageStats.Length$" extendedProjectileDamageStats");
	}
}

function Actor ReplaceActor(Actor Other)
{

        //replace character
        if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "x2v2.x2Character");
	}
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'x2ProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'x2ProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'x2ProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'x2ProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('ProjectileMortar'))
	{
		ProjectileMortar(Other).LifeSpan = 11; //was 8
		return Other;
	}
        if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'x2ProjectileSpinfusor';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = 0.7; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = 4700;//was 4700
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		WeaponEnergyBlade(Other).damageTypeClass = class'x2BladeProjectileDamageType';
		WeaponEnergyBlade(Other).Range = 500;//was 400
		WeaponEnergyBlade(Other).damageAmt = 30;//was 25
		WeaponEnergyBlade(Other).energyUsage = 25;//was 25
		WeaponEnergyBlade(Other).projectileClass = Class'x2ProjectileEnergyBlade'; // new damageType
		return Other;
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'x2ProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBurner'))
	{
               	WeaponBurner(Other).ProjectileClass = class'x2BurnerProjectile';
		WeaponBurner(Other).energyUsage = 12;//was 15
		WeaponBurner(Other).ProjectileInheritedVelFactor = 0.30;//was 0.0
		return Other;
	}
	
	if(Other.IsA('WeaponTurretBurner'))
	{
        WeaponTurretBurner(Other).ProjectileClass = class'x2TurretBurnerProjectile';
		return Other;
	}

        //Copied from Vanilla.  Thank you Rapher
	if(Other.IsA('Grappler'))
	{
		Gameplay.Grappler(Other).projectileClass = Class'x2DegrappleProjectile';
		Gameplay.Grappler(Other).reelInDelay = 0.5;
		Gameplay.Grappler(Other).roundsPerSecond = 1.0;
		return Super.ReplaceActor(Other);
	}
		
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = 0.600000;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.1250000;
		return Super.ReplaceActor(Other);
	}

	return Super.ReplaceActor(Other);
}


function string MutateSpawnCombatRoleClass(Character c)
{
	local int i, j;

	//Heavies.  Copied from Vanilla Plus. Thank you Odio
	c.team().combatRoleData[2].role.default.armorClass.default.knockbackScale = 1.04;
	c.team().combatRoleData[2].role.default.armorClass.default.health = 225;

	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 10;
				}
	return Super.MutateSpawnCombatRoleClass(c);
}


defaultproperties
{
     EnableVehicles = false
}
