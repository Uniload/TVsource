class promod extends Gameplay.Mutator config(promod);

//Thank you rapher, waterbottle, Stryker, schlieperich, turkey, Byte, Odio and StanRex.

const VERSION_NAME = "promod_v1rc5";

var config bool BonusStatsOn; //Enable bonus stats
var config bool EnablePod; // Enable the Pod
var config bool EnableRover; // Enable the Rover
var config bool EnableAssaultShip; // Enable the Assault Ship
var config bool EnableTank; // Enable the Tank
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

function PreBeginPlay()
{
	Super.PreBeginPlay();
	ModifyCharacters();
	ModifyPlayerStart();
        ModifyFlagThrower();
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
{
	local Gameplay.MultiplayerStart s;

	ForEach AllActors(class'Gameplay.MultiplayerStart', s){
		if (s != None)
		{ 
			s.combatRole = class'EquipmentClasses.CombatRoleLight';
			s.invincibleDelay = 2;
		}
	}
}
//Flag throwing physics changes
function ModifyFlagThrower()
{
        local GameClasses.CaptureFlagImperial ImpFlag;
        local GameClasses.CaptureFlagBeagle BEFlag;
        local GameClasses.CaptureFlagPhoenix PnxFlag;

        forEach AllActors(class'GameClasses.CaptureFlagImperial', ImpFlag)
                if (ImpFlag != None)
                       ImpFlag.carriedObjectClass = Class'promodFlagThrowerImperial';

        forEach AllActors(class'GameClasses.CaptureFlagBeagle', BEFlag)
                if (BEFlag != None)
                       BEFlag.carriedObjectClass = Class'promodFlagThrowerBeagle';

        forEach AllActors(class'GameClasses.CaptureFlagPhoenix', PnxFlag)
                if (PnxFlag != None)
                      PnxFlag.carriedObjectClass = Class'promodFlagThrowerPhoenix';
}
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
			vehiclePad.vehicleClass = class'promod_v1rc5.promodBuggy';
	      }
            else if(!EnableRover)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
			vehiclePad.setSwitchedOn(false);
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

         foreach AllActors(class'BaseObjectClasses.BaseCatapult', BaseCatapult)
           if(BaseCatapult != None)
                        BaseCatapult.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';
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
                // search for the spinfusor stat and set it's extended stat
		for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			// find by damageType
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSpinfusor')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statMA';
			}
		}

                // ### DAMAGE STATS ###

		statCount = M.projectileDamageStats.Length;
		
		M.projectileDamageStats.Insert(statCount, 1);

		// Head Shot
		M.projectileDamageStats[statCount].damageTypeClass = Class'promodSniperProjectileDamageType';
                M.projectileDamageStats[statCount].headShotStatClass = Class'statHS';
		M.projectileDamageStats[statCount].playerDamageStatClass = Class'Gameplay.Stat';
		++statCount;		
		
                // ### EXTENDED DAMAGE STATS ###

		statCount = M.extendedProjectileDamageStats.Length;
		
		M.extendedProjectileDamageStats.Insert(statCount, 7); // we have 7 new stats
                
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
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'promodProjectileBlaster';
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
		return ReplaceWith(Other, VERSION_NAME $ ".promodWeaponEnergyBlade");
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
		WeaponVehicleTank(Other).aimClass = Class'AimArcWeapons';
                WeaponVehicleTank(Other).projectileClass = Class'promodTankRound';
		WeaponVehicleTank(Other).projectileVelocity = 6000;
		WeaponVehicleTank(Other).ammoUsage = 0; //was 1
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
EnableAssaultShip=False
EnableTank=False
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
RunInTournamentMode=False
PlasmaVelocity=4900
PlasmaPIVF=0.5000
PlasmaEnergyUsage=0.000000
}