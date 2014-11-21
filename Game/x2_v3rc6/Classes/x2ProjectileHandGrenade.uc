class x2ProjectileHandGrenade extends EquipmentClasses.ProjectileHandGrenade;

simulated function bool projectileTouchProcessing(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (Other.IsA('BaseCatapult'))
	{
		return false;
	}
        if (Other.IsA('DeployedCatapult'))
	{
		return false;
	}
	return true;
	super.projectileTouchProcessing(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
}
