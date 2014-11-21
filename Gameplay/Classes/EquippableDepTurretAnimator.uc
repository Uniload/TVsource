class EquippableDepTurretAnimator extends EquippableAnimator;

static simulated function bool hasEquippableAnim(Equippable e, Name animName)
{
	return false;
}

static simulated function playEquippableAnim(Equippable e, Name animName, optional float rate, optional float tweenTime, optional int channel)
{
	if (e.Owner != None && e.Owner.HasAnim(animName))
		e.Owner.PlayAnim(animName);
}

static simulated function firstPersonStatus(Equippable e, bool bStatus)
{
}

static simulated function setLocRot(Equippable e, Vector newLocation, Rotator newRotation)
{
}

defaultproperties
{
}
