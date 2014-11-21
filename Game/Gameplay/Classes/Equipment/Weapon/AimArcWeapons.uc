class AimArcWeapons extends AimFunctions;

//=====================================================================
// Constants

const MAX_FLIGHT_TIME = 3.0f;	// estimate maximum flight time of an arced projectile

//=====================================================================
// Functions

//---------------------------------------------------------------------
// AI weapon function: get spot to aim for when firing this weapon

static function Vector getAimLocation( Weapon weapon, Pawn target, optional float leadScale )
{
	local Vector projectileLocation;
	local Vector targetLocation;
	local Vector aimLocation;
	local float timeToHit;
	local float distance;
	local float actualDistance;
	local float angle;			// firing angle
	local float heightDelta;
	local float angleInc;
	local float velX;			// projectile velocity in x
	local float velY;			// projectile velocity in y
	local float g;
	local float mantissa;
	local float sine2Angle;
	local int loopCtr;
	local float multiplicator;

	g = weapon.getPredictedProjectileGravity();

	if ( g == 0 )
		return class'AimProjectileWeapons'.static.getAimLocation( weapon, target );

	if ( leadScale == 0 )
		leadScale = static.getLeadScale( weapon );

	// travel time is somewhat off because of the parabolic trajectory - fix?
	timeToHit = static.projectileTimeToTarget( weapon, target );
	targetLocation = target.predictedLocation( leadScale * timeToHit ) -
					 timetoHit * weapon.rookMotor.getPhysicalAttachment().Velocity * weapon.projectileInheritedVelFactor;

	projectileLocation = weapon.rookMotor.getProjectileSpawnLocation();
	aimLocation = targetLocation;
	aimLocation.Z = projectileLocation.Z;

	distance = VSize2D( aimLocation - projectileLocation );
	heightDelta = targetLocation.Z - projectileLocation.Z;
	multiplicator = 1;

	//log( "getAimLocation:" @ VSize( target.Location - targetLocation ) @ distance @ heightDelta );

	// at what angle must I hold weapon to traverse "distance" (assuming target is at same height as weapon owner)
	sine2Angle = g * distance / weapon.projectileVelocity / weapon.projectileVelocity;

	if ( heightDelta < 0 )
	{
		if ( g == 0 || weapon.projectileVelocity * sqrt( 2 * -heightDelta / g ) > distance )
		{
			// if a horizontal shot would overshoot the target -> point at target and adjust up
			angle = atan( heightDelta, distance );
			angleInc = PI/180*2;
		}
		else
		{
			// if target is lower than shooter -> reduce angle
			angleInc = -PI/180*2;

			// can I shoot far enough?
			if ( sine2Angle > 1 )
				angle = PI/4 - angleInc;	// this is as far as I can shoot
			else
				angle = asin( sine2Angle ) / 2.0f;
		}
	}
	else
	{
		angleInc = PI/180*2;

		// aim at the max of direct angle and angle need to traverse distance, then adjust up
		if ( sine2Angle > 1 )
			angle = PI/4;	// this is as far as I can shoot
		else
		{
			//log( "angle_dist:" @ asin( sineAngle ) * 180 / PI @ "angle_direct:" @ atan( heightDelta, distance ) * 180 / PI );
			angle = FMax( asin( sine2Angle ) / 2.0f, atan( heightDelta, distance ) );
		}
	}

	//log( "New shot!" @ target.name @ "delta:" @ heightDelta @ "sin(2angle):" @ sine2Angle @ "angle:" @ angle / PI * 180 @ g @ weapon.projectileVelocity );

	// iterate over angles until distance travelled by grenade equals actual distance -
	// height sign tells you in which direction to iterate

	do 
	{
		angle += angleInc;

		velX = weapon.projectileVelocity * cos(angle);
		velY = weapon.projectileVelocity * sin(angle);

		// actual distance smaller than distance to apex? If yes, use first solution of the quadratic.
		if ( distance < velX * velY / g )
            multiplicator = -1;
		else
			multiplicator = 1;

		mantissa = FMax(0.0f, velY*velY - 2 * heightDelta * g);	// would be < 0 if target too high
		actualDistance = ( velY + multiplicator*sqrt( mantissa )) * velX / g;

		//log( "mult:" @ multiplicator @ "dist:" @ distance @ "actualDist:" @ actualDistance @ "adjusting by" @ angleInc @ "to" @ angle );

	} until ( ++loopCtr > 10 || angle >= 0.45*PI || static.bEndAngleAdjustment( distance, actualDistance, angleInc, multiplicator ) )

	//log( "its:" @ loopCtr ); 

	if ( angleInc > 0 && angle <= PI/4 )
		angle -= angleInc;			// always undershoot

	assert( angle != PI/2 );
	aimLocation.Z += tan( angle ) * distance; 

	return aimLocation;
}

//---------------------------------------------------------------------
// AI weapon function: return the approximate position of the projectile's impact
// (if nothing is hit timeToHit and hitLocation are unchanged)
// todo: think about whether it's ok for this function to ever return None (since all arced projectiles will eventualy hit *something*)

