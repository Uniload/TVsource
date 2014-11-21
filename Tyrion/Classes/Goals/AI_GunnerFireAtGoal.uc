//=====================================================================
// AI_GunnerFireAtGoal
//=====================================================================

class AI_GunnerFireAtGoal extends AI_GunnerGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) bool bGiveUpIfTargetLost "Terminate action if target lost?";
var(Parameters) bool bFireWithoutLOS "Fire even if you have no LOS on the target";

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, Vehicle.VehiclePositionType _position,
							  optional bool _bGiveUpIfTargetLost, optional bool _bFireWithoutLOS )
{
	priority = pri;
	target = _target;
	position = _position;
	bGiveUpIfTargetLost = _bGiveUpIfTargetLost;
	bFireWithoutLOS = _bFireWithoutLOS;

	super.construct( r );
}

//---------------------------------------------------------------------

function init( AI_Resource r )
{
	local Vehicle v;

	super.init( r );

	v = Vehicle(r.pawn());
	// only activate goal if position matches this resource
	if ( v != None && v.getPositionIndex( position ) != AI_MountResource(r).index )
	{
		bInactive = true;
	}
}

//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

