class z2 extends Gameplay.Mutator config(z2);

//Thank you rapher, waterbottle, Stryker, schlieperich and turkey.

var config bool EnableVehicles; // Enabling of all vehicles
var config bool EnablePod; // Enable the Pod
var config bool EnableRover; // Enable the Rover
var config bool EnableAssaultShip; // Enable the Assault Ship
var config bool EnableTank; // Enable the Tank
var config bool EnableDegrapple; // Enabling of degrapple.
var config int GrapplerAmmo; // Grappler ammo count
var config float GrapplerReelRate; // Grappler reel in rate
var config float GrapplerRPS; // Grappler rounds per second
var config int HOHealth; // HO Health
var config int HOknockbackscale; // HO knockback scale
var config float ShieldActive; // Active shield pack damage reduction
var config float ShieldPassive; // Passive shield pack damage reduction
var config float BurnerIBPV; // Inherited Burner projectile velocity
var config int BurnerEnergyUsage; // Energy usage of the burner
var config float SpinfusorPIVF; // Spinfusor disk inherited velocity
var config float SpinfusorVelocity; //Spinfusor projectile velocity
var config int EBladeRange; // Energy blade range
var config int EBladeDmg; // Energy blade damage amount
var config int EBladeEnergy; // Energy blade energy usage
var config int EBladeknockback; // Energy Blade knockback velocity
var config bool DisableDeployableTurrets; // Disable deployable turrets
var config bool DisableMines; // Disable deployable mines

var FileLog z2Log; // for logging

function string GetGameClass()
{
	local ModeInfo M;
	local int i, statCount;

	M = ModeInfo(Level.Game);

   //foreach AllActors(class'GameReplicationInfo', info)
   //{
    z2Log.Logf(string(M));

    return string(M);
   //}

   //return "";
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

function PreBeginPlay()
{
	Super.PreBeginPlay();

	z2Log = spawn(class 'FileLog');
	assert(z2Log != None);
	z2Log.OpenLog ("z2log");
	z2Log.Logf(self$": PreBeginPlay");

	ModifyVehiclePads();
	ModifyPlayerStart();
	ModifyCharacters();
	ModifyVehicles();
	ModifyStats();
	ModifyDepTurrets();
	ModifyDepMines();

	z2Log.Logf("========== END OF LOG ==========");
	z2Log.CloseLog();
}

function ModifyDepTurrets()
{
         local BaseObjectClasses.BaseDeployableSpawnTurret depspawnturret;
         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnTurret', depspawnturret)
            if(DisableDeployableTurrets == True)
             {
             depspawnturret.Destroy();
             }
}

function ModifyDepMines()
{
         local BaseObjectClasses.BaseDeployableSpawnShockMine depspawnmine;
         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnShockMine', depspawnmine)
            if(DisableMines == True)
             {
             depspawnmine.Destroy();
             }
}

function ModifyCharacters()
{
         local Gameplay.GameInfo C;
         foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               {
			C.Default.DefaultPlayerClassName = "z2.z2Character";
			C.DefaultPlayerClassName = "z2.z2Character";
			C.PlayerControllerClassName = "z2.z2PlayerCharacterController";
			C.Default.PlayerControllerClassName = "z2.z2PlayerCharacterController";
               }
}

function ModifyVehiclePads()
{
    local Gameplay.VehicleSpawnPoint vehiclePad;
    local Gameplay.Vehicle vehicle;
    local bool enabled;

    enabled = EnableVehicles;

    if(Instr(GetGameClass(), "Race") >= 0)
    {
       enabled = true;
    }

    ForEach AllActors(Class'Gameplay.VehicleSpawnPoint', vehiclePad)
        if(vehiclePad != None)
			vehiclePad.setSwitchedOn(enabled);

	ForEach AllActors(Class'Gameplay.Vehicle', vehicle)
		if(vehicle != None && !enabled)
			vehicle.Destroy();
}

function ModifyVehicles()
{
     local Gameplay.VehicleSpawnPoint vehiclePad;

           foreach AllActors(class'Gameplay.VehicleSpawnPoint', vehiclePad)
           {
	    if (EnablePod == True)
	      {
                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Pod')
			{
			vehiclePad.vehicleClass = class'z2.z2Pod';
			}
              }

            else if(EnablePod == False)
              {
                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Pod')
			    {
                            vehiclePad.setSwitchedOn(false);
                            }
              }

            if (EnableRover == True)
	      {

                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Buggy')
			{
			vehiclePad.setSwitchedOn(true);
			}
              }

             else if(EnableRover == False)
              {
                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Buggy')
			    {
			    vehiclePad.setSwitchedOn(false);
			    }
              }

	     if (EnableAssaultShip == True)
	      {

                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.AssaultShip')
			{
			vehiclePad.setSwitchedOn(true);
			}
              }

             else if(EnableAssaultShip == False)
              {
                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.AssaultShip')
			    {
			    vehiclePad.setSwitchedOn(false);
			    }
              }

	     if (EnableTank == True)
	      {

                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Tank')
			{
			vehiclePad.vehicleClass = class'z2.z2Tank';
			}
              }

             else if(EnableTank == False)
              {
                if (vehiclePad != None && vehiclePad.vehicleClass == class'Gameplay.Tank')
			    {
			    vehiclePad.setSwitchedOn(false);
			    }
              }
             }
}

function ModifyStats()
{
	local ModeInfo M;
	local int i, statCount;

	M = ModeInfo(Level.Game);

	z2Log.Logf("Modifying stats");
	z2Log.Logf("Mode is "$M);

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


                // ### DAMAGE STATS ###

		statCount = M.projectileDamageStats.Length;
		z2Log.Logf(statCount$" projectileDamageStats already there");

		M.projectileDamageStats.Insert(statCount, 3);

		// Lobotomy
		M.projectileDamageStats[statCount].damageTypeClass = Class'z2BladeProjectileDamageType';
		M.projectileDamageStats[statCount].headShotStatClass = Class'statLobotomy';
                M.projectileDamageStats[statCount].backstabStatClass = Class'statBackstabber';
		M.projectileDamageStats[statCount].playerDamageStatClass = Class'Gameplay.Stat';
		++statCount;
		
		// statBucklerBackBreaker
                M.projectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeBuckler';
		M.projectileDamageStats[statCount].backstabStatClass = Class'statBucklerBackBreaker';
		M.projectileDamageStats[statCount].playerDamageStatClass = Class'Gameplay.Stat';
		++statCount;


		// ### EXTENDED DAMAGE STATS ###

		statCount = M.extendedProjectileDamageStats.Length;
		z2Log.Logf(statCount$" extendedProjectileDamageStats already there");

		M.extendedProjectileDamageStats.Insert(statCount, 13); // we have 13 new stats

		// statMAPlus
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMAPlus';
		++statCount;

		// statMASupreme
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMASupreme';
		++statCount;
		
		// statEatDisc
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statEatDisc';
		++statCount;
		
		// GLMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statGLMA';
		++statCount;

		// MMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMMA';
		++statCount;

		//statRocketeer
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeRocketPod';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statRocketeer';
		++statCount;

		//statSweetShot
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statSweetShot';
		++statCount;
		
		//statSweetShot
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statSweetShot';
		++statCount;
		
		//statSweetShot
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statSweetShot';
		++statCount;

                // statOMG
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statOMG';
		++statCount;
		
		// statOMG
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statOMG';
		++statCount;
		
		// statOMG
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statOMG';
		++statCount;
		
		z2Log.Logf("now there are "$M.projectileDamageStats.Length$" projectileDamageStats and "$M.extendedProjectileDamageStats.Length$" extendedProjectileDamageStats");
	}
}

