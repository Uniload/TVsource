class MPCarryableThrower extends TimeChargeUpWeapon;
var()	float		extraSpawnDistance	"This distance will be added when carryables spawn as projectiles.  Can be used to prevent self-collisions.";
var	MPCarryable		carryable;

replication
{
	reliable if (Role == ROLE_Authority)
		carryable;
}

simulated function heldByCharacter(Character c)
{
	return; // MPCarryableThrower doesn't need this function
}

simulated function droppedByCharacter(Character c)
{
	return; // MPCarryableThrower doesn't need this function
}

function setCarryable(MPCarryable c)
{
	carryable = c;
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local vector newLoc; //hitLoc, hitNormal, startLoc;
	local int i;
	local MPCarryable extraCarryable;
	local Character c;
	local int numThrown;
	//local Vector extra, extraLoc, testLoc;;
	local bool bFreeze;

	c = Character(Owner);

	//startLoc = Owner.Location;
	//startLoc.z = c.EyeHeight;
	newLoc = fireLoc;
	//// hack check to stop carryable from falling through terrain
	//if (TerrainInfo(Trace(hitLoc, hitNormal, newLoc, startLoc, false, carryable.GetCollisionExtent())) != None)
	//{
	//	newLoc += hitNormal * carryable.CollisionHeight;
	//}

	//// Push the carryable further away from the player
	//// MJ:  Disabled because it was used for Fuel but you currently can't throw Fuel
	//extra.X = extraSpawnDistance;
	//extra.Y = extraSpawnDistance;
	//extra.Z = 0;
	//extraLoc += Normal(Vector(fireRot)) * extra;

	//// Don't allow throwing through geometry
	//// MJ:  Disabled...may no longer be necessary
	//startLoc -= Normal(Vector(fireRot)) * 10;
	//testLoc = extraLoc + Normal(Vector(fireRot)) * 10;
	//if (Trace(hitLoc, hitNormal, startLoc, fireLoc, true, carryable.GetCollisionExtent()) != None)
	//{
	//	bFreeze = true;
	//	newLoc = c.Location - hitNormal * 20;
	//}

	// First compose carryables into their largest denominations (if applicable)
	c.composeCarryables();

	// Throw carryables with spread
	// Don't throw the first one because it should be thrown without spread
	// Don't throw the character's permanent carryables
	// Throw in reverse so we can just chop off the array
	for(i=c.carryables.Length - 1; i>c.numPermanentCarryables; i--)
	{
		extraCarryable = c.carryables[i];
		//Log("Carryable makeProjectile "$extraCarryable$", newLoc = "$newLoc$", shooterloc = "$c.Location$", fireRot = "$fireRot);
		launchCarryable(extraCarryable, newLoc, fireRot, true, bFreeze);
		numThrown++;
	}

	// Throw the first carryable without spread
	launchCarryable(c.carryables[0], newLoc, fireRot, false, bFreeze);
	numThrown++;

	fireCount++;

	// If none should be left, clear them completely
	if (c.numPermanentCarryables == 0)
		c.clearCarryables();
	// Otherwise clear them partially
	else
	{
		c.carryables.Length = c.carryables.Length - numThrown;
		c.numCarryables = c.carryables.Length;
	}

	return None;
}

function launchCarryable(MPCarryable c, Vector newLoc, Rotator fireRot, bool bSpread, optional bool bFreeze)
{
	local Vector X, Y, Z;
	local Vector newVelocity;

	GetAxes(fireRot, X, Y, Z);

	c.SetPhysics(c.droppedPhysics);
	c.bWasDropped = true;
	c.unifiedSetPosition(newLoc);
	//c.SetRotation(fireRot);
	newVelocity = Normal(Vector(fireRot)) * projectileVelocity;

	// Random spread for all carryables except the first
	if (bSpread)
		newVelocity += Vector(fireRot) + (c.spread * (FRand() - 0.5)) * X +
										(c.spread * (FRand() - 0.5)) * Y +
										(c.spread * (FRand() - 0.5)) * Z;

	// Charge it
	newVelocity *= charge * chargeScale + 1.0;

	// inherit velocity from pawn
	newVelocity += Owner.Velocity * projectileInheritedVelFactor;

	if (bFreeze)
		c.unifiedSetVelocity(Vect(0, 0, 0));
	else
		c.unifiedSetVelocity(newVelocity);

	//Log("Launching "$c$" with velocity = "$newVelocity$" and charge "$charge$" at location "$newLoc$" in physics "$c.droppedPhysics);

	c.GotoState('Dropped');
}

simulated function moveWeapon()
{
	if (firstPersonMesh != None || firstPersonAltMesh != None)
		super.moveWeapon();
}

protected function fireWeapon()
{
	local Vector fireLoc;

	fireLoc = rookMotor.getProjectileSpawnLocation();
	makeProjectile(getAimRotation(fireLoc), fireLoc);

	lastFireTime = Level.TimeSeconds;

	bFiredWeapon = true;
}

simulated state FirePressed
{
	simulated function BeginState()
	{
		super.BeginState();
		carryable.bThrowingEffect = true;
		carryable.updateCarryableEffects();
		animClass.static.playEquippableAnim(self, fireAnimation);
	}
}

simulated state FireReleased
{
	simulated function BeginState()
	{
		super.BeginState();

		if (Role == ROLE_Authority)
		{
			carryable.bThrowingEffect = false;
			carryable.updateCarryableEffects();
		}

		// carryable code will put state to 'dropped'
	}
}

// dropped state: we can never really be dropped, we just hide ourselves and disable collision so we can't be picked up
simulated state Dropped
{
	simulated function BeginState()
	{
		Character(Owner).removeEquipment(self);
		equipped = false;
		bHidden = true;
		SetCollision(false, false, false);
	}
}

// if carryable is a weapon-type, we need to handle display and attachment when we are the selected weapon
simulated state Idle
{
	simulated function BeginState()
	{
		super.BeginState();
		if (Role == ROLE_Authority && carryable.bIsWeaponType)
		{
			carryable.bHidden = true;
		}
	}

	simulated function Tick(float Delta)
	{
		super.Tick(Delta);

		if (!IsAnimating())
			playIdleAnim();
	}
}

// if carryable is a weapon-type, we need to handle display and attachment when we are not the selected weapon
simulated state Held
{
	simulated function BeginState()
	{
		super.BeginState();
		if (Role == ROLE_Authority && carryable.bIsWeaponType)
		{
			if (carryable.isReplicatedInstance())
			{
				carryable.attachToCarrier();
				carryable.bHidden = false;
			}
			else
				carryable.bHidden = true;
		}
	}
}

defaultproperties
{
	firstPersonMesh = None
	thirdPersonMesh = None

	chargeScale = 1
	maxCharge = 0.5
	roundsPerSecond = 1.0

	ammoCount = 1
	ammoUsage = 1

	projectileClass = None
	projectileVelocity = 800
	projectileInheritedVelFactor = 1.0

	firstPersonOffset = (X=50,Y=30,Z=0)

	aimClass = class'AimArcWeapons'
	animClass = class'CharacterEquippableAnimator'
	animPrefix = "Carryable"
	releaseAnimation = "throw"
	releaseDelay = 0.1

	bShowChargeOnHUD = true
	bCanDrop = false

	extraSpawnDistance = 100
}