class promod extends Gameplay.Mutator config(promod);

//Thank you rapher, waterbottle, Stryker, schlieperich, turkey, Byte, Odio and StanRex.
//Original mod made by Dehav.

const VERSION_NAME = "promod_v1rc5";

var config bool BonusStatsOn; //Enable bonus stats
var config bool EnablePod; // Enable the Pod
var config bool EnableRover; // Enable the Rover
var config bool EnableRoverGun;
var config bool EnableAssaultShip; // Enable the Assault Ship
var config bool EnableTank; // Enable the Tank
var config bool TankUsesMortarProjectile; // Define whether tank uses default projectile or mortar projectile
var config float TankDefaultProjectileVelocity;
var config float TankMortarProjectileVelocity;
var config bool EnableDegrapple; // Enabling of degrapple.
var config float GrapplerReelRate; // Grappler reel in rate
var config float GrapplerRPS; // Grappler rounds per second
var config int HOHealth; // HO Health
var config int HOknockbackscale; // HO knockback scale
var config float ShieldActive; // Active shield pack damage reduction
var config float ShieldPassive; // Passive shield pack damage reduction
var config float ShieldActiveDuration; // Active shield pack duration
var config float ShieldCooldown; // shield pack cooldown
var config float ShieldActivationDuration; // shield pack activation time
var config float ShieldDeActivationDuration; // shield pack deactivation time
var config float PassiveFireRate;
var config float ActiveFireRate;
var config float SpeedCooldown;
var config float SpeedActivationDuration;
var config float SpeedActiveDuration;
var config float SpeedDeActivationDuration;
var config float RepairCooldown;
var config float RepairActivationDuration;
var config float RepairDeActivationDuration;
var config float RepairDuration;
var config float RepairRadius;
var config float RepairPassivePeriod;
var config float RepairPassiveHealthPerPeriod;
var config float RepairActivePeriod;
var config float RepairActiveHealthPerPeriod;
var config float RepairActiveExtraSelfHeal;
var config float RepairAccumulationScale;
var config float EnergyDuration;
var config float EnergyDeActivationDuration;
var config float EnergyActivationDuration;
var config float EnergyCooldown;
var config float EnergyPassiveRecharge;
var config float EnergyBoost; // enegry pack boost value per second
var config float SpinfusorPIVF; // Spinfusor disk inherited velocity
var config float SpinfusorVelocity; //Spinfusor projectile velocity
var config float PlasmaVelocity;
var config float PlasmaPIVF;
var config float PlasmaEnergyUsage;
var config float BlasterSpread;
var config float BlasterBulletAmount;
var config float BlasterRoundsPerSecond;
var config float BlasterEnergyUsage;
var config float BlasterAmmoUsage;
var config float BlasterVelocity;
var config float BlasterPIVF;
var config float EnergyBladedamage;
var config float EnergyBladerange;
var config float EnergyBladeUsage;
var config float EnergyBladeKnockBack;
var config bool RemoveBaseTurret; //Remove Base Turrets
var config bool DisableDeployableTurrets; // Disable deployable turrets
var config bool DisableMines; // Disable deployable mines 
var config Array<class<BaseDevice> > MTInclusionList; // Mines & Turrets stations base device list
var config Array<class<BaseDevice> > BRBaseDeviceInclusionList; // BaseRape base device list
var bool MTBalance; // Enable Mines, Turrets check
var bool BaseRape; // Enable BaseRape check
var config int MTTeamPlayerMin;  // Team Player Minimum per team required before mines and turrets are enabled.
var config int BRTeamPlayerMin;  // Team Player Minimum per team required before BaseRape is enabled.
var config int TimerInterval;  // Time in seconds to check mines, turrets, base rape and anti-tk
var config int TKNegativeLimit; // What is limit for negative points before a player is disciplined
var config bool TKBanUser; // Ban the player for TK infraction
var config bool RunInTournamentMode; // allow functions to be run in tournament mode
//var config bool CapperCanUseInvo;
var config class<Gameplay.CombatRole> SpawnCombatRole;
var config int SpawnInvincibility; //How long a newly spawned player is invincible

function bool CTFOn() // are we playing a game with a capture point?
{
local GameClasses.CaptureStand flagStand;
	foreach AllActors(class'GameClasses.CaptureStand', flagStand)
	  if (flagStand != None)
                return true;
}

