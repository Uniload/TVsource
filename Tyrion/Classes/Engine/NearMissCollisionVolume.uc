//=====================================================================
// NearMissCollisionVolume
//=====================================================================

class NearMissCollisionVolume extends Engine.Actor
	native;

//=====================================================================
// Constants

//=====================================================================
// Variables

var Pawn pawn;							// reference back to the character/turret this collision volume is attached to (or None)
var AI_NearMissSensor nearMissSensor;	// reference back to the sensor to notify

//=====================================================================

//---------------------------------------------------------------------

function Touch( actor Other )
{
	local Projectile projectile;

	projectile = Projectile(Other);
	//log( Other.name @ "touched fat volume of" @ pawn.name @ "rookAttacker" @ projectile.rookAttacker );

	if ( projectile != None && projectile.RookAttacker != pawn )
	{
		// when an AI gets hurt, activate it for it a bit so it can react regardless of it's LOD state
		pawn.setLimitedTimeLODActivation( class'AI_Controller'.const.MAX_TICKS_TO_PROCESS_PAIN );

		nearMissSensor.setObjectValue( other );
	}	
}

//---------------------------------------------------------------------

function Destroyed()
{
	super.Destroyed();

	//log( "@@@" @ nearMissSensor.name @ name @ pawn.name @ "DESTROYED!" );

	nearMissSensor = None;
}

//=====================================================================

defaultproperties
{
	remoteRole		  = ROLE_NONE
	bSkipEncroachment = true
    bCollideActors    = true
    bCollideWorld     = false
    bBlockActors      = false
    bBlockPlayers     = false
    bProjTarget       = true

	bHidden			= true
	DrawType		= DT_None
	bDisableTick	= true

	CollisionHeight = 400
	CollisionRadius = 600
}
