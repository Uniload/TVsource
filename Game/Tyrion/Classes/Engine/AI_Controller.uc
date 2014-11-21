//=====================================================================
// AI_Controller
// Dummy controller class to make Unreal happy
// - used to replicate data
// - stores frag statistics etc
// - contains interface to movement physics system
// - used as parameter to hearing related functions
//=====================================================================

class AI_Controller extends Engine.Controller
	native
	dependsOn(ActionBase);

import enum AlertnessLevels from Rook;
import enum ACT_ErrorCodes from ActionBase;

//=====================================================================
// Constants

// MUST BE MANUALLY KEPT IN SYNC WITH FUNCTION NUMBERS IN NATIVE CODE
const DO_LOCAL_MOVE_NUMBER = 2200;

// debug stuff
const DEBUGAI_X = 20;					// where debugai info will display on screen
const DEBUGAI_Y = 100;

struct native TerrainSample
{
	var Vector location;
	var Vector normal;
	var Vector velocity;
	var bool bTerrain;					// terrain hit or something else?
	var bool bDownSlope;
	var bool bBeforeSkiRouteStart;
};

// doLocalMove return codes
enum DLM_ReturnCodes
{
	DLM_SUCCESS,
	DLM_CANT_FIND_PATH,
	DLM_IRREVERSIBLY_OFF_COURSE,
	DLM_TIME_LIMIT_EXCEEDED,
	DLM_INSUFFICIENT_ENERGY,
	DLM_DESTINATION_ENCROACHED,
	DLM_ALL_RESOURCES_DIED
};

// doZeroGravityLocalMove return codes
enum DZGLM_ReturnCodes
{
	DZGLM_SUCCESS
};

// vehicle doLocalMove return codes
enum VDLM_ReturnCodes
{
	VDLM_SUCCESS,
	VDLM_TIMED_OUT
};

// local obstacle avoidance initial avoid directions
enum LOA_AvoidDirections
{
	LOA_DONTCARE,
	LOA_LEFT,
	LOA_RIGHT,
	LOA_UP
};

// doLocalMove movement mode
enum DLM_MovementMode
{
	DLMMM_WALKING,
	DLMMM_JETPACKING,
	DLMMM_SKIING
};

// Navigation System parameters
const DONT_CARE = -99999.0;

// times spent in various alertness states
const ALERTNESS_ALERT_TIME = 20.0f;		// approx time in seconds AI stays in ALERTNESS_Alert
const ALERTNESS_COMBAT_TIME = 10.0f;	// approx time in seconds AI stays in ALERTNESS_Combat

const MAX_TICKS_TO_PROCESS_PAIN = 5;	// upper bound on the number of AI ticks it will take to react to pain

//=====================================================================
// Variables

// used by the do local move latent function
var NS_DoLocalMove dlm;						// None if no doLocalMove is running
var vector localMoveOrigin;
var vector localMoveDirection;
var float localMoveTimeLimitSeconds;
var float localMoveStartTimeSeconds;
var float localMoveDistance;
var float localMoveNextDistance;
var vector localMoveNextDirection;
var vector localMoveNextDirectionXY;
var float localMoveNextDistanceXY;
var vector localSmoothMoveDestination;
var bool localSmoothMoveDestinationValid;
var float previousSmoothingFactor;
var DLM_ReturnCodes dlmReturnValue;			// return value of doLocalMove
var DLM_MovementMode dlmMovementMode;
var VDLM_ReturnCodes vehicleDoLocalMoveResult;

// used by local obstacle avoidance
var const Actor actorHit;				// last Actor hit
var const Actor followedActor;			// Actor being followed around
var const float avoidDistance;			// distance to goal when loa started
var const Vector avoidDirection;		// direction to start looking in when going around an obstacle
var const Actor lastActorHit;			// Actor hit last time something was hit
var const Vector lastActorLocation;		// location of actor the last time it was hit
var const LOA_AvoidDirections dirSwitch;// stores whether to avoid by going right or going left
var const int ticksElapsedWithNoProgress;// how long has LOA been on?
var const bool bAvoiding;				// am I currently doing lookAhead obstacle avoidance
var bool bNoLOA;						// ddon't do any local obstacle avoidance

