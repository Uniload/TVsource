//=====================================================================
// AI_Guard
// Engages any enemies within a specified area
// Doesn't require movement resource
//
// This is the manager action for GuardAttack
//
// What happens if multiple guard actions are posted on the same AI?
// Should work - if there are conflicts the one with the higher priority should prevail
//=====================================================================

class AI_Guard extends AI_CharacterAction implements IFollowFunction
	editinlinenew;

//=====================================================================
// Constants

const GUARDMOVEMENT_PRIORITY = 29;
const DEFAULT_GUARD_DISTANCE = 1500.0f;		// default distance to follow guarded target

//=====================================================================
// Variables

var(Parameters) Name engagementAreaCenterName "Label of the Actor that defines the center of the area to be guarded - any enemy within this area will be attacked; On Protectors this denotes the thing to be protected; an empty label is taken to mean the AI itself";
var(Parameters) float engagementAreaRadius "Radius of engagement area";
var(Parameters) Name movementAreaCenterName "Label of the Actor that defines the center of the area the AI can move around in to defend; an empty label is taken to mean the AI's spawn location";
var(Parameters) float movementAreaRadius "Radius of movement area (0 is taken to mean infinite/no restrictions)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;

var Rook movementAreaTargetRook;
var Pawn lastGuardTarget;
var float guardDistance;
var Actor a;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// IFollowFunction interface: should offset be updated?

function bool updateOffset( Pawn follower, Pawn leader, int positionIndex )
{
	return false;
}

//---------------------------------------------------------------------
// IFollowFunction interface: offset from leader pawn to actual location follower wants to go to

function Vector offset( Pawn leader, int positionIndex )
{
	return vect(0,0,0);
}

//---------------------------------------------------------------------
// IFollowFunction interface: is a given location a valid place to follow to?

function bool validDestination( Vector point )
{
	return movementAreaRadius == 0 || movementAreaTarget == pawn ||
			// if movement target isn't friendly you can always move
			(movementAreaTargetRook != None && !movementAreaTargetRook.isFriendly(Rook(pawn))) || 
			VSizeSquared2D( point - getMovementAreaCenter() ) <= movementAreaRadius * movementAreaRadius; 
}

//---------------------------------------------------------------------
// IFollowFunction interface: how close do you want to get to the target?
// (gets overridden by attack function)

function float proximityFunction()
{
	return class'AI_DirectAttack'.const.DEFAULT_PROXIMITY;
}

//---------------------------------------------------------------------
// get the center Location of the engagement area
// (not used)

function Vector getEngagementAreaCenter()
{
	if ( engagementAreaTarget == None )
		return engagementAreaCenter;
	else
		return engagementAreaTarget.Location;
}

//---------------------------------------------------------------------
// get the center Location of the movement area

function Vector getMovementAreaCenter()
{
	if ( movementAreaTarget == None )
		return movementAreaCenter;
	else
		return movementAreaTarget.Location;
}

//---------------------------------------------------------------------
// return pertinent information about an action for debugging

function string actionDebuggingString()
{
	return String(name) @ "eng:" $ getEngagementString() $ "," $ engagementAreaRadius @ "mov:" $ getMovementString() $ "," $ movementAreaRadius;
}

final function string getEngagementString()
{
	if ( engagementAreaTarget != None )
		return String(engagementAreaTarget.label);
	else if ( engagementAreaCenterName != '' )
		return String(engagementAreaCenterName);
	else
		return "static";
}