static function Actor getThingHit( out Vector hitLocation, out float timeToHit, Weapon weapon, Vector projVelocity )
{
	local Actor thingHit;
	local Vector projInitialLocation;	// projecile's starting location
	local Vector projStartPoint;		// projectile's location as it moves along simulated linear segments
	local Vector projEndPoint;
	local Vector hitNormal;

	local float g;					// gravity
	local float timeToApex;			// time till max height is reached
	local float timeToDestination;	// max travel time for projectile

	local float times[5];			// 5 times that define the linear approximation of the projectile parabola
	local float timeAdjust;			// subtracted from time during nounce prediction
	local int maxIt;
	local int i;					// your standard iterator variable

	local class<ArcProjectile> projClass;

	g = weapon.getPredictedProjectileGravity();

	if ( g == 0 )
		return class'AimProjectileWeapons'.static.getThingHit( hitLocation, timeToHit, weapon, projVelocity );

	thingHit = None;

	projClass = class<ArcProjectile>(weapon.projectileClass);
	projInitialLocation = weapon.rookMotor.getProjectileSpawnLocation();
	projStartPoint = projInitialLocation;

	//weapon.rookOwner.loaStartPoint = projInitialLocation;	// debug

	timeToApex = FMax( projVelocity.Z / g, 0.25f );	// if apex time is very small - don't worry about hitting the apex exactly
	timeToDestination = FMax( Abs(5.0f*timeToApex), MAX_FLIGHT_TIME );	// longest time it will take for projectile to reach destination

	// break up parabola into 5 linear segments based on travel time
	if ( timeToApex > 0 )				// projectile is being aimed upwards
	{
		maxIt = 4;
		times[0] = 0.7f * timeToApex;
		times[1] = 1.0f * timeToApex;
		times[2] = 1.3f * timeToApex;
		times[3] = 2.0f * timeToApex;
		times[4] = timeToDestination;
	}
	else								// projectile is being aimed downwards
	{
		maxIt = 3;
		times[0] = 0.25f;
		times[1] = 0.5f;
		times[2] = 1.0f;
		times[3] = timeToDestination;
	}

	// do raytraces along line segments
	for ( i = 0; i <= maxIt; i++ )
	{
		projEndPoint = static.ballisticPosition( projInitialLocation, projVelocity, times[i] - timeAdjust, g );

		thingHit = weapon.AIAimTrace(
					hitLocation, hitNormal,		// out values
					projStartPoint,				// start point
					projEndPoint );				// end point

		//log( i $ ":" @ projStartPoint @ "*" @ projEndPoint @ "*" @ times[i] );

		if ( thingHit != None )
		{
			timeToHit = getTimeToHit( projInitialLocation.Z, projVelocity.Z, g, hitLocation.Z, times[i] - timeAdjust >= timeToApex );
			timeAdjust += timeToHit;

			// bounce prediction is quite inaccurate: so err on the side of caution and don't do it if hitLocation is within "hurtRadius"
			if ( VDistSquared( hitLocation, weapon.Location ) >= projClass.default.radiusDamageSize * projClass.default.radiusDamageSize &&
				timeAdjust <= 0.9f * class<ArcProjectile>(weapon.projectileClass).default.FuseTimer )
			{
				//log( "BOUNCE" @ thingHit.name @ timeToHit @ timeAdjust );
				// velocity of projectile when it reaches hitLocation (XY remain unchanged)
				projVelocity.Z -= timeToHit * g;
				// fully elastic collision of projVelocity around normal
				projVelocity = class<ArcProjectile>(weapon.projectileClass).default.BounceVelocityModifier * mirrorVectorByNormal( projVelocity, hitNormal );
				// recompute timeToApex
				timeToApex = projVelocity.Z / g;
				// new starting location
				projInitialLocation = hitLocation;
				projStartPoint = hitLocation;

				timeToHit = timeAdjust;
			}
			else
			{
				timeToHit = timeAdjust;
				break;
			}
		}
		else
			projStartPoint = projEndPoint;
	}

	// debug 
	//if ( thingHit != None )
	//	weapon.rookOwner.loaEndPoint = hitLocation;
	//else
	//	weapon.rookOwner.loaEndPoint = weapon.Location;

	//log( "getThingHit:" @ weapon.rookOwner.name @ thingHit @ timeToApex );

	return thingHit;
}

//---------------------------------------------------------------------
// time for the projectile to reach the specified Z-value
// secondSolution: 
private static final function float getTimeToHit( float initialZ, float velZ, float g, float z, bool secondSolution )
{
	local float mantissa;
	local float timeToApex;

	timeToApex = velZ / g;
	mantissa = 2/g*(initialZ - z) + timeToApex*timeToApex;

	// can Z be reached?
	if ( mantissa <= 0 )
		return FMax( 0, timeToApex );	// no: return time at which max height is reached

	if ( secondSolution )
		return FMax( 0, sqrt( mantissa ) + timeToApex );
	else
		return FMax( 0, -sqrt( mantissa ) + timeToApex );
}

//---------------------------------------------------------------------
// helper function for iterative computation of throw angle

private static final function bool bEndAngleAdjustment( float distance, float actualDistance, float angleInc, float multiplicator )
{
	if ( angleInc < 0 || multiplicator < 0 )
		return actualDistance < distance;	// decreasing angle or angle >= 45 -> actualDistance will get iteratively smaller 
	else
		return actualDistance > distance;	// increasing angle -> actualDistance will iteratively increase
}

//---------------------------------------------------------------------
// helper function for ballistic movement

private static final function Vector ballisticPosition( Vector location, Vector velocity, float t, float gravity )
{
	location.Z -= 0.5f * gravity * t * t;
	return location + t * velocity;
}
