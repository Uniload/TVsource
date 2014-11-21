class GameInfo extends Info
    config(Game)
    native;

var globalconfig    bool        bKickLiveIdlers;        // if true, even playercontrollers with pawns can be kicked for idling

var globalconfig float MaxIdleTime;     // maximum time players are allowed to idle before being kicked

// speed hack detection
var globalconfig    float                   MaxTimeMargin;
var globalconfig    float                   TimeMarginSlack;
var globalconfig    float                   MinTimeMargin;

/* KickIdler() called if
        if ( (Pawn != None) || (PlayerReplicationInfo.bOnlySpectator && (ViewTarget != self))
            || (WorldInfo.Pauser != None) || WorldInfo.Game.bWaitingToStartMatch || WorldInfo.Game.bGameEnded )
        {
            LastActiveTime = WorldInfo.TimeSeconds;
        }
        else if ( (WorldInfo.Game.MaxIdleTime > 0) && (WorldInfo.TimeSeconds - LastActiveTime > WorldInfo.Game.MaxIdleTime) )
            KickIdler(self);
*/
event KickIdler(PlayerController PC)
{
    LogInternal("Kicking idle player "$PC.PlayerReplicationInfo.GetPlayerAlias());
    AccessControl.KickPlayer(PC, AccessControl.IdleKickReason);
}