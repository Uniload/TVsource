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
	dialMaterialIndex = 4
	plasmaMaterialIndex = 3

	spread = 4
	numberOfBullets = 7
	firstPersonMesh = Mesh'Weapons.Blaster'
	firstPersonOffset = (X=-33,Y=22,Z=-15)

	roundsPerSecond = 0.4
	energyUsage = 9.0
	ammoUsage = 0

	projectileClass = class'BlasterProjectile'
	projectileVelocity = 3000
	projectileInheritedVelFactor = 1.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Blaster"

	inventoryIcon		= texture'GUITribes.InvButtonBlaster'
	hudIcon				= texture'HUD.Tabs'
	hudIconCoords		= (U=0,V=472,UL=80,VL=40)
	hudRefireIcon		= texture'HUD.Tabs'
	hudRefireIconCoords	= (U=0,V=421,UL=80,VL=40)

	bGenerateMissSpeechEvents = false
}