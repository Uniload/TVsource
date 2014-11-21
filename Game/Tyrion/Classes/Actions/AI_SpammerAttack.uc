//=====================================================================
// AI_SpammerAttack
// Spammer AI standard attack
//=====================================================================

class AI_SpammerAttack extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the spammer (1 or 2)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

var() float minMortarRange "Minimum distance at which to equip the mortar";
var() float idealMortarRange "Preferred distance at which to use the mortar";
var() float maxEnergyBladeRange "Maximum distance at which to use the energy blade";

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a spammer
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;
	local Vector hitLocation;
	local float timeToHit;																	   

	w = Weapon( ai.nextEquipment( None, class'Mortar' ));
	//log( VDist( ai.Location, target.Location ) @ w.aimClass.static.obstacleInPath( hitLocation,
	//									  timeToHit,
	//									  target,
	//									  w,
	//									  w.aimClass.static.getAimLocation( w, target )) );
	if ( w != None && w.hasAmmo() && 
		( preferredWeaponClass == class'Mortar' ||
		  VDistSquared( ai.Location, target.Location ) >= minMortarRange * minMortarRange ) &&
		w.aimClass.static.obstacleInPath( hitLocation,
										  timeToHit,
										  target,
										  w,
										  w.aimClass.static.getAimLocation( w, target )) == None &&
		!w.aimClass.static.willHurt( w, ai, hitLocation, timeToHit ))
		return w;

	w = Weapon( ai.nextEquipment( None, class'Chaingun' ));
	if ( w != None && w.hasAmmo() )
		return w;

	w = Weapon( ai.nextEquipment( None, class'EnergyBlade' ));
	if ( w != None && VDistSquared( ai.Location, target.Location ) <= maxEnergyBladeRange * maxEnergyBladeRange )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	// always try to back up to the ideal mortar range unless holding the energy blade
	if ( ClassIsChildOf( weaponClass, class'EnergyBlade' ))
		return 0.8f * (class'EnergyBlade'.default.range + target.CollisionRadius);	// energy blade
	else
		return idealMortarRange;
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

	// when SpammerAttack deactivates, AI keeps on moving with his last direction
	// (maybe there should be a default low-pri action that lands the AI?)
	if ( class'Pawn'.static.checkAlive( pawn ) )
		AI_Controller(pawn.controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rank != 1 && rank != 2 )
	{
		log( "AI ERROR: invalid rank" @ rank @ "given to spammer" @ Pawn.name );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started." @ pawn.name @ "is attacking" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	waitForGoal( (new class'AI_DirectAttackGoal'( characterResource(), achievingGoal.priority, target, self, preferredWeaponClass, followFunction )).postGoal( self ) );

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

	minMortarRange = 1500
	idealMortarRange = 3000
	maxEnergyBladeRange = 400
}