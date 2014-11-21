//=====================================================================
// AI_MountResource
// Specialized AI_Resource for devices that can be occupied (vehicle positions, turrets))
//=====================================================================

class AI_MountResource extends AI_Resource
	abstract;

//=====================================================================
// Variables

var Pawn m_pawn;	// contains pointer to vehicle or turret
var int index;		// contains index of this resource in vehicle's "positions" array (or "-1" for turrets)

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Store a back pointer to the actor (vehicle) that this resource is attached to

function setResourceOwner( Engine.Actor aMount )
{
	m_pawn = Pawn(aMount);
}

//---------------------------------------------------------------------
// Store index of this vehicle position in vehicle

function setIndex( int aIndex )
{
	index = aIndex;
}

//---------------------------------------------------------------------
// Accessor functions

function Pawn pawn()
{
	return m_pawn;
}

function Vehicle vehicle()
{
	return Vehicle(m_pawn);
}

function Turret turret()
{
	return Turret(m_pawn);
}

// returns the rook representing the vehicle mounted turret or the vehicle (for drivers) or the turret 
function Rook localRook()
{
	if ( index < 0 )
		return Turret(m_pawn);
	else
		return Vehicle(m_pawn).positions[index].toBePossessed;
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

event init()
{
	// sensors are created here....

	super.init();
}

//---------------------------------------------------------------------
// perform resource-specific cleanup before resource is deleted

function cleanup()
{
	// Set sensorActions to None
	// ...

	super.cleanup();

	m_pawn = None;
}

//---------------------------------------------------------------------
// Does the resource have the sub-resources available to run an action?
// legspriority:  priority of the sub-goal that will be posted on the legs (0 if no goal)
// armsPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)
// headPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)

function bool requiredResourcesAvailable( int legsPriority, int armsPriority, optional int headPriority )
{
	return true;	// todo: figure out what sub-resources are (if anything) in mounts

//	local Pawn occupant;
//
//	occupant = vehicle().positions[index].occupant;
//
//	if ( occupant == None )
//		return false;
//	else
//		return AI_MovementResource(occupant.MovementAI).requiredResourcesAvailable( legsPriority, armsPriority, headPriority ) &&
//			   AI_WeaponResource(occupant.WeaponAI).requiredResourcesAvailable( legsPriority, armsPriority, headPriority );
}

//---------------------------------------------------------------------
// Can this resource run "action" if it's already being used?
// (assumes 'action' will be running on this resource)

function bool multipleActionsCheck( AI_Action action )
{
	return (action.resourceUsage & RU_MOUNT) == 0;		// mount not required
}

//----------------------------------------------------------------------
// Is the parent of this action already using a leaf resource?

function bool doesParentHaveResource( AI_Action parentAction )
{
	return parentAction != None &&
			ClassIsChildOf( parentAction.resource.class, class'AI_MountResource' ) &&
			(parentAction.resourceUsage & RU_MOUNT ) != 0 &&
			AI_MountResource(parentAction.resource).index == index;
}

//---------------------------------------------------------------------
// Should this resource be trying to satisfy goals?

event bool isActive()
{
	local Vehicle v;
	local Turret t;
	local Rook mount;

	v = vehicle();
	t = turret();
	mount = localRook();

	return class'Pawn'.static.checkAlive( m_pawn ) && mount.AI_LOD_Level >= AILOD_NORMAL &&
		// turret active when not occupied or occupied by an AI
		( t == None || ( t.IsInState('Active') && (class'Pawn'.static.checkAlive( t.driver ) || t.IsA( 'DeployedTurret' )) && !t.isHumanControlled() )) &&
		// vehicle active when occupied by an AI 
		( v == None || (class'Pawn'.static.checkAlive( v.positions[index].occupant ) && !mount.isHumanControlled() ));
}

//=====================================================================

defaultproperties
{
	index = -1
}
