class Chaingun extends Weapon;

var() float minSpread	"The angular deviation from ideal line of fire in degrees";
var() float maxSpread	"The maximum angle the spread will increase to during heatup";

var() float spinPeriod	"The amount of time it takes for the chaingun to spin up or spin down";
var float spinTime;

var bool overheated;
var() float heatPeriod			"The amount of time it takes for the chaingun to overheat";
var() float coolDownThreshold	"The fraction of the heatPeriod at which the gun can start firing again";
var() float speedCooldownFactor "Multiplier for the speed when calculating cooldown/heatup";
var float heatTime;

var Shader heatShader;
var ConstantColor heatColorMaterial;
var Color heatColor;
var() int heatMaterialIndex;

var bool bControllableSkinSet;

simulated function buildControllableSkins()
{
	// Build a controllable texture panner for the dial shader
	heatShader = Shader(ShallowCopyMaterial(GetMaterial(heatMaterialIndex), self));

	if (heatShader != None)
	{
		heatColorMaterial = ConstantColor(ShallowCopyMaterial(heatShader.SelfIllumination, self));

		if (heatColorMaterial != None)
		{
			heatShader.SelfIllumination = heatColorMaterial;

			heatColor.R = heatColorMaterial.color.R;
			heatColor.G = heatColorMaterial.color.G;
			heatColor.B = heatColorMaterial.color.B;
			heatColor.A = heatColorMaterial.color.A;

			setControllableSkins();
		}
	}
}

simulated function setHasAmmoSkins()
{
	Super.setHasAmmoSkins();
	ammoSkinChange();
}

simulated function setOutOfAmmo()
{
	Super.setOutOfAmmo();
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

	if (Skins.Length <= heatMaterialIndex)
		Skins.Length = heatMaterialIndex + 1;

	for (i = 0; i < heatMaterialIndex; ++i)
	{
		Skins[i] = None;
	}

	Skins[heatMaterialIndex] = heatShader;

	bControllableSkinSet = true;
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Rotator r;
	local float actualSpread;
	local float spreadInRotUnits;

	actualSpread = ((maxSpread - minSpread) * (heatTime / heatPeriod)) + minSpread;

	spreadInRotUnits = actualSpread * 65536 / 360;

	r.Yaw = spreadInRotUnits * (2.0f * FRand() - 1);
	r.Pitch = spreadInRotUnits * (2.0f * FRand() - 1);

	return Super.makeProjectile( fireRot + r, fireLoc );
}

function unEquip()
{
	Super.unEquip();
	spinTime = 0.0;
}

// function for HUD to get weapon spread
simulated function float GetProjectileSpreadScale()
{
	return heatTime / heatPeriod;
}

simulated function updateHeatGlow()
{
	local float colorScale;

	if (bIsFirstPerson && equipped)
	{
		if (bControllableSkinSet)
		{
			if (heatColorMaterial != None)
			{
				colorScale = heatTime / heatPeriod;
				heatColorMaterial.Color.R = float(heatColor.R) * colorScale;
				heatColorMaterial.Color.G = float(heatColor.G) * colorScale;
				heatColorMaterial.Color.B = float(heatColor.B) * colorScale;
				heatColorMaterial.Color.A = float(heatColor.A) * colorScale;
			}
			else
				Log("No heat colour material");
		}
		else
			buildControllableSkins();
	}
}

simulated function bool isInWater()
{
	return (Owner != None && Owner.PhysicsVolume != None && Owner.PhysicsVolume.bWaterVolume) ||
		   (PhysicsVolume != None && PhysicsVolume.bWaterVolume);
}

simulated function float speedRelativeCooldown()
{
	if (Owner != None)
		return VSize(Owner.Velocity) * speedCooldownFactor + 1.0;
	else
		return 1.0;
}

simulated function heatUp(float Delta)
{
	if (isInWater())
	{
		if (heatTime > 0.0)
		{
			heatTime = 0.0;
			TriggerEffectEvent('RapidCooldown');
		}
	}
	else
	{
		heatTime = FMin(heatPeriod, heatTime + (Delta * speedPackScale) / speedRelativeCooldown());
	}

	updateHeatGlow();

	overheated = heatTime >= heatPeriod;
}

