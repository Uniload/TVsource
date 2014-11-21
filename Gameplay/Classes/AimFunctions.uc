//=====================================================================
// AimFunctions
//
// Different types of weapons implement aiming differently.
//=====================================================================

class AimFunctions extends Core.Object;

//=====================================================================
// Constants

const MAX_PROJECTILE_TRAVEL_TIME = 100;		// upper limit on the number of seconds a projectile will travel
const MAX_GRENADE_LAUNCHER_RANGE = 5000;	// maximum range at which to fire a grenade launcher
const MAX_BLASTER_RANGE = 2500;				// maximum range at which to fire a blaster
const DAMAGECHECK_RADIUS_BUFFER = 100;		// add to explosive projectile radius checks to catch friendlies that could be hurt 

//=====================================================================
// Functions

//---------------------------------------------------------------------
// AI weapon function: get spot to aim for when firing this weapon

static function Vector getAimLocation( Weapon weapon, Pawn target, optional float leadScale );

//---------------------------------------------------------------------
// get factor to multiply shot leading component of aiming computation with

static function float getLeadScale( Weapon weapon )
{
	local Rook rook;

	rook = weapon.rookMotor.getPhysicalAttachment();
	return rook.shotLeadAbility.Min + FRand() * (rook.shotLeadAbility.Max - rook.shotLeadAbility.Min);
}

//---------------------------------------------------------------------
// AI weapon function: return the approximate time to the projectile's impact

static function float getTimeToHitTarget( Weapon weapon, Pawn target )
{
	local Vector spawnLocation;

	spawnLocation = weapon.rookMotor.getProjectileSpawnLocation();

	return VSize( target.Location - spawnLocation ) / VSize( static.getProjectileVelocity( weapon, target.Location ) );
}

//---------------------------------------------------------------------
// AI weapon function: return the approximate position of the projectile's impact
// (if nothing is hit timeToHit and hitLocation are unchanged)

static function Actor getThingHit( out Vector hitLocation, out float timeToHit, Weapon weapon, Vector projVelocity );

//---------------------------------------------------------------------
// AI weapon function: can projectile hit the target? Returns Actor in the way or None if path clear
// (if nothing is hit timeToHit and hitLocation are unchanged)

static function Actor obstacleInPath( out Vector hitLocation, out float timeToHit, Pawn target, Weapon weapon, Vector aimLocation )
{
	local Actor thingHit;
	local Vector projVelocity;
	local Rook rookHit;

	projVelocity = static.getProjectileVelocity( weapon, aimLocation );
	thingHit = static.getThingHit( hitLocation, timeToHit, weapon, projVelocity );
	rookHit = Rook(thingHit);

	//log( weapon.rookOwner.name $ ": obstacleInPath:" @ thingHit @ 
	//	static.getProjectileDamageRadius( weapon.projectileClass ) + target.CollisionHeight + target.CollisionRadius @
	//	VSize(hitLocation - Character(target).predictedLocation( timeToHit )));

	//weapon.drawDebugLine( weapon.Location, hitLocation, 0,255,0 );

	// trace hit target -> go ahead and shoot (duh!)
	if ( thingHit == target )
		return None;

	// trace hit object, but object is behind target -> no obstacle in path
	if ( thingHit != None &&
		VSize( hitLocation - weapon.Location ) > VSize( target.Location - weapon.Location ))
	{
		//log( weapon.rookOwner.name $ ": obstacleInPath:" @ thingHit @ "behind target (" @ VSize( hitLocation - weapon.Location ) @ ">" @ VSize( target.Location - weapon.Location ) @ ")" );
		return None;
	}

	if ( rookHit != None && weapon.rookMotor.getPhysicalAttachment().isFriendly( rookHit ) )
	{
		//log( weapon.rookOwner.name $ ": obstacleInPath: friendly hit" );
		return thingHit;
	}

	// trace hit object -> go ahead and shoot if hit within splash damage range
	if ( thingHit != None &&
		static.willHurt( weapon, target, hitLocation, timeToHit ))
	{
		//log( weapon.rookOwner.name $ ": obstacleInPath: Within splash damage range" );
		return None;
	}
	
	return thingHit;
}

