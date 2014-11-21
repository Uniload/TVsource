class compCharacter extends Gameplay.MultiplayerCharacter;

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
					compGrappler(weaponSlots[i]).Penalize();
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
					compGrappler(weaponSlots[i]).Penalize();
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
					compGrappler(weaponSlots[i]).Penalize();
					LOG("ammo--, now " $ weaponSlots[i].ammoCount);
				}
		
		return true;
	}

	return false;
}
*/
simulated event BreakGrapple()
{
	// call this when the grapple breaks because it will play the breaking sound


	if (Grappler(weapon) != None)
		Grappler(weapon).lastFireTime = Level.TimeSeconds - 0.5;

	detachGrapple();
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
	pseudoWeapon.projectileInheritedVelFactor = 0.6;//was 1
	pseudoWeapon.projectileVelocity = 1400;//was 800
	pseudoWeapon.maxCharge = 1;//was 1
	pseudoWeapon.chargeRate *= 2;
	pseudoWeapon.peakChargeMaxHoldTime = 9999999;
	}
}


/*function activatePack()
{
	//log("in activate pack");
	changeShield();
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
