//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioProxyHud extends HUD;

var HUD real;

/*
function Reset()
function CheckCountdown(GameReplicationInfo GRI);
function GetLocalStatsScreen();
function DrawHud (Canvas C);
function DrawSpectatingHud (Canvas C);
function bool DrawLevelAction (Canvas C);
function DisplayBadConnectionAlert (Canvas C);
function DisplayPortrait(PlayerReplicationInfo PRI);
function DisplayMessages(Canvas C)
function AddTextMessage(string M, class<LocalMessage> MessageClass, PlayerReplicationInfo PRI)
static function Font LoadFontStatic(int i)
static function font GetConsoleFont(Canvas C)
function Font GetFontSizeIndex(Canvas C, int FontSize)
static function Font GetMediumFontFor(Canvas Canvas)
static function Font LargerFontThan(Font aFont)
*/

/* This function is by necessity copy-pasted and updated from original HUD.. since we 
   need to modify the behaviour */
simulated event PostRender( canvas Canvas )
{
    local float XPos, YPos;
    local plane OldModulate,OM;

	if(PlayerOwner.GetStateName() != 'AttractMode2'){
		real.PostRender(Canvas);
		return;
	}
    real.BuildMOTD();

    OldModulate = Canvas.ColorModulate;

    Canvas.ColorModulate.X = 1;
    Canvas.ColorModulate.Y = 1;
    Canvas.ColorModulate.Z = 1;
    Canvas.ColorModulate.W = HudOpacity/255;

    real.LinkActors();

    real.ResScaleX = Canvas.SizeX / 640.0;
    real.ResScaleY = Canvas.SizeY / 480.0;

	real.CheckCountDown(PlayerOwner.GameReplicationInfo);

	//pawnowner and playerowner are the same for both 'real' and us.. so no change needed
    if ( !PlayerOwner.bBehindView && (PawnOwner != None) )
    {
		if ( PlayerOwner.bDemoOwner || ((Level.NetMode == NM_Client) && (PlayerOwner.Pawn != PawnOwner)) )
			PawnOwner.GetDemoRecordingWeapon();
		else if ( PawnOwner.Weapon != None )
			PawnOwner.Weapon.RenderOverlays(Canvas);
	}
	
	if ( PawnOwner != None && PawnOwner.bSpecialHUD )
		PawnOwner.DrawHud(Canvas);
    if ( real.bShowDebugInfo )
    {
        Canvas.Font = real.GetConsoleFont(Canvas);
        Canvas.Style = ERenderStyle.STY_Alpha;
        Canvas.DrawColor = real.ConsoleColor;

        PlayerOwner.ViewTarget.DisplayDebug (Canvas, XPos, YPos);
    }
	else if( !real.bHideHud )
    {
        if ( real.bShowLocalStats )
        {
			if ( real.LocalStatsScreen == None )
				real.GetLocalStatsScreen();
            if ( real.LocalStatsScreen != None )
            {
            	OM = Canvas.ColorModulate;
                Canvas.ColorModulate = OldModulate;
                real.LocalStatsScreen.DrawScoreboard(Canvas);
				real.DisplayMessages(Canvas);
                Canvas.ColorModulate = OM;
			}
		}
        else if (real.bShowScoreBoard)
        {
            if (real.ScoreBoard != None)
            {
            	OM = Canvas.ColorModulate;
                Canvas.ColorModulate = OldModulate;
                real.ScoreBoard.DrawScoreboard(Canvas);
				if ( real.Scoreboard.bDisplayMessages )
					real.DisplayMessages(Canvas);
                Canvas.ColorModulate = OM;
			}
        }
        else
        {
			if ( (PlayerOwner == None) || (PawnOwner == None) || (PawnOwnerPRI == None) || (PlayerOwner.IsSpectating() && PlayerOwner.bBehindView) )
			{
				//Time for some changes! Well perhaps not really..
            	DrawSpectatingHud(Canvas);
			}
			else if( !PawnOwner.bHideRegularHUD )
				real.DrawHud(Canvas);

            if (!real.DrawLevelAction (Canvas))
            {
            	if (PlayerOwner!=None)
                {
                	if (PlayerOwner.ProgressTimeOut > Level.TimeSeconds)
                    {
	                    real.DisplayProgressMessages (Canvas);
                    }
                    else if (real.MOTDState==1)
                    	real.MOTDState=2;
                }
           }

            if (real.bShowBadConnectionAlert)
                real.DisplayBadConnectionAlert (Canvas);
            real.DisplayMessages(Canvas);

        }

        if( real.bShowVoteMenu && real.VoteMenu!=None )
            real.VoteMenu.RenderOverlays(Canvas);
    }
    else if ( PawnOwner != None )
        real.DrawInstructionGfx(Canvas);


    PlayerOwner.RenderOverlays (Canvas);

    if ((real.PlayerConsole != None) && real.PlayerConsole.bTyping)
        real.DrawTypingPrompt(Canvas, real.PlayerConsole.TypedStr);

    Canvas.ColorModulate=OldModulate;
}

