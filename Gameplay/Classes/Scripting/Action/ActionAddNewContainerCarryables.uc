class ActionAddNewContainerCarryables extends Scripting.Action;

var() editcombotype(enumContainerLabels) Name target;
var() int numToAdd;

// execute
latent function Variable execute()
{
	local MPCarryableContainer cc;

	Super.execute();

	ForEach parentScript.actorLabel(class'MPCarryableContainer', cc, target)
	{
		cc.GotoState('Paused');
		cc.addNewCarryables(numToAdd);
		cc.GotoState('Active');
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Add "$numToAdd$" new carryables to container " $ propertyDisplayString('target');
}

event function enumContainerLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local MPCarryableContainer cc;
	
	ForEach level.AllActors(class'MPCarryableContainer', cc)
	{
		if (cc.label != '')
		{
			s[s.Length] = cc.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Add New Carryables to Container"
	actionHelp			= "Creates new carryables and deposits them to a container"
	category			= "Actor"
}