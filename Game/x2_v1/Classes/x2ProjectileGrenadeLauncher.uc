class x2ProjectileGrenadeLauncher extends EquipmentClasses.ProjectileGrenadeLauncher;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
       super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

simulated function bool projectileTouchProcessing(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (Other.IsA('BaseCatapult')) || (Other.IsA('DeployedCatapult'))
	{
		return false;
	}

	return true;
	super.projectileTouchProcessing(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
}