//Overridden as well..
simulated function DrawSpectatingHud (Canvas C)
{
	local string InfoString;
    local plane OldModulate;
    local float xl,yl,Full, Height, Top, TextTop, MedH, SmallH,Scale;
    local GameReplicationInfo GRI;
    
    local HudBDeathMatch breal;

	if (!real.IsA ('HudBDeathMatch')){
		real.DrawSpectatingHud(C);
		return;
	}

	breal = HudBDeathMatch (real);
    breal.DisplayLocalMessages (C);

    OldModulate = C.ColorModulate;

    C.Font = GetMediumFontFor(C);
    C.StrLen("W",xl,MedH);
	Height = MedH;
	C.Font = GetConsoleFont(C);
    C.StrLen("W",xl,SmallH);
    Height += SmallH;

	Full = Height;
    Top  = C.ClipY-8-Full;


	scale = (Full+16)/128;
/*
	// I like Yellow

    C.ColorModulate.X=255;
    C.ColorModulate.Y=255;
    C.ColorModulate.Z=0;
    C.ColorModulate.W=255;

	// Draw Border

	C.SetPos(0,Top);
    C.SetDrawColor(255,255,255,255);
    C.DrawTileStretched(material'InterfaceContent.SquareBoxA',C.ClipX,Full);
    C.ColorModulate.Z=255;

    TextTop = Top + 4;
    GRI = PlayerOwner.GameReplicationInfo;

    C.SetPos(0,Top-8);
    C.Style=5;
    C.DrawTile(material'LMSLogoSmall',256*Scale,128*Scale,0,0,256,128);
    C.Style=1;
*/

/*
    C.Font = GetConsoleFont(C);
    C.StrLen(GRI.GameName,XL,YL);
    C.SetPos( (C.ClipX/2) - (XL/2), 10);
    C.SetDrawColor(255,255,255,255);
    C.ColorModulate.Z = 255;
    C.DrawText(GRI.GameName);
*/

//Following not needed since spectators dont win or lose games
/*	if ( UnrealPlayer(Owner).bDisplayWinner ||  UnrealPlayer(Owner).bDisplayLoser )
	{
		if ( UnrealPlayer(Owner).bDisplayWinner )
			InfoString = YouveWonTheMatch;
		else
		{
			if ( PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner) != None )
				InfoString = WonMatchPrefix$PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner).PlayerName$WonMatchPostFix;
			else
				InfoString = YouveLostTheMatch;
		}

        C.SetDrawColor(255,255,255,255);
        C.Font = GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);
    } 

	else*/ 
	
	/*
	if ( Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None )
    {
    	// Draw View Target info

		C.SetDrawColor(32,255,32,255);

        // Draw "Now Viewing"

		C.SetPos((256*Scale*0.75),TextTop);
        C.DrawText(breal.NowViewing,false);

    	// Draw "Score"

        InfoString = breal.GetScoreText();
        C.StrLen(InfoString,Xl,Yl);
        C.SetPos(C.ClipX-5-XL,TextTop);
        C.DrawText(InfoString);

        // Draw Player Name

        C.SetDrawColor(255,255,0,255);
        C.Font = GetMediumFontFor(C);
        C.SetPos((256*Scale*0.75),TextTop+SmallH);
        C.DrawText(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName,false);

        // Draw Score

	    InfoString = breal.GetScoreValue(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);
	    C.StrLen(InfoString,xl,yl);
	    C.SetPos(C.ClipX-5-XL,TextTop+SmallH);
	    C.DrawText(InfoString,false);

        // Draw Tag Line

	    C.Font = breal.GetConsoleFont(C);
	    InfoString = breal.GetScoreTagLine();
	    C.StrLen(InfoString,xl,yl);
	    C.SetPos( (C.ClipX/2) - (XL/2),Top-3-YL);
	    C.DrawText(InfoString);
    }
    else
    {
	    if ( PlayerOwner.IsDead() )
	    {
	        if ( PlayerOwner.PlayerReplicationInfo.bOutOfLives )
	            InfoString = class'ScoreboardDeathMatch'.default.OutFireText;
	        else
	            InfoString = class'ScoreboardDeathMatch'.default.Restart;
	    }
	    else if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	        InfoString = breal.WaitingToSpawn;
        else
		 	InfoString = breal.InitialViewingString;

    	// Draw

    	C.SetDrawColor(255,255,255,255);
        C.Font = breal.GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);

    }
	*/
	
    C.ColorModulate = OldModulate;

	if (real.isa ('HudBTeamDeathMatch')) {
/*		if ( (PlayerOwner == None) || (PlayerOwner.PlayerReplicationInfo == None)
			|| !PlayerOwner.PlayerReplicationInfo.bOnlySpectator)
			return; */

		HudBTeamDeathMatch(real).UpdateRankAndSpread(C);
		HudBTeamDeathMatch(real).ShowTeamScorePassA(C);
		HudBTeamDeathMatch(real).ShowTeamScorePassC(C);
		HudBTeamDeathMatch(real).UpdateTeamHUD();	
	}
}

