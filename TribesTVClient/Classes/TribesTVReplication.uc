//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVReplication extends Engine.Actor;

//A constant of sorts
var config string TribesTVPackage;

//Configuration things
var config int ViewMode;		//0 = locked on freeflight, 1 = free, 2 = locked

struct Movement {
	var float time;
	var vector loc;
	var rotator rot;
};

var Movement moves[1000];    	//Around 10 should be enough.. :)
var int movehead;
var int movetail;

var bool viewingSelf;
var int lastViewedSelf;

var bool SeeAll;
var bool NoPrimary;
var bool FollowPrimary;
var bool MuteChat;
var string LastTargetName;
var bool FreeFlight;
var Vector LocalPos;
var bool LocalPosSet;
var bool moveForward,moveBackward,moveLeft,moveRight,moveUp,moveDown;	//shouldnt be needed but playercontroller aForward etc always 0 ?

struct TInterpol
{
  var float k1;
  var float k2;   //slope
  var float y1;
  var float y2;   //cur & next value
  var float g1;
  var float c1;
  var float dy;
  var float h1;
};

struct TPlayerInterpol
{
  var float x1;       //cur & next timevalue
  var float x2;

  var bool noinfo;    //if true, do linear extrapolation instead

  var TInterpol cords[7];   //x, y, z, rot.pitch, rot.yaw, viewrot.pitch, viewrot.yaw
};

var TPlayerInterpol interpol;

var config string ChatString;
var config bool wantBehindview;

replication
{
	//Things the server calls on us
	reliable if (Role == ROLE_Authority)
		GetFromServer, GetTarget;

	//Things we can call on the server
	reliable if (Role<ROLE_Authority)
		SendToServer, SendTarget;
}

var TribesTVInteraction uti;

var float currentTime;
var float lastSend;

var bool wasEnded;

simulated event PostBeginPlay()
{
	local PlayerController p;
	
	Log ("TribesTV: PostBeginPlay in replication");
	
	p = level.GetLocalPlayerController ();
	lastViewedSelf = 2;
	class'TribesTVReplication'.default.wantBehindview = true;
}

simulated event Tick (float deltatime)
{
	local PlayerController p;
	local string s;
	
	super.Tick (deltatime);
			
	currentTime += deltaTime;

	//Wait with creating the interaction until we know our role
	if ((GetStateName () != 'Secondary') && (GetStateName() != 'Primary')) {
		log ("TribesTV: Waiting for role information");
		return;
	}
	
	p = Level.GetLocalPlayerController();		
	if(p!=none && !LocalPosSet){
		localPosSet=true;
		localPos=p.location;
	}
	if (uti == none) {		
		if ((p != none) && (p.Player != none) && (p.Player.InteractionMaster != none)) {
			Log ("TribesTV: Creating TribesTVInteraction");
			uti = TribesTVInteraction (p.player.InteractionMaster.AddInteraction (class'TribesTVReplication'.default.TribesTVPackage $ ".TribesTVInteraction", p.player));
			uti.SetState (GetStateName () == 'Primary');
			uti.TribesTVRep=self;
		}
	}
	
	//Check if the player has used TribesTVsay
	if (class'TribesTVReplication'.default.ChatString != "") {
		//If you don't watch chat you are not allowed to send either
		if (!MuteChat) {
			s = GetUrlOption ("Name") $ ": " $ class'TribesTVReplication'.default.ChatString;		
			uti.ShowChat (s);
			SendToServer ("1 " $ s);
			Log ("TribesTV: Sending chat: " $ s);	
		}
		class'TribesTVReplication'.default.ChatString = "";
	}
}

function SendToServer (string s)
{
}

function SendTarget (Actor t)
{
}

simulated function GetTarget (Actor t)
{
	local PlayerController p;

	//Always update, since this one is guaranteed to be correct
	p = level.GetLocalPlayerController ();
	if(p==t || t==p.pawn){
		if(lastViewedSelf>2){
			p.SetViewTarget (t);
			viewingSelf=true;
		}else{
			lastViewedSelf++;
		}
	}else{
		viewingSelf=false;
		lastViewedSelf=0;
		p.SetViewTarget (t);
	}
}

