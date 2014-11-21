class Checker extends Engine.Actor
      config
      notplaceable;

var() config int UpdateTime; // How often to check Players
var() config int NegativeLimit; // What is limit for Negative points
var() config bool BanUser; // Ban the player for infraction
var() config string KickMsg; // message to show player when kicked
var() config string BanMsg; // message to show player when banned

var() const editconst string Build;

function PostBeginPlay()
{
  local int TimeToUpdate;

  Super.PostBeginPlay();

  if(MultiplayerGameInfo(Level.Game).bTournamentMode)
  {
     log("Tournament Mode enabled - Disabling Teamkill check", 'mutAntiTK');
     Destroy();
     return;
  }

  log("**************************************************", 'mutAntiTK');
  log("mutAntiTK build"@Build, 'mutAntiTK');
  log("Copyright 2004 by Byte <jfulbright@tsncentral.com>", 'mutAntiTK');
  log(" ", 'mutAntiTK');
  log("Update Time: "$UpdateTime, 'mutAntiTK');
  log("Negative Limit: "$NegativeLimit, 'mutAntiTK');
  log("Ban User: "$BanUser, 'mutAntiTK');
  log("**************************************************", 'mutAntiTK');

  // save out our config to ini just for sake of doing it
  SaveConfig();

  // setup our Timer to go thru each Controllers
  TimeToUpdate = UpdateTime; //*60
  SetTimer(TimeToUpdate, true);
}

function Timer()
{
  local Controller C;
  local int i, s;
  local PlayerReplicationInfo P;

  for (C = Level.ControllerList; C != none; C = C.nextController)
  {
	// if its none, then keep going thru list
    if (PlayerController(C) == none)
        continue;

    // get our Player Info
    P = C.PlayerReplicationInfo;

    // if playername or team are none continue
    if (P.playerName == "" || tribesReplicationInfo(P).team == None)
	 	continue;

	// add our limit to score to see if it makes us at 0 (infraction)
    // if so, we log it and kick or ip ban
    S = P.Score + NegativeLimit;

    // warn player as we're close to removal
    if(S==1 || S==2)
    {
       PlayerController(c).ReceiveLocalizedMessage(class'TKMessage', 0, P);
       return;
    }

    if(S<=0)
    {
		Level.Game.AccessControl.KickedMsg = GetKickReason();
		if(BanUser)
		{
           BroadcastLocalizedMessage(class'TKMessage', 2, P);
		   Level.Game.AccessControl.BanPlayer(PlayerController(C));
           log("Banning player"@P.playerName@"for negative score infraction - "$P.Score, name);
        }
        else
        {
           BroadcastLocalizedMessage(class'TKMessage', 1, P);
           log("Kicking player"@P.playerName@"for negative score infraction - "$P.Score, name);
           Level.Game.AccessControl.Kick(P.playerName);
        }
        Level.Game.AccessControl.KickedMsg = Level.Game.AccessControl.default.KickedMsg;
	}
  }
}

/** get the formatted kick message string */
function string GetKickReason()
{
	if(BanUser)
       return repl(BanMsg, "%s", NegativeLimit);

       return repl(KickMsg, "%s", NegativeLimit);
}

defaultproperties
{
     UpdateTime=300
     NegativeLimit=10
     KickMsg="Kicked due to Negative Score Limit: %s"
     BanMsg="Banned due to Negative Score Limit: %s"
     Build="1.0"
}
