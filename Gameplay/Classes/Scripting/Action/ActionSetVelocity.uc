class ActionSetVelocity extends Scripting.Action;

var() editcombotype(enumCharacterLabels) Name target;
var() Rotator direction;
var() float magnitude;

// execute
latent function Variable execute()
{
	local Character c;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, target)
	{
		c.setVelocity(Vector(direction) * magnitude);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Set the velocity of " $ propertyDisplayString('target') $ " to (" $ Vector(direction) * magnitude $ ")";
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
	returnType			= None
	actionDisplayName	= "Set Velocity"
	actionHelp			= "Sets the velocity of a character"
	category			= "Actor"
}