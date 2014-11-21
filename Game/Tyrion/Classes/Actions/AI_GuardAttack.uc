//=====================================================================
// AI_GuardAttack
// Engages any enemies within a specified area
// Doesn't require movement resource
//
// If guardAttack priority is higher than priority of the actions using
// the movement resource, Guard will use the characters regular attack.
// If not, guardAttack will just fire its weapon.
//=====================================================================

class AI_GuardAttack extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Variables

var(InternalParameters) float engagementAreaRadius "Radius of engagement area";
var(InternalParameters) float movementAreaRadius "Radius of movement area";
var(InternalParameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

var Pawn target;
var AI_Goal subGoal;
var int origPriority;		// original priority of GuardAttackGoal

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 0.9;		// lower than Protect if Protect applies
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	// clear GuardSensor value so action can be activated again
	// (also important because GuardSensor doesn't terminate when LOS is lost - it relies on the action to do this)
	if ( achievingGoal.activationSentinel.sensor != None )
		achievingGoal.activationSentinel.sensor.setObjectValue( None );

	weaponSelection = None;
	followFunction = None;

	if ( subGoal != None )
	{
		subGoal.Release();
		subGoal = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	target = Pawn(achievingGoal.activationSentinel.sensor.queryObjectValue());
	AI_Guard(achievingGoal.parentAction).lastGuardTarget = target;

	if ( target == None )
	{
		log( "AI WARNING:" @ name $ ":" @ pawn.name @ "has no guard target" );
	}
	else
	{
		if ( pawn.logTyrion )
			log( name @ "started on" @ pawn.name $ ". Attacking" @ target.name );

		do
		{
			if ( subGoal != None )
			{
				subGoal.unPostGoal( self );
				subGoal.Release();
				subGoal = None;
			}

			origPriority = achievingGoal.priorityFn();

			subGoal = (new class'AI_AttackGoal'( characterResource(), achievingGoal.priorityFn(), target,,, followFunction )).postGoal( self ).myAddRef();

			// if priority changes, repost goals
			while ( class'Pawn'.static.checkAlive( pawn ) && class'Pawn'.static.checkAlive( target ) &&
					!subGoal.hasCompleted() && achievingGoal.priorityFn() == origPriority )
			{
				Sleep( 1.0f );
			}

		} until ( class'Pawn'.static.checkDead( pawn ) || class'Pawn'.static.checkDead( target ) || subGoal.hasCompleted() )
	}

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") succeeded" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GuardAttackGoal'
}