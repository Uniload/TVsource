//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
	native
	config(user)
	transient;

//=============================================================================
// Variables.

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;            // Largest system font.

var string HUDConfigWindowType;
var HUD nextHUD;	// list of huds which render to the canvas
var PlayerController PlayerOwner; // always the actual owner

var localized string ProgressFontName;
var Font ProgressFontFont;
var float ProgressFadeTime;
var Color MOTDColor;

var ScoreBoard Scoreboard;
var bool bHideHUD;
var bool	bShowScores;
var bool	bShowDebugInfo;				// if true, show properties of current ViewTarget
var bool	bHideCenterMessages;		// don't draw centered messages (screen center being used)
var bool    bBadConnectionAlert;	// display warning about bad connection
var config bool bMessageBeep;

var globalconfig float HudCanvasScale;    // Specifies amount of screen-space to use (for TV's).

var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;

var Color ConsoleColor;
var globalconfig int ConsoleMessageCount;
var globalconfig int ConsoleFontSize;
var globalconfig int MessageFontOffset;

#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var Core.Object Related1;
	var Core.Object Related2;
	var Core.Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

#else
struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Core.Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};
#endif

struct native ConsoleMessage
{
	var string Text;
	var color TextColor;
	var float MessageLife;
	var PlayerReplicationInfo PRI;
};
var ConsoleMessage TextMessages[8];

var() float ConsoleMessagePosX, ConsoleMessagePosY; // DP_LowerLeft

var localized string FontArrayNames[9];
var Font FontArrayFonts[9];
var int FontScreenWidthMedium[9];
var int FontScreenWidthSmall[9];

/* Draw3DLine()
draw line in world space. Should be used when engine calls RenderWorldOverlays() event.
*/
native final function Draw3DLine(vector Start, vector End, color LineColor);

#if IG_SHARED // ckline: more utility methods to draw primitives on the HUD

// Draw a circle aligned with the specified plane. Default value for NumSides is 16.
native final function Draw3DCircle(Vector Origin, Vector PlaneXAxis, Vector PlaneYAxis, 
                                   float Radius, 
                                   Color Color, optional int NumSides);

// Draw a cylinder centered at Base, whose height, width, and depth are aligned with the given 
// Z, Y, and X vectors (respectively). The width and depth are specified in the Radius parameter, 
// and the height will be twice the value of HalfHeight (extends HalfHeight in both directions from Base).
// Default value for NumSides is 16.
native final function Draw3DCylinder(Vector Base, Vector X, Vector Y, Vector Z, 
                                     float Radius, float HalfHeight, 
                                     Color Color, optional int NumSides);

// Draw a cone that starts from the specified Origin along the axis specified by Direction,
// ending after the given Length. HalfAngle is the angle (in DEGREES) between the cone axis 
// and one edge of the cone. NumSides will be clamped to be at least 6 and no more than 40; 
// the default value is 12.
native final function Draw3DCone(Vector Origin, Vector Direction, 
                                 float Length, float HalfAngle, 
                                 Color Color, optional int NumSides);

#endif // IG_SHARED

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerOwner = PlayerController(Owner);

#if IG_SHARED // karl:
	SmallFont=Font(DynamicLoadObject("Engine_res.SmallFont", class'Font'));
	MedFont=Font(DynamicLoadObject("Engine_res.MediumFont", class'Font'));
	BigFont=Font(DynamicLoadObject("Engine_res.MediumFont", class'Font'));
	LargeFont=Font(DynamicLoadObject("Engine_res.MediumFont", class'Font'));
#endif
}

function SpawnScoreBoard(class<Scoreboard> ScoringType)
{
	if ( ScoringType != None )
		Scoreboard = Spawn(ScoringType, PlayerOwner);
}

simulated event Destroyed()
{
    if( ScoreBoard != None )
    {
        ScoreBoard.Destroy();
        ScoreBoard = None;
    }
	Super.Destroyed();
}


//=============================================================================
// Execs

/* toggles displaying scoreboard
*/
exec function ShowScores()
{
	bShowScores = !bShowScores;
}

/* toggles displaying properties of player's current viewtarget
*/
exec function ShowDebug()
{
	bShowDebugInfo = !bShowDebugInfo;
}

simulated event WorldSpaceOverlays()
{
    if ( bShowDebugInfo && Pawn(PlayerOwner.ViewTarget) != None )
        DrawRoute();
}

