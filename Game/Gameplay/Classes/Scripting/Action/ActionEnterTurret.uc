class ActionEnterTurret extends Scripting.Action;

var() editcombotype(enumCharacterLabels) Name targetCharacter;
var() editcombotype(enumTurretLabels) Name targetTurret;

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

event function enumTurretLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Turret t;

	ForEach level.AllActors(class'Turret', t)
	{
		if (t.label != '')
		{
			s[s.Length] = t.label;
		}
	}
}

// execute
latent function Variable execute()
{
	local Character c;
	local Turret t;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, targetCharacter)
		break;

	if (c == None)
		return None;

	ForEach parentScript.actorLabel(class'Turret', t, targetTurret)
		break;

	if (t == None)
		return None;

	if (!t.tryToControl(c))
		slog(c @ " failed to enter " @ t);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = propertyDisplayString('targetCharacter') @ "enters" @ propertyDisplayString('targetTurret');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enter Turret"
	category			= "Actor"
}