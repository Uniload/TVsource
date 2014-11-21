//=====================================================================
// AI_TargetMemorySensor
// Keeps track of a particular pawn; "knows" where pawn is for a while
// even after losing sight of said pawn
//
// (Note: Since Tyrion can't distinguish sensors based on their parameters,
// a new class was has to be created for any targetSensor with a differing
// "canStillSeePeriod" value.)
//
// Value (object): pointer to the target or None
//=====================================================================

class AI_TargetMemorySensor extends AI_TargetSensor;

//=====================================================================
// Variables

//=====================================================================
// Functions

//=====================================================================

defaultproperties
{
}
