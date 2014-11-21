//=====================================================================
// AI_GrenadierAttack
// Grenadier AI standard attack
//=====================================================================

class AI_GrenadierAttack extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the grenadier (1 or 2)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

var() float minGrenadeLauncherRange "Minimum distance at which to equip the grenade launcher";
var() float idealGrenadeLauncherRange "Preferred distance at which to use the grenade launcher";

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a grenadier
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;
	local Vector hitLocation;
	local float timeToHit;																	   

	w = Weapon( ai.nextEquipment( None, class'GrenadeLauncher' ));
	if ( w != None && w.hasAmmo() && 
		( preferredWeaponClass == class'GrenadeLauncher' ||
		  VDistSquared( ai.Location, target.Location ) >= minGrenadeLauncherRange * minGrenadeLauncherRange ) &&
		w.aimClass.static.obstacleInPath( hitLocation,
										  timeToHit,
										  target,
										  w,
										  w.aimClass.static.getAimLocation( w, target )) == None &&
		!w.aimClass.static.willHurt( w, ai, hitLocation, timeToHit ))
		return w;

	w = Weapon( ai.nextEquipment( None, class'EnergyBlade' ));
	if ( w != None && VDistSquared( ai.Location, target.Location ) <= minGrenadeLauncherRange * minGrenadeLauncherRange )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	// always try to back up to the ideal grenade launcher range unless holding the energy blade
	if ( ClassIsChildOf( weaponClass, class'EnergyBlade' ))
		return 0.8f * (class'EnergyBlade'.default.range + target.CollisionRadius);	// energy blade
	else
		return idealGrenadeLauncherRange;
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

	// when GrenadierAttack deactivates, AI keeps on moving with his last direction
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
		log( "AI ERROR: invalid rank" @ rank @ "given to grenadier" @ Pawn.name );
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

	minGrenadeLauncherRange = 750
	idealGrenadeLauncherRange = 3000
}