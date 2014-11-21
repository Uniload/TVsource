class ActionGetArmorType extends Scripting.Action;

// execute
latent function Variable execute()
{
	local Character c;
	local class<Armor> NextClass;

	Super.execute();

	c = Character(findByLabel(class'Character', 'Player'));
	if (c == None)
	{
		logError("Could not find player");
	}
	else
	{
		if(c.ArmorClass == None)
			return newTemporaryVariable(class'VariableFloat', "0");

		NextClass = class<Armor>(DynamicLoadObject("EquipmentClasses.ArmorLight", class'Class'));
		if(classIsChildOf(c.ArmorClass, NextClass))
		{
			SLog("Armor Index of player is 1");
			return newTemporaryVariable(class'VariableFloat', "1");
		}

		NextClass = class<Armor>(DynamicLoadObject("EquipmentClasses.ArmorMedium", class'Class'));
		if(classIsChildOf(c.ArmorClass, NextClass))
		{
			SLog("Armor Index of player is 2");
			return newTemporaryVariable(class'VariableFloat', "2");
		}

		NextClass = class<Armor>(DynamicLoadObject("EquipmentClasses.ArmorHeavy", class'Class'));
		if(classIsChildOf(c.ArmorClass, NextClass))
		{
			SLog("Armor Index of player is 3");
			return newTemporaryVariable(class'VariableFloat', "3");
		}
	}

	logError("Armor Index of player was not found");
	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Get the armor index of the player.";
}


defaultproperties
{
	returnType			= class'VariableFloat'
	actionDisplayName	= "Get Player Armor type"
	actionHelp			= "Returns an index representing the players armor type"
	category			= "Actor"
}