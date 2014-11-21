class x2 extends Gameplay.Mutator config(x2);

//Thank you rapher, waterbottle and Stryker. Try not to cringe too much at my hack job.

var config bool EnableVehicles; // Enabling of vehicles.


const VERSION_NAME = "x2_v1";

function PreBeginPlay()
{
	//ModifyFlagStands();
	ModifyVehiclePads();
	ModifyCharacters();
	//ModifyPlayerStart();
}

function ModifyCharacters()
{
         local Gameplay.GameInfo C;
         foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               {
			C.Default.DefaultPlayerClassName = "x2v1.compCharacter";
			C.DefaultPlayerClassName = "x2v1.compCharacter";
			C.PlayerControllerClassName = "x2v1.compPlayerCharacterController";
			C.Default.PlayerControllerClassName = "x2v1.compPlayerCharacterController";
               }
}
/* function ModifyPlayerStart(){
	local Gameplay.MultiplayerStart s;

	ForEach AllActors(class'Gameplay.MultiplayerStart', s){
		if (s != None)
		{ 
			s.combatRole = class'EquipmentClasses.CombatRoleLight';
			s.invincibleDelay = 2;
		}
	}
} */

//Thank you Stryker
/* function ModifyFlagStands()
{
	local Gameplay.MpCapturePoint flagStand;
	foreach AllActors(class'Gameplay.MPCapturePoint', flagStand)
		if (flagStand != None)
		{
			flagStand.capturableClass =	class'FailMPFlag';
         	}
} */

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

function Actor ReplaceActor(Actor Other)
{

        //replace character
        if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "x2v1.compCharacter");
	}
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'FailProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'FailProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'FailProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'FailProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('ProjectileMortar'))
	{
		ProjectileMortar(Other).LifeSpan = 11; //was 8
		return Other;
	}
        if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'FailProjectileSpinfusor';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = 0.7; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = 5170;//was 4700
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		WeaponEnergyBlade(Other).damageTypeClass = class'auBladeProjectileDamageType';
                WeaponEnergyBlade(Other).Range = 550;//was 400
		WeaponEnergyBlade(Other).damageAmt = 50;//was 25
		WeaponEnergyBlade(Other).energyUsage = 25;//was 25
		return Other;
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'FailProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBurner'))
	{
               	WeaponBurner(Other).ProjectileClass = class'compBurnerProjectile';
		WeaponBurner(Other).energyUsage = 12;//was 15
		WeaponBurner(Other).ProjectileInheritedVelFactor = 0.30;//was 0.0
		return Other;
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
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = 0.6500000;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.2000000;
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

	//c.team().combatRoleData[0].role.default.armorClass.default.AllowedDeployables = class<Armor>(DynamicLoadObject(VERSION_NAME $ ".FailArmorLight", class'class')).default.AllowedDeployables;

	return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
     EnableVehicles = false
}
