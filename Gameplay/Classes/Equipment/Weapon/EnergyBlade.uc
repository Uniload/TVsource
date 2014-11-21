class EnergyBlade extends Weapon;

var() int range;
var() int damageAmt;
var() float energyUsage;

var() float knockBackVelocity;

var() class<DamageType> damageTypeClass;

function useAmmo()
{
	Character(rookOwner).weaponUseEnergy(energyUsage);
}

simulated function bool hasAmmo()
{
	if (character(rookOwner) == None)
		return false;

	return Character(rookOwner).energy > energyUsage;
}

simulated function bool canFire()
{
	return hasAmmo();
}

simulated protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Vector hitLocation;
	local Vector hitNormal;
	local Vector traceEnd;
	local Material hitMaterial;
	local Actor victim;
	local Actor viewActor;
	local Vector startLoc;
	local Rotator viewRot;
	local PlayerController pc;

	useAmmo();
	fireCount++;

	pc = PlayerController(rookOwner.Controller);

	if (pc != None)
	{
		startLoc = pc.location;
		viewRot = pc.rotation;
		viewActor = Owner;
		pc.PlayerCalcView(viewActor, startLoc, viewRot);
	}
	else
	{
		startLoc = Owner.Location;
		viewRot = fireRot;
	}

	traceEnd = fireLoc + Vector(viewRot) * range;

	victim = Trace(hitLocation, hitNormal, traceEnd, startLoc, true, Vect(0.0, 0.0, 0.0), hitMaterial);

	if (victim != None)
	{
		TriggerEffectEvent('Hit', None, hitMaterial, hitLocation, Rotator(hitNormal));

		if (Level.NetMode != NM_Client)
			victim.TakeDamage(damageAmt, rookOwner, hitLocation, Normal(traceEnd - fireLoc) * knockBackVelocity, damageTypeClass);
	}

	return None;
}

function drawDebug(HUD debugHUD)
{
	local Rotator fireRot;
	local Vector traceBegin;
	local Vector traceEnd;

	fireRot = Character(rookOwner).motor.getViewRotation();

	traceBegin = calcProjectileSpawnLocation(fireRot);

	traceEnd = traceBegin + Vector(fireRot) * range;

	debugHUD.Draw3DLine(traceBegin, traceEnd, class'Canvas'.Static.MakeColor(0, 0, 255));
}

defaultproperties
{
	damageAmt = 20.0

	firstPersonMesh = Mesh'Weapons.Blade'
	firstPersonOffset = (X=-15,Y=22,Z=-15)

	roundsPerSecond = 0.5

	ammoUsage = 0
	energyUsage = 25.0

	range = 200

	knockBackVelocity = 5000

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "EnergyBlade"
	equippedArmAnim = "weapon_energyblade_hold"

	bGenerateMissSpeechEvents = false

	damageTypeClass = class'ProjectileDamageType'
}