function bool TournamentOn() // is Tournament Mode on?
{
        if (!RunInTournamentMode)
           {
           if(MultiplayerGameInfo(Level.Game).bTournamentMode)
           return true;
           }
}

function bool PlayerHasFlag()
{
        local GameClasses.CaptureFlagImperial ImpFlag;
        local GameClasses.CaptureFlagBeagle BEFlag;
        local GameClasses.CaptureFlagPhoenix PnxFlag;
		
			if(ImpFlag != None || BEFlag != None || PnxFlag != None)
			return true;
}


function PreBeginPlay()
{
	Super.PreBeginPlay();
	ModifyCharacters();
	ModifyPlayerStart();
        ModifyFlagBehaviour();
//		ModifyInventoryStationAccess();
//		ModifyStatThreshold();
        ModifyVehicles();
        ModifyCatapultINVHealth();
        RemoveBaseTurrets();
        DisableMT();
        ModifyStats();
}
function ModifyCharacters()
{
         local Gameplay.GameInfo C;
         foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               {
		C.Default.DefaultPlayerClassName = VERSION_NAME $ ".promodMultiplayerCharacter";
		C.DefaultPlayerClassName = VERSION_NAME $ ".promodMultiplayerCharacter";
	       }
}
function ModifyPlayerStart()
//{
//	local Gameplay.MultiplayerStart s;
//
//	ForEach AllActors(class'Gameplay.MultiplayerStart', s){
//		if (s != None)
//		{ 
//			s.combatRole = class'EquipmentClasses.CombatRoleLight';
//			s.invincibleDelay = 2;
//		}
//	}
//}
{
   local Gameplay.MultiPlayerStart Start;
  
   forEach AllActors(class'Gameplay.MultiPlayerStart', Start)
   {
        if(Start != None && Start.combatRole != class'EquipmentClasses.CombatRoleLight' && CTFOn()) //exclude VM maps and only set the combat role if it's CTF
            Start.combatRole = SpawnCombatRole; 

        if(Start != None)
            Start.invincibleDelay = SpawnInvincibility;
   }
}


// Miserable attempt at overriding a function
//function ModifyHeadShotStatThreshold( function OnHeadShot )
//{
//	local projectileDamageStat pds;
//
	// Don't track friendly or weak head shots
//	if (Rook(instigatedBy).team() == Rook(target).team() || amount < 1)
//		return;
//
//	if (getProjectileDamageStat(damageType, pds, PDS_Headshot))
//		Tracker.awardStat(instigatedBy.Controller, pds.headShotStatClass, target.Controller);
//}

//Flag throwing physics changes
function ModifyFlagBehaviour()
{
		local GameClasses.CaptureFlagImperial ImpFlag;
        local GameClasses.CaptureFlagBeagle BEFlag;
        local GameClasses.CaptureFlagPhoenix PnxFlag;

        forEach AllActors(class'GameClasses.CaptureFlagImperial', ImpFlag)
                if (ImpFlag != None)
					{
                    ImpFlag.carriedObjectClass = Class'promodFlagThrowerImperial';
					}						
        forEach AllActors(class'GameClasses.CaptureFlagBeagle', BEFlag)
                if (BEFlag != None)
					{
                    BEFlag.carriedObjectClass = Class'promodFlagThrowerBeagle';
					}						
        forEach AllActors(class'GameClasses.CaptureFlagPhoenix', PnxFlag)
                if (PnxFlag != None)
					{
                    PnxFlag.carriedObjectClass = Class'promodFlagThrowerPhoenix';
					}
					
//	if(TournamentOn() && PlayerHasFlag())
//		{
//			InventoryStationAccess(Other).bAutoFillCombatRoles = false;
//			InventoryStationAccess(Other).bAutoFillWeapons = false;
//			InventoryStationAccess(Other).bAutoFillPacks = false;
//			InventoryStationAccess(Other).bAutoConfigGrenades = false;
//			InventoryStationAccess(Other).bCanUseCustomLoadouts = false;
//			InventoryStationAccess(Other).prompt = "You cannot use the Inventory Station while carrying the flag";
//		} else {
//			InventoryStationAccess(Other).bAutoFillCombatRoles = true;
//			InventoryStationAccess(Other).bAutoFillWeapons = true;
//			InventoryStationAccess(Other).bAutoFillPacks = true;
//			InventoryStationAccess(Other).bAutoConfigGrenades = true;
//			InventoryStationAccess(Other).bCanUseCustomLoadouts = true;
//			InventoryStationAccess(Other).prompt = "Press '%1' to enter the Inventory Station";
//			Gameplay.InventoryStationAccess(Other).prompt = "Press '%1' to enter the Inventory Station";
//		}					
}

