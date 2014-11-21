class VanCharacter extends Gameplay.MultiplayerCharacter;

var float tempFloat;

var float fallDamageModifier;
/*
	var float lightActiveShield;
	var float mediumActiveShield;
	var float heavyActiveShield;

	var float lightPassiveShield;	
	var float mediumPassiveShield;	
	var float heavyPassiveShield;	

simulated function bool shouldBreakRope()
{

	local int i;
	local float ropeLength;

	if (Level.NetMode == NM_Client)
		return false;

	ropeLength = VSize(proj.Location - rope.Location);

	if (Controller == None)
	{
		
		//Log("!!!!!!!!Break grapple: Controller was None");
		return true;
	}

	if (bAttached && (proj.Base == None || proj.Base.bDeleteMe))
	{
		//Log("!!!!!!!!Break grapple: Projectiles base was None or destroyed");
		//one less ammo
		for(i = 0; i < NUM_WEAPON_SLOTS;i++)
			if( Grappler(weaponSlots[i]) != None)
				{
					
					Grappler(weaponSlots[i]).ammoCount--;
					if (Grappler(weaponSlots[i]).ammoCount <= 0)
						Grappler(weaponSlots[i]).setOutOfAmmo();
					VanGrappler(weaponSlots[i]).Penalize();
					LOG("ammo--, now " $ weaponSlots[i].ammoCount);
				}
		
		
		return true;
	}

	if (ropeLength > grapplerClass.default.maxRopeLength)
	{
		//Log("!!!!!!!!Break grapple: Rope got too long");
		for(i = 0; i < NUM_WEAPON_SLOTS;i++)			
			if(Grappler(weaponSlots[i]) != None)
				{
					
					Grappler(weaponSlots[i]).ammoCount--;
					if (Grappler(weaponSlots[i]).ammoCount <= 0)
						Grappler(weaponSlots[i]).setOutOfAmmo();
					VanGrappler(weaponSlots[i]).Penalize();
					LOG("ammo--, now " $ weaponSlots[i].ammoCount);
				}
		
		return true;
	}

	if (ropeObstructionTrace(ropeLength - grapplerClass.default.ropeNonCollisionLength))
	{
		//Log("!!!!!!!!Break grapple: Rope was obstructed");
		for(i = 0; i < NUM_WEAPON_SLOTS;i++)
			if(Grappler(weaponSlots[i]) != None)
				{
					
					Grappler(weaponSlots[i]).ammoCount--;
					if (Grappler(weaponSlots[i]).ammoCount <= 0)
						Grappler(weaponSlots[i]).setOutOfAmmo();
					VanGrappler(weaponSlots[i]).Penalize();
					LOG("ammo--, now " $ weaponSlots[i].ammoCount);
				}
		
		return true;
	}

	return false;
}
*/

function bool shouldBreakRope()
{
	
	local float ropeLength;
log("in SBR " $ ROLE);
	if (Level.NetMode == NM_Client)
		return false;

	ropeLength = VSize(proj.Location - rope.Location);

	if (Controller == None)
	{
		//Log("!!!!!!!!Break grapple: Controller was None");
		return true;
	}

	if (bAttached && (proj.Base == None || proj.Base.bDeleteMe))
	{
		//Log("!!!!!!!!Break grapple: Projectiles base was None or destroyed");
		return true;
	}

	if (ropeLength > grapplerClass.default.maxRopeLength)
	{
		//Log("!!!!!!!!Break grapple: Rope got too long");
		return true;
	}

	if (ropeObstructionTrace(ropeLength - grapplerClass.default.ropeNonCollisionLength))
	{
		//Log("!!!!!!!!Break grapple: Rope was obstructed");
		return true;
	}

	return false;
}

simulated function tickGrappler(float Delta)
{
local float ropeLength;
	if (proj != None)
	{
		if (rope == None)
			createRope();

		updateGrapplerRopeThirdPerson();

		//energy use code
		/*if (bAttached)
		{
			ropeLength = VSize(proj.Location - rope.Location);
			tempFloat = (70 + ropeNaturalLength - ropeLength); //should be negative
			if(tempFloat < 0)
				{
					if(!weaponUseEnergy( -(tempFloat * Delta / 12) ))
						{
							breakGrapple();
						}
				}
			log("temp float: " $ tempFloat $ "   energyUse: " $ tempFloat  / 12);
		}*/
		
		if (!shouldBreakRope())
		{
			if (bAttached && bReelIn)
				ropeNaturalLength = FMax(0.0, ropeNaturalLength - grapplerClass.default.reelinLengthRate * Delta);
		}
		else 
			breakGrapple();
	}
	else if (rope != None)
	{
		rope.Destroy();
		rope = None;
	}
}

simulated function createRope()
{
// weaponUseEnergy(8);
super.createRope();
}

// on movement collision damage.
// this method is called by fusion whenever a collision in the movement
// is suffiently large as to cause damage to the character.

simulated event OnMovementCollisionDamage(float damage)
{

    local class<MovementCollisionDamageType> collisionDamageType;
	damage *= fallDamageModifier;
    if (blockMovementDamage)
        return;

    if (level.timeSeconds<lastMovementDamageTime+0.1)
        return;
        
    if (movement==MovementState_Elevator)       // no damage in elevator volumes
        return;
    
    // determine collision damage type
    
    collisionDamageType = class'MovementCollisionDamageType';
                                                                                                            
    if (armorClass!=None && armorClass.default.movementDamageTypeClass!=none)
        collisionDamageType = armorClass.default.movementDamageTypeClass; 
	
	TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), collisionDamageType);

    PlayEffect("MovementCollisionDamage", DamageTag(damage));

    lastMovementDamageTime = level.timeSeconds;
}


function pickupCarryable(MPCarryable c)
{
	super.pickupCarryable(c);


	//if its a flag, lets change how it throws
	if(MPFlag(c) != None)
	{
	pseudoWeapon.chargeScale = 0.45;//was 1
	pseudoWeapon.releaseDelay = 0.05;//was .1
	pseudoWeapon.projectileInheritedVelFactor = 1.00;//was 1
	pseudoWeapon.projectileVelocity = 875;//was 800
	pseudoWeapon.maxCharge = 1;//was 1
	pseudoWeapon.chargeRate *= 2;
	pseudoWeapon.peakChargeMaxHoldTime = 30;
	}
}


//old hack
/*function activatePack()
{
	//log("in activate pack");
	changeShield(); //hack for using the base sp instead of the compmod one
	super.activatePack();
}

simulated function changeShield()
{
log("in change shield");
if(pack.class == class'EquipmentClasses.PackShield')
	{
		
		if(armorClass.default.armorName == "Light")
		{
			//log("light");
			EquipmentClasses.PackShield(pack).passiveFractionDamageBlocked = lightPassiveShield;
			EquipmentClasses.PackShield(pack).activeFractionDamageBlocked = lightActiveShield;
			//log(lightActiveShield);
		}
		else if(armorClass.default.armorName == "Medium")
		{
			//log("medium");
			EquipmentClasses.PackShield(pack).passiveFractionDamageBlocked = mediumPassiveShield;
			EquipmentClasses.PackShield(pack).activeFractionDamageBlocked = mediumActiveShield;
			
		}
		else 
		{
			//log("heavy");
			EquipmentClasses.PackShield(pack).passiveFractionDamageBlocked = heavyPassiveShield;
			EquipmentClasses.PackShield(pack).activeFractionDamageBlocked = heavyActiveShield;
		
		}
	}
}
*/

defaultproperties
{
     fallDamageModifier=0.800000
}
