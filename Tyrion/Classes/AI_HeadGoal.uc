//=====================================================================
// AI_HeadGoal
// Goals for the Head Resource
//=====================================================================

class AI_HeadGoal extends AI_Goal
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Return the resource class for this goal

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_HeadResource';
}

//---------------------------------------------------------------------
// Depending on the type of goal, find the resource the goal should be
// attached to (if you happen to have an instance of the goal pass it in)

static function Tyrion_ResourceBase findResource( Pawn p, optional Tyrion_GoalBase goal )
{
	return p.headAI;
}

//---------------------------------------------------------------------
// Get the character resource for this goal

function AI_CharacterResource characterResource()
{
	 return AI_CharacterResource(AI_HeadResource(resource).m_pawn.characterAI);
}

defaultproperties
{
}