//lower Head shot stat damage threshold
//function ModifyStatThreshold()
//{
//	promod_v1rc5.promodHeadShotStatThreshold.OnHeadShot(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount);
//}

// use Vehicles or disable
function ModifyVehicles()
{
     local Gameplay.VehicleSpawnPoint vehiclePad;

     foreach AllActors(class'Gameplay.VehicleSpawnPoint', vehiclePad)
        {
	    if(EnablePod)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.vehicleClass = class'promod_v1rc5.promodPod';
	      }
            else if(!EnablePod)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.setSwitchedOn(false);
              }
            if(EnableRover)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
				{
				if(EnableRoverGun == true)
					{
					vehiclePad.vehicleClass = class'promod_v1rc5.promodBuggyWithGun';
					} else {
					vehiclePad.vehicleClass = class'promod_v1rc5.promodBuggyWithoutGun';
					}
				}
		      else if(!EnableRover)
				{
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
				vehiclePad.setSwitchedOn(false);
                }
		  }	  			  
            if(EnableAssaultShip)
	      {
              if(vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
			vehiclePad.setSwitchedOn(true);
	      }
            else if(!EnableAssaultShip)
              {
              if(vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
			vehiclePad.setSwitchedOn(false);
	      }
            if(EnableTank)
	      {
              if(vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleTank')
			vehiclePad.vehicleClass = class'promod_v1rc5.promodTank';
	      }
            else if(!EnableTank)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleTank')
			vehiclePad.setSwitchedOn(false);
              }
        }
}
//Remove Base Turrets
function RemoveBaseTurrets()
{
         local BaseObjectClasses.BaseTurret BaseTurrets;
         local BaseObjectClasses.StaticMeshRemovable TurretBase;
         
         foreach AllActors(class'BaseObjectClasses.BaseTurret', BaseTurrets)
            if(BaseTurrets != None && RemoveBaseTurret)
                        BaseTurrets.destroy();

         foreach AllActors(class'BaseObjectClasses.StaticMeshRemovable', TurretBase)
            if(BaseTurrets != None && RemoveBaseTurret)
                        TurretBase.destroy();
}
//Set Base Catapult and INV health
function ModifyCatapultINVHealth()
{
        local BaseObjectClasses.BaseCatapult BaseCatapult;
		local BaseObjectClasses.BaseInventoryStation BaseInventoryStation;
;		local BaseObjectClasses.BaseShockMine BaseShockMine;
		
        foreach AllActors(class'BaseObjectClasses.BaseCatapult', BaseCatapult)
			if(BaseCatapult != None)
				{
                BaseCatapult.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';
				}		
		foreach AllActors(class'BaseObjectClasses.BaseInventoryStation', BaseInventoryStation)
			if(BaseInventoryStation != None)
				{
				BaseInventoryStation.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';
				}
}
// Disable Mines and/or deployable turrets
function DisableMT()
{
         local BaseObjectClasses.BaseDeployableSpawnTurret depspawnturret;
         local BaseObjectClasses.BaseDeployableSpawnShockMine depspawnmine;

         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnTurret', depspawnturret)
            if(depspawnturret != None && DisableDeployableTurrets)
                        depspawnturret.Destroy();

         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnShockMine', depspawnmine)
            if(depspawnmine != None && DisableMines)
                        depspawnmine.Destroy();
}

