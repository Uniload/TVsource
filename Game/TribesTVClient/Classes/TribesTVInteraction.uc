//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVInteraction extends Engine.Interaction;

//P should always be set.. up is not set for the primary spectator
var PlayerController p;
var TribesTVReplication TribesTVRep;
//var TribesTVPlayer up;

var bool shownWelcome;
var float WelcomeWidth;
var float WelcomeMargin;
var float WelcomePos;
var int WelcomeStart[2];
var int WelcomeEnd[2];
var string WelcomeMsg[10];

var string WarnMsg;
var int Clients;
var int Delay;
var int RestartIn;

//primary only
var string ServerAddress;
var int ServerPort;
var int ListenPort;
var string JoinPassword;
var string PrimaryPassword;
var string VipPassword;
var string NormalPassword;
//var float Delay;
var int MaxClients;


//Remove ourselves if the level changes
event NotifyLevelChange()
{
	Log ("TribesTV: Removed interaction");
	Master.RemoveInteraction (self);
}

simulated function SetState (bool primary)
{
	if (primary)
		GotoState ('Primary');
	else
		GotoState ('Secondary');
}

simulated function SetWarning (string msg)
{
	WarnMsg = msg;
}

function bool globalKeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local string tmp;

	if ((!shownWelcome) && (Action == IST_Press)) {
		shownWelcome = true;
		return true;
	}
	
	//Is it the key that would invoke say?
	if (Action == IST_Press) {
		tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
		if (tmp ~= "F8") { 
			ShowMenu ();
			return true;
		}	
	}
	
	return false;
}

//stub, overriden in states
function DrawWelcome (Canvas canvas)
{
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

function DrawWelcomeText (Canvas canvas, int index)
{
	local float x, y, xw, yw;
	local int i;

    // TRIBESTV TODO - font

	//Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.
		
	yw = 0;
	xw = WelcomeWidth - WelcomeMargin*2;
	
	//Check sizing
	for (i = WelcomeStart[index]; i <= WelcomeEnd[index]; ++i) {
		DrawTextBox (canvas, WelcomeMsg[i], true, 0, yw, xw);
	}

	//Now draw it
	x = (1 - WelcomeWidth) / 2;
	y = ((1 - yw) / 2) - 0.1;		//kind of looks better with - 0.1
		
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.ClipX * x, Canvas.ClipY * y);

    // TRIBESTV TODO - gui

	//Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', Canvas.ClipX * WelcomeWidth, Canvas.ClipY * (yw + WelcomeMargin * 2));

	y += WelcomeMargin;
	x += WelcomeMargin;

	for (i = WelcomeStart[index]; i <= WelcomeEnd[index]; ++i) {	
		DrawTextBox (canvas, WelcomeMsg[i], false, x, y, xw);
	}		
}

function DrawWarnMsg (Canvas canvas, string m)
{
	local float xl, yl;
	
    //Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX);
	  
	// TRIBESTV TODO - font
	    
	Canvas.StrLen(m,XL,YL);
	
	//Canvas.DrawColor = class'HUD'.default.GoldColor;
	
	Canvas.SetPos(0.5*(Canvas.ClipX-XL), Canvas.ClipY * 0.15);
	Canvas.DrawText(m, true);
}

function DrawStats (Canvas canvas)
{
/*	
	local float xl, yl;

    Canvas.Font = class'HUD'.static.GetConsoleFont (Canvas);
	Canvas.DrawColor = class'HUD'.default.WhiteColor;
	Canvas.StrLen("o_O", xl, yl);
	Canvas.SetPos(0.01 * (Canvas.ClipX), Canvas.ClipY * 0.25);
	Canvas.DrawText("TribesTV Clients: " $ Clients, true);	
	Canvas.SetPos(0.01 * (Canvas.ClipX), Canvas.ClipY * 0.25 + yl * 1.1);
	Canvas.DrawText("TribesTV Delay: " $ Delay $ " seconds", true);		
*/
}

function PostRender( canvas Canvas )
{	
	if (p == none) {
		Log ("TribesTV: Interaction setting playercontroller to " $ viewportowner.actor);
		p = ViewPortOwner.Actor;
	}
	
	Canvas.Style = p.ERenderStyle.STY_Alpha;

	if (!shownWelcome) {
		DrawWelcome (canvas);
	}
	
	//Anything important to tell the client?
	if (RestartIn > 0) {
		DrawWarnMsg (Canvas, "The TribesTV Proxy will restart in about " $ RestartIn $ " seconds");
	}
	else {
		if (WarnMsg != "") {
			DrawWarnMsg (Canvas, WarnMsg);
		}
	}
	
	DrawStats (Canvas);	
}

function ShowChat (string msg)
{
	Viewportowner.Actor.ClientMessage (msg);
}

function ShowMenu ()
{
}

simulated function GotStatus (string s)
{
 	local string tmps;
 	local int i;
 	 	
 	//Parse out the values
 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	clients = int (tmps);
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	delay = int (tmps);
 	s = Mid (s, i + 1);

 	restartin = int (s);
 	
 	Log ("TribesTV: Got status - " $ clients $ " - " $ delay $ " - " $ restartin);
}

