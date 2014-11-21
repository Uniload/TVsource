///////////////////////////////////////////////////////////////////////////////
// IHearingNotification.uc - IHearingNotification interface
// this interface is used when we want to be a client of the Hearing notification system
// clients are stored in the HearingNotifier of an AI

interface IHearingNotification;
///////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////
/// IHearingNotification Signature
/////////////////////////////////////////////////

function OnListenerHeardNoise(Pawn Listener, Actor SoundMaker, vector SoundOrigin, Name SoundCategory);

defaultproperties
{
}
