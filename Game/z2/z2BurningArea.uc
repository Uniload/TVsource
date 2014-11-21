class z2BurningArea extends EquipmentClasses.ProjectileBurnerBurningArea;

simulated function Tick(float Delta)
{

	local Actor hook;
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{

		if (!Touching[i].bProjTarget)
			continue;

		hook = z2DegrappleProjectile(Touching[i]);
		
		if (hook != None)//&& FastTrace(hook.Location))
		{

			hook.TakeDamage(z2DegrappleProjectile(hook).burningDamagerPerSecond * Delta, None, Location, Velocity, None);
		}
	}
	super.Tick(Delta);
}

defaultproperties
{
}
