class ActionGiveWeapon extends Scripting.Action;

var() editcombotype(enumCharacterLabels) Name target;
var() actionnoresolve class<Weapon> weaponClass;

// execute
latent function Variable execute()
{
	local Character c;
	local Weapon w;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, target)
	{
		w = Weapon(c.nextEquipment(None, weaponClass));

		if (w == None)
			c.newEquipment(weaponClass);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Give " $ propertyDisplayString('target') $ " a weapon of class " $ weaponClass;
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
	actionDisplayName	= "Give Weapon"
	actionHelp			= "Give a weapon to a character if they don't already have it"
	category			= "Actor"
}