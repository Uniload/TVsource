//=====================================================================
// AI_SkiToGoal
//=====================================================================

class AI_SkiToGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name jetToPointName "A path node label the AI will jet to before skiing (can be empty)";
var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) Character.SkiCompetencyLevels skiCompetency "How well the AI can ski";
var(Parameters) Character.JetCompetencyLevels jetCompetency "How well the AI can jetpack";
var(Parameters) float terminalDistanceXY "How close the AI must get to its destination in XY";
var(Parameters) float terminalDistanceZ "How close the AI must get to its destination in Z";
var(Parameters) float energyUsage "How much energy the AI must have when the action completes";
var(Parameters) float terminalVelocity "How fast the AI should be going when it reaches its destination";
var(Parameters) float terminalHeight "How high above the ground the AI should be when it reaches its destination";

var(InternalParameters) editconst Vector jetToPoint;
var(InternalParameters) editconst Vector destination;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector _jetToPoint, Vector _destination,
	optional Character.SkiCompetencyLevels _skiCompetency, optional Character.JetCompetencyLevels _jetCompetency,
	optional float _energyUsage, optional float _terminalVelocity, optional float _terminalHeight,
	optional float _terminalDistanceXY, optional float _TerminalDistanceZ )
{
	priority = pri;
	jetToPoint = _jetToPoint;
	destination = _destination;
	skiCompetency = _skiCompetency;
	jetCompetency = _jetCompetency;

	if ( _terminalDistanceXY == 0 )
		terminalDistanceXY = default.terminalDistanceXY;
	else
		terminalDistanceXY = _terminalDistanceXY;

	if ( _terminalDistanceZ == 0 )
		terminalDistanceZ = default.terminalDistanceZ;
	else
		terminalDistanceZ = _terminalDistanceZ;

	energyUsage = _energyUsage;
	terminalVelocity = _terminalVelocity;
	terminalHeight = _TerminalHeight;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	priority = 30

	terminalDistanceXY = 2000
	terminalDIstanceZ = 500
}

