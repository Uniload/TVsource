class x2anticloak extends Gameplay.Cloakpack;

var config bool AnnounceCheater; // Announce cheater to the server.

simulated function startApplyPartialActiveEffect()
{
	setTimer(jammingPeriodSeconds, false);
}

simulated function applyPartialActiveEffect(float alpha, Character characterOwner)
{
        characterOwner.bHidden = false;
        //Announce();
}

/* function KillPlayer()
{
        local Controller C;
        C.Pawn.TakeDamage(300, C.Pawn, C.Pawn.Location, vect(0,0,1), class'Suicided');
} */

/* function Announce()
{
         local Controller C;
         if(AnnounceCheater)
	 {
		//Level.Game.AccessControl.KickPlayer(PlayerController(C));
		log("Player '" $ C.PlayerReplicationInfo.PlayerName $ "' has been killed for exploiting.", 'x2');
		Level.Game.BroadcastLocalized(self, class'x2GameMessage', 102, C.PlayerReplicationInfo);
          }
} */

defaultproperties
{
//AnnounceCheater=True
}
