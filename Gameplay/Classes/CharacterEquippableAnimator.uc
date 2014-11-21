class CharacterEquippableAnimator extends EquippableAnimator;

static simulated function bool isAnimating(Equippable e)
{
	local Character c;
	c = Character(e.rookOwner);

	return e.IsAnimating() && (c == None || c.arms.IsAnimating());
}

static simulated function bool hasEquippableAnim(Equippable e, Name animName)
{
	local Name prefixedAnimName;

	if (e.Mesh == None)
		return false;

	if (!e.bIsFirstPerson)
		return super.hasEquippableAnim(e, animName);

	if (e.animPrefix != "")
		prefixedAnimName = Name(e.animPrefix $ "_" $ animName);
	else
		prefixedAnimName = animName;

	return e.HasAnim(prefixedAnimName);
}

static simulated function playEquippableAnim(Equippable e, Name animName, optional float rate, optional float tweenTime, optional int channel)
{
	local Character c;
	local Name prefixedAnimName;

	if (e.Mesh == None)
		return;

	if (e.animPrefix != "")
		prefixedAnimName = Name(e.animPrefix $ "_" $ animName);
	else
		prefixedAnimName = animName;

	// The native execPlayAnim gives rate a default of 1.0 but we can't do that in script (the default is always 0.0),
	// so we need to assume that a rate of 0.0 is "invalid" and set it to 1.0
	if (rate == 0.0)
		rate = 1.0;

	if (e.bIsFirstPerson)
	{
		if (e.HasAnim(prefixedAnimName))
			e.PlayAnim(prefixedAnimName, rate, tweenTime, channel);

		c = Character(e.rookOwner);

		if (c != None)
		{
			if (c.arms != None)
			{
				if (c.arms.HasAnim(prefixedAnimName))
					c.arms.PlayAnim(prefixedAnimName, rate, tweenTime, channel);

				c.needToPlayArmAnim = '';
			}
			else
				c.needToPlayArmAnim = prefixedAnimName;
		}
	}
	else
		super.playEquippableAnim(e, animName, rate, tweenTime, channel);
}

static simulated function firstPersonStatus(Equippable e, bool bStatus)
{
	local Character c;

	c = Character(e.rookOwner);

	if (c != None && c.arms != None)
		c.arms.bHidden = !bStatus;
}

static simulated function setLocRot(Equippable e, Vector newLocation, Rotator newRotation)
{
	local Character c;

	if (e.bIsFirstPerson)
	{
		c = Character(e.rookOwner);

		if (c != None && c.arms != None)
		{
			c.arms.SetLocation(newLocation);
			c.arms.SetRotation(newRotation);
		}
	}
}

defaultproperties
{
}
