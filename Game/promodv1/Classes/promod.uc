class promod extends Gameplay.Mutator config(promod);

// promodv1
// Designed by Binwees.
// Code put together by dehav

//Thank you rapher, waterbottle, Stryker, schlieperich, turkey, Byte, Odio and StanRex.

const VERSION_NAME = "promodv1";

var config bool EnablePod;
var config bool EnableRover;
var config bool EnableAssaultShip;
var config bool EnableTank;
var config float GrapplerReelRate;
var config int HOHealth;
var config int HOknockbackscale;
var config float ShieldActive;
var config float ShieldPassive;
var config float SpinfusorPIVF;
var config float SpinfusorVelocity;
var config float PlasmaVelocity;
var config float PlasmaPIVF;
var config float PlasmaEnergyUsage;
var config Array<class<BaseDevice> > MTInclusionList;
var config Array<class<BaseDevice> > BRBaseDeviceInclusionList;
var config int TimerInterval;
var config int TKNegativeLimit;
var config bool TKBanUser;
var config bool DisableVehicles;

function bool TournamentOn()
{
        if(MultiplayerGameInfo(Level.Game).bTournamentMode)
        return true;
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
        RemoveMT();
        UpdateBaseDevices();
        ModifyStats();
}
function ModifyCharacters()
{
         local Gameplay.GameInfo C;
         foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
                  C.Default.DefaultPlayerClassName = VERSION_NAME $ ".promodMultiplayerCharacter";
		  C.DefaultPlayerClassName = VERSION_NAME $ ".promodMultiplayerCharacter";
}
function ModifyPlayerStart()
{
	local Gameplay.MultiplayerStart s;

	ForEach AllActors(class'Gameplay.MultiplayerStart', s)
		if (s != None)
                      s.combatRole = class'EquipmentClasses.CombatRoleLight';
		      s.invincibleDelay = 2;
}
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
function ModifyVehicles()
{
     local Gameplay.VehicleSpawnPoint vehiclePad;

     foreach AllActors(class'Gameplay.VehicleSpawnPoint', vehiclePad)
        {
	    if(EnablePod)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.setSwitchedOn(true);
	      }
            else if(!EnablePod)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehiclePod')
			vehiclePad.setSwitchedOn(false);
              }
            if(EnableRover)
	      {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleBuggy')
			vehiclePad.vehicleClass = class'promodv1.promodBuggy';
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
			vehiclePad.setSwitchedOn(true);
	      }
            else if(!EnableTank)
              {
              if (vehiclePad != None && vehiclePad.vehicleClass == class'VehicleClasses.VehicleTank')
			vehiclePad.setSwitchedOn(false);
              }
        }
}
function RemoveBaseTurrets()
{
         local BaseObjectClasses.BaseTurret BaseTurrets;

         foreach AllActors(class'BaseObjectClasses.BaseTurret', BaseTurrets)
            if(BaseTurrets != None)
                        BaseTurrets.destroy();
}
function ModifyCatapultINVHealth()
{
         local BaseObjectClasses.BaseCatapult BaseCatapult;

         foreach AllActors(class'BaseObjectClasses.BaseCatapult', BaseCatapult)
           if(BaseCatapult != None)
                        BaseCatapult.personalShieldClass = Class'BaseObjectClasses.ScreenStrong';
}
function RemoveMT()
{
         local BaseObjectClasses.BaseDeployableSpawnTurret depspawnturret;
         local BaseObjectClasses.BaseDeployableSpawnShockMine depspawnmine;

         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnTurret', depspawnturret)
            if(depspawnturret != None)
                        depspawnturret.Destroy();

         foreach AllActors(class'BaseObjectClasses.BaseDeployableSpawnShockMine', depspawnmine)
            if(depspawnmine != None)
                        depspawnmine.Destroy();
}
function UpdateBaseDevices()
{
	local BaseDevice device;

	ForEach AllActors(Class'BaseDevice', device)
		if(device != None)
			if(ShouldModifyBRDevice(device))
				device.bCanBeDamaged=false;
}
function bool ShouldModifyBRDevice(BaseDevice device)
{
	local int i;

	for(i = 0; i < BRBaseDeviceInclusionList.Length; i++)
		if(device.IsA(BRBaseDeviceInclusionList[i].Name))
			return true;
        return false;
}
function ModifyStats()
{
	local ModeInfo M;
	local int i, statCount;

	M = ModeInfo(Level.Game);

	if(M != None)
	{
                for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSpinfusor')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statMA';
			}
		}

                statCount = M.extendedProjectileDamageStats.Length;
		
		M.extendedProjectileDamageStats.Insert(statCount, 4);
                
                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'promodv1.promodBladeProjectileDamageType';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statEBMA';
		++statCount;

		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statGLMA';
		++statCount;

		M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeMortar';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statMMA';
		++statCount;

                M.extendedProjectileDamageStats[statCount].damageTypeClass = Class'EquipmentClasses.ProjectileDamageTypeBurner';
		M.extendedProjectileDamageStats[statCount].extendedStatClass = Class'statPMA';
		++statCount;

	}
}

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
		WeaponSpinfusor(Other).projectileInheritedVelFactor = SpinfusorPIVF;
		WeaponSpinfusor(Other).projectileVelocity = SpinfusorVelocity;
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
		WeaponBurner(Other).projectileInheritedVelFactor = PlasmaPIVF;
		WeaponBurner(Other).projectileVelocity = PlasmaVelocity;
		WeaponBurner(Other).energyUsage = PlasmaEnergyUsage;
	}
        if(Other.IsA('Grappler'))
	{
                Gameplay.Grappler(Other).projectileClass = Class'promodDegrappleProjectile';
                Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;
		Gameplay.Grappler(Other).roundsPerSecond = 1.000000;
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
		ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;
		ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive; 
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

        c.team().combatRoleData[2].role.default.armorClass.default.knockbackScale = HOknockbackscale;
	c.team().combatRoleData[2].role.default.armorClass.default.health = HOHealth;

        c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promodv1.promodArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promodv1.promodArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("promodv1.promodArmorHeavy", class'class')).default.AllowedWeapons;

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
EnablePod=False
EnableRover=True
EnableAssaultShip=False
EnableTank=False
GrapplerReelRate=0.5
ShieldActive=0.600000
ShieldPassive=0.1250000
HOHealth=200
HOknockbackscale=1.00
SpinfusorPIVF=.4
SpinfusorVelocity=4700
TimerInterval=60
TKNegativeLimit=4
TKBanUser=True
PlasmaVelocity=6300
PlasmaPIVF=0.0
PlasmaEnergyUsage=0.000000
}