function CheckCountdown(GameReplicationInfo GRI);

event ConnectFailure(string FailCode, string URL)
{
	PlayerOwner.ReceiveLocalizedMessage(class'FailedConnect', class'FailedConnect'.Static.GetFailSwitch(FailCode));
}
#if !IG_TRIBES3 // dbeswick: not even used in UT2003
/* ShowUpgradeMenu()
Event called when the engine version is less than the MinNetVer of the server you are trying
to connect with.  
*/ 
event ShowUpgradeMenu();
#endif

function PlayStartupMessage(byte Stage);

//=============================================================================
// Message manipulation

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos
	M.Related1 = None;
	M.Related2 = None;
#else
	M.RelatedPRI = None;
#endif
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos
	M1.Related1 = M2.Related1;
	M1.Related2 = M2.Related2;
#else
	M1.RelatedPRI = M2.RelatedPRI;
#endif
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// Status drawing.


simulated event PostRender( canvas Canvas )
{
	local float XPos,YPos;
	local Pawn P;

	CheckCountDown(PlayerOwner.GameReplicationInfo);

	P = Pawn(PlayerOwner.ViewTarget);

#if !IG_TRIBES3	// david:
	if ( !PlayerOwner.bBehindView )
	{
		if ( (P != None) && (P.Weapon != None) )
			P.Weapon.RenderOverlays(Canvas);
	}
#endif

//FIXMEJOE
/*
	if ( PlayerConsole.bNoDrawWorld )
	{
		Canvas.SetPos(0,0);
		Canvas.DrawPattern( Texture'Border', Canvas.ClipX, Canvas.ClipY, 1.0 );
	}
*/	
	DisplayMessages(Canvas);

	bHideCenterMessages = DrawLevelAction(Canvas);

	if ( !bHideCenterMessages && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) )
		DisplayProgressMessage(Canvas);

	if ( bBadConnectionAlert )
		DisplayBadConnectionAlert();

	if ( P != None && P.bSpecialHUD )
		P.DrawHud(Canvas);

    if ( bShowDebugInfo )
    {
        Canvas.Font = GetConsoleFont(Canvas);
        Canvas.Style = ERenderStyle.STY_Alpha;
        Canvas.DrawColor = ConsoleColor;

        PlayerOwner.ViewTarget.DisplayDebug (Canvas, XPos, YPos);
    }
	else if( !bHideHud )
    {
        if ( bShowScores )
        {
            if (ScoreBoard != None)
            {
                ScoreBoard.DrawScoreboard(Canvas);
				if ( Scoreboard.bDisplayMessages )
					DisplayMessages(Canvas);
			}
        }
        else
        {
#if IG_TRIBES3 // david: we make another hud instead of using DrawSpectatingHUD
            if ( (PlayerOwner == None) || (P == None) || (P.PlayerReplicationInfo == None) || PlayerOwner.IsSpectating() )
                DrawHud(Canvas);
            else if( !P.bHideRegularHUD )
                DrawHud(Canvas);
#else
            if ( (PlayerOwner == None) || (P == None) || (P.PlayerReplicationInfo == None) || PlayerOwner.IsSpectating() )
                DrawSpectatingHud(Canvas);
            else if( !P.bHideRegularHUD )
                DrawHud(Canvas);
#endif

            if ( !DrawLevelAction(Canvas) )
            {
                if ((PlayerOwner != None) && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds))
                    DisplayProgressMessage(Canvas);
            }

            DisplayMessages(Canvas);
        }
    }

    PlayerOwner.RenderOverlays (Canvas);
/*FIXME_MERGE
    if ((PlayerConsole != None) && PlayerConsole.bTyping)
        DrawTypingPrompt(Canvas, PlayerConsole.TypedStr);
        */
}

#if !IG_TRIBES3 // david: we make another hud instead of using DrawSpectatingHUD
function DrawSpectatingHud (Canvas C);
#endif

