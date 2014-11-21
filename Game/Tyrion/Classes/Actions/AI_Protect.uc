//=====================================================================
// AI_Protect
// Shield the thing being protected from attacks
//=====================================================================

class AI_Protect extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

const PROTECT_DISTANCE = 1000.0f;	// ideal distance from protected object
const ADJUST_DISTANCE = 80.0f;		// how far from ideal before protect position is adjusted
const MAX_BURN_DIST = 5000.0f;		// how close to protectee does an enemy have to get before Protector burns the ground
const MIN_BURN_DIST = 750.0f;		// min dist enemy has to be from ai (to burn ground in front of them)
const MAX_BURN_YAW = 3640;			// 20 degrees left/right spread for the ground burning

//=====================================================================
// Variables

var(InternalParameters) float engagementAreaRadius "Radius of engagement area";
var(InternalParameters) float movementAreaRadius "Radius of movement area";
var(InternalParameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// (ignored)
var(InternalParameters) editconst IFollowFunction followFunction;

var() float maxChainGunRange "Maximum distance at which to use the chaingun";
var() float maxEnergyBladeRange "Maximum distance at which to use the energy blade";

var BaseAICharacter ai;				// the character this action is running on
var Pawn target;
var Pawn guardee;
var float protectDistance;			// ideal distance from protected object
var Vector protectPosition;
var Rotator burnRotation;
var Vector aimLocation;
var Vector hitLocation;
var float timeToHit;
var Vector projectileSpawnLocation;
var Actor obstacle;					// possible obstacle in my shot line
var AI_Goal fireAtGoal;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;															   

	//log( "bestWeapon:" @ VDist( ai.Location, target.Location ) );

	w = Weapon( ai.nextEquipment( None, class'Chaingun' ));
	if ( w != None && w.hasAmmo() && VDistSquared( ai.Location, target.Location ) <= maxChainGunRange * maxChainGunRange )
		return w;

	w = Weapon( ai.nextEquipment( None, class'EnergyBlade' ));
	if ( w != None && VDistSquared( ai.Location, target.Location ) <= maxEnergyBladeRange * maxEnergyBladeRange )
		return w;

	w = Weapon( ai.nextEquipment( None, class'Burner' ));
	if ( w != None && w.hasAmmo() )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon
// (not used in protect)

function float firingRange( class<Weapon> weaponClass )
{
	if ( ClassIsChildOf( weaponClass, class'EnergyBlade' ))
		return 0.8f * (class'EnergyBlade'.default.range + target.CollisionRadius);	// energy blade
	else
		return -1;
}

//---------------------------------------------------------------------
// are conditions met for firing this weapon?

function bool bShouldFire( BaseAICharacter ai, Weapon weapon )
{
	return true;
}

//---------------------------------------------------------------------
// get the position between the attacker and the target (BASE_NODE_GAP above the ground)
// returns pawn location if no suitable location is found

private final function Vector getProtectPosition()
{
	local Vector targetVector;

	targetVector = target.Location - engagementAreaTarget.Location;
	targetVector *= min( protectDistance, 0.5f * VSize( targetVector ) ) / VSize( targetVector );

	return AI_Controller(ai.controller).getRandomLocation( ai, engagementAreaTarget.Location + targetVector, 0, 0 );
}

//---------------------------------------------------------------------
// get a place to burn

private final function Rotator getBurnRotation()
{
	local Vector targetVector;
	local Rotator r;

	// 2/5 shots go directly towards the target; others build fire wall
	if ( FRand() >= 0.4f )
	{
		targetVector = target.Location - engagementAreaTarget.Location; 
		targetVector *= FMax( VDist( ai.Location, engagementAreaTarget.Location ) + MIN_BURN_DIST, VDist( engagementAreaTarget.Location, target.Location ) - 200.0f ) / VSize( targetVector );
		targetVector.z = AI_Controller(ai.Controller).getTerrainHeight(target.Location) - engagementAreaTarget.Location.Z;	// aim for the ground

		r = Rotator((engagementAreaTarget.Location + targetVector) - ai.motor.getProjectileSpawnLocation());

		r.Yaw = (r.Yaw + Rand( 2 * MAX_BURN_YAW ) - MAX_BURN_YAW) & 65535;
	}
	else
		r = Rotator(target.Location - ai.motor.getProjectileSpawnLocation());

	return r;
}

//---------------------------------------------------------------------
// find this AI's dodge sensor
// Note: This is a bit of a hack, since Protect is messing with a sensor
// in a sibling action. The proper "Tyrion way" would be to have a common
// parent action that does this but that's a little tricky to set up in this
// situation (I'll have to think about it).

private final function AI_DodgeSensor getDodgeSensor()
{
	return characterResource().commonSenseSensorAction.dodgeSensor;
}

//---------------------------------------------------------------------

private final function bool keepRunning()
{
	return class'Pawn'.static.checkAlive( target ) && class'Pawn'.static.checkAlive( ai ) &&
			( guardee == None || guardee.isAlive() );
}

//---------------------------------------------------------------------

private final function bool burnGround()
{
	return VSizeSquared2D( target.Location - engagementAreaTarget.Location ) <= MAX_BURN_DIST * MAX_BURN_DIST && 
			VDistSquared( target.Location, ai.location ) > MIN_BURN_DIST * MIN_BURN_DIST;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	// clear GuardSensor value so action can be activated again
	// (also important because GuardSensor doesn't terminate when LOS is lost - it relies on the action to do this)
	if ( achievingGoal.activationSentinel.sensor != None )
		achievingGoal.activationSentinel.sensor.setObjectValue( None );

	if ( fireAtGoal != None )
	{
		fireAtGoal.Release();
		fireAtGoal = None;
	}

	weaponSelection = None;
	followFunction = None;

	getDodgeSensor().setParameters( None );
}

//=====================================================================
// State code

state Running
{
Begin:
	assert( engagementAreaTarget != None );

	target = Pawn(achievingGoal.activationSentinel.sensor.queryObjectValue());
	guardee = Pawn(engagementAreaTarget); 
	AI_Guard(achievingGoal.parentAction).lastGuardTarget = target;
	getDodgeSensor().setParameters( Rook(engagementAreaTarget) );
	ai = baseAICharacter();

	if ( target == None )
	{
		log( "AI WARNING:" @ name $ ":" @ ai.name @ "has no guard target" );
	}
	else if ( ( guardee != None && !guardee.isAlive() ) ||
		VDistSquared( ai.Location, engagementAreaTarget.Location ) > VDistSquared( target.Location, engagementAreaTarget.Location ))
	{
		 WaitForGoal( (new class'AI_AttackGoal'( characterResource(), achievingGoal.priorityFn(), target, self,, followFunction )).postGoal( self ) );
	}
	else
	{
		useResources( class'AI_Resource'.const.RU_LEGS );	// so resource is occupied while AI turns

		if ( movementAreaRadius > 0 )
			protectDistance = min( 0.8f * movementAreaRadius, PROTECT_DISTANCE );

		if ( ai.logTyrion )
			log( name @ "started on" @ ai.name $ ". Protecting" @ engagementAreaTarget @ "against" @ target.name );

		// (it's important that FireAt fail when target is lost - otherwise the guard sensor won't select a new target)
		fireAtGoal = (new class'AI_FireAtGoal'( weaponResource(), achievingGoal.priorityFn()-1, target, self, preferredWeaponClass, true )).postGoal( self ).myAddRef();

		while ( keepRunning() && ai.vision.isLocallyVisible( target ) )
		{
			// Get between the thing being protected and the attacker
			protectPosition = getProtectPosition();

			if ( VDistSquared( protectPosition, ai.Location ) > ADJUST_DISTANCE * ADJUST_DISTANCE )
			{
				//log( "Moving..." );
				clearDummyMovementGoal();
				waitForGoal( (new class'AI_MoveToGoal'( movementResource(), achievingGoal.priorityFn(), protectPosition,,, ,,,, ADJUST_DISTANCE,, Rotator(target.Location - ai.Location) )).postGoal( self ), true );
				useResources( class'AI_Resource'.const.RU_LEGS );	// so resource is occupied while AI turns
			}

			if ( !keepRunning() )
				break;

			// Burn terrain in front of attacker (with the burninator)
			if ( burnGround() )
			{
				if ( fireAtGoal != None )
				{
					fireAtGoal.unPostGoal( self );
					fireAtGoal.Release();
					fireAtGoal = None;
				}

				if ( ai.weapon.fireRatePassed() )
				{
					//log( "Burninating!..." @ VDist( ai.Location, target.Location ) );
					burnRotation = getBurnRotation();

					//waitForAction( class'NS_Turn'.static.startAction( AI_Controller(ai.controller), self, burnRotation ));

					ai.motor.setWeapon( Weapon( ai.nextEquipment( None, class'Burner' )) );
					ai.motor.setViewRotation( burnRotation );

					projectileSpawnLocation = ai.motor.getProjectileSpawnLocation();
					aimLocation = VSize(target.Location - projectileSpawnLocation) * Vector(burnRotation) + projectileSpawnLocation;
					obstacle = ai.weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, ai.weapon, aimLocation );

					if ( !ai.weapon.aimClass.static.willHurt( ai.weapon, ai, hitLocation, timeToHit ) )
						ai.motor.fire(true);
				}
			}
			else if ( fireAtGoal == None )
			{
				// (it's important that FireAt fail when target is lost - otherwise the guard sensor won't select a new target)
				fireAtGoal = (new class'AI_FireAtGoal'( weaponResource(), achievingGoal.priorityFn()-1, target, self, preferredWeaponClass, true )).postGoal( self ).myAddRef();
			}

			yield();
		}
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") succeeded" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GuardAttackGoal'

	maxEnergyBladeRange		= 400
	maxChainGunRange		= 400
}