class TurretMotor extends Motor implements IFiringMotor
	native;

var Turret			turret;

// construct
overloaded simulated function construct( actor Owner, optional optional name Tag, 
										  optional vector Location, optional rotator Rotation)
{
	Super.construct(Owner, Tag, Location, Rotation);

	turret = Turret(Owner);
	if (turret == None)
	{
		LOG("ERROR: TurretMotor's owner is not a turret");
	}
}

// setZoomed
event setZoomed(bool bZoomed)
{
	if (turret.driver != None)
		turret.driver.setZoomed(bZoomed);
}

// setViewTarget
native function setViewTarget(Rotator r);

// getViewTarget
native function Rotator getViewTarget();

// getViewRotation
native function Rotator getViewRotation();

function bool aimAdjustViewRotation()
{
	return true;
}

function setViewRotation(Rotator r)
{
	// can only set view target
	setViewTarget(r);
}

// fire
native function fire(optional bool fireOnce);

// altFire
function altFire(optional bool fireOnce)
{

}

// releaseAltFire
function releaseAltFire()
{

}

// releaseFire
native function releaseFire();

function bool shouldFire(Equippable e)
{
	return false;
}

function setFirePressed(Equippable e, bool pressed)
{
}

/*//setWeapon
event setWeapon(Weapon w)
{
	if (turret.deployable != None)
		setDeployable(None);

	if (turret.weapon != None)
		turret.weapon.unEquip(w);
	else if (w != None)
		w.equip();
}*/

function vector getProjectileSpawnLocation()
{
	if (turret.weapon == None)
	{
		warn("attempted to get projectile spawn location from turret with no weapon");
		return turret.location;
	}

	return turret.weapon.calcProjectileSpawnLocation(getViewRotation());
}

function onShotFiredNotification()
{
	// ignore
}

function float getEnergy()
{
	warn("not implemented");
	return 0.0f;
}

function useEnergy(float amount)
{
	warn("not implemented");
}

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart);

simulated function vector getFirstPersonEquippableLocation(Equippable subject)
{
	local Vector v;

	v = turret.Location + (subject.getFirstPersonOffset() >> turret.controller.GetViewRotation()) + (turret.WalkBob * (1.0 - subject.firstPersonBobMultiplier));
	v.Z += turret.EyeHeight;

	return v;
}

simulated function rotator getFirstPersonEquippableRotation(Equippable subject)
{
	return turret.Controller.GetViewRotation();
}

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = turret;
	boneName = 'weapon';
}

function Rook getPhysicalAttachment()
{
	return turret;
}

function Weapon getWeapon()
{
	return turret.weapon;
}

simulated function Actor getEffectsBaseActor()
{
	return None;
}

simulated function bool customFiredEffectProcessing()
{
	return false;
}

simulated function doCustomFiredEffectProcessing()
{
	assert(false);
}

defaultproperties
{
}
