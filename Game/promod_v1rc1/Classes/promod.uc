class promod extends Gameplay.Mutator config(promod);

//Thank you rapher, waterbottle, Stryker, schlieperich, turkey, Byte, Odio and StanRex.

const VERSION_NAME = "promod_v1rc1";

var config bool BonusStatsOn; //Enable x2 bonus stats
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
var config float SpinfusorPIVF; // Spinfusor disk inherited velocity
var config float SpinfusorVelocity; //Spinfusor projectile velocity
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
var config class<Gameplay.CombatRole> SpawnCombatRole;
var config int SpawnInvincibility; //How long a newly spawned player is invincible
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
// use x2 Vehicles or disable
function ModifyVehicles()
{
     local Gameplay.VehicleSpawnPoint vehiclePad;

     foreach AllActors(class'Gameplay.VehicleSpawnPoint', vehiclePad)
        {
	    if(EnablePod)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.vehicleClass = class'promod_v1rc1.promodPod';
	      }
            else if(!EnablePod)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.setSwitchedOn(false);
              }
            if(EnableRover)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
			vehiclePad.vehicleClass = class'promod_v1rc1.promodBuggy';
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
			vehiclePad.vehicleClass = class'promod_v1rc1.promodTank';
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
         local BaseObjectClasses.BaseInventoryStation InvStation;
         
         foreach AllActors(class'BaseObjectClasses.BaseCatapult', BaseCatapult)
           if(BaseCatapult != None)
                        BaseCatapult.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';

         foreach AllActors(class'BaseObjectClasses.BaseInventoryStation', InvStation)
           if(InvStation != None)
                        InvStation.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';
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
		
		M.projectileDamageStats.Insert(statCount, 2);

		// E-Blade
		M.projectileDamageStats[statCount].damageTypeClass = Class'promodBladeProjectileDamageType';
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
		
		M.extendedProjectileDamageStats.Insert(statCount, 10); // we have 11 new stats

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
	}
}
//Anti-BaseRape, anti-team kill, set start role and mines/turret control
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
               	Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".promodWeaponPlasma");
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
	// Gameplay hack fix
        if(Other.IsA('ShieldPack'))
	{
		ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;   //was .75
		ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive; //was .2
                ShieldPack(Other).rechargeTimeSeconds = 16.000000;
                ShieldPack(Other).rampUpTimeSeconds = 0.250000;
	        ShieldPack(Other).durationSeconds = 3.000000;
	        ShieldPack(Other).deactivatingDuration = 0.250000;
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('CloakPack'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".promodanticloak");
	}
	if(Other.IsA('EnergyPack'))
	{
                EnergyPack(Other).boostImpulsePerSecond = 75000.000000;
                EnergyPack(Other).rechargeScale = 1.155000;
                EnergyPack(Other).rechargeTimeSeconds = 18.000000;
                EnergyPack(Other).rampUpTimeSeconds = 0.250000;
	        EnergyPack(Other).durationSeconds = 1.000000;
	        EnergyPack(Other).deactivatingDuration = 0.250000;
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('RepairPack'))
	{
                RepairPack(Other).accumulationScale = 0.500000;
                RepairPack(Other).activeExtraSelfHealthPerPeriod = 1.750000;
                RepairPack(Other).activeHealthPerPeriod = 13.000000;
                RepairPack(Other).activePeriod = 1.000000;
	        RepairPack(Other).passiveHealthPerPeriod = 1.750000;
	        RepairPack(Other).passivePeriod = 1.000000;
	        RepairPack(Other).radius = 1500.000000;
	        RepairPack(Other).deactivatingDuration = 0.250000;
	        RepairPack(Other).durationSeconds = 15.000000;
	        RepairPack(Other).rampUpTimeSeconds = 0.250000;
	        RepairPack(Other).rechargeTimeSeconds = 12.000000;
	        return Super.ReplaceActor(Other);
	}
        if(Other.IsA('SpeedPack'))
	{
                SpeedPack(Other).passiveRefireRateScale = 1.250000;
                SpeedPack(Other).refireRateScale = 1.800000;
                SpeedPack(Other).rechargeTimeSeconds = 13.000000;
                SpeedPack(Other).rampUpTimeSeconds = 0.250000;
	        SpeedPack(Other).durationSeconds = 2.000000;
	        SpeedPack(Other).deactivatingDuration = 0.250000;
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

        c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc1.promodArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc1.promodArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promod_v1rc1.promodArmorHeavy", class'class')).default.AllowedWeapons;

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
ShieldPassive=0.1250000
HOHealth=225
HOknockbackscale=1.04
SpinfusorPIVF=.4
SpinfusorVelocity=4700
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
}