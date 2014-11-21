class ActionBaseDevicePowerSwitch extends Scripting.Action;

var() editcombotype(enumBaseDeviceLabels) Name target;
var() bool bOn		"If true, sets the base device's power switch to on. Else, sets it to off.";

// execute
latent function Variable execute()
{
	local BaseDevice b;

	Super.execute();

	ForEach parentScript.actorLabel(class'BaseDevice', b, target)
	{
		b.setSwitchedOn(bOn);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	if (bOn)
		s = "Turn on base device "$propertyDisplayString('target');
	else
		s = "Turn off base device "$propertyDisplayString('target');
}

event function enumBaseDeviceLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local BaseDevice b;
	
	ForEach level.AllActors(class'BaseDevice', b)
	{
		if (b.label != '')
		{
			s[s.Length] = b.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set Base Device Power Switch"
	actionHelp			= "Turns a base device on or off. If you turn off a base device then it will not regain power until you turn it back on, even if its power generator is knocked out and repaired."
	category			= "Actor"
}