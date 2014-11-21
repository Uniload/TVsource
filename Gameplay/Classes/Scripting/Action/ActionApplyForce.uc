class ActionApplyForce extends Scripting.Action;

var() editcombotype(enumCharacterLabels) Name target;
var() Rotator direction;
var() float force;
var() float duration;
var float endTime;
var array<Character> characters;

// execute
latent function Variable execute()
{
	local Character c;
	local int i;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, target)
	{
		characters[characters.length] = c;
	}

	endTime = parentScript.Level.TimeSeconds + duration;

	while (parentScript.Level.TimeSeconds < endTime)
	{
		for (i = 0; i < characters.length; ++i)
			if (characters[i] != None)
				characters[i].unifiedAddImpulse(Vector(direction) * force);

		Sleep(0.0);
	}

	characters.Length = 0;

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Apply force vector (" $ Vector(direction) * force $ ") to " $ propertyDisplayString('target') $ " for " $ propertyDisplayString('duration') $ " seconds";
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
	actionDisplayName	= "Apply Force"
	actionHelp			= "Applys a force to a character for a set duration"
	category			= "Actor"
}