// Register and modify new stats. thank you schlieperich
function ModifyStats()
{
	local ModeInfo M;
	local int i, statCount;

	M = ModeInfo(Level.Game);

	if(M != None && BonusStatsOn && !TournamentOn() && CTFOn())
	{
                // search for the weapon stat and set it's extended stat
		for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			// find by damageType
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSpinfusor')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statMA';
				log("MA stat modified");
			}		
		}
		for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			// find by damageType
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSniperRifle')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statBuggedHS';
				log("HS stat modified");
			}
		}

                // ### DAMAGE STATS ###

		statCount = M.projectileDamageStats.Length;
		
		M.projectileDamageStats.Insert(statCount, 1);

		// Head Shot
		M.projectileDamageStats[statCount].damageTypeClass = Class'promod_v1rc5.promodSniperProjectileDamageType';
        M.projectileDamageStats[statCount].headShotStatClass = Class'StatHS';
		M.projectileDamageStats[statCount].playerDamageStatClass = Class'Gameplay.ExtendedStat';
		++statCount;		
		
                // ### EXTENDED DAMAGE STATS ###

		statCount = M.extendedProjectileDamageStats.Length;
		
		M.extendedProjectileDamageStats.Insert(statCount, 9); // we have 9 new stats
        
//				 SniperRifle HS
//		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'promod_v1rc5.promodSniperProjectileDamageType';
//		++statCount;
		
                // E-Blade
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'promod_v1rc5.promodBladeProjectileDamageType';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statEBMA';
		++statCount;
                // GLMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statGLMA';
		++statCount;

		// MMA
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMMA';
		++statCount;

		//PMA
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeBurner';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statPMA';
		++statCount;
		
		// statEatDisc
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statEatDisc';
		++statCount;
		
		//statRocketeer
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeRocketPod';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statRocketeer';
		++statCount;
		
		// statOMG
		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeSpinfusor';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statOMG';
		++statCount;

	}
}

//Anti-BaseRape, anti-team kill and mines/turret control
function PostBeginPlay()
{
	Super.PostBeginPlay();

        if(!TournamentOn() && CTFOn())  // Don't work if game is in Tournament Mode and must be a game with a capture point
        {
	UpdateMTDevices();
	UpdateBRDevices();
	SetTimer(TimerInterval, true);
	}
}

function Timer()
{
  local Controller C;
  local int i, s;
  local PlayerReplicationInfo P;

        if(MTBalance && !EnableMT())
	{
		MTBalance = false;
		UpdateMTDevices();
		Level.Game.BroadcastLocalized(self, class'promodGameMessage', 100);
	}
        else if(!MTBalance && EnableMT())
	{
		MTBalance = true;
		UpdateMTDevices();
		Level.Game.BroadcastLocalized(self, class'promodGameMessage', 101);
	}
	if(BaseRape && !EnableBR())
	{
		BaseRape = false;
		UpdateBRDevices();
		Level.Game.BroadcastLocalized(self, class'promodGameMessage', 103);
	}
        else if(!BaseRape && EnableBR())
	{
		BaseRape = true;
		UpdateBRDevices();
		Level.Game.BroadcastLocalized(self, class'promodGameMessage', 104);
	}
        //Anti-TK
        for (C = Level.ControllerList; C != none; C = C.nextController)
        {
                if(PlayerController(C) == none && !MultiplayerGameInfo(Level.Game).bTournamentMode)
                   continue;

                P = C.PlayerReplicationInfo;

                if(P.playerName == "" || tribesReplicationInfo(P).team == None)
            	   continue;

            	S = P.Score + TKNegativeLimit;
            
                if(S==1 || S==2)
                {
                 PlayerController(C).ReceiveLocalizedMessage(class'promodGameMessage', 105, P);
                 return;
                }

                if(S<=0)
                {
                  if(TKBanUser)
            	    {
                    Level.Game.BroadcastLocalized(self, class'promodGameMessage', 106, P);
            	    Level.Game.AccessControl.BanPlayer(PlayerController(C));
                    }
                  else
                    {
                    Level.Game.BroadcastLocalized(self, class'promodGameMessage', 107, P);
                    Level.Game.AccessControl.KickPlayer(PlayerController(C));
                    }
                }
        }
}
function bool EnableMT()
{
	local TeamInfo team;

	ForEach AllActors(Class'TeamInfo', team)
		if(team != None)
			if(team.numPlayers() < MTTeamPlayerMin)
				return false;
        return true;
}
function bool EnableBR()
{
	local TeamInfo team;

	ForEach AllActors(Class'TeamInfo', team)
		if(team != None)
			if(team.numPlayers() < BRTeamPlayerMin)
				return false;
        return true;
}
function UpdateMTDevices()
{
	local BaseDevice device;

	ForEach AllActors(Class'BaseDevice', device)
		if(device != None)
			if(ShouldModifyMTDevice(device))
				device.setSwitchedOn(MTBalance);
}
function UpdateBRDevices()
{
	local BaseDevice device;

	ForEach AllActors(Class'BaseDevice', device)
		if(device != None)
			if(ShouldModifyBRDevice(device))
				device.bCanBeDamaged = BaseRape;
}
function bool ShouldModifyMTDevice(BaseDevice device)
{
	local int i;

	for(i = 0; i < MTInclusionList.Length; i++)
		if(device.IsA(MTInclusionList[i].Name))
			return true;
        return false;
}
function bool ShouldModifyBRDevice(BaseDevice device)
{
	local int i;

	for(i = 0; i < BRBaseDeviceInclusionList.Length; i++)
		if(device.IsA(BRBaseDeviceInclusionList[i].Name))
			return true;
        return false;
}

