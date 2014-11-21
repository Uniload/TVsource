class stvGrapplerProjectile extends Gameplay.GrapplerProjectile;

//server crash fix
simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	local Character c;
	c = Character(Other);

	  if(c != None)
            Destroy();

	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(true, true, true);
}

defaultproperties
{
}