simulated function DrawRoute()
{
	local Controller C;
	local vector Start, RealStart;

	C = Pawn(PlayerOwner.ViewTarget).Controller;
	if ( C == None )
		return;
#if !IG_TRIBES3	//rowan: not using this
	if ( C.CurrentPath != None )
		Start = C.CurrentPath.Start.Location;
	else
#endif
		Start = PlayerOwner.ViewTarget.Location;
	RealStart = Start;

#if !IG_TRIBES3	//rowan: not using this
	if ( C.bAdjusting )
	{
		Draw3DLine(C.Pawn.Location, C.AdjustLoc, class'Canvas'.Static.MakeColor(255,0,255));
		Start = C.AdjustLoc;
	}

	// show where pawn is going
	if ( (C == PlayerOwner)
		|| (C.MoveTarget == C.RouteCache[0]) && (C.MoveTarget != None) )
	{
		if ( (C == PlayerOwner) && (C.Destination != vect(0,0,0)) )
		{
			if ( C.PointReachable(C.Destination) )
			{
				Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}
			C.FindPathTo(C.Destination);
		}
		for ( i=0; i<16; i++ )
		{
			if ( C.RouteCache[i] == None )
				break;
			bPath = true;
			Draw3DLine(Start,C.RouteCache[i].Location,class'Canvas'.Static.MakeColor(0,255,0));
			Start = C.RouteCache[i].Location;
		}
		if ( bPath )
			Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));
	}
	else if ( PlayerOwner.ViewTarget.Velocity != vect(0,0,0) )
		Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));

	if ( C == PlayerOwner )
		return;

	// show where pawn is looking
	if ( C.Focus != None )
		End = C.Focus.Location;
	else
		End = C.FocalPoint;
	Draw3DLine(PlayerOwner.ViewTarget.Location + Pawn(PlayerOwner.ViewTarget).BaseEyeHeight * vect(0,0,1),End,class'Canvas'.Static.MakeColor(255,0,0));
#endif
}

/* DrawHUD() Draw HUD elements on canvas.
*/
function DrawHUD(canvas Canvas);

/*  Print a centered level action message with a drop shadow.
*/
function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;

	if ( Len(BigMessage) > 10 )
		UseLargeFont(C);
	else
		UseHugeFont(C);
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(0.5 * (C.ClipX - XL) + 1, 0.66 * C.ClipY - YL * 0.5 + 1);
	C.SetDrawColor(0,0,0);
	C.DrawText( BigMessage, false );
	C.SetPos(0.5 * (C.ClipX - XL), 0.66 * C.ClipY - YL * 0.5);
	C.SetDrawColor(0,0,255);;
	C.DrawText( BigMessage, false );
}

