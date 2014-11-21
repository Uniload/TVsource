//=====================================================================
// AI_HeadAction
// Actions that involve a character's head
//=====================================================================

class AI_HeadAction extends AI_Action
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Accessor function for resource

#if IG_TRIBES3
function Rook rook()
{
	return Rook(AI_HeadResource(resource).m_pawn);
}

function Character character()
{
	return Character(AI_HeadResource(resource).m_pawn);
}

function BaseAICharacter baseAIcharacter()
{
	return BaseAICharacter(AI_HeadResource(resource).m_pawn);
}
#endif

function AI_HeadResource headResource()
{
	return AI_HeadResource(resource);
}

function AI_CharacterResource characterResource()
{
	return AI_CharacterResource(AI_HeadResource(resource).m_pawn.characterAI);
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_HeadResource';
}

//---------------------------------------------------------------------
// Depending on the type of action, find the resource the action should
// be attached to

static function Tyrion_ResourceBase findResource( Pawn p )
{
	return p.headAI;
}

//---------------------------------------------------------------------
// Run an action
// Typically called by the resource
// 
// Note: The "head" resource is considered "used" when an action running
//       on this resource declares it needs it

function runAction()
{
	Super.runAction();

	if ( resource.isActive() && (resourceUsage & class'AI_Resource'.const.RU_HEAD) != 0 && resource.usedByaction == None )
		resource.usedByAction = self;
}

//=======================================================================

function classConstruct()
{
	resourceUsage = class'AI_Resource'.const.RU_HEAD;
}

defaultproperties
{
}