// used by smoothing
var bool disableSmoothing;
var bool smoothingStarted;

// used by weapon system
var bool bAiming;						// when true, point weapon towards viewdirection

// used by the Dodge action
var float dodgeExpirationTime;			// the level time at which the displacement values expire
var float dodgeStartTime;				// the level time after which dodging should start
var Vector dodgeDisplacement;			// total displacement needed to dodge, reduced as pawn moves
var const Vector LastLocation;			// location of rook at last tick

// used by native vehicle navigation code
var CarDoLocalMove carLocalMoveAction;
var AircraftDoLocalMove aircraftLocalMoveAction;
var bool aircraftAttacking;
var float moveStartTime;
var float maximumDuration;
var int vehicleNavigationFunctionIndex;
var float currentSpeed;

// used by zero gravity local move
var NS_DoZeroGravityLocalMove zeroGravityMoveAction;
var vector elevatorCentreXY;
var DZGLM_ReturnCodes zeroGravityMoveResult;

// other actions
var bool bPatrolling;					// AI is patrolling (means it will never stop moving)

// for jetpacking/skiing
var bool bJetSkiManager;				// is JetSkiManager running?
var bool bSkiTo;						// is SkiTo running?
var bool bJetpacking;					// is jetpacking control code in DoLocalMove running?
var bool bTerminate;					// terminate the doLocalMove
var bool bShouldJetpack;				// when true, AI has a prefernce for jetpacking to next node
var array<TerrainSample> terrainSamples;
var array<TerrainSample> terrainSamplesDebug;	// for debug only

// Navigation System Variables:
var array<NS_Action> idleActions;		// idle navigation system actions
var array<NS_Action> runningActions;	// running navigation system actions
var array<NS_Action> removedActions;	// actions waiting to be deleted
var ACT_ErrorCodes lastErrorCode;		// debug only: last non-zero nav system error code

// nav system tick control
var Range tickTimeUpdateRange;			// min and max time that will be used to make a random tickTime

//=====================================================================
// Functions

//---------------------------------------------------------------------
// only used for debug

function Tick( float delta )
{
	local Rotator r;
	local Character character;
	local Vector direction;

	super.Tick( delta );

	character = Character(pawn);

	if ( character != None && character.bShowNavigationDebug )
		displayNavigationDebug();

	if ( false && character != None && character.bShowJSDebug && IsZero(character.Velocity) )
	{
		r = character.motor.getViewRotation();
		r.Yaw += 20;
		character.motor.setViewRotation( r );
		character.motor.setAIMoveRotation( r );
		direction = Vector(r);
		direction *= 5000 / VSize(direction);

		findLandingSpot( character.Location + direction, 100, JC_LevelExpert, 1 );
	}

	if (Pawn != None && Pawn.logNavigationSystem)
	{
		drawRouteCache();
	}

	if ( character != None && character.bShowJSDebug )
		drawJettingSkiingDebug();

	if ( character != None && character.bShowLOADebug )
		drawLOADebug();
}

//---------------------------------------------------------------------

function PawnDied(Pawn p)
{
	log( p.name @ "in" @ name @ "DIED! (" $ p.level.TimeSeconds $ ")" );

	stopActions();

	Super.PawnDied(p);
	RemoveController();
}

//---------------------------------------------------------------------
// stop all controller actions

function stopActions()
{
	while ( idleActions.length > 0 )
	{
		//log( "=>" @ name @ "removing" @ runningActions[0].name ); 
		idleActions[0].instantFail( ACT_RESOURCE_INACTIVE );	// modifies idleActions.length
	}
	while ( runningActions.length > 0 )
	{
		//log( "=>" @ name @ "removing" @ runningActions[0].name );
		runningActions[0].instantFail( ACT_RESOURCE_INACTIVE );	// modifies runningActions.length
	}
}

