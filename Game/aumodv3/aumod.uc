class aumod extends Gameplay.Mutator;

function preBeginPlay()
{
 
local Gameplay.GameInfo C;
local Gameplay.VehicleSpawnPoint VSP;

foreach AllActors(class'Gameplay.GameInfo', C)
            if (C != None)
               { 
			C.Default.DefaultPlayerClassName = "aumodv3.compCharacter";
			C.DefaultPlayerClassName = "aumodv3.compCharacter";
			C.PlayerControllerClassName = "aumodv3.compPlayerCharacterController";
			C.Default.PlayerControllerClassName = "aumodv3.compPlayerCharacterController";
		}

foreach AllActors(class'Gameplay.VehicleSpawnPoint', VSP)
	{
		if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
				{
					VSP.vehicleClass = class'aumodv3.compPod';
				}
		else if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
				{
					VSP.vehicleClass = class'aumodv3.compTank';
				}
         }
}
function Actor ReplaceActor(Actor Other)
{
//replace ammotypes first for speed
	if(Other.IsA('ProjectileMortar'))
	{
		ProjectileMortar(Other).LifeSpan = 11; //was 8
		return Other;
	}

//swap cg bullets
	else if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = class'compProjectileChaingun';
		return Other;
	}

//replace character

	if(Other.IsA('Character'))
	{
		Other.Destroy();
		return ReplaceWith(Other, "aumodv3.compCharacter");
	}


//limit ammo for grappler

	if(Other.IsA('WeaponGrappler'))
	{
		WeaponGrappler(Other).ropeClass = class'compGrapplerRope';
		WeaponGrappler(Other).projectileClass = class'compGrapplerProjectile';

		return Other;
		//Other.Destroy();
		//return ReplaceWith(Other, "aumodv3.compGrappler");
	}

//change spinfusor

	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).ProjectileClass = class'compSpinfusorProjectile';
		WeaponSpinfusor(Other).ProjectileInheritedVelFactor = 0.7; //was .4
		WeaponSpinfusor(Other).ProjectileVelocity = 4700;//was 4700
		return Other;
	}

//change WeaponEnergyBlade

	if(Other.IsA('WeaponEnergyBlade'))
	{
		//Other.Destroy();
		//return ReplaceWith(Other, "aumodv3.auEnergyBlade");
                WeaponEnergyBlade(Other).damageTypeClass = class'auBladeProjectileDamageType';
                //WeaponEnergyBlade(Other).roundsPerSecond = 0.8000;
                WeaponEnergyBlade(Other).Range = 500;//was 400
		WeaponEnergyBlade(Other).damageAmt = 50;//was 25
		WeaponEnergyBlade(Other).energyUsage = 25;//was 25
		return Other;
	}

//change burner

	if(Other.IsA('WeaponBurner'))
	{
		
		WeaponBurner(Other).ProjectileClass = class'compBurnerProjectile';
		WeaponBurner(Other).energyUsage = 12;//was 15
		WeaponBurner(Other).ProjectileInheritedVelFactor = 0.30;//was 0.0
		return Other;
	}


//change tank weapon
	if(Other.IsA('WeaponVehicleTank'))
	{
		//WeaponVehicleTank(Other).roundsPerSecond = 0.4;

		WeaponVehicleTank(Other).aimClass = class'AimArcWeapons';

		WeaponVehicleTank(Other).projectileClass = class'compTankRound';
		WeaponVehicleTank(Other).projectileVelocity = 6000;
		WeaponVehicleTank(Other).ammoUsage = 0; //was 1
		
		return Other;
	}
   return Other;
}

function string MutateSpawnCombatRoleClass(Character c)
{

//hack in the grappler

	//c.grapplerClass = class<Grappler>(DynamicLoadObject("aumodv3.compGrappler", class'Class'));

	c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("aumodv3.compArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("aumodv3.compArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("aumodv3.compArmorHeavy", class'class')).default.AllowedWeapons;

}

defaultproperties
{
}
