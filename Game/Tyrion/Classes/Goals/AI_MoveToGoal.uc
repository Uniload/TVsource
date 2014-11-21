//=====================================================================
// AI_MoveToGoal
//=====================================================================

class AI_MoveToGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) Character.SkiCompetencyLevels skiCompetency "How well the AI can ski";
var(Parameters) Character.JetCompetencyLevels jetCompetency "How well the AI can jetpack";
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement mode";
var(Parameters) float terminalDistanceXY "How close the AI must get to its destination in XY";
var(Parameters) float terminalDistanceZ "How close the AI must get to its destination in Z";
var(Parameters) float energyUsage "How much energy the AI must have when the action completes";
var(Parameters) float terminalVelocity "How fast the AI should be going when it reaches its destination";
var(Parameters) float terminalHeight "How high above the ground the AI should be when it reaches its destination";
var(Parameters) Rotator terminalRotation "Which way the AI should be facing when it reaches its destination";

var(InternalParameters) editconst Vector destination;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector _destination,
	optional Character.SkiCompetencyLevels _skiCompetency, optional Character.JetCompetencyLevels _jetCompetency,
	optional Character.GroundMovementLevels _groundMovement,
	optional float _energyUsage, optional float _terminalVelocity, optional float _terminalHeight,
	optional float _terminalDistanceXY, optional float _terminalDistanceZ, optional Rotator _terminalRotation )
{
	priority = pri;
	destination = _destination;
	skiCompetency = _skiCompetency;
	jetCompetency = _jetCompetency;
	groundMovement = _groundMovement;
	terminalDistanceXY = _terminalDistanceXY;
	terminalDistanceZ = _terminalDistanceZ;
	energyUsage = _energyUsage;
	terminalVelocity = _terminalVelocity;
	terminalHeight = _terminalHeight;
	terminalRotation = _terminalRotation;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	priority = 31
}

