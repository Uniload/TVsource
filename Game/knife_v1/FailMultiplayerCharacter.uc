class FailMultiplayerCharacter extends Gameplay.MultiplayerCharacter;

simulated function int getMaxAmmo(class<Weapon> weaponClass){
	if(weaponClass == class'FailWeaponPlasma'){
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

/* DOESN'T WORK
function Bump(Actor other)
{
	local float combinedVelocity;
	local float impactDamage;
	local Buckler buckler;
	local Vector bucklerDir;

	buckler = Buckler(weapon);

	if (buckler != None && buckler.hasAmmo() &&
		Level.TimeSeconds - buckler.lastCheckTime > buckler.default.minCheckRate)
	{
		combinedVelocity = VSize(Velocity) + VSize(other.Velocity);

		if (combinedVelocity < buckler.default.minCheckVelocity)
			return;

		bucklerDir = Normal(Vector(motor.GetViewRotation()));

		if ((bucklerDir Dot Normal(other.Location - Location)) > buckler.cosDeflectionAngle)
		{
			buckler.lastChecktime = Level.TimeSeconds;
			impactDamage = buckler.checkingDamage + buckler.checkingDmgVelMultiplier * combinedVelocity * 100;

			if (Character(Other) != None)
				Character(Other).blockMovementDamage = true;

			Other.TakeDamage(impactDamage, self, other.Location, bucklerDir * buckler.checkingMultiplier * combinedVelocity, class'DamageType');
			buckler.TriggerEffectEvent('BucklerCheck');
			changeEnergy(-20);
		}
	}

}
*/

defaultproperties
{
}
