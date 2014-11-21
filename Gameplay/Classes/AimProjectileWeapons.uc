class AimProjectileWeapons extends AimFunctions;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// AI weapon function: get spot to aim for when firing this weapon

static function Vector getAimLocation( Weapon weapon, Pawn target, optional float leadScale )
{
	local float timeToHit;

	assert( target != None );
	assert( weapon.rookMotor != None );

	if ( leadScale == 0 )
		leadScale = static.getLeadScale( weapon );

	timeToHit = static.projectileTimeToTarget( weapon, target );
	return target.predictedLocation( leadScale * timeToHit ) -
			timetoHit * weapon.rookMotor.getPhysicalAttachment().Velocity * weapon.projectileInheritedVelFactor;
}

//---------------------------------------------------------------------
// AI weapon function: return the approximate position of the projectile's impact
// (if nothing is hit timeToHit and hitLocation are unchanged)

static function Actor getThingHit( out Vector hitLocation, out float timeToHit, Weapon weapon, Vector projVelocity )
{
	local Actor thingHit;
	local Vector spawnLocation;
	local Vector hitNormal;

	spawnLocation = weapon.rookMotor.getProjectileSpawnLocation();

	thingHit = weapon.AIAimTrace(
				hitLocation, hitNormal,											// out value
				spawnLocation,													// start point
				spawnLocation + MAX_PROJECTILE_TRAVEL_TIME * projVelocity );	// end point

	if ( thingHit != None )
		timeToHit = VSize( hitLocation - spawnLocation ) / VSize( projVelocity );

	return thingHit;
}

defaultproperties
{
}
