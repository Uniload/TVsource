//=====================================================================
// AI_SquadAttack
// Has a squad attacks another squad
// High level attack - moves to a target and engages it
//=====================================================================

class AI_SquadAttack extends AI_SquadAction
	editinlinenew;

//=====================================================================
// Constants

const DEFAULT_PROXIMITY = 1000;	// how close to get to target (by default)

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target pawn or squad";

var(InternalParameters) editconst SquadInfo targetSquad;
var(InternalParameters) editconst Pawn target;

var int i;
var Actor targetActor;
var Pawn attacker;
var bool bAttackGoalPosted;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// child action callbacks

function goalAchievedCB( AI_Goal goal, AI_Action child ) 
{
	super.goalAchievedCB( goal, child );

	// assign new target
	if ( assignNewTarget( goal.resource.pawn() ) == None )
		runAction();			// no targets left -> action continues running
}

//---------------------------------------------------------------------
// child action callbacks

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	super.goalNotAchievedCB( goal, child, errorCode );

	//log( name $ ":" @ goal.name @ "not achieved" @ "with errorcode" @ errorcode );

	if ( errorCode == ACT_ALL_RESOURCES_DIED || errorCode == ACT_RESOURCE_INACTIVE )
	{
		if ( !resource.isActive() )
			instantFail( ACT_RESOURCE_INACTIVE );
	}
	else
	{
		if ( assignNewTarget( goal.resource.pawn() ) == None )
			runAction();			// no targets left -> action continues running

		goal.unPostGoal( self );				// unpost old goal (deletes goal!)
	}
}

//---------------------------------------------------------------------
// finds a new target and posts an attack goal
// returns the target found

private function Pawn assignNewTarget( Pawn attacker )
{
	local Pawn target;

	target = bestTarget( attacker );

	if ( target != None )
		(new class'AI_AttackGoal'( AI_Resource(attacker.characterAI), achievingGoal.priority, target )).postGoal( self );

	return target;
}

//---------------------------------------------------------------------
// finds best target in targetSquad
// return None if all target pawns are dead

private function Pawn bestTarget( Pawn attacker )
{
	local int i, j;
	local Pawn enemy;
	local Pawn closestEnemy;				// closest living enemy
	local AI_AttackGoal goal;
	local bool bEnemyBeingAttacked;
	local array<Pawn> sortedTargets;		// targets sorted by distance
	local array<float> distancesSquared;

	if ( target != None || targetSquad == None )
		return target;						// attacking a single target

	// sort targets by distance (stupid n-squared insertion sort)
	for ( i = 0; i < targetSquad.pawns.length; i++ )
	{
		enemy = targetSquad.pawns[i];
		if ( enemy == None )
			distancesSquared[i] = 99999999999999.9f;
		else
			distancesSquared[i] = VDistSquared( enemy.Location, attacker.Location );

		// maintain sorted list of distances
		for( j = 0; j < i; ++j )
		{
			if ( distancesSquared[j] < distancesSquared[i] )
				break;
		}
		sortedTargets.insert(j, 1);
		sortedTargets[j] = enemy;
	}

	// find enemy member that isn't being attacked and is visible
	for ( i = 0; i < sortedTargets.length; i++ )
	{
		enemy = targetSquad.pawns[i];

		if ( class'Pawn'.static.checkAlive( enemy ) && Rook(attacker).vision.isVisible( enemy ) )
		{
			for ( j = 0; j < resource.goals.length; j++ )
			{
				goal = AI_AttackGoal(resource.goals[j]);
				if ( goal != None && goal.target == enemy )
				{
					bEnemyBeingAttacked = true;
					break;
				}
			}
			
			if ( !bEnemyBeingAttacked )
				return enemy;

			if ( closestEnemy == None )
				closestEnemy = enemy;
		}
	}

	// all enemies being attacked - just return closest one (or None)
	return closestEnemy;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetSquad == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "(" @ squad().name @ ") has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetSquad == None )
	{
		targetActor = squad().findStaticByLabel( class'Actor', targetName, true );
		targetSquad = SquadInfo(targetActor);
		target = Pawn(targetActor);
	}

	if ( squad().logTyrion )
		if ( target != None )
			log( name @ "started." @ squad().name @ "is attacking" @ target.name );
		else
			log( name @ "started." @ squad().name @ "is attacking" @ targetSquad.name );

	if ( target == None && targetSquad == None )
	{
		log( "AI WARNING:" @ name @ "(" @ squad().name @ ") can't find specified target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// find targets for all squad members
	for ( i = 0; i < squad().pawns.length; i++ )
	{
		attacker = squad().pawns[i];
		if ( class'Pawn'.static.checkAlive( attacker ) && assignNewTarget( attacker ) != None )
			bAttackGoalPosted = true;
	}

	// pauses until all targets have died (all attackers dying handled in callback)
	if ( bAttackGoalPosted )
		pause();		// at least one AttackGoal posted

	if ( squad().logTyrion )
	{
		if ( !targetSquad.squadAI.isActive() )
			log( name @ "(" @ squad().name @ ")succeeded!" );
		else
			log( name @ "(" @ squad().name @ ")failed." );
	}

	if ( !targetSquad.squadAI.isActive() )
		succeed();
	else
	{
		// (Tyrion won't rematch this goal since it doesn't use leaf resources - but it should try again if it fails)
		resource.bMatchGoals = true;
		fail( ACT_GENERAL_FAILURE );
	}
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_SquadAttackGoal'
}