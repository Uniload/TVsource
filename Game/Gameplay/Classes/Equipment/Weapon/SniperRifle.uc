class SniperRifle extends Weapon;

function useAmmo()
{
	Character(rookOwner).weaponUseEnergy(Character(rookOwner).energy);
	Super.useAmmo();
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local SniperRifleProjectile p;
	local SniperRifleBeam b;

	p = SniperRifleProjectile(Super.makeProjectile(fireRot, fireLoc));

	if (p != None)
		b = new class'SniperRifleBeam'(p);

	return p;
}

simulated function Tick(float Delta)
{
	local Character characterOwner;

	Super.Tick(Delta);

	characterOwner = Character(rookOwner);

	if (bIsFirstPerson)
	{
		if (!IsAnimating())
			PlayAnim(Name(animPrefix $ "_Close"),,, 1);

		AnimBlendParams(1, characterOwner.energy / characterOwner.energyMaximum);
		PlayAnim(Name(animPrefix $ "_Open"),,, 1);
	}
}

defaultproperties
{
	firstPersonMesh = Mesh'Weapons.SniperRifle'
	firstPersonOffset = (X=-25,Y=26,Z=-18)

	roundsPerSecond = 0.5
	ammoCount = 10
	ammoUsage = 1

	projectileClass = class'SniperRifleProjectile'
	projectileVelocity = 25000
	projectileInheritedVelFactor = 1.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "SniperRifle"
}