function Actor ReplaceActor(Actor Other)
{

        //replace character
        if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "z2.z2Character");
	}
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'z2ProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'z2ProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'z2ProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).projectileClass = Class'z2ProjectileBuckler';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'z2ProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('ProjectileMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'z2ProjectileMortar';
                return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'z2ProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponTurretBurner'))
	{
        WeaponTurretBurner(Other).ProjectileClass = class'z2TurretBurnerProjectile';
		return Other;
	}
        if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'z2ProjectileSpinfusor';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = SpinfusorPIVF; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = SpinfusorVelocity; //was 4700
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		WeaponEnergyBlade(Other).damageTypeClass = class'z2BladeProjectileDamageType';
		WeaponEnergyBlade(Other).Range = EBladeRange; //was 400
		WeaponEnergyBlade(Other).damageAmt = EBladeDmg; //was 25
		WeaponEnergyBlade(Other).energyUsage = EBladeEnergy; //was 25
		WeaponEnergyBlade(Other).knockbackVelocity = EBladeknockback; // was 100000
		WeaponEnergyBlade(Other).projectileClass = Class'z2ProjectileEnergyBlade'; // new damageType
		return Other;
	}
	if(Other.IsA('WeaponBurner'))
	{
               	WeaponBurner(Other).ProjectileClass = class'z2ProjectileBurner';
		WeaponBurner(Other).energyUsage = BurnerEnergyUsage; //was 15
		WeaponBurner(Other).ProjectileInheritedVelFactor = BurnerIBPV; //was 0.0
		return Other;
	}

        //Copied from Vanilla.  Thank you Rapher
	if(Other.IsA('Grappler'))
	{
		if(EnableDegrapple)
			Gameplay.Grappler(Other).projectileClass = Class'z2DegrappleProjectile';
		else
			Gameplay.Grappler(Other).projectileClass = Class'Gameplay.GrapplerProjectile';

		Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;	
		Gameplay.Grappler(Other).roundsPerSecond = GrapplerRPS;
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;   //was .75
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive; //was .2
		return Super.ReplaceActor(Other);
	}

	return Super.ReplaceActor(Other);
}


function string MutateSpawnCombatRoleClass(Character c)
{
	local int i, j;

	//Heavies. Knockback of weapon explosions decreased to balance health increase with disc jumping.  Copied from Vanilla Plus. Thank you Odio
	c.team().combatRoleData[2].role.default.armorClass.default.knockbackScale = HOknockbackscale; //was 1.175
	c.team().combatRoleData[2].role.default.armorClass.default.health = HOHealth; //was 195

	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = GrapplerAmmo;
				}
	return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
     EnableRover=True
     EnableDegrapple=True
     GrapplerAmmo=10
     GrapplerReelRate=0.500000
     GrapplerRPS=1.000000
     HOHealth=225
     HOknockbackscale=1
     shieldActive=0.600000
     ShieldPassive=0.125000
     BurnerIBPV=0.300000
     BurnerEnergyUsage=12
     SpinfusorPIVF=0.400000
     SpinfusorVelocity=4700.000000
     EBladeRange=500
     EBladeDmg=30
     EBladeEnergy=25
     EBladeknockback=100000
}
