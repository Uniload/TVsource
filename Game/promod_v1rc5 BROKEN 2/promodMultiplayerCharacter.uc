class promodMultiplayerCharacter extends Gameplay.MultiplayerCharacter config(promod);

var config float fallDamageModifier;

simulated function int getMaxAmmo(class<Weapon> weaponClass){
	if(weaponClass == class'promodWeaponPlasma'){
		return getModifiedAmmo(armorClass.static.maxAmmo(class'EquipmentClasses.WeaponBurner'));
	}
	return super.getMaxAmmo(weaponClass);
}

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

defaultproperties
{
     fallDamageModifier=1.00000
}