//---------------------------------------------------------------------
// Delete actions that have been removed from idle and running lists

event deleteRemovedActions()
{
	local int i;
	local int count;

	for ( i = 0; i < removedActions.length; i++ )
	{
		count = removedActions[i].Release();	// Comment out this line to disable Nav system action deletion
		if ( count != 0 )
		{
			removedActions[i].NullReferences();
			//log( "deleteRemovedActions: deleting" @ removedActions[i].name @ count );
		}
	}
	removedActions.length = 0;
}

//---------------------------------------------------------------------
// AI Controller no longer possesses a pawn so stop actions

function UnPossess()
{
	stopActions();

	super.UnPossess();
}

//---------------------------------------------------------------------
// put AI into an alertness state

function setAlertnessLevel( AlertnessLevels newLevel, optional bool bDontHandleSquadMembers )
{
	local int i;
	local Character character;
	local Pawn member;
	local AlertnessLevels currentLevel;

	character = Character(Pawn);

	if ( character != None )
	{
		currentLevel = character.getAlertnessLevel();

		if ( character.logAlertnessChanges )
				log( character.name @ "(" $ character.label $ "):" @ currentLevel @ "->" @ newLevel );

		if ( newLevel > currentLevel )	// new level more "severe" than old
		{
			character.setAlertnessLevel( newLevel );
			if ( newLevel == ALERTNESS_Alert )
			{
				// handle squads: when a member is alerted they all are
				if ( !bDontHandleSquadMembers && character.squad() != None )
				{
					for ( i = 0; i < character.squad().pawns.length; ++i )
					{
						member = character.squad().pawns[i];
						if ( member != character && class'Pawn'.static.checkAlive( member ) && member.controller != None )
							AI_Controller(member.controller).setAlertnessLevel( newLevel, true );
					}
				}

				// invoke nail-biting tension!
				if ( Pawn.level.MusicMgr != None ) 
					Pawn.level.MusicMgr.TriggerDynamicMusic( MT_Tension );
			}
		}

		// reset timer based on level
		if ( newLevel == ALERTNESS_Alert ) 
			SetTimer( ALERTNESS_ALERT_TIME, false );
		else if ( newLevel == ALERTNESS_Combat )
			SetTimer( ALERTNESS_COMBAT_TIME, false );
	}
}

//---------------------------------------------------------------------

function Timer()
{
	local Character character;
	local AlertnessLevels currentLevel;

	character = Character(Pawn);

    if ( character != None )
	{
		currentLevel = character.getAlertnessLevel();

		if ( currentLevel == ALERTNESS_Alert )
			character.setAlertnessLevel( ALERTNESS_Neutral );

		if ( currentLevel == ALERTNESS_Combat )
		{
			character.setAlertnessLevel( ALERTNESS_Alert );
			SetTimer( ALERTNESS_ALERT_TIME, false );
		}

		if ( character.logAlertnessChanges )
			log( character.name @ "(" $ character.label $ "): decaying to state" @ character.getAlertnessLevel() );
	}
}