simulated function coolDown(float Delta)
{
	if (isInWater())
	{
		if (heatTime > 0.0)
		{
			heatTime = 0.0;
			TriggerEffectEvent('RapidCooldown');
		}
	}
	else
	{
		heatTime = FMax(0.0, heatTime - Delta * speedRelativeCooldown());
	}

	updateHeatGlow();

	if (heatTime <= coolDownThreshold)
		overheated = false;
}

simulated State Idle
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

simulated State Spinup
{
	simulated function BeginState()
	{
		if (spinTime >= spinPeriod)
			spinTime = 0.0;

		if (spinTime == 0.0)
		{
			if (hasAmmo())
				animClass.static.playEquippableAnim(self, 'Start');
			else
				animClass.static.playEquippableAnim(self, 'Start_Empty');
		}
	}

	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (!IsInState('Spinup')) // State change is possible in Global.Tick
			return;

		coolDown(Delta);

		spinTime += Delta;

		if (spinTime >= spinPeriod)
			GotoState('FirePressed');
	}

	simulated protected function bool handleReleaseFire()
	{
		spinTime = spinPeriod - spinTime;

		GotoState('Spindown');

		return true;
	}
}

simulated state FirePressed
{
	simulated function BeginState()
	{
		heatTime = FMin(heatPeriod, heatTime + (1 / roundsPerSecond) * 2.0);
		super.BeginState();
	}
	simulated function Tick(float Delta)
	{
		heatUp(Delta);
		Super.Tick(Delta);
	}
}

simulated state Empty
{
	simulated function BeginState()
	{
		Super.BeginState();
		fireState = 'FirePressed';
	}

	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}

	simulated function EndState()
	{
		Super.EndState();
		fireState = 'Spinup';
	}
}

simulated State Spindown
{
	simulated function BeginState()
	{
		animClass.static.playEquippableAnim(self, 'Spindown_Idle');

		if (spinTime >= spinPeriod)
			spinTime = 0.0;
	}

	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (!IsInState('Spindown')) // State change is possible in Global.Tick
			return;

		coolDown(Delta);

		spinTime += Delta;

		if (spinTime >= spinPeriod)
			GotoState('Idle');
	}

	simulated protected function bool handleFire()
	{
		spinTime = spinPeriod - spinTime;

		GotoState('Spinup');

		return true;
	}
}

simulated State AwaitingPickup
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

simulated State Held
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

simulated State Dropped
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

simulated State Equipping
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

simulated State Unequipping
{
	simulated function Tick(float Delta)
	{
		coolDown(Delta);

		Super.Tick(Delta);
	}
}

defaultproperties
{
     minSpread=1.000000
     maxSpread=4.000000
     spinPeriod=0.500000
     heatPeriod=3.000000
     coolDownThreshold=1.700000
     speedCooldownFactor=0.000800
     heatMaterialIndex=1
     ammoCount=150
     roundsPerSecond=12.000000
     projectileClass=Class'ChaingunProjectile'
     projectileVelocity=5500.000000
     projectileInheritedVelFactor=1.000000
     aimClass=Class'AimProjectileWeapons'
     bGenerateMissSpeechEvents=False
     firstPersonMesh=SkeletalMesh'weapons.Chaingun'
     firstPersonOffset=(X=-23.000000,Y=26.000000,Z=-24.000000)
     animPrefix="Chaingun"
     fireState="Spinup"
     releaseFireState="Spindown"
     animClass=Class'CharacterEquippableAnimator'
     inventoryIcon=Texture'GUITribes.InvButtonChaingun'
     hudIcon=Texture'HUD.Tabs'
     hudIconCoords=(U=205.000000,V=472.000000)
     hudRefireIcon=Texture'HUD.Tabs'
     hudRefireIconCoords=(U=205.000000,V=421.000000)
}
