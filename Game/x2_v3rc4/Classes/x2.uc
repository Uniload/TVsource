class x2 extends Gameplay.Mutator config(x2);

//Thank you rapher, waterbottle, Stryker, schlieperich, turkey, Byte, Odio and StanRex.

const VERSION_NAME = "x2_v3RC4";

var config bool BonusStatsOn; //Enable x2 bonus stats
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

function bool CTFOn() // are we playing a CTF gametype?
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

	ModifyCaptureFlagImp();
        ModifyCaptureFlagBE();
        ModifyCaptureFlagPnx();
        ModifyVehicles();
        ModifyStats();
}
//Flag throwing physics changes
function ModifyCaptureFlagImp()
{
        local GameClasses.CaptureFlagImperial ImpFlag;
        forEach AllActors(class'GameClasses.CaptureFlagImperial', ImpFlag)
                if (ImpFlag != None)
                       ImpFlag.carriedObjectClass = Class'x2FlagThrowerImperial';
}
function ModifyCaptureFlagBE()
{
        local GameClasses.CaptureFlagBeagle BEFlag;
        forEach AllActors(class'GameClasses.CaptureFlagBeagle', BEFlag)
                if (BEFlag != None)
                       BEFlag.carriedObjectClass = Class'x2FlagThrowerBeagle';
}
function ModifyCaptureFlagPnx()
{
        local GameClasses.CaptureFlagPhoenix PnxFlag;
        forEach AllActors(class'GameClasses.CaptureFlagPhoenix', PnxFlag)
                if (PnxFlag != None)
                      PnxFlag.carriedObjectClass = Class'x2FlagThrowerPhoenix';
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
			vehiclePad.vehicleClass = class'x2_v3RC4.x2Pod';
	      }
            else if(!EnablePod)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.setSwitchedOn(false);
              }
            if(EnableRover)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
			vehiclePad.setSwitchedOn(true);
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
			vehiclePad.vehicleClass = class'x2_v3RC4.x2Tank';
	      }
            else if(!EnableTank)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleTank')
			vehiclePad.setSwitchedOn(false);
              }
        }
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
		
		M.projectileDamageStats.Insert(statCount, 3);

		// Lobotomy
		M.projectileDamageStats[statCount].damageTypeClass = Class'x2BladeProjectileDamageType';
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
		
		M.extendedProjectileDamageStats.Insert(statCount, 11); // we have 11 new stats

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
	}
}

//Anti-BaseRape, anti-team kill, set start role and mines/turret control
function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetStartRole();

        if(!TournamentOn() && CTFOn())  // Don't work if game is in Tournament Mode and must be CTF
        {
	UpdateMTDevices();
	UpdateBRDevices();
	SetTimer(TimerInterval, true);
	}
}

function SetStartRole() //Set the spawn combatrole and invincibilty time
{
   local Gameplay.MultiPlayerStart Start;
  
   forEach AllActors(class'Gameplay.MultiPlayerStart', Start)
   {
        if(Start != None && Start.combatrole != class'EquipmentClasses.CombatRoleLight' && CTFOn()) //exclude VM maps and only set the combat role if it's CTF
            Start.combatRole = SpawnCombatRole; 

        if(Start != None)
            Start.invincibleDelay = SpawnInvincibility;
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
		Level.Game.BroadcastLocalized(self, class'x2GameMessage', 100);
	}
        else if(!MTBalance && EnableMT())
	{
		MTBalance = true;
		UpdateMTDevices();
		Level.Game.BroadcastLocalized(self, class'x2GameMessage', 101);
	}
	if(BaseRape && !EnableBR())
	{
		BaseRape = false;
		UpdateBRDevices();
		Level.Game.BroadcastLocalized(self, class'x2GameMessage', 103);
	}
        else if(!BaseRape && EnableBR())
	{
		BaseRape = true;
		UpdateBRDevices();
		Level.Game.BroadcastLocalized(self, class'x2GameMessage', 104);
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
                 PlayerController(C).ReceiveLocalizedMessage(class'x2GameMessage', 105, P);
                 return;
                }

                if(S<=0)
                {
                  if(TKBanUser)
            	    {
                    Level.Game.BroadcastLocalized(self, class'x2GameMessage', 106, P);
            	    Level.Game.AccessControl.BanPlayer(PlayerController(C));
                    }
                  else
                    {
                    Level.Game.BroadcastLocalized(self, class'x2GameMessage', 107, P);
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
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).projectileClass = Class'x2ProjectileBuckler';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'x2ProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('ProjectileMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'x2ProjectileMortar';
                return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'x2ProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponTurretBurner'))
	{
                WeaponTurretBurner(Other).ProjectileClass = Class'x2TurretBurnerProjectile';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'x2ProjectileSpinfusor';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = SpinfusorPIVF; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = SpinfusorVelocity; //was 4700
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".x2WeaponEnergyBlade");
	}
        if(Other.IsA('WeaponBurner'))
	{
               	WeaponBurner(Other).ProjectileClass = Class'x2ProjectileBurner';
		WeaponBurner(Other).energyUsage = BurnerEnergyUsage; //was 15
		WeaponBurner(Other).ProjectileInheritedVelFactor = BurnerIBPV; //was 0.0
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('Grappler'))
	{
		if(EnableDegrapple)
			Gameplay.Grappler(Other).projectileClass = Class'x2DegrappleProjectile';
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
	if(Other.IsA('CloakPack')) // cloak pack hack fix
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".x2anticloak");
	}
        if(Other.IsA('WeaponVehicleTank'))
	{
		WeaponVehicleTank(Other).aimClass = Class'AimArcWeapons';
                WeaponVehicleTank(Other).projectileClass = Class'x2TankRound';
		WeaponVehicleTank(Other).projectileVelocity = 6000;
		WeaponVehicleTank(Other).ammoUsage = 0; //was 1
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
     BonusStatsOn=True
     EnablePod=True
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
     MTTeamPlayerMin=3
     BRTeamPlayerMin=6
     TimerInterval=45
     SpawnInvincibility=5
     TKNegativeLimit=3
     TKBanUser=True
}