/* 
 * And now for the passthrough calls 
 */

simulated function BuildMOTD()
{
	real.buildmotd();
}

simulated event PostBeginPlay()
{
//dont have real here?
	if(real!=none)
		real.postbeginplay ();
}

simulated function CreateKeyMenus()
{
	real.createkeymenus ();
}

simulated event Destroyed()
{
	real.destroyed ();
}

exec function ShowScores()
{
	real.showscores ();
}

exec function ShowStats()
{
	real.showstats ();
}

exec function NextStats()
{
	real.nextstats ();
}

exec function ShowDebug()
{
	real.showdebug ();
}

simulated event WorldSpaceOverlays()
{
	real.worldspaceoverlays ();
}

event ConnectFailure(string FailCode, string URL)
{
	real.connectfailure (failcode, url);
}

/*simulated event PostRender( canvas Canvas )
{
	real.postrender (canvas);
	
	Canvas.SetPos(0,0);
	Canvas.SetDrawColor (255, 255, 255, 255);		
	Canvas.DrawIcon(texture'tviOptWatermark', 1);	
} */

simulated function DrawInstructionGfx( Canvas C )
{
	real.drawinstructiongfx (c);
}

simulated function SetInstructionText( string text )
{
	real.setinstructiontext (text);
}

simulated function SetInstructionKeyText( string text )
{
	real.setinstructionkeytext (text);
}

simulated function DrawRoute()
{
	real.drawroute ();
}

simulated function DisplayProgressMessages (Canvas C)
{
	real.displayprogressmessages (c);
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
	real.localizedmessage (message, switch, relatedpri_1, relatedpri_2, optionalobject, criticalstring);
}

simulated function DrawTypingPrompt (Canvas C, String Text, optional int Pos)
{
	real.drawtypingprompt (c, text,Pos);
}

simulated function SetScoreBoardClass (class<Scoreboard> ScoreBoardClass)
{
	real.setscoreboardclass (scoreboardclass);
}

exec function ShowHud()
{
	real.showhud ();
}

simulated function LinkActors()
{
	real.linkactors ();
}

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	real.message (pri, msg, msgtype);
}

exec function GrowHUD()
{
	real.growhud ();
}

exec function ShrinkHUD()
{
	real.shrinkhud ();
}

simulated function SetTargeting( bool bShow, optional Vector TargetLocation, optional float Size )
{
	real.settargeting (bshow, targetlocation, size);
}

simulated function DrawCrosshair(Canvas C)
{
	real.drawcrosshair (c);
}

simulated function SetCropping( bool Active )
{
	real.setcropping (active);
}

simulated function Font LoadFont(int i)
{
	return real.loadfont (i);
}

simulated function font LoadProgressFont()
{
	return loadprogressfont ();
}

simulated function DrawTargeting( Canvas C )
{
	real.drawtargeting (c);
}

DefaultProperties
{

}
