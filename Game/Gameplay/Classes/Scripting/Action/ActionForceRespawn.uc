class ActionForceRespawn extends Scripting.Action;

// execute
latent function Variable execute()
{
	local SinglePlayerGameInfo gi;
	local PlayerController pc;
	local Character c;
	local bool temp;

	Super.execute();

	gi = SinglePlayerGameInfo(parentScript.Level.Game);

	if (gi != None)
	{
		pc = parentScript.Level.GetLocalPlayerController();

		if (pc != None)
		{
			temp = gi.bRestartLevel;
			gi.bRestartLevel = false;

			// kill label on all dead players, so if scripts want to refer to the player after respawn it works
			foreach parentScript.actorLabel(class'Character', c, 'Player')
			{
				if (c.health <= 0)
					c.Label = 'DeadPlayer';
			}

			gi.RestartPlayer(pc);

			gi.bRestartLevel = temp;
		}
		else
			logError("Couldn't get the local player controller");
	}
	else
		logError("The force respawn action only works for single player games");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Force the player to respawn";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Force Respawn"
	actionHelp			= "Forces the player to respawn, only works in single player games"
	category			= "Level"
}