//---------------------------------------------------------------------
// Called when a pawn takes damage

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local BaseAICharacter ai;

	super.NotifyTakeHit( InstigatedBy, HitLocation, Damage, damageType, Momentum );

	if ( pawn.characterAI != None )
	{
		ai = BaseAICharacter(pawn);

		// commonSenseSensorAction won't be initialized if the resource hasn't been initialized yet
		// (but this should never happen because Rook resources are set up on first rook tick)
		if ( AI_CharacterResource(pawn.characterAI).commonSenseSensorAction == None )
		{
			log( "AI WARNING: NotifyHit called on" @ pawn.name @ "by" @ InstigatedBy.name @ "before sensors were initialized!" );
			return;
		}

		// when an AI gets hurt, activate it for it a bit so it can react regardless of it's LOD state
		ai.setLimitedTimeLODActivation( MAX_TICKS_TO_PROCESS_PAIN );

		if ( !ai.isFriendly( Rook(InstigatedBy) ) )
		{
			// pain reaction
			if ( ai.painReactionCategory == PR_FLINCH )
			{
				ai.noAttackUntil = level.timeSeconds + class'BaseAICharacter'.const.PAIN_REACTION_FLINCH_TIME;
			}
			else if ( ai.painReactionCategory == PR_FREEZE )
			{
				ai.noAttackUntil = level.timeSeconds + class'BaseAICharacter'.const.PAIN_REACTION_FREEZE_TIME;
				ai.noMovementUntil = level.timeSeconds + class'BaseAICharacter'.const.PAIN_REACTION_FREEZE_TIME;
			}
		}

		// notify pain sensor
		AI_CharacterResource(pawn.characterAI).commonSenseSensorAction.painSensor.setValue( damage, InstigatedBy, hitLocation, damageType, pawn.lastTick );
	}

	//log( pawn.name @ "hurt by" @ InstigatedBy.name @ ".Damage:" @ damage );
}

//---------------------------------------------------------------------
// Was rook just hit by a weapon?

function bool wasJustHit()
{
	local AI_PainSensor painSensor;

	if ( pawn.characterAI != None )
	{
		painSensor = AI_CharacterResource(pawn.characterAI).commonSenseSensorAction.painSensor;
		return painSensor.tickStamp >= pawn.lastTick - 2;	// pawn took damage less than two ticks ago
	}
	else
		return false;
}

//---------------------------------------------------------------------
// Move the controlled AI to the specified location. See NS_DoLocalMove.uc
// for a more detailed explanation.

native final latent function doLocalMove( NS_DoLocalMove dlm );

native final latent function doZeroGravityLocalMove(NS_DoZeroGravityLocalMove action);

//---------------------------------------------------------------------
// Vehicle specifc versions of above function.

native final latent function CarDoLocalMove(CarDoLocalMove action);
native final latent function AircraftDoLocalMove(AircraftDoLocalMove action);

//---------------------------------------------------------------------

native final function Actor jetLookAhead( Vector loc1, Vector loc2 );

//---------------------------------------------------------------------

native final function Vector findLandingSpot( Vector destination, float energy, Character.JetCompetencyLevels jetCompetency, int nSamples );

//---------------------------------------------------------------------

native final function bool bSuitableTerrainForSkiing( Vector destination, float energy );

//---------------------------------------------------------------------

native final function generateReverseSkiRoute( Character character, Vector endPoint, Vector endVelocity );

//---------------------------------------------------------------------

native final function logSkiRoute();

//---------------------------------------------------------------------

native final event copyTerrainProfileDebug();

//---------------------------------------------------------------------

native function bool canPointBeReached( Vector startPoint, Vector endPoint, Pawn pawn, array<Actor> ignore,
								optional out vector lastValidLocation, optional out float traversedDistanceXY );

//---------------------------------------------------------------------

native function bool canPointBeReachedUsingAircraft( Vector startPoint, Vector endPoint, Pawn aircraft );

//---------------------------------------------------------------------
// cautious estimate of whether point can be reached using jetpacking (based on distance)

native function bool canPointBeReachedUsingJetpack( Vector startPoint, Vector endPoint, Pawn pawn );

//---------------------------------------------------------------------
// cautious estimate of whether point can be reached using jetpacking (based on energy)
// returns energy required or -1 if point not reachable

native function float canJetToPoint( Character c, Vector startLoc, Vector endLoc, float energy );

//---------------------------------------------------------------------
// Does "point" offer cover from "enemy"?

native function bool offersCover( Pawn enemy, Vector point );

//---------------------------------------------------------------------
// can an AI occupy a point?

