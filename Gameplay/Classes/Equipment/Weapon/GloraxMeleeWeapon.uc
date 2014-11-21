class GloraxMeleeWeapon extends Weapon;

var() int range;
var() int damageAmt;

var() float knockBackVelocity;

function useAmmo()
{
}

simulated function bool hasAmmo()
{
	return true;
}

simulated function bool canFire()
{
	return true;
}

simulated function Vector calcProjectileSpawnLocation(Rotator fireRot)
{
	return rookMotor.getFirstPersonEquippableLocation(self) + (projectileSpawnOffset >> fireRot);
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Vector hitLocation;
	local Vector hitNormal;
	local Vector traceEnd;
	local Material hitMaterial;
	local Actor victim;

	useAmmo();
	fireCount++;

	traceEnd = Owner.Location + Vector(fireRot) * range;

	victim = Trace(hitLocation, hitNormal, traceEnd, Owner.Location, true, Vect(0.0, 0.0, 0.0), hitMaterial);

	if (victim != None)
	{
		TriggerEffectEvent('Hit', None, hitMaterial, hitLocation, Rotator(hitNormal));

		victim.TakeDamage(damageAmt, rookOwner, hitLocation, Normal(traceEnd - Owner.Location) * knockBackVelocity, class'DamageType');
	}

	return None;
}

defaultproperties
{
	damageAmt = 20.0

	firstPersonOffset = (X=-15,Y=22,Z=-15)

	roundsPerSecond = 0.5

	ammoUsage = 0

	range = 200

	knockBackVelocity = 5000

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	bMelee = true
	fireAnimSubString = "Weapon_Melee"
	animPrefix = "GloraxMelee"
}