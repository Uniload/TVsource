//=====================================================================
// AI_SquadMoveToGoal
//=====================================================================

class AI_SquadMoveToGoal extends AI_SquadGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) float formationDiameter "What's the approximate diameter of the formation?";
var(Parameters) Character.SkiCompetencyLevels skiCompetency;
var(Parameters) Character.JetCompetencyLevels jetCompetency;
var(Parameters) Character.GroundMovementLevels groundMovement;
var(Parameters) float terminalDistanceXY;
var(Parameters) float terminalDistanceZ;
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

var(InternalParameters) editconst Vector destination;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector destination,
	optional float formationDiameter,
	optional Character.SkiCompetencyLevels skiCompetency, optional Character.JetCompetencyLevels jetCompetency,
	optional Character.GroundMovementLevels groundMovement,
	optional float energyUsage, optional float terminalVelocity, optional float terminalHeight,
	optional float terminalDistanceXY, optional float terminalDistanceZ)
{
	self.priority = pri;
	self.destination = destination;
	self.formationDiameter = formationDiameter;
	self.skiCompetency = skiCompetency;
	self.jetCompetency = jetCompetency;
	self.groundMovement = groundMovement;
	self.terminalDistanceXY = terminalDistanceXY;
	self.terminalDistanceZ = terminalDistanceZ;
	self.energyUsage = energyUsage;
	self.terminalVelocity = terminalVelocity;
	self.terminalHeight = terminalHeight;

	if ( formationDiameter == 0.0f )
		self.formationDiameter = self.default.formationDiameter;
	else
		self.formationDiameter = formationDiameter;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	priority = 31

	formationDiameter = 600
}

