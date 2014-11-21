/*
####################################################################################
#	                     		SUPER SHOUT OUTS TO			   #
#				   	      Striker				   #
#				   	      Rapher				   #
#				   	      StanRex				   #
#				   	      RenWerx                              #
#				   	      deHav				   #
####################################################################################
*/
class Loader extends Gameplay.Mutator;

function preBeginPlay()
{

local Gameplay.GameInfo C;
local Gameplay.VehicleSpawnPoint VSP;
 log("************************");
 log("***    VanillaPlusRC2c   ***");
 log("************************");

foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
		{ 
			C.Default.DefaultPlayerClassName = "VanillaPlusRC2c.VanCharacter";
			C.DefaultPlayerClassName = "VanillaPlusRC2c.VanCharacter";
			C.PlayerControllerClassName	= "VanillaPlusRC2c.VanPlayerCharacterController";
			C.Default.PlayerControllerClassName	= "VanillaPlusRC2c.VanPlayerCharacterController";
		}
	foreach AllActors(class'Gameplay.VehicleSpawnPoint', VSP)
		{

			if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
				{
					VSP.vehicleClass=None;
				}
			else if (VSP!= None && VSP.vehicleClass == class'VehicleClasses.VehicleBuggy')
				{
				   VSP.vehicleClass = class'VanillaPlusRC2c.VanRover';
				}
			else if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
				{
					VSP.vehicleClass=None;
				}
			else if (VSP!= None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
				{
				   VSP.vehicleClass = class'VanillaPlusRC2c.VanPod';
				}
		}
}

/*function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
	PlayerCharacterController(Sender).Level.Game.DefaultPlayerClassName = "VanillaPlusRC2c.VanCharacter";
	PlayerCharacterController(Sender).Level.Game.Default.DefaultPlayerClassName = "VanillaPlusRC2c.VanCharacter";
	PlayerCharacterController(Sender).Level.Game.PlayerControllerClassName	= "VanillaPlusRC2c.VanPlayerCharacterController";
	PlayerCharacterController(Sender).Level.Game.Default.PlayerControllerClassName	= "VanillaPlusRC2c.VanPlayerCharacterController";
	
}*/


function Actor ReplaceActor(Actor Other)
{
	
	if(Other.IsA('Grappler'))
	{
		Gameplay.Grappler(Other).roundsPerSecond = 1.0;
		Gameplay.Grappler(Other).projectileClass = Class'DegrappleProjectile';
		return Other;
	}
	
	if(Other.IsA('EnergyBlade'))
	{
		Gameplay.EnergyBlade(Other).damageAmt = 40.0;
		Gameplay.EnergyBlade(Other).energyUsage = 30.0;
		Gameplay.EnergyBlade(Other).range = 525;
		return Other;
	}
	
	if(Other.IsA('Buckler'))
	{
		WeaponBuckler(Other).roundsPerSecond = 2;
		WeaponBuckler(Other).checkingDamage = 0;
		WeaponBuckler(Other).checkingDmgVelMultiplier = 0;
		WeaponBuckler(Other).checkingMultiplier = 0;
		WeaponBuckler(Other).minCheckRate = 0;
		WeaponBuckler(Other).minCheckVelocity = 0;
		return Other;
	}
	
	if(Other.IsA('PodWeapon'))
	{
		Gameplay.PodWeapon(Other).roundsPerSecond = 1.5;
		return Other;
	}

	if(Other.IsA('ShieldPack'))
	{

		Other.Destroy();
		return ReplaceWith(Other, "VanillaPlusRC2c.VanShieldPack");
	}

	if(Other.IsA('MultiplayerCharacter'))
	{

		Other.Destroy();
		return ReplaceWith(Other, "VanillaPlusRC2c.VanCharacter");
	}
	
	if(Other.IsA('Spinfusor'))
	{
		Gameplay.Spinfusor(Other).projectileVelocity = 4300;
		Gameplay.Spinfusor(Other).projectileClass = Class'SpinfusorProjectile';
		return Other;
	}

	if(Other.IsA('Mortar'))
	{
		Gameplay.Mortar(Other).projectileClass = Class'MortarProjectile';
		return Other;
	}
	
	if(Other.IsA('BurnerProjectile'))
	{
		Gameplay.BurnerProjectile(Other).damageAmt = 0.5;
		return Other;
	}

	if(Other.IsA('GrenadeLauncher'))
	{
		Gameplay.GrenadeLauncher(Other).projectileClass = Class'GrenadeLauncherProjectile';
		return Other;
	}

	if(Other.IsA('ModeCTF'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "VanillaPlusRC2c.ModeCTF");
	}
	
}

function string MutateSpawnCombatRoleClass(Character c)
{

	c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("VanillaPlusRC2c.VanArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("VanillaPlusRC2c.VanArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("VanillaPlusRC2c.VanArmorHeavy", class'class')).default.AllowedWeapons;
	

}

defaultproperties
{
}
