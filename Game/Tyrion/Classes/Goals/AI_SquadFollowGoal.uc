//=====================================================================
// AI_SquadFollowGoal
//=====================================================================

class AI_SquadFollowGoal extends AI_SquadGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) float proximity "How close to get to one's desired position while following";
var(Parameters) float formationDiameter "What's the approximate diameter of the formation?";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;
var(Parameters) Character.GroundMovementLevels preferredGroundMovement;

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn target, optional float proximity,
							  optional float formationDiameter, optional float energyUsage,
							  optional float terminalVelocity, optional float terminalHeight,
							  optional Character.GroundMovementLevels preferredGroundMovement )
{
	self.priority = pri;
	self.target = target;

	if ( proximity == 0.0f )
		self.proximity = self.default.proximity;
	else
		self.proximity = proximity;

	if ( formationDiameter == 0.0f )
		self.formationDiameter = self.default.formationDiameter;
	else
		self.formationDiameter = formationDiameter;

	self.energyUsage = energyUsage;
	self.terminalVelocity = terminalVelocity;
	self.terminalHeight = terminalHeight;
	self.preferredGroundMovement = preferredGroundMovement;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false

	proximity = 800
	formationDiameter = 600
}

