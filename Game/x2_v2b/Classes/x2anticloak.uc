class x2anticloak extends Gameplay.Cloakpack;

simulated function startApplyPartialActiveEffect()
{
	setTimer(jammingPeriodSeconds, false);
}

simulated function applyPartialActiveEffect(float alpha, Character characterOwner)
{
	characterOwner.bHidden = false;
}


/* simulated function applyPartialActiveEffect(float alpha, Character characterOwner)
{
	Level.Game.AccessControl.KickPlayer(PlayerController(C));
	log("Player '" $ characterOwner.PlayerReplicationInfo.PlayerName $ "' has been kicked for cheating.", 'x2');
	Level.Game.BroadcastLocalized(self, class'x2GameMessage', 31, C.PlayerReplicationInfo);
} */

defaultproperties
{
}
