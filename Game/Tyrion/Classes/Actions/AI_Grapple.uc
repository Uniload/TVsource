//=====================================================================
// AI_Grapple
// Try to bring an opponent down to the ground or slow him down with the grappler
//=====================================================================

class AI_Grapple extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

const REEL_IN_DIST = 750.0f;	// distance to reel in target to

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the grappler (1 or 2)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

var() float idealBlasterRange "Preferred distance at which to use the blaster";

var BaseAICharacter ai;
var Vector aimLocation;
var ACT_Errorcodes errorCode;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from sub-goals;
// they are only used to stop the action when any success/failure message
// comes up that isn't an interruption
// todo: automate this process? A new flag on goals/waitForGoals?
/*
function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	super.goalAchievedCB( goal, child );

	errorCode = ACT_SUCCESS;
	runAction();
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes anErrorCode ) 
{
	super.goalNotAchievedCB( goal, child, anErrorCode );

	errorCode = anErrorCode;

	if ( errorCode != ACT_INTERRUPTED )
		runAction();
}
*/
//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;

	// always use the blaster to shoot
	w = Weapon( ai.nextEquipment( None, class'Blaster' ));
	if ( w != None && w.hasAmmo() )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	return idealBlasterRange;
}

//---------------------------------------------------------------------
// are conditions met for firing this weapon?

function bool bShouldFire( BaseAICharacter ai, Weapon weapon )
{
	return true;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	weaponSelection = None;
	followFunction = None;

	// when GruntAttack deactivates, AI keeps on moving with his last direction
	// (maybe there should be a default low-pri action that lands the AI?)
	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		AI_Controller(resource.pawn().controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rank != 1 && rank != 2 )
	{
		log( "AI ERROR: invalid rank" @ rank @ "given to grappler" @ Pawn.name );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	ai = baseAICharacter();

	if ( target == None )
		target = Pawn(ai.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started." @ pawn.name @ "is grappling!" );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// start up attack goal (using the blaster)

	(new class'AI_DirectAttackGoal'( characterResource(), achievingGoal.priority-1, target, self, preferredWeaponClass, followFunction )).postGoal( self );

	// grappler control code
	while( class'Pawn'.static.checkAlive( pawn ) &&  class'Pawn'.static.checkAlive( target ))
	{
		// should I grapple?
		if ( !ai.bAttached && VDist( target.Location, pawn.Location ) <= ai.grapplerClass.default.maxRopeLength && 
				ai.vision.isLocallyVisible( target ))
		{
			useResources( class'AI_Resource'.const.RU_ARMS );	// stop regular firing behavior

			log( "!" @ ai.name @ "Switching to Grappler" );
			ai.motor.setWeapon( Weapon( ai.nextEquipment( None, class'Grappler' )) );

			Sleep( 1.0f );		// wait for weapon change
			if ( class'Pawn'.static.checkDead( pawn ) || class'Pawn'.static.checkDead( target ) )
				break;

			//log( "!" @ ai.name @ "weapon equipped:" @ ai.weapon );
			//log( "!" @ ai.name @ "Firing Grappler" );

			// compute place to aim to
			if ( ai.weapon == None )
				aimLocation = target.Location;
			else			
				aimLocation = ai.weapon.aimClass.static.getAimLocation( ai.weapon, target, 1.0f );

			ai.motor.setViewRotation( Rotator(aimLocation - ai.Location) );
			ai.motor.fire(true);

			Sleep( 1.0f );		// wait for grapple to hit
			if ( class'Pawn'.static.checkDead( pawn ) || class'Pawn'.static.checkDead( target ) )
				break;

			// should I reel in?
			if ( ai.bAttached ) //&& ai.weapon.IsA( 'Grappler' ) )
			{
				if ( ai.proj != None && ai.proj.Base == target )	// Grappler hit the target?
				{
					//log( "!" @ ai.name @ "Reeling in" );
					Grappler(ai.weapon).beginReelIn();

					// todo: jetpack backwards to slow down target
		
					while ( ai.bAttached && 
							class'Pawn'.static.checkAlive( pawn ) &&  class'Pawn'.static.checkAlive( target ) &&
							VDist( target.Location, pawn.Location ) > REEL_IN_DIST )
						yield();	

					//log( "!" @ ai.name @ "Stopped reeling in" );
					Grappler(ai.weapon).endReelIn();
				}
				else
				{
					//log( "!" @ ai.name @ "Detaching Grapple" );
					ai.detachGrapple();
				}
			}
			clearDummyWeaponGoal();			// resume regular firing behavior
		}

		yield();
	}

	if ( class'Pawn'.static.checkDead( target ) )
	{
		if ( pawn.logTyrion )
			log( name @ "stopped. TARGET DEAD!" );
		succeed();
	}
	else
		fail( ACT_GENERAL_FAILURE );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_AttackGoal'

	idealBlasterRange = 1500
}