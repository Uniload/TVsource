//=====================================================================
// Tyrion_Setup
// Performs one-time initializations/setup for Tyrion AI
//=====================================================================

class Tyrion_Setup extends Actor
	native;

//=====================================================================
// Variables

var transient Object deadClasses;	// a pointer to the DeadClasses package; the outers of goal classes
									// get set to this when their regular outer is destroyed

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Hook in Tyrion for the rook to call into at every tick

event doRookRelatedAIProcessing( float deltaSeconds, Pawn pawn );

//---------------------------------------------------------------------
// Hook in Tyrion for the Player to call into at every tick

function doPlayerRelatedAIProcessing( float deltaSeconds, Pawn pawn );

//---------------------------------------------------------------------

native function setAILOD( Pawn pawn, Tyrion_ResourceBase.AI_LOD_Levels newLODLevel );

//---------------------------------------------------------------------
// stop all movement actions

event stopActions( Pawn pawn );

//---------------------------------------------------------------------
// clear vision lists

native function shutDownVision( Pawn pawn );

//---------------------------------------------------------------------

native function makeSafeOuter( Object objOwner, Object obj );

//---------------------------------------------------------------------
// Shallow copy function
// Returns None if copy failed
// Note: shouldn't this be in Object.uc?

static function Object shallowCopy( Object source )
{
	local Object dest;

	dest = new(source.outer) source.class;

	if ( static.copyParameters( source, dest ) )
		return dest;
	else
		return None;
}

//---------------------------------------------------------------------
// Shallow copy goal function
// Goals need their own shallow copy because they need to be put into
// the sources package rather than the sources outer
// Returns None if copy failed

static function Object shallowCopyGoal( Object source )
{
	local Object dest;
	local Object destOuter;

	for (destOuter = source.Outer; destOuter.Outer != None; destOuter = destOuter.Outer)
		;

	dest = new(destOuter) source.class;

	if ( static.copyParameters( source, dest ) )
		return dest;
	else
		return None;
}

//---------------------------------------------------------------------
// Copy parameters from source to dest
// Note: shouldn't this be in Object.uc?

native static function bool copyParameters( Object source, Object dest);

//---------------------------------------------------------------------
// Sends a message to GetOutOfWaySensor when a pawn was bumped by a friendly
// (this function is overriden in Tyrion)

function sendGetOutOfWayMessage( Pawn bumpedPawn, Vector bumpDirection );

//---------------------------------------------------------------------
// Sends a message to painSensor of squad members when a member dies
// (this function is overriden in Tyrion)

function sendAllyDiedMessage( Pawn ally, Pawn deadPawn, Pawn InstigatedBy, class<DamageType> damageType, vector HitLocation );

//---------------------------------------------------------------------
// gets enemy list from the enemy sensor

function array<Pawn> getEnemyListFromSensor( Pawn ai );

//---------------------------------------------------------------------

event enemyListSanityCheck( Pawn ai );

//=====================================================================
// defaults

defaultproperties
{
     DrawType=DT_None
     bHidden=True
}
