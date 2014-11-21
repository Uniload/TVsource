//=====================================================================
// IGoalNotification
//
// A class that implements this interface can be notified of goal
// events
//=====================================================================

interface IGoalNotification;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callback for goal completed

function OnGoalCompleted( bool bAchieved );