class EquippableAnimator extends Core.Object;

static simulated function bool isAnimating(Equippable e)
{
	return e.IsAnimating();
}

static simulated function bool hasEquippableAnim(Equippable e, Name animName)
{
	return e.HasAnim(animName);
}

static simulated function playEquippableAnim(Equippable e, Name animName, optional float rate, optional float tweenTime, optional int channel)
{
	// The native execPlayAnim gives rate a default of 1.0 but we can't do that in script (the default is always 0.0),
	// so we need to assume that a rate of 0.0 is "invalid" and set it to 1.0
	if (rate == 0.0)
		rate = 1.0;

	if (e.Mesh != None && e.HasAnim(animName))
		e.PlayAnim(animName, rate, tweenTime, channel);
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
