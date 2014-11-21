//=====================================================================
// AI_FireAtGoal
//=====================================================================

class AI_FireAtGoal extends AI_WeaponGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";
var(Parameters) bool bGiveUpIfTargetLost "Terminate action if target lost?";
var(Parameters) bool bFireWithoutLOS "Fire even if you have no LOS on the target";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, optional IWeaponSelectionFunction _weaponSelection,
							  optional class<Weapon> _preferredWeaponClass, optional bool _bGiveUpIfTargetLost,
							  optional bool _bFireWithoutLOS )
{
	priority = pri;
	target = _target;
	weaponSelection = _weaponSelection;
	preferredWeaponClass = _preferredWeaponClass;
	bGiveUpIfTargetLost = _bGiveUpIfTargetLost;
	bFireWithoutLOS = _bFireWithoutLOS;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

