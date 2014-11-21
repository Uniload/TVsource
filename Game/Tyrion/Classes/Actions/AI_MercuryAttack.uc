//=====================================================================
// AI_MercuryAttack
// Attack behaviour for Mercury AI
//=====================================================================

class AI_MercuryAttack extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) int rank "Rank (not used)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

var() float maxBlasterRange "Max distance at which to use the blaster";
var() float idealSniperRange "Preferred distance at which to use the sniperRifle";
var() float minSnipingEnergy "Minimum percentage of energy you need to fire sniperRifle";

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a boss
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;

	//log( VDist( ai.Location, target.Location ) );

	w = Weapon( ai.nextEquipment( None, class'Blaster' ));
	if ( w != None && w.hasAmmo() &&
		( preferredWeaponClass == class'Blaster' ||
		  VDistSquared( ai.Location, target.Location ) <= maxBlasterRange * maxBlasterRange ) )
		return w;

	w = Weapon( ai.nextEquipment( None, class'SniperRifle' ));
	if ( w != None && w.hasAmmo() )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	//if ( ClassIsChildOf( weaponClass, class'ChainGun' ))
	//	return idealChaingunRange;

	return idealSniperRange;
}

//---------------------------------------------------------------------
// are conditions met for firing this weapon?

function bool bShouldFire( BaseAICharacter ai, Weapon weapon )
{
	return ( ai.energy > minSnipingEnergy * ai.default.energy / 100.0f || !weapon.IsA( 'SniperRifle' ) );
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

	maxBlasterRange		= 1200
	idealSniperRange	= 3000
	minSnipingEnergy	= 50
}