class ActionHasItem extends Scripting.ActionBool;

var() editcombotype(enumCharacterLabels) Name target;
var() actionnoresolve class<Equipment> itemType;

// execute
latent function Variable execute()
{
	local VariableBool result;
	local Equipment item;
	local Character c;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, target)
	{
		item = c.nextEquipment(None, itemType);
	}

	result = VariableBool(newTemporaryVariable(class'VariableBool'));
	result.value = item != None;

	return result;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Check if " $ propertyDisplayString('target') $ " is carrying " $ itemType;
}

event function enumCharacterLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Character c;
	
	ForEach level.AllActors(class'Character', c)
	{
		if (c.label != '')
		{
			s[s.Length] = c.label;
		}
	}
}

defaultproperties
{
	actionDisplayName	= "Has Item"
	actionHelp			= "Returns true if the target has an item of type itemType in thier equipment list"
	category			= "Actor"
}