//=====================================================================
// AI_BucklerDeflect
// If a buckler is equipped, tries to deflect incoming projectiles
//=====================================================================

class AI_BucklerDeflect extends AI_WeaponAction
	editinlinenew;

//=====================================================================
// Variables

var BaseAICharacter ai;
var float endTime;
var float timeToHit;
var Rotator aimRotation;
var Pawn shooter;			// who fired the projectile I want to deflect

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	local Weapon w;

	w = Weapon(Character(goal.resource.pawn()).nextEquipment( None, class'Buckler' ));

	// don't run action if no buckler equipped or buckler is flying (test could be moved to a sensor for efficiency)
	if ( w != None && w.hasAmmo() )
		return 1.0;
	else
		return 0.0;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( resource.pawn().controller != None )
		AI_Controller(resource.pawn().controller).bAiming = true;
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( ai.logTyrion )
		log( name @ "started on" @ ai.name );

	// look towards enemy (unnecessary if a general "stay faced towards enemy" goal is ever added to AI's)
	if ( ai.controller != None )
		AI_Controller(ai.controller).bAiming = true;

	shooter = Pawn(characterResource().commonSenseSensorAction.dodgeSensor.queryObjectValue());

	timeToHit = 1.0f;	// todo: use actual "tomeToHit" (DodgeSensor would have to make this value available)
	endTime = ai.level.timeSeconds + timeToHit;

	while ( ai.level.timeSeconds < endTime )
	{
		aimRotation = Rotator(shooter.Location - ai.Location);
		ai.motor.setAIMoveRotation( aimRotation );
		ai.motor.setViewRotation( aimRotation );	// target needs to kept in view
		Sleep( 0.1f );	
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") stopped" );

	succeed();	// pawn death check handled inside "waitForAction" 
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_BucklerDeflectGoal'
}