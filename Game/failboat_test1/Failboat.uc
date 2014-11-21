class Failboat extends Gameplay.Mutator config(Fail);

var config float spinfusorProjectileVelocity;

const VERSION_NAME = "Failboat_Test1";

function PreBeginPlay()
{
	ModifyFlagStands();
	ModifyVehiclePads();
	ModifyBaseTurrets();
	ModifyPlayerStart();
	ModifyGameInfo();
	//ModifyTurretSpawn();
}

function ModifyTurretSpawn(){
	local BaseObjectClasses.BaseDeployableSpawnTurret turret;

	ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnTurret', turret){
		turret.objectType = class'FailDeployableTurret';
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

function ModifyBaseTurrets()
{
	local BaseObjectClasses.BaseTurret baseTurret;

	ForEach AllActors(Class'BaseObjectClasses.BaseTurret', baseTurret){
		baseTurret.weaponClass = Class'FailWeaponTurretSentry';
		baseTurret.personalShieldClass = Class'FailScreenStrongMedium';
		baseTurret.localizedName = "Sentry Turret";
	}
}

function ModifyVehiclePads()
{
	local Gameplay.VehicleSpawnPoint vehiclePad;
	local Vector oldLocation;
	local Rotator oldRotation;
	local BaseInfo oldOwnerBase;
	local Gameplay.VehicleSpawnPoint newVehiclePad;

	local bool bHasAssaultShip;
	bHasAssaultShip = false;

	ForEach AllActors(Class'Gameplay.VehicleSpawnPoint', vehiclePad)
		if(vehiclePad != None){
			if(vehiclePad.vehicleClass == Class'VehicleClasses.VehicleAssaultShip'){
				bHasAssaultShip = true;
				Break;
			}
		}

	ForEach AllActors(Class'Gameplay.VehicleSpawnPoint', vehiclePad)
		//vehiclePad.setSwitchedOn(false);
		if(vehiclePad != None){
			if(vehiclePad.vehicleClass == Class'VehicleClasses.VehiclePod'){
				vehiclePad.setSwitchedOn(false);
				//ReplaceVehiclePad(vehiclePad, Class'FailVehicleSpawnFighter');
				Continue;
			}
			if(vehiclePad.vehicleClass == Class'VehicleClasses.VehicleBuggy'){
				ReplaceVehiclePad(vehiclePad, Class'FailVehicleSpawnBuggy');
				Continue;
			}
			if(vehiclePad.vehicleClass == Class'VehicleClasses.VehicleAssaultShip'){
				ReplaceVehiclePad(vehiclePad, Class'FailVehicleSpawnAssaultShip');
				Continue;
			}
			if(vehiclePad.vehicleClass == Class'VehicleClasses.VehicleTank')
				if(!bHasAssaultShip)
					ReplaceVehiclePad(vehiclePad, Class'FailVehicleSpawnAssaultShip');
				else
					vehiclePad.setSwitchedOn(false);
					//ReplaceVehiclePad(vehiclePad, Class'FailVehicleSpawnTank');
		}
}

function ReplaceVehiclePad(VehicleSpawnPoint vehiclePad, Class<VehicleSpawnPoint> vehiclePadClass){
	local Gameplay.VehicleSpawnPoint newVehiclePad;
	local Vector oldLocation;
	local Rotator oldRotation;
	local BaseInfo oldOwnerBase;

	local BaseInfo base;
	
	oldLocation = vehiclePad.Location;
	oldRotation = vehiclePad.Rotation;
	oldOwnerBase = vehiclePad.ownerBase;
		
	vehiclePad.Destroy();

	newVehiclePad = Spawn(vehiclePadClass, , , oldLocation ,  oldRotation);
	newVehiclePad.ownerBase = oldOwnerBase;
	newVehiclePad.bCollideWorld = true;
	newVehiclePad.bWorldGeometry = true;

	if(newVehiclePad.ownerBase == None){
		ForEach AllActors(Class'Gameplay.BaseInfo', base){
			if(oldOwnerBase == None){
				oldOwnerBase = base;
			} else {
				if(VSize(oldOwnerBase.location - newVehiclePad.location) > VSize(base.location - newVehiclePad.location))
					oldOwnerBase = base;
			}
		}
		newVehiclePad.ownerBase = oldOwnerBase;
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
	if(Other.IsA('WeaponBurner'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".FailWeaponPlasma");
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'FailProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).lostReturnDelay = 5.0;
		return Super.ReplaceActor(Other);
	}

	//Copied from Vanilla.  Thank you Rapher
	if(Other.IsA('Grappler'))
	{
		Gameplay.Grappler(Other).projectileClass = Class'FailDegrappleProjectile';
		Gameplay.Grappler(Other).reelInDelay = 0.5;
		Gameplay.Grappler(Other).roundsPerSecond = 1.0;
		return Super.ReplaceActor(Other);
	}
		
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = 0.500000;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.1000000;
		return Super.ReplaceActor(Other);
	}
	/*
	if(Other.IsA('DeployableTurret'))
	{
		//DeployableTurret(Other).baseDeviceClass = Class'FailDeployableTurret';
		//return Super.ReplaceActor(Other);
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".FailDeployableTurret");
	}
	*/
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
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 5;
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponBurner')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 20 + i *5;
		}

	//c.team().combatRoleData[0].role.default.armorClass.default.AllowedDeployables = class<Armor>(DynamicLoadObject(VERSION_NAME $ ".FailArmorLight", class'class')).default.AllowedDeployables;

	return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
     spinfusorProjectileVelocity=6000.000000
}