//replace actors
function Actor ReplaceActor(Actor Other)
{
        if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'promodProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'promodProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponHandGrenade'))
	{
		WeaponHandGrenade(Other).projectileClass = Class'promodProjectileHandGrenade';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'promodProjectileBlaster';
		WeaponBlaster(Other).spread = BlasterSpread;
		WeaponBlaster(Other).numberOfBullets = BlasterBulletAmount;
		WeaponBlaster(Other).roundsPerSecond = BlasterRoundsPerSecond;
		WeaponBlaster(Other).energyUsage = BlasterEnergyUsage;
		WeaponBlaster(Other).ammoUsage = BlasterAmmoUsage;
		WeaponBlaster(Other).projectileVelocity = BlasterVelocity;
		WeaponBlaster(Other).projectileInheritedVelFactor = BlasterPIVF;
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).projectileClass = Class'promodProjectileBuckler';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'promodProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
    if(Other.IsA('WeaponMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'promodProjectileMortar';
                return Super.ReplaceActor(Other);
	}
    if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'promodProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'promodProjectileSpinfusor';
		WeaponSpinfusor(Other).projectileInheritedVelFactor = SpinfusorPIVF; //was .4
		WeaponSpinfusor(Other).projectileVelocity = SpinfusorVelocity; //was 4700
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "promod_v1rc5.promodWeaponEnergyBlade");
	}
	if(Other.IsA('EnergyBlade'))
	{
		EnergyBlade(Other).damageAmt = EnergyBladedamage;
		EnergyBlade(Other).range = EnergyBladerange;
		EnergyBlade(Other).energyUsage = EnergyBladeUsage;
		EnergyBlade(Other).knockBackVelocity = EnergyBladeKnockBack;
//		promod_v1rc5.promodWeaponEnergyBlade.EnergyBlade(Other).damageAmt = EnergyBladedamage;	
		return other;
	}
	if(Other.IsA('WeaponBurner'))
	{
        WeaponBurner(Other).projectileClass = Class'promodProjectilePlasma';
		WeaponBurner(Other).projectileInheritedVelFactor = PlasmaPIVF; //was .4
		WeaponBurner(Other).projectileVelocity = PlasmaVelocity; //was 4700
		WeaponBurner(Other).energyUsage = PlasmaEnergyUsage;
		WeaponBurner(Other).localizedname = "Plasma gun";

    }
	if(Other.IsA('WeaponVehicleTank'))
	{
		if(TankUsesMortarProjectile == true)
			{
				WeaponVehicleTank(Other).aimClass = Class'AimArcWeapons';
                WeaponVehicleTank(Other).projectileClass = Class'promod_v1rc5.promodTankRound';
				WeaponVehicleTank(Other).projectileVelocity = TankMortarProjectileVelocity;
				WeaponVehicleTank(Other).ammoUsage = 0; //was 1
			} else {
				WeaponVehicleTank(Other).aimClass = Class'AimProjectileWeapons';
				WeaponVehicleTank(Other).projectileVelocity = TankDefaultProjectileVelocity;
				WeaponVehicleTank(Other).ammoUsage = 0; //was 1
			}	
                return Super.ReplaceActor(Other);
	}
