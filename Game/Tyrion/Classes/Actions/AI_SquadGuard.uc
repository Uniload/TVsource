//=====================================================================
// AI_SquadGuard
//
// Just a convenience action to set up guards on the members
//=====================================================================

class AI_SquadGuard extends AI_SquadAction
	editinlinenew;

//=====================================================================
// Constants

const MAX_SQUAD_SIZE = 9;			// maximum number of pawns in a squad

//=====================================================================
// Variables

var(Parameters) Name engagementAreaCenterName "Label of the Actor that defines the center of the area to be guarded - any enemy within this area will be attacked; an empty label is taken to mean the AI itself";
var(Parameters) float engagementAreaRadius "Radius of engagement area";
var(Parameters) Name movementAreaCenterName "Label of the Actor that defines the center of the area the AI can move around in to defend; an empty label is taken to mean the AI's spawn location";
var(Parameters) float movementAreaRadius "Radius of movement area (0 is taken to mean infinite/no restrictions)";
var(Parameters) bool removeDefaultGuardGoals "Remove squad members' default guard goals?";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;

var int i;
var Pawn pawn;
var AI_Goal goal;
var AI_Goal guardGoals[MAX_SQUAD_SIZE];		// member's guard goals
var Actor a;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Inform an action that a particular pawn died

function pawnDied( Pawn member ) 
{
	if ( squad().logTyrion )
		log( name $ ": (" @ squad().name @ ")" @ member.name @ "died!" );

	assert( member != None );

	if ( !squad().squadAI.isActive() )
	{
		if ( squad().logTyrion )
			log( name @ "stopped." );
		instantFail( ACT_ALL_RESOURCES_DIED );
	}
}

//---------------------------------------------------------------------

function cleanup()
{
	local int i;

	super.cleanup();

	// stop all the followers
	for ( i = 0; i < squad().pawns.length; i++ )
	{
		if ( guardGoals[i] != None )
		{
			guardGoals[i].Release();
			guardGoals[i] = None;
		}
	}
}
//=====================================================================
// State code

state Running
{
Begin:
	// Gotta do assignments involving Names here since names are not passed down to Guard...
	if ( engagementAreaCenter == default.engagementAreaCenter && engagementAreaCenterName == '' && engagementAreaTarget == None )
	{
		engagementAreaCenter = class'AI_GuardGoal'.default.engagementAreaCenter;
		//log( name @ "resetting engagementAreaCenter to" @ engagementAreaCenter );
	}

	if ( engagementAreaCenterName != '' )
	{
		a = squad().findStaticByLabel( class'Actor', engagementAreaCenterName, true );
		if ( a == None )
		{
			log( "AI ERROR:" @ name @ engagementAreaCenterName @ "not found!" );
			fail( ACT_INVALID_PARAMETERS, true );
		}
		engagementAreaTarget = a;
		engagementAreaCenter = a.Location;
	}

	if ( movementAreaCenter == default.movementAreaCenter && movementAreaCenterName == '' && movementAreaTarget == None )
	{
		movementAreaCenter = class'AI_GuardGoal'.default.movementAreaCenter;
		//log( name @ "resetting engagementAreaCenter to" @ movementAreaCenter );
	}

	if ( movementAreaCenterName != '' )
	{
		a = squad().findStaticByLabel( class'Actor', movementAreaCenterName, true );
		if ( a == None )
		{
			log( "AI ERROR:" @ name @ movementAreaCenterName @ "not found!" );
			fail( ACT_INVALID_PARAMETERS, true );
		}
		movementAreaTarget = a;
		movementAreaCenter = a.Location;
	}

	if ( squad().logTyrion )
		log( name @ "started." );

	for ( i = 0; i < squad().pawns.length; ++i )
	{
		pawn = squad().pawns[i];

		if ( class'Pawn'.static.checkAlive( pawn ) )
		{
			// Remove default guard goal if it exists
			if ( removeDefaultGuardGoals )
			{
				goal = class'AI_Goal'.static.findGoalByName( pawn, "DefaultGuardGoal" );
				if ( goal != None )
				{
					if ( squad().logTyrion )
						log( name $ ": Removing 'DefaultGuardGoal' from" @ pawn.name );
					goal.unPostGoal( None );
				}
			}
			guardGoals[i] = (new class'AI_GuardGoal'( AI_CharacterResource(pawn.characterAI), achievingGoal.priority,
										engagementAreaCenter, engagementAreaTarget, engagementAreaRadius,
										movementAreaCenter, movementAreaTarget, movementAreaRadius,	).postGoal( self )).myAddRef();
		}
		else
			guardGoals[i] = None;
	}

	pause();
	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_SquadGuardGoal'
}