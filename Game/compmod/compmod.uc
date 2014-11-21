class compMod extends Gameplay.Mutator; 

var class<compPodRocket> rocketClass;
function preBeginPlay()
{
 
local Gameplay.GameInfo C;
local Gameplay.VehicleSpawnPoint VSP;

foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               { 
			C.Default.DefaultPlayerClassName = "compMod.compCharacter";
			C.DefaultPlayerClassName = "compMod.compCharacter";
			//C.PlayerControllerClassName	= "compMod.compPlayerCharacterController";
			//C.Default.PlayerControllerClassName	= "compMod.compPlayerCharacterController";
		}
foreach AllActors(class'Gameplay.VehicleSpawnPoint', VSP)
	{
		if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
			{
			VSP.vehicleClass = class'compmod.compPod';
			}
		if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
			{
			VSP.vehicleClass = class'compmod.compTank';
			}
	}
}

/*function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
	PlayerCharacterController(Sender).Level.Game.DefaultPlayerClassName = "compMod.compCharacter";
	PlayerCharacterController(Sender).Level.Game.Default.DefaultPlayerClassName = "compMod.compCharacter";
	PlayerCharacterController(Sender).Level.Game.PlayerControllerClassName	= "compMod.PlayerCharacterController";
	PlayerCharacterController(Sender).Level.Game.Default.PlayerControllerClassName	= "compMod.PlayerCharacterController";
	
}*/

function Actor ReplaceActor(Actor Other)
{
//replace ammotypes first for speed
	if(Other.IsA('ProjectileSniperRifle'))
	{
		ProjectileSniperRifle(Other).LifeSpan = 0.2;//was .1
		return Other;
	}

	if(Other.IsA('ProjectileMortar'))
	{
		ProjectileMortar(Other).LifeSpan = 11; //was 8
		return Other;
	}
//swap cg bullets
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = class'compProjectileChaingun';
		return Other;
	}
	
//replace character

	if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "compMod.compCharacter");
	}

//replace shield

	if(Other.IsA('PackShield'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "compMod.compShieldPack");
		///PackShield(Other).durationSeconds = 8;
		//PackShield(Other).rechargeTimeSeconds = 1.5;
		//PackShield(Other).rampUpTimeSeconds = 0;
		//return Other;
	}

//limit ammo for grappler

	if(Other.IsA('WeaponGrappler'))
	{
		WeaponGrappler(Other).ropeClass = class'compGrapplerRope';
		WeaponGrappler(Other).projectileClass = class'compGrapplerProjectile';
		
		return Other;
		//Other.Destroy();
		//return ReplaceWith(Other, "compMod.compGrappler");
	}

//change spinfusor

	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).ProjectileClass = class'compSpinfusorProjectile';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = 0.75; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = 5300;//was 4700
		return Other;
	}
//change WeaponEnergyBlade

	if(Other.IsA('WeaponEnergyBlade'))
	{
		WeaponEnergyBlade(Other).Range = 500;//was 400
		WeaponEnergyBlade(Other).damageAmt = 45;//was 25
		return Other;
	}

//change burner

	if(Other.IsA('WeaponBurner'))
	{
		
		//return ReplaceWith(Other, "compMod.compBurner");
		WeaponBurner(Other).ProjectileClass = class'compBurnerProjectile';
		//WeaponBurner(Other).ProjectileVelocity = 5000; //was 5000
		WeaponBurner(Other).energyUsage = 12;//was 15 
		WeaponBurner(Other).ProjectileInheritedVelFactor = 0.5;//was 0.0
		return Other;
	}


	/****
//change sniper rifle

	if(Other.IsA('WeaponSniperRifle'))
	{
		Other.Destroy();
		WeaponSniperRifle(Other).ProjectileVelocity = 6000000;
		return ReplaceWith(Other, "compMod.compSniperRifle");
	}

	****/


//change blaster

	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).ProjectileClass = class'compBlasterProjectile';
		WeaponBlaster(Other).numberOfBullets = 12;
		WeaponBlaster(Other).energyUsage = 0.75;
		return Other;
	}


//change buckler

	if(Other.IsA('WeaponBuckler'))
	{
		
		WeaponBuckler(Other).checkingDmgVelMultiplier = 0.005;//was .0005
		return Other;
	}
	if(Other.IsA('ProjectileBuckler'))
	{
		ProjectileBuckler(Other).damageAmt = 38;//was 34
		return Other;
	}
//change rocket pod

	if(Other.IsA('WeaponRocketPod'))
	{
		
		WeaponRocketPod(Other).launchDelay = 0.08;
		return Other;
	}

//change pod weapon
	//if(Other.IsA('WeaponVehicleFighterRocket'))
	//{
	//	Other.Destroy();
	//	return ReplaceWith(Other, "compMod.compPodWeapon");
		//WeaponVehicleFighterRocket(Other).projectileClass = class'compMod.compPodRocket';
		//WeaponVehicleFighterRocket(Other).roundsPerSecond = 0.8; //was 2.2
		//WeaponVehicleFighterRocket(Other).projectileVelocity = 8000; //was 13000
		//WeaponVehicleFighterRocket(Other).projectileInheritedVelFactor = 0.4;//from 0
		//return Other;
	//}

//change tank weapon
	if(Other.IsA('WeaponVehicleTank'))
	{
		WeaponVehicleTank(Other).roundsPerSecond = 0.4;

		WeaponVehicleTank(Other).aimClass = class'AimArcWeapons';

		WeaponVehicleTank(Other).projectileClass = class'compTankRound';
		WeaponVehicleTank(Other).projectileVelocity = 6000;
		WeaponVehicleTank(Other).ammoUsage = 0; //was 1
		
		return Other;
	}
   return Other;
}


//function string MutateSpawnLoadoutClass(Character c)
//{
//      return "compMod.compSpawnLoadout";
//} 

function string MutateSpawnCombatRoleClass(Character c)
{

//hack in the grappler

	//c.grapplerClass = class<Grappler>(DynamicLoadObject("compMod.compGrappler", class'Class'));

	c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compMod.compArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compMod.compArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("compMod.compArmorHeavy", class'class')).default.AllowedWeapons;

}

defaultproperties
{
}
