interface IInterestedTeamChanged;

//-------------------------------------------------------------------
// IInterestedTeamChanged:
// 
// This interface should be implemented by those objects that wish
// to be notified whenever a rook changes team. Interested objects can 
// register for such notification via the following methods on Rook: 
//
//   RegisterNotifyTeamChanged(IInterestedTeamChanged ObjectToNotify)
//   UnRegisterNotifyTeamChanged(IInterestedTeamChanged RegisteredObject)
//
// The new team will be set on the pawn when "onTeamChanged" is called.
//-------------------------------------------------------------------

function onTeamChanged( Pawn pawn );

defaultproperties
{
}
