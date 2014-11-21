class GameMessage extends LocalMessage;

var localized string	      SwitchLevelMessage;
var localized string	      LeftMessage;
var localized string	      FailedTeamMessage;
var localized string	      FailedPlaceMessage;
var localized string	      FailedSpawnMessage;
var localized string	      EnteredMessage;
var	localized string	      MaxedOutMessage;
var localized string OvertimeMessage;
var localized string GlobalNameChange;
var localized string NewTeamMessage;
var localized string NewTeamMessageTrailer;
var localized string	NoNameChange;
var localized string VoteStarted;
var localized string VotePassed;
var localized string MustHaveStats;

var localized string NewPlayerMessage;

//
// Messages common to GameInfo derivatives.
//
#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	)
{
	local PlayerReplicationInfo PRI1;

	PRI1 = PlayerReplicationInfo(Related1);

	switch (Switch)
	{
		case 0:
			return Default.OvertimeMessage;
			break;
		case 1:
			if (Related1 == None)
                return Default.NewPlayerMessage;

			return PRI1.PlayerName$Default.EnteredMessage;
			break;
		case 2:
			if (Related1 == None)
				return "";

			return PRI1.OldName@Default.GlobalNameChange@PRI1.PlayerName;
			break;
		case 3:
			if (Related1 == None)
				return "";
			if (OptionalObject == None)
				return "";

            return PRI1.PlayerName@Default.NewTeamMessage$Default.NewTeamMessageTrailer;
			break;
		case 4:
			if (Related1 == None)
				return "";

			return PRI1.PlayerName$Default.LeftMessage;
			break;
		case 5:
			return Default.SwitchLevelMessage;
			break;
		case 6:
			return Default.FailedTeamMessage;
			break;
		case 7:
			return Default.MaxedOutMessage;
			break;
		case 8:
			return Default.NoNameChange;
			break;
        case 9:
            return PRI1.PlayerName@Default.VoteStarted;
            break;
        case 10:
            return Default.VotePassed;
            break;
        case 11:
			return Default.MustHaveStats;
			break;
	}
	return "";
}

#else
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Core.Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.OvertimeMessage;
			break;
		case 1:
			if (RelatedPRI_1 == None)
                return Default.NewPlayerMessage;

			return RelatedPRI_1.PlayerName$Default.EnteredMessage;
			break;
		case 2:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.PlayerName;
			break;
		case 3:
			if (RelatedPRI_1 == None)
				return "";
			if (OptionalObject == None)
				return "";

            return RelatedPRI_1.PlayerName@Default.NewTeamMessage@TeamInfo(OptionalObject).GetHumanReadableName()$Default.NewTeamMessageTrailer;
			break;
		case 4:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName$Default.LeftMessage;
			break;
		case 5:
			return Default.SwitchLevelMessage;
			break;
		case 6:
			return Default.FailedTeamMessage;
			break;
		case 7:
			return Default.MaxedOutMessage;
			break;
		case 8:
			return Default.NoNameChange;
			break;
        case 9:
            return RelatedPRI_1.PlayerName@Default.VoteStarted;
            break;
        case 10:
            return Default.VotePassed;
            break;
        case 11:
			return Default.MustHaveStats;
			break;
	}
	return "";
}
#endif

defaultproperties
{
     SwitchLevelMessage="Switching Levels"
     LeftMessage=" left the game."
     FailedTeamMessage="Could not find team for player"
     FailedPlaceMessage="Could not find a starting spot"
     FailedSpawnMessage="Could not spawn player"
     EnteredMessage=" entered the game."
     MaxedOutMessage="Server is already at capacity."
     OvertimeMessage="Score tied at the end of regulation. Sudden Death Overtime!!!"
     GlobalNameChange="changed name to"
     NewTeamMessage="is now on"
     NoNameChange="Name is already in use."
     VoteStarted="started a vote."
     VotePassed="Vote passed."
     MustHaveStats="Must have stats enabled to join this server."
     NewPlayerMessage="A new player entered the game."
     bIsSpecial=False
}