native function bool isPointEncroachedForMovement( Pawn pawn, Vector point );

//---------------------------------------------------------------------

native final function Vector getRandomLocation( Pawn pawn, Vector center, float outerRadius, float innerRadius, optional bool bJetpack );

//---------------------------------------------------------------------

native final function float speedInDirection( Vector velocity, Vector direction );

//---------------------------------------------------------------------
// raytraces down from given point, returns Z coord of hit

native final function float getTerrainHeight( Vector point );

//---------------------------------------------------------------------

native final function stopMove();

//---------------------------------------------------------------------
// returns locations of all path nodes within a particular range

native final function getNodesWithinSphere(vector origin, float radius, out array<vector> nodes);

//---------------------------------------------------------------------
// Displays debugging information for "showdebug" flag

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas,YL,YPos);
	
	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText("AI_Controller Stuff");
	YPos += YL;
	Canvas.SetPos(4,YPos);

	// indicate  state
	Canvas.DrawText("     STATE: " $ GetStateName());
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function displayWorldSpaceDebug(HUD displayHUD)
{
	Super.displayWorldSpaceDebug(displayHUD);

	drawRouteCache();
}

function drawRouteCache()
{
	local int routeSegmentI;

	// draw route segments
	for (routeSegmentI = 0; routeSegmentI < routeCache.length - 1; ++routeSegmentI)
	{
		if (routeCache[routeSegmentI + 1].jetpack)
			DrawDebugLine(routeCache[routeSegmentI].location, routeCache[routeSegmentI + 1].location, 255, 255, 255);
		else
			DrawDebugLine(routeCache[routeSegmentI].location, routeCache[routeSegmentI + 1].location, 0, 255, 0);
	}

	// draw route points
	for (routeSegmentI = 0; routeSegmentI < routeCache.length; ++routeSegmentI)
	{
		DrawDebugLine(routeCache[routeSegmentI].location + vect(0,0,-40), routeCache[routeSegmentI].location + vect(0,0,40), 0, 0, 255);
	}

	if (dlm != None)
	{
		// draw line to current do local move destination
		DrawDebugLine(dlm.destination, Pawn.Location, 255, 0, 255);

		// draw line to current smoothing destination
		if (localSmoothMoveDestinationValid)
			DrawDebugLine(localSmoothMoveDestination, Pawn.Location, 255, 255, 0);
	}
}

//---------------------------------------------------------------------

function drawLOADebug()
{
	local byte r,g,b;
	local Rook rook;

	rook = Rook(pawn);

	// LOA lookahead debug
	if ( rook.loaHit )
		r = 255;
	else
	{
		r = 50;
		g = 255;
	}

	DrawDebugLine( rook.loaStartPoint, rook.loaEndPoint, r, g, b );
	DrawDebugLine( rook.loaStartPoint2, rook.loaEndPoint2, r, g, b );
}

//---------------------------------------------------------------------
// Display world space overlays for jetting and skiing debug

function drawJettingSkiingDebug()
{
	local int i;			// terrain profile debug
	local Byte r,g,b;

	for ( i = 0; i < terrainSamplesDebug.length; ++i )
	{
		if ( i == 0 )
			r = 255;
		else
			b = 255;

		DrawDebugLine( terrainSamplesDebug[i].location + vect(0,0,-40),
						terrainSamplesDebug[i].location + vect(0,0,40),
						r, g, b );

		if ( terrainSamplesDebug[i].bBeforeSkiRouteStart )
		{
			r = 180;
			g = 180;
			b = 180;
		}
		else if ( terrainSamplesDebug[i].bDownSlope )
		{
			r = 0;
			g = 0;
			b = 255;
		}
		else
		{
			r = 255;
			g = 60;
			b = 0;
		}

		if ( i > 0 )
			DrawDebugLine( terrainSamplesDebug[i-1].location + vect(0,0,20),
							terrainSamplesDebug[i].location + vect(0,0,20),
							r, g, b );
	}

	// draw movementForce applied to char
	DrawDebugLine( Rook(pawn).Location, Rook(pawn).Location + Rook(pawn).movementForce, 0, 150, 255);

	// draw a cross at prediction location
/*	aColor = class'Canvas'.static.MakeColor(150, 0, 0);

	displayHUD.Draw3DLine( Rook(pawn).estLocation + vect(-30,-30,20),
							Rook(pawn).estLocation + vect(30,30,20),
							aColor);
	displayHUD.Draw3DLine( Rook(pawn).estLocation + vect(-30,30,20),
							Rook(pawn).estLocation + vect(30,-30,20),
							aColor);
	displayHUD.Draw3DLine( Rook(pawn).estLocation + vect(0,0,500),
							Rook(pawn).estLocation + vect(0,0,-1000),
							aColor);*/
}

