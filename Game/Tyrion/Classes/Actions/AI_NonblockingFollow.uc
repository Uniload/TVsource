//=====================================================================
// AI_NonblockingFollow
// Unposts follow goal when close to target, thus freeing up movement
// resource
//=====================================================================

class AI_NonblockingFollow extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "An actor to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

var(InternalParameters) editconst Actor target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;

var Rook targetRook;
var ACT_Errorcodes errorCode;
var AI_Goal followGoal;
var float distanceSquared;
var float maxWaitingDist;
var bool bDoLOSCheck;		// follow until LOS of target has been achieved?

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from followGoal

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes anErrorCode ) 
{
	super.goalNotAchievedCB( goal, child, anErrorCode );

	// todo: should action terminate when interrupted? (probably not but it doesn't seem to be causing any problems)
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------
// how close do you want to get?

private final function float proximityFunction()
{
	if ( followFunction != None )
		return followFunction.proximityFunction();
	else
		return proximity;
}

//---------------------------------------------------------------------
// Return false if LOS check is required and target cannot be seen

private final function bool bLOSCheck()
{
	return !bDoLOSCheck || (rook().bUnobstructedLOF && rook().vision.isLocallyVisible( targetRook ));
}

//---------------------------------------------------------------------
// maximum distance from target before movement engages again

private final function float maxWaitingDistance()
{
	local float maxDistance;

	maxDistance = proximityFunction();
	maxDistance += FMin( maxDistance * (class'NS_Follow'.const.PROXIMITY_HYSTERESIS_FACTOR - 1.0f), class'NS_Follow'.const.PROXIMITY_HYSTERESIS_MAX );
	return maxDistance;
}

//---------------------------------------------------------------------
// return pertinent information about an action for debugging

function string actionDebuggingString()
{
	return String(name) @ target.label $ "," $ proximityFunction() $ "," $ maxWaitingDistance();
}

//---------------------------------------------------------------------
// need to follow?

private final function bool bNeedFollow()
{
	return distanceSquared > maxWaitingDist * maxWaitingDist || !bLOSCheck();
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( followGoal != None )
	{
		followGoal.Release();
		followGoal = None;
	}

	followFunction = None;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Engine.Pawn', targetName, true ));

	if ( pawn.logTyrion)
		log( name @ "started." @ resource.pawn().name @ "is following" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// enemy targets are followed until LOS is achieved
	targetRook = Rook(target);
	bDoLOSCheck = targetRook != None && !Rook(Pawn).isFriendly( targetRook );

	while ( errorCode == ACT_SUCCESS && 
			class'Pawn'.static.checkAlive( pawn ) && ( targetRook == None || class'Pawn'.static.checkAlive( targetRook ) ))
	{
		distanceSquared = VDistSquared( pawn.Location, target.Location );
		maxWaitingDist = maxWaitingDistance();

		//log( Sqrt( distanceSquared ) );
		// todo: worry about "validDestination" checks done in NS_Follow?
		if ( followGoal == None && bNeedFollow() )
			followGoal = (new class'AI_FollowGoal'( AI_MovementResource(pawn.movementAI),
							achievingGoal.priority,
							target, proximity, followFunction, positionIndex,
							energyUsage, terminalVelocity, terminalHeight ) ).postGoal( self ).myAddRef();

		if ( followGoal != None && !bNeedFollow() )
		{
			followGoal.unPostGoal( self );
			followGoal.Release();			// must be done here as well as cleanup because followGoal could be overwritten
			followGoal = None;
		}

		Sleep(1.0);
	}

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped with errorCode" @ errorCode );

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_NonblockingFollowGoal'
}