//	if(Other.IsA('Buggy'))
//	{
//		if(EnableRoverGun == true)
//			promodBuggy(Other).gunnerWeaponClass = class'Gameplay.AntiAircraftWeapon';
//		else
//			promodBuggy(Other).gunnerWeaponClass = None;
//			
//			return Super.ReplaceActor(Other);
//	}
	if(Other.IsA('InventoryStationAccess'))
	{
		if(TournamentOn() && PlayerHasFlag())
			{
				InventoryStationAccess(Other).bAutoFillCombatRoles = false;
				InventoryStationAccess(Other).bAutoFillWeapons = false;
				InventoryStationAccess(Other).bAutoFillPacks = false;
				InventoryStationAccess(Other).bAutoConfigGrenades = false;
				InventoryStationAccess(Other).bCanUseCustomLoadouts = false;
				InventoryStationAccess(Other).prompt = "You cannot use the Inventory Station while carrying the flag";
			} else {
				InventoryStationAccess(Other).bAutoFillCombatRoles = true;
				InventoryStationAccess(Other).bAutoFillWeapons = true;
				InventoryStationAccess(Other).bAutoFillPacks = true;
				InventoryStationAccess(Other).bAutoConfigGrenades = true;
				InventoryStationAccess(Other).bCanUseCustomLoadouts = true;
				InventoryStationAccess(Other).prompt = "Press '%1' to enter the Inventory Station";
				Gameplay.InventoryStationAccess(Other).prompt = "Press '%1' to enter the Inventory Station";
			}
			return Super.ReplaceActor(Other);
	}			
	if(Other.IsA('Grappler'))
	{
		if(EnableDegrapple)
			Gameplay.Grappler(Other).projectileClass = Class'promodDegrappleProjectile';
		else
			Gameplay.Grappler(Other).projectileClass = Class'Gameplay.GrapplerProjectile';

		Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;
		Gameplay.Grappler(Other).roundsPerSecond = GrapplerRPS;
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('CatapultDeployable'))
	{
               	CatapultDeployable(Other).basedeviceClass = Class'promodDeployedCatapult';
		return Super.ReplaceActor(Other);
        }
        if(Other.IsA('InventoryStationDeployable'))
	{
               	InventoryStationDeployable(Other).basedeviceClass = Class'promodDeployedInventoryStation';
                return Super.ReplaceActor(Other);
        }
//       if(Other.IsA('ShockMineDeployable'))
//	{
//          	ShockMineDeployable(Other).basedeviceClass = Class'promodDeployedShockMine';
//                return Super.ReplaceActor(Other);
//		}	
	// Gameplay hack fix
        if(Other.IsA('ShieldPack'))
	{
		ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;   //was .75
		ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive; //was .2
                ShieldPack(Other).rechargeTimeSeconds = ShieldCooldown; //was 16.000000
                ShieldPack(Other).rampUpTimeSeconds = ShieldActivationDuration; //was .250000
	        ShieldPack(Other).durationSeconds = ShieldActiveDuration; //was 3.000000
	        ShieldPack(Other).deactivatingDuration = ShieldDeActivationDuration; //was .250000
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('CloakPack'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".promodanticloak");
	}
	if(Other.IsA('EnergyPack'))
	{
            EnergyPack(Other).boostImpulsePerSecond = EnergyBoost; //was 75000.000000
            EnergyPack(Other).rechargeScale = EnergyPassiveRecharge; //was 1.155000
            EnergyPack(Other).rechargeTimeSeconds = EnergyCooldown; //was 18.000000
            EnergyPack(Other).rampUpTimeSeconds = EnergyActivationDuration; //was 0.250000
	        EnergyPack(Other).durationSeconds = EnergyDuration; //was 1.000000
	        EnergyPack(Other).deactivatingDuration = EnergyDeActivationDuration; //was 0.250000
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('RepairPack'))
	{
			RepairPack(Other).accumulationScale = RepairAccumulationScale; //was 0.500000
			RepairPack(Other).activeExtraSelfHealthPerPeriod = RepairActiveExtraSelfHeal; //was 1.750000
			RepairPack(Other).activeHealthPerPeriod = RepairActiveHealthPerPeriod; //was 13.000000
			RepairPack(Other).activePeriod = RepairActivePeriod; //was 1.000000
	        RepairPack(Other).passiveHealthPerPeriod = RepairPassiveHealthPerPeriod; //was 1.750000
	        RepairPack(Other).passivePeriod = RepairPassivePeriod; //was 1.000000
	        RepairPack(Other).radius = RepairRadius; //was 1500.000000
	        RepairPack(Other).deactivatingDuration = RepairDeActivationDuration; //was 0.250000
	        RepairPack(Other).durationSeconds = RepairDuration; //was 15.000000
	        RepairPack(Other).rampUpTimeSeconds = RepairActivationDuration; //was 0.250000
	        RepairPack(Other).rechargeTimeSeconds = RepairCooldown; //was 12.000000
	        return Super.ReplaceActor(Other);
	}
    if(Other.IsA('SpeedPack'))
	{
            SpeedPack(Other).passiveRefireRateScale = PassiveFireRate; //was 1.250000
            SpeedPack(Other).refireRateScale = ActiveFireRate; //was 1.800000
            SpeedPack(Other).rechargeTimeSeconds = SpeedCooldown; //was 13.000000
            SpeedPack(Other).rampUpTimeSeconds = SpeedActivationDuration; //was 0.250000
	        SpeedPack(Other).durationSeconds = SpeedActiveDuration; //was 2.000000
	        SpeedPack(Other).deactivatingDuration = SpeedDeActivationDuration; //was 0.250000
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

        c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc5.promodArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc5.promodArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc5.promodArmorHeavy", class'class')).default.AllowedWeapons;

        for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++)
                      {
                       if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponBurner')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 25 + i *5;
                      }

	
        return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
