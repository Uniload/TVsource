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
     Range=200
     damageAmt=20
     energyUsage=25.000000
     knockBackVelocity=5000.000000
     damageTypeClass=Class'ProjectileDamageType'
     ammoUsage=0
     aimClass=Class'AimProjectileWeapons'
     bGenerateMissSpeechEvents=False
     firstPersonMesh=SkeletalMesh'weapons.Blade'
     firstPersonOffset=(X=-15.000000,Y=22.000000,Z=-15.000000)
     animPrefix="EnergyBlade"
     animClass=Class'CharacterEquippableAnimator'
     equippedArmAnim="weapon_energyblade_hold"
}