//---------------------------------------------------------------------

event OnHearSound(Actor SoundMaker, vector SoundOrigin, Name SoundCategory)
{
#if IG_TRIBES3
	// temporary (probably want to catch this case earlier)
	if (Rook(pawn).hearing != None)
		Rook(pawn).hearing.OnHearSound(SoundMaker, SoundOrigin, SoundCategory);
#endif    
}

//---------------------------------------------------------------------
// navigation actions debug display function

function displayNavigationDebug()
{
    local int i;
	local Pawn debugPawn;
	local NS_Action action;

	debugPawn = Pawn;
    debugPawn.AddDebugMessage(" ");

	debugPawn.AddDebugMessage( "Navigation Actions (" $ lastErrorCode $ ")", class'Canvas'.static.MakeColor(255,255,255));
	for ( i = 0; i < runningActions.length; i++ )
	{
		action = runningActions[i];
		debugPawn.AddDebugMessage( "  " $ action.actionDebuggingString() @ "(" $ action.errorCode $ ")" );
	}
}

//---------------------------------------------------------------------
// Display AI Debug Info (obsolete)

function drawDebug( Canvas canvas, HUD hud )
{
	local array<String> debugAIText;
	local int i;
	local float strX;
	local float strY;
	local float debugAIX;
	local float debugAIY;
	local AI_Resource r;
	local Gameplay.DefaultHUD dhud;

	// construct debug text
	dhud = Gameplay.DefaultHUD( hud );
	if ( Pawn != None )
	{
		debugAIText.length = 4;
		debugAIText[0] = String( Pawn.name ) $ ":";
		r = AI_Resource( Pawn.characterAI );

		debugAIText[1] = " Goals:";
		for ( i = 0; i < r.goals.length; i++ )
			debugAIText[1] = debugAIText[1] $ " " $ r.goals[i].name;

		debugAIText[2] = " Running Actions:";
		for ( i = 0; i < r.runningActions.length; i++ )
			debugAIText[2] = debugAIText[2] $ " " $ r.runningActions[i].name;

		debugAIText[3] = " Idle Actions:";
		for ( i = 0; i < r.idleActions.length; i++ )
			debugAIText[3] = debugAIText[3] $ " " $ r.idleActions[i].name;

		// render text
		Canvas.SetDrawColor(255, 0, 0, 255);
		debugAIX = /*Scale * */ DEBUGAI_X;
		debugAIY = /*Scale * */ DEBUGAI_Y;
		Canvas.Font = dhud.smallFont; //MyFont.GetSmallFont(Canvas.ClipX);
		for (i = 0; i < debugAIText.length; i++)
		{
			Canvas.StrLen(debugAIText[i], strX, strY);
			Canvas.SetPos(debugAIX /*- strX / 2*/, debugAIY + i * strY - strY / 2);	
			Canvas.DrawText(debugAIText[i], false);		
		}
	}
}

//=============================================================================

defaultProperties
{
	localSmoothMoveDestinationValid = false

	tickTimeUpdateRange			= (Min=0.095,Max=0.105)
}