/* Display Progress Messages
display progress messages in center of screen
*/
simulated function DisplayProgressMessage(Canvas C)
{
    local int i, LineCount;
    local GameReplicationInfo GRI;
    local float FontDX, FontDY;
    local float X, Y;
    local int Alpha;
    local float TimeLeft;

    TimeLeft = PlayerOwner.ProgressTimeOut - Level.TimeSeconds;

    if( TimeLeft >= ProgressFadeTime )
        Alpha = 255;
    else
        Alpha = (255 * TimeLeft) / ProgressFadeTime;

    GRI = PlayerOwner.GameReplicationInfo;

    LineCount = 0;

    for (i = 0; i < ArrayCount (PlayerOwner.ProgressMessage); i++)
    {
        if (PlayerOwner.ProgressMessage[i] == "")
            continue;

        LineCount++;
    }

    if (GRI != None)
    {
        if( GRI.MOTDLine1 != "" ) LineCount++;
        if( GRI.MOTDLine2 != "" ) LineCount++;
        if( GRI.MOTDLine3 != "" ) LineCount++;
        if( GRI.MOTDLine4 != "" ) LineCount++;
    }

    C.Font = LoadProgressFont();

    C.Style = ERenderStyle.STY_Alpha;

    C.TextSize ("A", FontDX, FontDY);

    X = (0.5 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
    Y = (0.5 * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);

    Y -= FontDY * (float (LineCount) / 2.0);

    for (i = 0; i < ArrayCount (PlayerOwner.ProgressMessage); i++)
    {
        if (PlayerOwner.ProgressMessage[i] == "")
            continue;

        C.DrawColor = PlayerOwner.ProgressColor[i];
        C.DrawColor.A = Alpha;

        C.TextSize (PlayerOwner.ProgressMessage[i], FontDX, FontDY);
        C.SetPos (X - (FontDX / 2.0), Y);
        C.DrawText (PlayerOwner.ProgressMessage[i]);

        Y += FontDY;
    }

    if( (GRI != None) && (Level.NetMode != NM_StandAlone) )
    {
        C.DrawColor = MOTDColor;
        C.DrawColor.A = Alpha;

        if( GRI.MOTDLine1 != "" )
        {
            C.TextSize (GRI.MOTDLine1, FontDX, FontDY);
            C.SetPos (X - (FontDX / 2.0), Y);
            C.DrawText (GRI.MOTDLine1);
            Y += FontDY;
        }

        if( GRI.MOTDLine2 != "" )
        {
            C.TextSize (GRI.MOTDLine2, FontDX, FontDY);
            C.SetPos (X - (FontDX / 2.0), Y);
            C.DrawText (GRI.MOTDLine2);
            Y += FontDY;
        }

        if( GRI.MOTDLine3 != "" )
        {
            C.TextSize (GRI.MOTDLine3, FontDX, FontDY);
            C.SetPos (X - (FontDX / 2.0), Y);
            C.DrawText (GRI.MOTDLine3);
            Y += FontDY;
        }

        if( GRI.MOTDLine4 != "" )
        {
            C.TextSize (GRI.MOTDLine4, FontDX, FontDY);
            C.SetPos (X - (FontDX / 2.0), Y);
            C.DrawText (GRI.MOTDLine4);
            Y += FontDY;
        }
    }
}


/* Draw the Level Action
*/
function bool DrawLevelAction( canvas C )
{
	local string BigMessage;

	if (Level.LevelAction == LEVACT_None )
	{
		if ( (Level.Pauser != None) && (Level.TimeSeconds > Level.PauseDelay + 0.2) )
			BigMessage = PausedMessage; // Add pauser name?
		else
		{
			BigMessage = "";
			return false;
		}
	}
	else if ( Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;
	
	if ( BigMessage != "" )
	{
		C.Style = ERenderStyle.STY_Normal;
		UseLargeFont(C);	
		PrintActionMessage(C, BigMessage);
		return true;
	}
	return false;
}

/* DisplayBadConnectionAlert()
Warn user that net connection is bad
*/
function DisplayBadConnectionAlert();
//=============================================================================
// Messaging.

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
	if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
		Msg = PRI.PlayerName$": "$Msg;
	AddTextMessage(Msg,class'LocalMessage',PRI);
}

function DisplayPortrait(PlayerReplicationInfo PRI);

#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Core.Object OptionalObject, optional string CriticalString, optional string OptionalString );
#else
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Core.Object OptionalObject, optional string CriticalString );
#endif

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerOwner.ClientMessage(S);
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
}

function bool ProcessKeyEvent( int Key, int Action, FLOAT Delta )
{
	if ( NextHud != None )
		return NextHud.ProcessKeyEvent(Key,Action,Delta);
	return false;
}

/* DisplayMessages() - display current messages
*/
function DisplayMessages(Canvas C)
{
    local int i, j, XPos, YPos,MessageCount;
    local float XL, YL;

    for( i = 0; i < ConsoleMessageCount; i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;
        else if( TextMessages[i].MessageLife < Level.TimeSeconds )
        {
            TextMessages[i].Text = "";

            if( i < ConsoleMessageCount - 1 )
            {
                for( j=i; j<ConsoleMessageCount-1; j++ )
                    TextMessages[j] = TextMessages[j+1];
            }
            TextMessages[j].Text = "";
            break;
        }
        else
			MessageCount++;
    }

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);

    C.Font = GetConsoleFont(C);
    C.DrawColor = ConsoleColor;

    C.TextSize ("A", XL, YL);

    YPos -= YL * MessageCount+1; // DP_LowerLeft
    YPos -= YL; // Room for typing prompt

    for( i=0; i<MessageCount; i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;

        C.StrLen( TextMessages[i].Text, XL, YL );
        C.SetPos( XPos, YPos );
        C.DrawColor = TextMessages[i].TextColor;
        C.DrawText( TextMessages[i].Text, false );
        YPos += YL;
    }
}

function AddTextMessage(string M, class<LocalMessage> MessageClass, PlayerReplicationInfo PRI)
{
	local int i;


	if( bMessageBeep && MessageClass.Default.bBeep )
		PlayerOwner.PlayBeepSound();

    for( i=0; i<ConsoleMessageCount; i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;
    }

    if( i == ConsoleMessageCount )
    {
        for( i=0; i<ConsoleMessageCount-1; i++ )
            TextMessages[i] = TextMessages[i+1];
    }

    TextMessages[i].Text = M;
    TextMessages[i].MessageLife = Level.TimeSeconds + MessageClass.Default.LifeTime;
    TextMessages[i].TextColor = MessageClass.static.GetConsoleColor(PRI);
    TextMessages[i].PRI = PRI;
}

