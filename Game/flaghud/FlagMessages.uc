/*******************************************************************************
	Manages FlagHUD data    										      <br />

	(c) 2004, Jeremiah "Byte" Fulbright
	Released under the Open Unreal Mod License
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense

	<!-- $Id: FlagMessages.uc,v1.0 2004/10/17 03:30 jfulbright Exp $ -->
*******************************************************************************/
class FlagMessages extends TribesGUI.HUDMessagePane config(rapher);

var() config HUDMaterial IconMaterial;
var() config int IconWidth;
var() config int IconHeight;

var string PlayerName;
var string EventAction;

var config array<string> FlagHUDClass;

var() config string Separator;

var() config bool bLogEvents; // if we want to output what happens to logfile for parsing
var() config bool bTeamNames; // show team names
var() config bool bSeparators; // show separators
var() config color FriendlyColor, EnemyColor; // Hud colors
var() config color FriendlyDroppedColor, EnemyDroppedColor; //colors for the dropped text
var() config int TrimLength; //shorten nicks
var() config string FieldBegin, FieldEnd; // Dropped - InField Header and Footer
var() config string HomeString; // String to show when Flag is Home

// delegate stubs
delegate OnFlagTaken(string PlayerName, string Team);
delegate OnFlagReturned(string PlayerName, string Team);
delegate OnFlagDropped(string PlayerName, string Team, int TimeCount);
delegate OnFlagCaptured(string PlayerName, string Team);

function GetNewMessages(ClientSideCharacter c)
{
	local int i;
	local string TeamEvent;

    // Don't display any event messages in single player
	if (ClassIsChildOf(c.GameClass, class'SinglePlayerGameInfo'))
		return;

	// add all the messages
	for(i = 0; i < c.EventMessages.Length; ++i)
	{
		IconMaterial.Material = c.EventMessages[i].IconMaterial;
        TeamEvent = MessageStyles[c.EventMessages[i].StringOneType];

        //parse playername - shorten to # letters...
        PlayerName = ColorTrim(c.EventMessages[i].StringOne);
        PlayerName = Left(PlayerName, TrimLength);

        // parse out flag event
        EventAction = LTrim(c.EventMessages[i].StringTwo);

        if(EventAction~="taken")
           OnFlagTaken(PlayerName, TeamEvent);
        else if (EventAction~="captured")
           OnFlagCaptured(PlayerName, TeamEvent);
        else if (EventAction~="returned")
           OnFlagReturned(PlayerName, TeamEvent);
        else if (EventAction~="dropped")
           OnFlagDropped(PlayerName, TeamEvent, c.Countdown);
    }

	// we shouldn't remove them since other windows might need them
    //c.EventMessages.Remove(0, c.EventMessages.Length);
}

// we don't allocate messages from the pool, therefore, nothing to "hide"
// this should kill error messages and keep spam to a min.
function UpdateMessageVisibility()
{
}

static final function string ColorTrim(coerce string S)
{
    S = Right(S, Len(S) - 10);
    S = Left(S, Len(S) - 4);

    return S;
}

static final function string LTrim(coerce string S)
{
    while (Left(S, 1) == " ")
        S = Right(S, Len(S) - 1);
    return S;
}

defaultproperties
{
     IconMaterial=(DrawColor=(B=255,G=255,R=255,A=255),Style=1)
     IconWidth=45
     IconHeight=20
     FlagHUDClass(0)="GameClasses.ModeCTF"
     FlagHUDClass(1)="rapher.LT"
     FlagHUDClass(2)="rapher.ModeCTF"
     friendlyColor=(G=255,A=255)
     enemyColor=(R=255,A=255)
     FriendlyDroppedColor=(G=255,R=255,A=255)
     EnemyDroppedColor=(G=255,R=255,A=255)
     TrimLength=14
     FieldBegin="Dropped:"
     HomeString="Home"
     resFontNames(0)="DefaultSmallFont"
     resFontNames(1)="Tahoma8"
     resFontNames(2)="Tahoma8"
     resFontNames(3)="Tahoma10"
     resFontNames(4)="Tahoma12"
     resFontNames(5)="Tahoma12"
     resFonts(0)=Font'Engine_res.Res_DefaultFont'
     resFonts(1)=Font'TribesFonts.Tahoma8'
     resFonts(2)=Font'TribesFonts.Tahoma8'
     resFonts(3)=Font'TribesFonts.Tahoma10'
     resFonts(4)=Font'TribesFonts.Tahoma12'
     resFonts(5)=Font'TribesFonts.Tahoma12'
}
