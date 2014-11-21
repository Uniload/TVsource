class compBurningArea extends EquipmentClasses.ProjectileBurnerBurningArea;

simulated function Tick(float Delta)
{

	local Actor hook;
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{
		if (!Touching[i].bProjTarget)
			continue;

		hook = compGrapplerProjectile(Touching[i]);
		
		if (hook != None)//&& FastTrace(hook.Location))
		{
			hook.TakeDamage(compGrapplerProjectile(hook).burningDamagerPerSecond * Delta, None, Location, Velocity, None);
		}
	}

	super.Tick(Delta);
}

defaultproperties
{
}
