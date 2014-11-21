class Blaster extends Weapon;

var() float spread "Max angular deviation from ideal line of fire in degrees"; //needs to shoot multiple projectiles at once, with a certain spread 
var() int numberOfBullets	"Number of bullets to fire when shot";

var() float energyUsage		"Amount of energy to use when shot";

var Shader plasmaShader;
var ControllableTexturePanner plasmaTexPanner;
var() int plasmaMaterialIndex;

var Shader dialShader;
var ControllableTexturePanner dialTexPanner;
var() int dialMaterialIndex;

var bool bControllableSkinSet;

var float baseScale;
var float nextFireTime;
var float timeCounter;
var bool bPostFire;

simulated function buildControllableSkins()
{
	local Combiner dialCombiner;

	// Build a controllable texture panner for the plasma shader
	plasmaShader = Shader(ShallowCopyMaterial(GetMaterial(plasmaMaterialIndex), self));

	if (plasmaShader != None)
	{
		plasmaTexPanner = new class'ControllableTexturePanner';
		plasmaTexPanner.PanDirection = Vector(TexPanner(plasmaShader.SelfIllumination).PanDirection);
		plasmaTexPanner.Material = TexPanner(plasmaShader.SelfIllumination).Material;

		plasmaShader.Diffuse = plasmaTexPanner;
		plasmaShader.SelfIllumination = plasmaTexPanner;
		plasmaShader.SelfIlluminationMask = plasmaTexPanner;
	}

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

	// If both succeeded set the shaders as the skins for the weapon
	if (plasmaTexPanner != None && dialTexPanner != None)
		setControllableSkins();
}

simulated protected function FireWeapon()
{
	Super.FireWeapon();

	baseScale = 0.5;
	bPostFire = true;
	timeCounter = 0.0;
	nextFireTime = 1 / roundsPerSecond;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (useAlternateMesh())
		return;

	if (PlayerCharacter(Owner) != None)
	{
		if (bControllableSkinSet)
		{
			dialTexPanner.Scale = FMax(0.0, Character(rookOwner).energy / Character(rookOwner).energyMaximum - 0.09);

			if (bPostFire)
			{
				timeCounter += DeltaTime;

				plasmaTexPanner.Scale = FMax(0.0, 0.5 - ((timeCounter / nextFireTime) * 0.5));

				bPostFire = timeCounter <= nextFireTime;

				if (!bPostFire)
					baseScale = 0.0;
			}
			else
			{
				plasmaTexPanner.Scale = baseScale;
			}
		}
		else
			buildControllableSkins();
	}
}

simulated function setControllableSkins()
{
	local int maxNeedIndex;
	local int i;

	maxNeedIndex = Max(plasmaMaterialIndex, dialMaterialIndex);

	if (Skins.Length <= maxNeedIndex)
		Skins.Length = maxNeedIndex + 1;

	for (i = 0; i < maxNeedIndex; ++i)
	{
		Skins[i] = None;
	}

	Skins[plasmaMaterialIndex] = plasmaShader;
	Skins[dialMaterialIndex] = dialShader;

	bControllableSkinSet = true;
}

simulated function setHasAmmoSkins()
{
	// Always has ammo
}

function useAmmo()
{
	Character(rookOwner).weaponUseEnergy(energyUsage);
}

simulated function bool hasAmmo()
{
	return true;
}

simulated function bool canFire()
{
	return (rookOwner != None) && (Character(rookOwner).energy > (energyUsage * numberOfBullets));
}

// makeProjectile
// not simulated, server only
protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Rotator r;
	local float spreadInRotUnits;
	local int i;

	spreadInRotUnits = spread * 65536 / 360;

	for (i = 0; i < numberOfBullets; i++)
	{
		r.Yaw = spreadInRotUnits * (2.0f * FRand() - 1);
		r.Pitch = spreadInRotUnits * (2.0f * FRand() - 1);

		Super.makeProjectile( fireRot + r, fireLoc );
	}

	return None; // Warning: return None for this weapons projectile
}

defaultproperties
{
     Spread=4.000000
     numberOfBullets=7
     energyUsage=9.000000
     plasmaMaterialIndex=3
     dialMaterialIndex=4
     ammoUsage=0
     roundsPerSecond=0.400000
     projectileClass=Class'BlasterProjectile'
     projectileVelocity=3000.000000
     projectileInheritedVelFactor=1.000000
     aimClass=Class'AimProjectileWeapons'
     bGenerateMissSpeechEvents=False
     firstPersonMesh=SkeletalMesh'weapons.Blaster'
     firstPersonOffset=(X=-33.000000,Y=22.000000,Z=-15.000000)
     animPrefix="Blaster"
     animClass=Class'CharacterEquippableAnimator'
     inventoryIcon=Texture'GUITribes.InvButtonBlaster'
     hudIcon=Texture'HUD.Tabs'
     hudIconCoords=(V=472.000000)
     hudRefireIcon=Texture'HUD.Tabs'
     hudRefireIconCoords=(V=421.000000)
}
