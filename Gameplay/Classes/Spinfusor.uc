class Spinfusor extends Weapon;

var float secsUntilNextFire;

var Shader dialShader;
var ControllableTextureRotator dialTexRotator;
var() int dialMaterialIndex;

var bool bControllableSkinSet;

simulated function buildControllableSkins()
{
	local Combiner dialCombiner;

	// Build a controllable texture panner for the dial shader
	dialShader = Shader(ShallowCopyMaterial(GetMaterial(dialMaterialIndex), self));

	if (dialShader != None)
	{
		dialCombiner = Combiner(ShallowCopyMaterial(dialShader.SelfIllumination, self));

		if (dialCombiner != None)
		{
			dialTexRotator = new class'ControllableTextureRotator';
			dialTexRotator.Rotation = TexRotator(dialCombiner.Material2).Rotation;
			dialTexRotator.UOffset = TexRotator(dialCombiner.Material2).UOffset;
			dialTexRotator.VOffset = TexRotator(dialCombiner.Material2).VOffset;
			dialTexRotator.Material = TexRotator(dialCombiner.Material2).Material;

			dialCombiner.Material2 = dialTexRotator;

			dialShader.SelfIllumination = dialCombiner;
		}
	}

	// If succeeded set the shader as the skins for the weapon
	if (dialTexRotator != None)
		setControllableSkins();
}

simulated function setHasAmmoSkins()
{
	Super.setHasAmmoSkins();
	ammoSkinChange();
}

simulated function ammoSkinChange()
{
	if (bControllableSkinSet)
		setControllableSkins();
	else
		buildControllableSkins();
}

simulated function setControllableSkins()
{
	local int i;

	if (Skins.Length <= dialMaterialIndex)
		Skins.Length = dialMaterialIndex + 1;

	for (i = 0; i < dialMaterialIndex; ++i)
	{
		Skins[i] = None;
	}

	Skins[dialMaterialIndex] = dialShader;

	bControllableSkinSet = true;
}

simulated protected function FireWeapon()
{
	Super.FireWeapon();

	secsUntilNextFire = 1 / roundsPerSecond;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (PlayerCharacter(Owner) != None)
	{
		if (bControllableSkinSet)
		{
			if (secsUntilNextFire > 0.0)
			{
				dialTexRotator.Scale = (secsUntilNextFire / (1 / roundsPerSecond)) - 0.016;
				secsUntilNextFire -= DeltaTime;
			}
			else
				dialTexRotator.Scale = -0.016;
		}
		else
			buildControllableSkins();
	}
}

defaultproperties
{
     dialMaterialIndex=1
     roundsPerSecond=0.560000
     bNeedIdleFX=True
     projectileClass=Class'SpinfusorProjectile'
     projectileVelocity=2600.000000
     projectileInheritedVelFactor=0.500000
     aimClass=Class'AimProjectileWeapons'
     firstPersonMesh=SkeletalMesh'weapons.Spinfusor'
     firstPersonOffset=(X=-26.000000,Y=22.000000,Z=-18.000000)
     animPrefix="Spinfusor"
     animClass=Class'CharacterEquippableAnimator'
     inventoryIcon=Texture'GUITribes.InvButtonSpinfusor'
     hudIcon=Texture'HUD.Tabs'
     hudIconCoords=(U=102.000000,V=472.000000)
     hudRefireIcon=Texture'HUD.Tabs'
     hudRefireIconCoords=(U=102.000000,V=421.000000)
}
