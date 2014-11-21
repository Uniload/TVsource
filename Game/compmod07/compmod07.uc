class compmod07 extends Gameplay.Mutator; 

var class<compPodRocket> rocketClass;
function preBeginPlay()
{

	local Gameplay.GameInfo C;
	local Gameplay.VehicleSpawnPoint VSP;
	local Gameplay.MPCapturePoint flagStand;
	log("************************");
	log("***     CompMod      ***");
	log("************************");

	foreach AllActors(class'Gameplay.GameInfo', C)
		if (C != None)
		{ 
			C.Default.DefaultPlayerClassName = "compmod07.compCharacter";
			C.DefaultPlayerClassName = "compmod07.compCharacter";
			C.PlayerControllerClassName	= "compmod07.compPlayerCharacterController";
			C.Default.PlayerControllerClassName	= "compmod07.compPlayerCharacterController";
		}
	foreach AllActors(class'Gameplay.VehicleSpawnPoint', VSP)
		{
			if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
				{
					VSP.vehicleClass = class'compmod07.compPod';
				}
			else if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
				{
					VSP.vehicleClass = class'compmod07.compTank';
				}
			else if (VSP!= None && VSP.vehicleClass == class'VehicleClasses.VehicleBuggy')
				{
				   VSP.vehicleClass = class'compmod07.compRover';
				}
			else if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
				{
					VSP.vehicleClass = class'compmod07.compAssaultShip';
				}
		}
	foreach AllActors(class'Gameplay.MPCapturePoint', flagStand)
		if (flagStand != None)
		{ 
			flagStand.capturableClass =	class'compmod07.compMPFlag';
		}

}

/*function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
	PlayerCharacterController(Sender).Level.Game.DefaultPlayerClassName = "compmod07.compCharacter";
	PlayerCharacterController(Sender).Level.Game.Default.DefaultPlayerClassName = "compmod07.compCharacter";
	PlayerCharacterController(Sender).Level.Game.PlayerControllerClassName	= "compmod07.PlayerCharacterController";
	PlayerCharacterController(Sender).Level.Game.Default.PlayerControllerClassName	= "compmod07.PlayerCharacterController";
	
}*/

function Actor ReplaceActor(Actor Other)
{

//replace ammotypes first for speed
	if(Other.IsA('ProjectileSniperRifle'))
	{
		ProjectileSniperRifle(Other).LifeSpan = 0.15;//was .1
		return Other;
	}
//change sniper rifle
	/*else if(Other.IsA('WeaponSniperRifle'))
	{
		//Other.Destroy();
		//WeaponSniperRifle(Other).ProjectileVelocity = 6000000;
		//return ReplaceWith(Other, "compmod07.compSniperRifle");
	}*/

	else if(Other.IsA('ProjectileMortar'))
	{
		ProjectileMortar(Other).LifeSpan = 12; //was 8
		return Other;
	}
//swap cg bullets
	else if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = class'compProjectileChaingun';
		return Other;
	}
	
//replace character

	else if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "compmod07.compCharacter");
	}

//replace shield

	/*else if(Other.IsA('PackShield'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "compmod07.compShieldPack");
	}*/

//edit grappler

	else if(Other.IsA('WeaponGrappler'))
	{
		//WeaponGrappler(Other).ropeClass = class'compGrapplerRope';
		WeaponGrappler(Other).projectileClass = class'compGrapplerProjectile';
		//WeaponGrappler(Other).ammoUsage = 0;
		return Other;
	}
//change buckler
	else if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).checkingDamage = 0;//15
		WeaponBuckler(Other).checkingDmgVelMultiplier = 0;//0.01
		WeaponBuckler(Other).checkingMultiplier = 0;//300
		WeaponBuckler(Other).minCheckRate = 0;//0.2
		WeaponBuckler(Other).minCheckVelocity = 0;//800
	}
//change spinfusor

	/*else if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).ProjectileClass = class'compSpinfusorProjectile';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = 0.75; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = 5300;//was 4700
		return Other;
	}*/
