//-----------------------------------------------------------
// This class adds permanent information to the screen
// when TribesTVStudiotudio is active. It could perhaps be in a HUD
// subclass, but since it's meant to extend the hud rather
// than replace it it's here instead!
//-----------------------------------------------------------
class TribesTVStudioHudAugmentation extends Interaction;

var float YPos;

var TribesTVStudioTestController tvc;
var bool showWatermark;

var bool shownWelcome;
var float WelcomeWidth;
var float WelcomeMargin;
var float WelcomePos;
var int WelcomeLen;
var string WelcomeMsg[5];

function setControllerOwner (TribesTVStudioTestController t)
{
	tvc = t;
}

function PostRender( canvas Canvas )
{
	local float XL, YL;
	local string CurPlayer;
	local HudBDeathmatch hud;
	
	//    local xPawn pawn;
	//    local vector pos;
	
	if (tvc.GetStateName () != 'AttractMode2'){
		return;
	}
	
	hud = HudBDeathMatch(TribesTVStudioProxyHud(tvc.myhud).real);
	
		
	if ((tvc.GetCamTargetName () != "") && (tvc.camSysMode != 9)) {
		if(hud==None)
			CurPlayer = tvc.getCamTargetName ();
		else
			CurPlayer = hud.NowViewing $ " " $ tvc.getCamTargetName ();

		Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.
		Canvas.TextSize("10-", XL, YL);
		Canvas.SetDrawColor(255,255,128,255);
		Canvas.SetPos(Canvas.ClipX*0.5, (Canvas.ClipY) - (1.3*YL));
		Canvas.DrawText(CurPlayer);




/*
    Canvas.Font = hud.GetMediumFontFor(Canvas);	
    	    
		CurPlayer = hud.NowViewing $ " " $ tvc.getCamTargetName ();
//		Canvas.StrLen("W",XL,YL);
//		Canvas.Style = hud.ERenderStyle.STY_Alpha;
		Canvas.DrawColor = hud.GoldColor;
		Canvas.SetPos(0.1*Canvas.ClipX, Canvas.ClipY *0.9);
//		Canvas.SetPos(0.5*(Canvas.ClipX-XL), Canvas.ClipY - 2*YL);
		Canvas.DrawText(CurPlayer, true);
*/	}
	
	if(showWatermark){
		Canvas.SetPos(Canvas.ClipX-tvc.watermark.USize,Canvas.ClipY-tvc.watermark.VSize);
		Canvas.SetDrawColor (255, 255, 255, 128);		
		Canvas.Style = tvc.ERenderStyle.STY_Alpha;		
		Canvas.DrawIcon(tvc.watermark, 1);
	}

	if (!shownWelcome) {
		DrawWelcome (canvas);
	}
}

function DrawWelcome (Canvas canvas)
{
	DrawWelcomeText (canvas);
}

function DrawTextBox (Canvas canvas, string text, bool sizing, float X, out float Y, float XW)
{
	local float LineSpace;
	local float WordSpace;
	local string cur;
	local float xl, yl;
	local int i;
	local float curx;
	
	Canvas.TextSize("A", XL, YL);
	LineSpace = (YL * 1.1) / Canvas.ClipY;
	Canvas.TextSize(" ", XL, YL);
	WordSpace = XL * 1.1;

	curx = 0;

	while (len (text) > 0) {
		i = InStr (text, " ");
		if (i == -1) {
			cur = text;
			text = "";
		} else {
			cur = Mid (text, 0, i);
			text = Mid (text, i + 1);
		}

		Canvas.TextSize (cur, xl, yl);
		if (curx + xl > xw * Canvas.ClipX) {
			Y+=LineSpace;
			Curx = 0;
		} 
		
		if (!sizing) {
			Canvas.SetPos ((Canvas.ClipX * x) + curx, Canvas.ClipY * y);
			Canvas.DrawText (cur, false);
		}
		
		curx += xl + wordspace;
	}
	Y+=LineSpace;
}

function DrawWelcomeText (Canvas canvas)
{
	local float x, y, xw, yw;
	local int i;

	Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.
		
	yw = 0;
	xw = WelcomeWidth - WelcomeMargin*2;
	
	//Check sizing
	for (i = 0; i < WelcomeLen; ++i) {
		DrawTextBox (canvas, WelcomeMsg[i], true, 0, yw, xw);
	}

	//Now draw it
	x = (1 - WelcomeWidth) / 2;
	y = ((1 - yw) / 2) - 0.1;		//kind of looks better with - 0.1
		
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.ClipX * x, Canvas.ClipY * y);
	Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', Canvas.ClipX * WelcomeWidth, Canvas.ClipY * (yw + WelcomeMargin * 2));

	y += WelcomeMargin;
	x += WelcomeMargin;

	for (i = 0; i < WelcomeLen; ++i) {	
		DrawTextBox (canvas, WelcomeMsg[i], false, x, y, xw);
	}		
}
	
function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if ((!shownWelcome) && (Action == IST_Press)) {
		shownWelcome = true;
		return true;
	}
	return false;
}

DefaultProperties
{
	bActive=True
	bVisible=True
	showWatermark=false;
	YPos=0.85
	WelcomeWidth=0.4
	WelcomeMargin=0.02
	WelcomePos=0.2
	WelcomeLen=5
	WelcomeMsg[0]="Welcome to TribesTribesTVStudiotudio!"
	WelcomeMsg[1]=""
	WelcomeMsg[2]="This server is running a mod that enhances the spectator interface. You access this functionality through the TribesTribesTVStudiotudio menu which can be activated by pressing F8."
	WelcomeMsg[3]=""
	WelcomeMsg[4]="Press any key to close this window.."
}