//=============================================================================
// Font Selection.

function UseSmallFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = SmallFont;
	else
		Canvas.Font = MedFont;
}

function UseMediumFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = MedFont;
	else
		Canvas.Font = BigFont;
}

function UseLargeFont(Canvas Canvas)
{
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = BigFont;
	else
		Canvas.Font = LargeFont;
}

function UseHugeFont(Canvas Canvas)
{
	Canvas.Font = LargeFont;
}

static function Font LoadFontStatic(int i)
{
	if( default.FontArrayFonts[i] == None )
	{
		default.FontArrayFonts[i] = Font(DynamicLoadObject(default.FontArrayNames[i], class'Font'));
		if( default.FontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.FontArrayNames[i]);
	}

	return default.FontArrayFonts[i];
}

simulated function Font LoadFont(int i)
{
	if( FontArrayFonts[i] == None )
	{
		FontArrayFonts[i] = Font(DynamicLoadObject(FontArrayNames[i], class'Font'));
		if( FontArrayFonts[i] == None )
			Log("Warning: "$Self$" Couldn't dynamically load font "$FontArrayNames[i]);
	}
	return FontArrayFonts[i];
}


static function font GetConsoleFont(Canvas C)
{
	local int FontSize;

	FontSize = Default.ConsoleFontSize;
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	return LoadFontStatic(Min(8,FontSize));
}

static function Font GetMediumFontFor(Canvas Canvas)
{
	local int i;

	for ( i=0; i<8; i++ )
	{
		if ( Default.FontScreenWidthMedium[i] <= Canvas.ClipX )
			return LoadFontStatic(i);
	}
	return LoadFontStatic(8);
}

static function Font LargerFontThan(Font aFont)
{
	local int i;

	for ( i=0; i<7; i++ )
		if ( LoadFontStatic(i) == aFont )
			return LoadFontStatic(Max(0,i-4));
	return LoadFontStatic(5);
}

simulated function font LoadProgressFont()
{
	if( ProgressFontFont == None )
	{
		ProgressFontFont = Font(DynamicLoadObject(ProgressFontName, class'Font'));
		if( ProgressFontFont == None )
		{
			Log("Warning: "$Self$" Couldn't dynamically load font "$ProgressFontName);
			ProgressFontFont = SmallFont;
		}
	}
	return ProgressFontFont;
}

#if !IG_SHARED // ckline: this doesn't seem to be called by anything
simulated function DrawTargeting( Canvas C );
#endif

#if IG_SWAT //tcohen: declarations of debugLine support, implemented in SwatHUD
function int AddDebugLine(vector EndA, vector EndB, color Color, optional float Lifespan);
function RemoveDebugLine(int Index);
#endif

defaultproperties
{
     ProgressFontName="Engine_res.Res_DefaultFont"
     ProgressFadeTime=1.000000
     MOTDColor=(B=255,G=255,R=255,A=255)
     bMessageBeep=True
     HudCanvasScale=0.950000
     LoadingMessage="LOADING"
     SavingMessage="SAVING"
     ConnectingMessage="CONNECTING"
     PausedMessage="PAUSED"
     ConsoleColor=(B=253,G=216,R=153,A=255)
     ConsoleMessageCount=6
     ConsoleFontSize=5
     FontArrayNames(0)="Engine_res.Res_DefaultFont"
     FontArrayNames(1)="Engine_res.Res_DefaultFont"
     FontArrayNames(2)="Engine_res.Res_DefaultFont"
     FontArrayNames(3)="Engine_res.Res_DefaultFont"
     FontArrayNames(4)="Engine_res.Res_DefaultFont"
     FontArrayNames(5)="Engine_res.Res_DefaultFont"
     FontArrayNames(6)="Engine_res.Res_DefaultFont"
     FontArrayNames(7)="Engine_res.Res_DefaultFont"
     FontArrayNames(8)="Engine_res.Res_DefaultFont"
     bHidden=True
     RemoteRole=ROLE_None
}