final function string getMovementString()
{
	if ( movementAreaTarget != None )
		return String(movementAreaTarget.label);
	else if ( movementAreaCenterName != '' )
		return String(movementAreaCenterName);
	else
		return "static";
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	weaponSelection = None;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( engagementAreaCenter == default.engagementAreaCenter && engagementAreaCenterName == '' && engagementAreaTarget == None )
	{
		engagementAreaTarget = pawn;
		engagementAreaCenter = pawn.Location;
		//log( name @ "resetting engagementAreaCenter to" @ engagementAreaCenter );
	}

	if ( engagementAreaCenterName != '' )
	{
		do
		{
			a = pawn.findStaticByLabel( class'Actor', engagementAreaCenterName, true );
			if ( a == None )
			{
				if ( engagementAreaCenterName != 'Player' )
				{
					log( "AI ERROR:" @ name $ ":" @ engagementAreaCenterName @ "not found!" );
					fail( ACT_INVALID_PARAMETERS, true );
				}
				else
					Sleep(1.0f);	// if Player can't be found: try again in a little bit
			}
		} until ( a != None );

		engagementAreaTarget = a;
		engagementAreaCenter = a.Location;
	}

	if ( movementAreaCenter == default.movementAreaCenter && movementAreaCenterName == '' && movementAreaTarget == None )
	{
		movementAreaCenter = pawn.Location;
		//log( name @ "resetting engagementAreaCenter to" @ movementAreaCenter );
	}

	if ( movementAreaCenterName != '' )
	{
		do
		{
			a = pawn.findStaticByLabel( class'Actor', movementAreaCenterName, true );
			if ( a == None )
			{
				if ( movementAreaCenterName != 'Player' )
				{
					log( "AI ERROR:" @ name $ ":" @ movementAreaCenterName @ "not found!" );
					fail( ACT_INVALID_PARAMETERS, true );
				}
				else
					Sleep(1.0f);	// if Player can't be found: try again in a little bit
			}
		} until ( a != None );

		movementAreaTarget = a;
		movementAreaTargetRook = Rook(a);
		movementAreaCenter = a.Location;
	}

	//movementAreaRadius == 0  =>  ignore movement restrictions

	if ( pawn.logTyrion )
		log( name @ "started on" @ pawn.name @ 
			"( movement:" @ getMovementString() $ ", engagement:" @ getEngagementString() @ ")" );

	(new class'AI_GuardAttackGoal'( characterResource(), achievingGoal.priority, 
									engagementAreaCenter, engagementAreaTarget, engagementAreaRadius,
									movementAreaCenter, movementAreaTarget, movementAreaRadius,						  
									weaponSelection, preferredWeaponClass, self )).postGoal( self );

	// Problem: FollowGoal posted below never stops, so even if no enemies are present and the target is stationary,
	//          lower priority goals won't get a chance to run
	// Idea:    Revamp guardMovement to handle following, and to stop following if within movement area and target
	//          isn't moving
	// Idea2:   A more general way to go would be to have follow be triggered off a sensor and free its resources
	//          when within proximity of the target (would have to make all parents of follow can deal with
	//          Follow only being achieved part of the time)

	// Separate issue: Even if they can't shoot, AI's should face their opponent and move to an appropriate
	//          place in their movement area (guardAttack doesn't do this)
	// Idea:    post "if you see a suspicious enemy but can't attack it keep turned to it" goal ?

	if ( movementAreaTarget == None )
	{
		// stationary movement area
		// return to movement area center when no enemies present
		(new class'AI_GuardMovementGoal'( movementResource(), Min(GUARDMOVEMENT_PRIORITY, achievingGoal.priority-1), movementAreaCenter )).postGoal( self );
	}
	else if ( movementAreaTarget != pawn )
	{
		if ( pawn.logTyrion )
			log( name @ "(" @ pawn.name @ ") movementAreaTarget" @ movementAreaTarget.name );

		// moving movement area
		if ( movementAreaRadius == 0 )
			guardDistance = DEFAULT_GUARD_DISTANCE;
		else
			guardDistance = FMin( DEFAULT_GUARD_DISTANCE, 0.75f * movementAreaRadius );

		(new class'AI_NonblockingFollowGoal'( resource,
									achievingGoal.priority-1, movementAreaTarget, guardDistance )).postGoal( self );
		//(new class'AI_FollowGoal'( AI_MovementResource(pawn.movementAI),
		//							achievingGoal.priority-1, movementAreaTarget, guardDistance )).postGoal( self );
	}

	pause();
	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GuardGoal'
}