class TribesLocalMessage extends Engine.LocalMessage;

struct announcement
{
	var() name				effectEvent;
	var() name				speechTag;
	var() localized string	debugString;
};

var(Messages) array<announcement>	announcements;

// Expects:
// Related1 - TeamInfo that is the subject of this message

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString 
	)
{
	// Don't manually display any string.  It'll get displayed by the dynamic speech system
	return "";

	//if(Switch >= default.announcements.Length || TeamInfo(Related1) == None)
	//	return "";
	//Log("Announcement: "$replaceStr(default.announcements[Switch].debugString, TeamInfo(Related1).localizedName));
	//return replaceStr(default.announcements[Switch].debugString, TeamInfo(Related1).localizedName);
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString
	)
{
	local TeamInfo t;

	// from base code
    if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
		P.Player.InteractionMaster.Process_Message( Static.GetString( Switch, Related1, Related2, OptionalObject, OptionalString ), 6.0, P.Player.LocalInteractions);

	if(Switch >= default.announcements.Length)
	{
		PlayerCharacterController(P).lowPriorityPromptText = GetString(Switch);
		PlayerCharacterController(P).lowPriorityPromptTimeout = 3;
		return;
	}

	t = TeamInfo(Related1);

	if (default.announcements[Switch].effectEvent != '')
		P.TriggerEffectEvent(default.announcements[Switch].effectEvent);

	if (default.announcements[Switch].speechTag != '')
		P.Level.speechManager.PlayAnnouncerSpeech(default.announcements[Switch].speechTag,, t );
}

defaultproperties
{
     bFadeMessage=True
     bCenter=True
     lifetime=8
     DrawColor=(B=0,G=0)
}
