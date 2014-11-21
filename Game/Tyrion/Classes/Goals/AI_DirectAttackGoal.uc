//=====================================================================
// AI_DirectAttackGoal
// The DirectAttackGoal is only matched by DirectAttack, whereas the
// AttackGoal is matched by any character-specific attack behavior
//=====================================================================

class AI_DirectAttackGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editconst int rank "Rank of the AI; set by the ability in the class DB";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, 
							  optional IWeaponSelectionFunction _weaponSelection,
							  optional class<Weapon> _preferredWeaponClass, optional IFollowFunction _followFunction )
{
	priority = pri;
	target = _target;
	weaponSelection = _weaponSelection;
	preferredWeaponClass = _preferredWeaponClass;
	followFunction = _followFunction;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called when a goal is removed

function cleanup()
{
	super.cleanup();

	followFunction = None;
	weaponSelection = None;
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	if ( target == None && targetName != '' )
		target = Pawn(resource.pawn().findByLabel( class'Pawn', targetName, true ));

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" @ targetName );

		// goal needs to be matched so it can be cleaned up by the action:
		bInActive = false;
	}
	else
	{
		// userData is always 'None' for deactivation sensors, and != None for activation sensors
		activationSentinel.activateSentinel( self, class'AI_TargetMemorySensor', r,, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
		AI_TargetMemorySensor(activationSentinel.sensor).setParameters( target, Rook(resource.pawn()).visionMemory );
	}
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = false
}

