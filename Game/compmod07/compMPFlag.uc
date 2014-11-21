class compMPFlag extends Gameplay.MPFlag;

singular function Touch(Actor Other)
{
	local Character c;
	local GrapplerProjectile p;
	local vector hitLoc, hitNormal, startLoc, testLoc;

	p = GrapplerProjectile(Other);
	if (p != None)
	{
		log("flag grappled");
		//Character(p.Instigator).detachGrapple();
		onGrappled(Character(p.instigator));
		return;
	}

	c = Character(Other);

	if (c == None || c.controller == None || bHidden || !c.isAlive() || carrier != None 
		|| c.bDontAllowCarryablePickups || c.Physics == PHYS_None || !bInitialized)
	{
		//Log("Unable to pickup "$self$" probably due to "$bInitialized);
		return;
	}

	// Don't allow picking up through geometry
	// TODO:  Unfortunately this doesn't fully solve the case of energy barriers where
	// the player can be standing inside one
	startLoc = c.Location - Normal(c.Location - Location) * 10;
	testLoc = Location;
	testLoc.z += CollisionHeight;
	if (Trace(hitLoc, hitNormal, startLoc, testLoc, false) != None)
	{
		//Log("Not allowing pickup of "$self$" due to Trace");
		return;
	}

	//Log(self$" attempting pickup by "$c);
	attemptPickup(c);
}

defaultproperties
{
}
