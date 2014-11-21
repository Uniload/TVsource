class x2BurningArea extends EquipmentClasses.ProjectileBurnerBurningArea;

simulated function Tick(float Delta)
{
	local Actor hook;
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{

		if (!Touching[i].bProjTarget)
			continue;

		hook = x2DegrappleProjectile(Touching[i]);
		
		if (hook != None)
		{
                hook.TakeDamage(x2DegrappleProjectile(hook).burningDamagerPerSecond * Delta, None, Location, Velocity, None);
		}
	}
	super.Tick(Delta);
}

defaultproperties
{
}