//change WeaponEnergyBlade

	else if(Other.IsA('WeaponEnergyBlade'))
	{
		WeaponEnergyBlade(Other).Range = 500;//was 400
		WeaponEnergyBlade(Other).damageAmt = 50;//was 25
		return Other;
	}

//change burner

	/*if(Other.IsA('WeaponBurner'))
	{
		
		//return ReplaceWith(Other, "compmod07.compBurner");
		WeaponBurner(Other).ProjectileClass = class'compBurnerProjectile';
		//WeaponBurner(Other).ProjectileVelocity = 5000; //was 5000
		WeaponBurner(Other).energyUsage = 12;//was 15 
		WeaponBurner(Other).ProjectileInheritedVelFactor = 0.5;//was 0.0
		return Other;
	}*/

//change blaster

	else if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).ProjectileClass = class'compBlasterProjectile';
		WeaponBlaster(Other).numberOfBullets = 12;
		WeaponBlaster(Other).energyUsage = 0.75;
		return Other;
	}


//change buckler

	/*if(Other.IsA('WeaponBuckler'))
	{
		
		WeaponBuckler(Other).checkingDmgVelMultiplier = 0.005;//was .0005
		return Other;
	}
	if(Other.IsA('ProjectileBuckler'))
	{
		ProjectileBuckler(Other).damageAmt = 38;//was 34
		return Other;
	}*/
//change rocket pod

	/*else if(Other.IsA('WeaponRocketPod'))
	{
		
		WeaponRocketPod(Other).launchDelay = 0.08;
		return Other;
	}*/

//change pod weapon
	//if(Other.IsA('WeaponVehicleFighterRocket'))
	//{
	//	Other.Destroy();
	//	return ReplaceWith(Other, "compmod07.compPodWeapon");
		//WeaponVehicleFighterRocket(Other).projectileClass = class'compmod07.compPodRocket';
		//WeaponVehicleFighterRocket(Other).roundsPerSecond = 0.8; //was 2.2
		//WeaponVehicleFighterRocket(Other).projectileVelocity = 8000; //was 13000
		//WeaponVehicleFighterRocket(Other).projectileInheritedVelFactor = 0.4;//from 0
		//return Other;
	//}

//change tank weapon
	else if(Other.IsA('WeaponVehicleTank'))
	{

		WeaponVehicleTank(Other).roundsPerSecond = 0.4;

		WeaponVehicleTank(Other).aimClass = class'AimArcWeapons';

		WeaponVehicleTank(Other).projectileClass = class'compTankRound';
		WeaponVehicleTank(Other).projectileVelocity = 6000;
		WeaponVehicleTank(Other).ammoUsage = 0; //was 1
		
		return Other;
	}
//change assault ship weapon
	/*else if(Other.IsA('WeaponVehicleAssaultShipBomb'))
	{
		WeaponVehicleAssaultShipBomb(Other).roundsPerSecond = 3;

		//WeaponVehicleAssaultShipBomb(Other).aimClass = class'AimArcWeapons';

		//WeaponVehicleAssaultShipBomb(Other).projectileClass = class'compTankRound';
		WeaponVehicleAssaultShipBomb(Other).projectileVelocity = 1;
		WeaponVehicleAssaultShipBomb(Other).ammoUsage = 0; //was 1
		
		return Other;
	}
	else if(Other.IsA('BaseObjectVehicleSpawnBuggy'))
	{
		Log("*****Replacing rover pad");
		Other.destroy();
		return ReplaceWith(Other, "compmod07.compSpawnRover");
	}*/
   return Other;
}


//function string MutateSpawnLoadoutClass(Character c)
//{
//      return "compmod07.compSpawnLoadout";
//} 

function string MutateSpawnCombatRoleClass(Character c)
{

	//hack in the grappler
	//c.grapplerClass = class<Grappler>(DynamicLoadObject("compmod07.compGrappler", class'Class'));

	c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compmod07.compArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compmod07.compArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compmod07.compArmorHeavy", class'class')).default.AllowedWeapons;

}

defaultproperties
{
}
