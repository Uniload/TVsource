class ActionSetTeam extends Scripting.Action;

var() editcombotype(enumRookLabels) Name target;
var() editcombotype(enumTeamInfo) TeamInfo targetTeam;

// execute
latent function Variable execute()
{
	local Rook r;

	Super.execute();

	ForEach parentScript.actorLabel(class'Rook', r, target)
	{
		r.setTeam(targetTeam);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Set "$propertyDisplayString('target')$"'s team to "$targetTeam;
}

event function enumRookLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Rook r;
	
	ForEach level.AllActors(class'Rook', r)
	{
		if (r.label != '')
		{
			s[s.Length] = r.label;
		}
	}
}

function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set Team"
	actionHelp			= "Sets a Rook's team"
	category			= "Actor"
}