BonusStatsOn=True
EnablePod=True
EnableRover=True
EnableRoverGun=True
EnableAssaultShip=False
EnableTank=False
TankUsesMortarProjectile=False
TankDefaultProjectileVelocity=6000
TankMortarProjectileVelocity=6000
EnableDegrapple=True
GrapplerReelRate=0.5
GrapplerRPS=1.0
ShieldActive=0.600000
ShieldPassive=0.130000
ShieldActiveDuration=3.00000
ShieldCooldown=16.00000
ShieldDeActivationDuration=0.250000
ShieldActivationDuration=0.250000
PassiveFireRate=1.250000
ActiveFireRate=1.800000
SpeedCooldown=13.000000
SpeedActivationDuration=0.250000
SpeedActiveDuration=2.000000
SpeedDeActivationDuration=0.250000
RepairCooldown=12.000000
RepairActivationDuration=0.250000
RepairDeActivationDuration=0.250000
RepairDuration=15.000000
RepairRadius=1500.000000
RepairPassivePeriod=1.000000
RepairPassiveHealthPerPeriod=1.750000
RepairActivePeriod=1.000000
RepairActiveHealthPerPeriod=13.000000
RepairActiveExtraSelfHeal=1.750000
RepairAccumulationScale=0.500000
EnergyDuration=1.000000
EnergyDeActivationDuration=0.250000
EnergyActivationDuration=0.250000
EnergyCooldown=18.000000
EnergyPassiveRecharge=1.155000
EnergyBoost=75000.000000
BlasterSpread=4
BlasterBulletAmount=7
BlasterRoundsPerSecond=0.4
BlasterEnergyUsage=9
BlasterAmmoUsage=0
BlasterVelocity=3000
BlasterPIVF=1
EnergyBladedamage=50
EnergyBladerange=500
EnergyBladeUsage=0.000000
EnergyBladeKnockBack=175000.000000
HOHealth=195
HOknockbackscale=1.04
SpinfusorPIVF=.5000
SpinfusorVelocity=6800
DisableDeployableTurrets=False
DisableMines=False
RemoveBaseTurret=True
MTBalance=False
BaseRape=False
MTTeamPlayerMin=3
BRTeamPlayerMin=6
TimerInterval=45
TKNegativeLimit=3
TKBanUser=True
SpawnInvincibility=2
RunInTournamentMode=False
//CapperCanUseInvo=False
PlasmaVelocity=4900
PlasmaPIVF=0.5000
PlasmaEnergyUsage=0.000000
}