simulated function GotInitMsg (string s)
{
 	local string tmps;
 	local int i,a;
 	 	
 	//Parse out the values
 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	a = int (tmps);
	if (a == 1)
		GotoState ('Primary');
	else
		GotoState ('Secondary');
 	s = Mid (s, i + 1); 

 	a = int (s);
 	if (a == 2){
 		SeeAll=true;
 		NoPrimary=true;
		FollowPrimary=false;
		FreeFlight=true;
	} else if (a == 1){
		SeeAll=true;
 		NoPrimary=false;
	}else{
		SeeAll=false;
 		NoPrimary=false;
	}
}

simulated function GetFromServer (string s)
{
	local int i, cmd;
	local string tmp;
	
	//Find the command number
	i = InStr (s, " ");
	tmp = Mid (s, 0, i);
	cmd = int (tmp);
	s = Mid (s, i + 1);
		
	switch (cmd) {
		case 8:
			Log("TribesTV: Got init " $ s);
			GotInitMsg(s);
			break;
	}
	
	//No need to check the following if we are not initialized yet
	if (uti == none)
		return;
		
	switch (cmd) {
		case 1:
			if (!MuteChat)
				uti.ShowChat (s);
			break;
		case 2:
			ReceiveMovement (s);
			break;
		case 4:
			uti.GotStatus (s);
			break;
		case 7:
			uti.GotBigStatus (s);
			break;
	}
}

//Stub function
simulated function ReceiveMovement (string s)
{
}

