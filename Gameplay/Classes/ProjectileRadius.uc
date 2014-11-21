class ProjectileRadius extends Engine.Actor;

simulated function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (Owner == None)
	{
		Destroy();
		return;
	}

	if (Other.bProjTarget)
		Projectile(Owner).ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     bProjectile=True
}
