class ActionChangeAIControl extends TyrionScriptAction;

var() editcombotype(enumTyrionTargets) Name target;
var() actionnoresolve Tyrion_ResourceBase.AI_LOD_Levels newAI_LOD_level;

// execute
latent function Variable execute()
{
	local Rook r;

	Super.execute();

	ForEach parentScript.actorLabel(class'Rook', r, target)
	{
		r.level.AI_Setup.setAILOD( r, newAI_LOD_Level );
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Changes AI control level of " $ propertyDisplayString('target');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Change AI Control"
	actionHelp			= "Changes AI control level (AI LOD level) of this rook."
	category			= "AI"
}