//---------------------------------------------------------------------
// Will this weapon's projectile hurt 'target' with splash damage if hits 'hitLocation'

static function bool willHurt( Weapon weapon, Pawn target, Vector hitLocation, float timeToHit )
{
	local float damageRadius;
	local Vector predictedLocation;
	local Vector hitLocation2, hitNormal;
	local Actor thingHit;
	local class<ExplosiveProjectile> explosiveProjClass;
	local class<BurnerProjectile> burnerProjClass;

	explosiveProjClass = class<ExplosiveProjectile>(weapon.projectileClass);
	burnerProjClass = class<BurnerProjectile>(weapon.projectileClass);

	if ( explosiveProjClass != None )
		damageRadius = explosiveProjClass.default.radiusDamageSize;
	else if ( burnerProjClass != None )
		damageRadius = burnerProjClass.default.postIgnitionColRadius + 50;

	if ( damageRadius > 0 )
	{
		predictedLocation = target.predictedLocation( timeToHit );
		if ( VSize( predictedLocation - hitLocation ) <= damageRadius + target.CollisionHeight )
		{
			// check if splash damage would be done to hitLocation
			thingHit = weapon.AIAimTrace( hitLocation2, hitNormal, hitLocation, predictedLocation );
			return thingHit == None || thingHit == target ;
		}
		else
			return false;
	}
	else
		return false;
}

//---------------------------------------------------------------------
// get projectile velocity vector of projectile if weapon were to be fired now

static function Vector getProjectileVelocity( Weapon weapon, Vector aimLocation )
{
	local Vector projVelocity;

	// determine projectile velocity
	projVelocity = aimLocation - weapon.rookMotor.getProjectileSpawnLocation();
	projVelocity *= weapon.projectileVelocity / VSize( projVelocity );
	projVelocity += weapon.rookMotor.getPhysicalAttachment().Velocity * weapon.projectileInheritedVelFactor;

	return projVelocity;
}

//---------------------------------------------------------------------
// radius of projectile damage

static function float getProjectileDamageRadius( class<Projectile> projectileClass )
{
	if ( ClassIsChildOf( projectileClass, class'ExplosiveProjectile' ) )
		return class<ExplosiveProjectile>(projectileClass).default.radiusDamageSize;
	else
		return 0;
}

//---------------------------------------------------------------------
// maximum effective range of a weapon (-1 is an unspecified range)

static function float getMaxEffectiveRange( class<Weapon> weaponClass )
{
	if ( ClassIsChildOf( weaponClass, class'EnergyBlade' ) )
		return class<EnergyBlade>(weaponClass).default.range;
	else if ( ClassIsChildOf( weaponClass, class'GrenadeLauncher' ) )
		return MAX_GRENADE_LAUNCHER_RANGE;
	else if ( ClassIsChildOf( weaponClass, class'Blaster' ))
		return MAX_BLASTER_RANGE;
	else
		return -1;
}

//---------------------------------------------------------------------
// The time it takes for the projectile to hit the target,
// taking inherited velocity into account

static function float projectileTimeToTarget( Weapon weapon, Pawn target )
{
	local Vector targetDirection;
	local Vector projectileVelocity;
	local float targetDistance;

	assert( target != None );

	targetDirection = target.Location - weapon.rookMotor.getProjectileSpawnLocation();
	targetDistance = VSize( targetDirection );
	projectileVelocity = targetDirection / targetDistance * weapon.projectileVelocity + weapon.rookMotor.getPhysicalAttachment().Velocity * weapon.projectileInheritedVelFactor;

	// projectile speed in the direction of the target
	// projectileSpeed = (projectileVelocity Dot targetDirection) / targetDistance; // not necessary since you are assuming the projecile will hit (and thus move towards) the target anyways

	// time to hit target if you fire at where target is now;
	// (of course this isn't exactly where you'll end up aiming so the time will be off by a bit -
	// solving this more accurately would require an iterative solution)
	return targetDistance / VSize( projectileVelocity );
}

defaultproperties
{
}