exec function TribesTVsay (string s)
{
	Log ("TribesTV: Got TribesTVsay: " $ s);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////

state Primary {

	simulated function BeginState ()
	{
		log ("TribesTV: Entering primary state");
	}

	simulated function CheckGameEnd ()
	{
		local PlayerController p;
	
		if (!wasEnded) {
			p = Level.GetLocalPlayerController();
			if (p.IsInState('GameEnded')) {
				wasEnded = true;
				SendToServer ("3");			
				Log ("TribesTV: Send gameend to server");
			}
		}	
	}
		
	simulated function SendInterpolValues ()
	{
		local string s;
		local playercontroller p;
	
		p = level.GetLocalPlayerController ();
		s = "2 " /* $ currentTime $ " " */ $ p.Location $ " " $ p.Rotation;
		SendToServer (s);	
	}
	
	simulated function Tick (float delta)
	{
		local PlayerController p;
	
		global.tick (delta);
		
		//Send out values for interpolation 
		if (currentTime - LastSend > 0.5) {
			p = level.GetLocalPlayerController ();
			SendInterpolValues ();			
			LastSend = currentTime;
			
			SendTarget (p.ViewTarget);
		}
		
		//Check if the game has started
		CheckGameEnd ();
	}

}

state Secondary
{
	//Either x2 or both x2 and x3 can be zero, and indicates no known info at that time
	simulated function CalculateInterpol (int cord, float x1, float x2, float x3, float y1, float y2, float y3)
	{
		local TInterpol p;

		//Retrieve last one
		p = interpol.cords[cord];

		//Just stop if we don't even have two points
		if (x2 == 0) {
			x2 = x1;
			y2 = y1;
		}
	
		p.y1 = y1;
		p.y2 = y2;
	
		//Calculate start and endslope
		p.k1 = p.k2;
	
		//If no info at x3, make the derivative zero
		if (x3 == 0)
			p.k2 = 0;
		else
			p.k2 = (y3 - y1) / (x3 - x1);
	
		p.h1 = x2 - x1;
		p.dy = y2 - y1;
	
		p.g1 = p.h1 * p.k1 - p.dy;
		p.c1 = 2 * p.dy - p.h1 * (p.k1 + p.k2);
	
		interpol.cords[cord] = p;
	  
		//doh
		interpol.x1 = x1;
		interpol.x2 = x2;
	
		interpol.noinfo = ((x2 == 0) || (x3 == 0));  
	}
	
	//Get position according to timestamp variable
	simulated function float GetInterpolatedPos (int cord)
	{
		local TInterpol p;
		local float h1;
		local float t;
		local float x1;
		local float x2;
		local float res;
	
		p = interpol.cords [cord];
		x1 = interpol.x1;
		x2 = interpol.x2;
	
		h1 = x2 - x1;
	  
		//assert: x1 < timestamp < x2
		if (x2 == x1)
			return 0;
	
		t = (currentTime - x1) / (x2 - x1);
					
		res = p.y1 + t * (p.dy) + t * (1 - t) * p.g1 + t*t * (1 - t) * p.c1;  
		return res;
	}
	
	//Makes sure the absolute differences between pitch & yaw isn't more than 32k (since it's mod 65k anyway)
	simulated function FixRotDist (out int t1, out int t2, optional bool down)
	{
		if (Abs (t1 - t2) > 32768) {
			if (t1 > 32768)
	      		t2 += 65536;
			else
				t2 -= 65536;
	  	}
	}

	simulated function CheckGameEnd ()
	{
		local PlayerController p;
	
		if (!wasEnded) {
			p = Level.GetLocalPlayerController();
			if (p.IsInState('GameEnded')) {
				wasEnded = true;
				SendToServer ("3");			
			}
		}	
	}
	
	simulated function Tick (float delta)
	{
		local vector pos;
		local rotator rot;
		local string WarnMsg;
		local PlayerController p;
		local Actor target;
	
		global.tick (delta);
		
		if(NoPrimary)
			CheckGameEnd();
		
		p = Level.GetLocalPlayerController ();
		ProcessMovement ();
		
		if(FollowPrimary){				
			p.SetPropertyText("TribesTVOverideUpdate","false");
			//Do we have interpolation data to act on?	
			if ((interpol.x2 < currentTime) || (interpol.x1 == interpol.x2)) {
				WarnMsg = "Waiting on movement interpolation data";
			}
			else {
				//Calculate interpolated position and rotation	
				pos.x = GetInterpolatedPos (0);
				pos.y = GetInterpolatedPos (1);
				pos.z = GetInterpolatedPos (2);

				rot.pitch = GetInterpolatedPos (3);
				rot.yaw = GetInterpolatedPos (4);
				rot.roll = 0;

				//Always set the location
				if(viewingSelf)
	   				p.SetLocation (pos);

				//Force behindview depending on user pref when speccing something
				if ((p.viewtarget == none) || (p.ViewTarget == p)) {
					p.bBehindView = false;
				}
				else {
					p.bBehindView = class'TribesTVReplication'.default.wantBehindview;
				}
				
				//Now determine what to do with the rotation
				switch (class'TribesTVReplication'.default.ViewMode) {
					case 0:
						if ((p.ViewTarget == none) || (p.ViewTarget == p)) {
							p.SetRotation (rot);
						}
						break;
					case 1:
						p.SetRotation (rot);
						break;
					case 2:
						break;
				}
			}
		} else {	//not following primary
			p.SetPropertyText("TribesTVOverideUpdate","true");
			if(FreeFlight){
				p.SetPropertyText("TribesTVFreeFlight","true");

				//LocalPos+=p.aForward*delta*0.15*Vector(p.rotation);
				//LocalPos-=p.aStrafe*delta*0.15*Vector(p.rotation) Cross Vect(0,0,1);
				if(MoveForward)	
					LocalPos+=delta*1000*Vector(p.rotation);
				if(MoveBackward)	
					LocalPos-=delta*1000*Vector(p.rotation);
				if(MoveRight)	
					LocalPos-=delta*1000*Vector(p.rotation) Cross Vect(0,0,1);
				if(MoveLeft)	
					LocalPos+=delta*1000*Vector(p.rotation) Cross Vect(0,0,1);
				if(MoveUp)	
					LocalPos+=delta*1000*Vect(0,0,1);
				if(MoveDown)	
					LocalPos-=delta*1000*Vect(0,0,1);
				
				//p.ClientMessage ("Move " $ MoveForward $ " - " $ LocalPos $ " - " $ delta);

				p.bBehindView=false;
				p.SetViewTarget(p);
				p.SetLocation(LocalPos);
				if(p.pawn!=none){
					p.Pawn.SetLocation(LocalPos);
				}
				p.SetPropertyText("TribesTVPos",string(LocalPos));
			} else {
				p.SetPropertyText("TribesTVFreeFlight","false");
				p.SetPropertyText("TribesTVLastTargetName",LastTargetName);

				p.bBehindView = class'TribesTVReplication'.default.wantBehindview;
				target=GetPawnFromName(LastTargetName);
				if(target!=none){
					p.SetViewTarget(target);
				}
			}
		}
		uti.SetWarning (WarnMsg);				
	}
	
	simulated function Movement GetNextMovement (int num)
	{
		local int i;
		local int index;

		index = movetail;
		for (i = 0; i < num; ++i) {
			index++;
			if (index == 1000)
				index = 0;
		}
	
		return moves [index];
	}

	simulated function ProcessMovement ()
	{
		local Movement m1, m2, m3;

		if (movetail == movehead) 
			return;

		if (moves[movetail].time < currentTime) {
			m1 = moves[movetail];
			//log ("Processing move to: " $ tmp.loc $ " - " $ tmp.rot);
	
			movetail++;
			if (movetail == 1000)
				movetail = 0;
			
			//Calculate new interpolation values
		
			m2 = GetNextMovement (0);
			m3 = GetNextMovement (1);
		
			//Log ("processing moves from: " $ m1.time $ " - " $ m2.time $ " - " $ m3.time);
		
			FixRotDist (m1.rot.pitch, m2.rot.pitch);
			FixRotDist (m2.rot.pitch, m3.rot.pitch, true);
			FixRotDist (m1.rot.yaw, m2.rot.yaw);
			FixRotDist (m2.rot.yaw, m3.rot.yaw, true);

			//Coordinates		
			CalculateInterpol (0, m1.time, m2.time, m3.time, m1.loc.x, m2.loc.x, m3.loc.x);
			CalculateInterpol (1, m1.time, m2.time, m3.time, m1.loc.y, m2.loc.y, m3.loc.y);
			CalculateInterpol (2, m1.time, m2.time, m3.time, m1.loc.z, m2.loc.z, m3.loc.z);		
		
			//Rotation
			CalculateInterpol (3, m1.time, m2.time, m3.time, m1.rot.pitch, m2.rot.pitch, m3.rot.pitch);
			CalculateInterpol (4, m1.time, m2.time, m3.time, m1.rot.yaw, m2.rot.yaw, m3.rot.yaw);							
		}
	}

	simulated function ReceiveMovement (string s)
	{
	 	local Movement tmp;
	 	local string tmps;
	 	local int i;
 	
	 	//Parse out the values
	 	i = InStr (s, " ");
	 	tmps = Mid (s, 0, i);
	 	tmp.loc = vector (tmps);
	 	s = Mid (s, i + 1);

	 	tmp.rot = rotator (s);
 	
		//Log ("Got movement: " $ tmp.time $ " - " $ tmp.loc $ " - " $ tmp.rot);
 	
	 	//test
	 	tmp.time = currentTime + 5;
 	
	 	//And insert it into the queue
	 	if (movehead == movetail) {
	 		moves[movehead] = tmp;
	 		movehead++;
	 		if (movehead == 1000)
	 			movehead = 0;
	 	}
	 	else {
	 		//Make sure we only insert newer things
	 		i = movehead - 1;
	 		if (i < 0)
	 			i = 999;
	 		if (tmp.time > moves[i].time) {
	 			moves[movehead] = tmp;
	 			movehead++;
	 			if (movehead == 1000)
	 				movehead = 0;
	 		}
	 	} 		
	}
		
	simulated function BeginState ()
	{
		log ("TribesTV: Entering secondary state");
	}	
}

simulated function  GetNextPlayer()
{
	local Pawn tempPawn;
	local string targetName;
	local bool getNext;
	
	getNext=true;
	foreach AllActors(class'Pawn',tempPawn){
		if(tempPawn.PlayerReplicationInfo!=none){
			if(GetNext){
				GetNext=false;
				TargetName=tempPawn.PlayerReplicationInfo.PlayerName;
			}
		
			if(tempPawn.PlayerReplicationInfo.PlayerName==LastTargetName){
				GetNext=true;
			}
		}
	}
	LastTargetName=TargetName;
}

simulated function Pawn GetPawnFromName(string name)
{
	local Pawn tempPawn;

	foreach AllActors(class'Pawn',tempPawn){
		if(tempPawn.PlayerReplicationInfo!=none && tempPawn.PlayerReplicationInfo.PlayerName==name){
			return tempPawn;
			break;
		}
	}
	return none;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    bHidden=true
	bTearoff=false
	bSkipActorPropertyReplication=true	
	TribesTVPackage="TribesTVClient"
	seeAll=false
	NoPrimary=false
	followPrimary=true
	freeFlight=true
	LocalPosSet=false;
}
