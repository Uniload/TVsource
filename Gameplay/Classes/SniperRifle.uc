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
     ammoCount=10
     projectileClass=Class'SniperRifleProjectile'
     projectileVelocity=25000.000000
     projectileInheritedVelFactor=1.000000
     aimClass=Class'AimProjectileWeapons'
     firstPersonMesh=SkeletalMesh'weapons.SniperRifle'
     firstPersonOffset=(X=-25.000000,Y=26.000000,Z=-18.000000)
     animPrefix="SniperRifle"
     animClass=Class'CharacterEquippableAnimator'
}