simulated function GotBigStatus (string s)
{
 	local string tmps;
 	local int i;
 	 	
 	//Parse out the values
 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ServerAddress = tmps;
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ServerPort = int (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ListenPort = int (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	JoinPassword = tmps;
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	PrimaryPassword = tmps;
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	VipPassword = tmps;
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	NormalPassword = tmps;
 	s = Mid (s, i + 1); 

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	Delay = float (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	MaxClients = int (tmps);
 	s = Mid (s, i + 1);
}

state Primary
{
 	function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
		local string tmp;
	
		if (GlobalKeyEvent (Key, Action, Delta))
			return true;
		
		//Check stuff
		if (Action == IST_Press) {
			//teamsay key?
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);
			
			if (tmp ~= "TeamTalk") {
				p.ClientOpenMenu (class'TribesTVReplication'.default.TribesTVPackage $ ".TribesTVInputPage");
			    return true;
			}
		}		
	}

   	function ShowMenu () 
	{
		if(ListenPort!=0){
			//StopForceFeedback();
			p.ClientMessage ("Opening menu");
			p.ClientOpenMenu(class'TribesTVReplication'.default.TribesTVPackage $ ".TribesTVPrimaryMenu");
		} else {
			p.ClientMessage ("Waiting for info from proxy");			
		}
	}
	
	function DrawWelcome (canvas canvas)
	{
		DrawWelcomeText (canvas, 0);
	}
	
}

state Secondary
{
	function ShowMenu () 
	{
		//StopForceFeedback();
		p.ClientMessage ("Opening menu");
		p.ClientOpenMenu(class'TribesTVReplication'.default.TribesTVPackage $ ".TribesTVWatcherMenu");
	}

	function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
		local string tmp;
		
		if (GlobalKeyEvent (Key, Action, Delta))
			return true;
		
		//Check stuff
		if (Action == IST_Press) {
		
			//Right mouse pressed?
			if (Key == IK_RightMouse) {
				if(TribesTVRep.FollowPrimary){
					if(TribesTVRep.SeeAll){
						TribesTVRep.FollowPrimary=false;
						TribesTVRep.FreeFlight=true;		
						p.ClientMessage ("Free flight mode");			
					} else {
						if (class'TribesTVReplication'.default.wantBehindview)
							class'TribesTVReplication'.default.wantBehindview = false;
						else
							class'TribesTVReplication'.default.wantBehindview = true;
					}
				} else {
					if(TribesTVRep.FreeFlight || class'TribesTVReplication'.default.wantBehindview){
						TribesTVRep.FreeFlight=false;
						if(TribesTVRep.LastTargetName=="")
							TribesTVRep.GetNextPlayer();
						if(class'TribesTVReplication'.default.wantBehindview){
							p.ClientMessage ("Following player in 1st person view");			
							class'TribesTVReplication'.default.wantBehindview = false;
						} else {
							p.ClientMessage ("Following player with behindview");			
							class'TribesTVReplication'.default.wantBehindview = true;						
						}
					} else {
						if(TribesTVRep.NoPrimary){
							TribesTVRep.FollowPrimary=false;
							TribesTVRep.FreeFlight=true;		
							p.ClientMessage ("Free flight mode");						
						} else {
							class'TribesTVReplication'.default.wantBehindview = false;						
							TribesTVRep.FollowPrimary=true;
							p.ClientMessage ("Following primary");
						}
					}
				}
				return true;
			}
			if (Key == IK_LeftMouse) {
				if(!TribesTVRep.FollowPrimary){
					TribesTVRep.GetNextPlayer();
					TribesTVRep.FreeFlight=false;
					return true;
				}
			}
		
			//Or the say key?
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);
			
			if (tmp ~= "Talk") {
				p.ClientOpenMenu (class'TribesTVReplication'.default.TribesTVPackage $ ".TribesTVInputPage");
			    return true;
			}
			if (tmp ~= "MoveForward") {
				TribesTVRep.MoveForward=true;
			}
			if (tmp ~= "MoveBackward") {
				TribesTVRep.MoveBackward=true;
			}
			if (tmp ~= "StrafeLeft") {
				TribesTVRep.MoveLeft=true;
			}
			if (tmp ~= "StrafeRight") {
				TribesTVRep.MoveRight=true;
			}
			if (tmp ~= "Jump") {
				TribesTVRep.MoveUp=true;
			}
			if (tmp ~= "Duck") {
				TribesTVRep.MoveDown=true;
			}
		}
		if (Action == IST_Release) {
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);

			if (tmp ~= "MoveForward") {
				TribesTVRep.MoveForward=false;
			}
			if (tmp ~= "MoveBackward") {
				TribesTVRep.MoveBackward=false;
			}
			if (tmp ~= "StrafeLeft") {
				TribesTVRep.MoveLeft=false;
			}
			if (tmp ~= "StrafeRight") {
				TribesTVRep.MoveRight=false;
			}		
			if (tmp ~= "Jump") {
				TribesTVRep.MoveUp=false;
			}
			if (tmp ~= "Duck") {
				TribesTVRep.MoveDown=false;
			}
		}
	
		return false;
	}
	
	function DrawWelcome (canvas canvas)
	{
		DrawWelcomeText (canvas, 1);
	}
	
}

DefaultProperties
{
	bActive=true
	bVisible=true
	WelcomeWidth=0.4
	WelcomeMargin=0.02
	WelcomePos=0.2
	WelcomeStart[0]=0
	WelcomeEnd[0]=4
	WelcomeMsg[0]="Welcome to TribesTV Primary Client!"
	WelcomeMsg[1]=""
	WelcomeMsg[2]="You are now broadcasting a game to people over the net!"
	WelcomeMsg[3]=""
	WelcomeMsg[4]="Press any key to close this window.."	
	WelcomeStart[1]=5
	WelcomeEnd[1]=9	
	WelcomeMsg[5]="Welcome to TribesTV Watcher Client!"
	WelcomeMsg[6]=""
	WelcomeMsg[7]="You are watching a live broadcast of a game!"
	WelcomeMsg[8]=""
	WelcomeMsg[9]="Press any key to close this window.."		
}
