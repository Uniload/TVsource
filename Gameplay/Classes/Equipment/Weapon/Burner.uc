class Burner extends Weapon;

var() float energyUsage			"The amount of energy to use when fired";

var Shader dialShader;
var ControllableTexturePanner dialTexPanner;
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
			dialTexPanner = new class'ControllableTexturePanner';
			dialTexPanner.PanDirection = Vector(TexPanner(dialCombiner.Material2).PanDirection);
			dialTexPanner.Material = TexPanner(dialCombiner.Material2).Material;

			dialCombiner.Material2 = dialTexPanner;
			dialCombiner.Mask = dialTexPanner;

			dialShader.SelfIllumination = dialCombiner;
		}
	}

	// If succeeded set the shader as the skin for the weapon
	if (dialTexPanner != None)
		setControllableSkins();
}

simulated function bool canFire()
{
	return Character(rookOwner).energy > energyUsage;
}

function useAmmo()
{
	Character(rookOwner).weaponUseEnergy(energyUsage);
}

simulated function bool hasAmmo()
{
	return true;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bIsFirstPerson && equipped)
	{
		if (bControllableSkinSet)
			dialTexPanner.Scale = FMax(0.0, Character(rookOwner).energy / Character(rookOwner).energyMaximum - 0.09);
		else
			buildControllableSkins();
	}
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

simulated function setHasAmmoSkins()
{
	// Always has ammo
}

defaultproperties
{
	dialMaterialIndex = 3

	firstPersonMesh = Mesh'Weapons.Blaster'
	firstPersonOffset = (X=-33,Y=22,Z=-15)

	roundsPerSecond = 1.0
	energyUsage = 20
	ammoUsage = 0

	projectileClass = class'BurnerProjectile'
	projectileVelocity = 3000
	projectileInheritedVelFactor = 1.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Burner"
}