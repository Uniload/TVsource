class x2Character extends Gameplay.MultiplayerCharacter;

var float fallDamageModifier;

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

//Flag changes
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

defaultproperties
{
     fallDamageModifier=0.800000
}
