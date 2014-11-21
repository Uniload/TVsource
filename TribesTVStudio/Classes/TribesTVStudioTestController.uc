//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioTestController extends xPlayer;

var TribesTVStudioMenuInteraction tvi;
var TribesTVStudioHudAugmentation tvh;

var TribesTVStudioViewSelector curViewSelector;
var TribesTVStudioMutator TVMutator;
var string vsNames[10];          	//replicated from the server, list of viewselectors
var texture vsIcons[10];			//ditto
var int vsActive[10];            	//client-side list of active selectors
var string mcNames[64];			 	//replicated from the server, list of metacameras
var int mcActive;					//client-side nr of current metacamera active
var texture watermark;				//Replicated from the server

struct RailNode
{
	var Vector location;
	var float maxDistance;
	var float viewAngle;
	var float minZoomDist;
	var float maxZoomDist;
	var float Priority;
};
struct FixedCam
{
	var Vector location;
	var float maxDistance;
	var float viewAngle;
	var float minZoomDist;
	var float maxZoomDist;
	var rotator rotation;
	var float maxRotation;
	var float Priority;
};

var string sysNames[6];
var float sysDists[6];
var int attractCamSys;
var int pathNodeCamSys;

var RailNode railNodes[2000];
var FixedCam fixedCams[2000];
var int numRail,numFixed;
var int curcam2;
var int curCamType; // 0=none,1=fixed,2=rail,3=spline

var Vector curCamSpeed;
var bool inViewLastTimer;
var float wantedDist;
var float lastHurry;
var float zoomSpeed;
var int camSysMode;
var bool redoCamera;
var float lastServerPosSet;

var Actor camTarget,camTargetOld;
var Vector camTargetPos;
var string camTargetName;   //don't access this directly, rather use getcamtargetname ()

var int myCamNum; //our number in the camera list kept by the mutator
var bool isWatched; //if a meta camera is currently watching us
var string oldTarget; //used to see when target has changed

var float zoomModifier;

struct ViewPriority
{
	var int id;                 //ID of the viewselector
	var float priority;         //and the priority that it wants
};

struct TargetPriority
{
	var string name;
	var array<ViewPriority> prios;
};

var array<TargetPriority> camTargets;       //Use the one with the hightest prio
var string forcedTarget;                    //Can be set from the menu

var TribesTVStudioSplineHandler splines;

//var float camTargetPriority;
//var float camTargetPriorityDecay;

replication
{
	//mirror camera stuff
	reliable if ( Role==ROLE_Authority)
		WatcherJoined,myCamNum,isWatched;

	reliable if ( Role<ROLE_Authority )
		ServerBeginWatch, ServerEndWatch;

	reliable if ( Role==ROLE_Authority)
		SetTargetAndMode,SetPosAndRot,SetDistAndZoom;

	reliable if ( Role<ROLE_Authority )
		SendTargetAndMode,SendPosAndRot,SendDistAndZoom;

	//
	//Things the server sends to the client
	reliable if ( Role==ROLE_Authority)
		vsNames, vsIcons, mcNames, watermark;

	//Things the server calls
	reliable if (Role==ROLE_Authority)
		SetCamTarget, SetCamMode;

	unreliable if( Role==ROLE_Authority)
		SetClientObjectPos;

	//Things we can call on the server
	unreliable if( Role<ROLE_Authority )
		GetObjectPosFromServer,SetLocationServer;

	reliable if ( Role<ROLE_Authority )
		ServerSetViewSelector, ServerSetMetaCamera;
}

simulated function PostBeginPlay()
{
	local TribesTVStudioMutator tvm;
	local int i;

	LoadSettings();
	Super.PostBeginPlay();

	mcActive = -1;

	//Update the list of available viewselectors so they can be replicated
	//This runs on the server
	if (Role == ROLE_Authority) {
		foreach Allactors (class'TribesTVStudioMutator', tvm) {
			TVMutator = tvm;
			break;      //should be only one anyway..
		}

		if (tvm == none)
			Log ("TribesTVStudio: no mutator found(??)");

		for (i = 0; i < tvm.vsCount; ++i) {
			vsNames[i] = tvm.vsList[i].description;
			vsIcons[i] = tvm.vsList[i].icon;
			Log ("TribesTVStudio: Adding viewcontroller " $ vsnames[i]);
		}
		
		watermark = tvm.watermark;
	} 
	
	//Only run this on the client in netgames, or in standalone games
	if ((Level.NetMode == NM_StandAlone) || (Role < ROLE_Authority)) {
	  	ConsoleCommand("SET INPUT F8 TVMENU");	
	}	
	clientmessage("post begin play run");
}

//Only exists as placeholder
exec function tvmenu ()
{
	clientmessage ("Sorry, this command is for spectators only");
}

simulated function destroyed ()
{
	if (tvi != none) {
		player.interactionmaster.removeinteraction (tvi);
		tvi = none;
	}
	if (tvh != none) {
		player.interactionmaster.removeinteraction (tvh);
		tvh = none;
	}
	super.destroyed ();
}

//Allows us to inject a proxy hud class
simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	local HUD realhud;

    if ( myHUD != none )
        myHUD.Destroy();

    if (newHUDClass == None)
        myHUD = None;
    else
    {
    	log ("TribesTVStudio: trying to spawn our hud.. " $ getstatename ());
    	
    	//Only use this proxy hud when we are an TribesTribesTVStudiotudio spectator
    	if (GetStateName() == 'AttractMode2') {
//		if (PlayerReplicationInfo.bOnlySpectator) {
	        myHUD = spawn (class'TribesTVStudioProxyHud', self);
			realhud = spawn (newHUDClass, self);        
			TribesTVStudioProxyHud(myhud).real = realhud;
//			TribesTVStudioProxyHud(myhud).SetControllerOwner (self);
		}
		else {
			myHUD = spawn (newHUDClass, self);        
		}

        if (myHUD == None)
            log ("PlayerController::ClientSetHUD(): Could not spawn a proxy HUD of class "$newHUDClass, 'Error');
        else
            myHUD.SetScoreBoardClass( newScoringClass );
    }
}

//Only call this when switching is actually wanted
function SwitchHud ()
{
	local HUD realhud;

	if ((myHud != none) && (!myHud.IsA ('TribesTVStudioProxyHud'))) {
		Log ("TribesTVStudio: Hud needed switching");
		realhud = myhud;
		myhud = spawn (class'TribesTVStudioProxyHud', self);		
		TribesTVStudioProxyHud(myhud).real = realhud;		
//		TribesTVStudioProxyHud(myhud).SetControllerOwner (self);		
		
		myhud.playerowner = realhud.playerowner;
		myhud.pawnowner = realhud.pawnowner;
	}
}

state Spectating
{
	function BeginState ()
	{
		Log ("TribesTVStudio: moving to our attractmode from spectating");
		clientmessage("switching to attract2 from spectating");
		GotoState ('AttractMode2');		
	}
}

state AttractMode
{
	function BeginState ()
	{
		Log ("TribesTVStudio: moving to our attractmode from attractmode");
		GotoState ('AttractMode2');		
	}
	
/*	exec function Fire( optional float F )
	{
		GotoState ('AttractMode2');
		clientmessage("Switching to attract2 mode");
		Log ("TribesTVStudio: tried attractmode2");
	}
	exec function AltFire( optional float F )
	{
		attracttarget = PickNextBot(attracttarget);
		targettime = 0;
	} */
}

state AttractMode2 extends Spectating
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
		ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange,
		Say, TeamSay;
	
	//Only performs init if needed
	function initTribesTVStudio () 
	{
		if (tvi != none)
			return;
			
		//Check if init can be performed at this time			
		if ((player != none) && (player.interactionmaster != none)) {				
			tvi = TribesTVStudioMenuInteraction (player.InteractionMaster.AddInteraction("TribesTribesTVStudiotudio.TribesTVStudioMenuInteraction", player));
			tvi.SetControllerOwner (self);
			tvh = TribesTVStudioHudAugmentation (player.InteractionMaster.AddInteraction ("TribesTribesTVStudiotudio.TribesTVStudioHudAugmentation", player));
			tvh.SetControllerOwner (self);
		}	
	}
	
	//By placing it here it is only available when we actually are in allowed state
	exec function tvmenu ()
	{
		if( tvi.GetStateName() == 'MenuVisible' )
		{
			tvi.GotoState('');
			return;
		}

		tvi.GotoState('MenuVisible');
	}
		
	function bool IsSpectating()
	{
		return true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
	}

	function PlayerMove(float DeltaTime)
	{
		local float deltayaw, destyaw;
		local float deltapitch, destpitch;
		local Rotator newrot;
		local Vector newPos;
		local Vector target;
		local Vector wantedSpeed,speedDif;
		local float inHurry;
		
		initTribesTVStudio ();
		FindCameraTarget();
		
		if(camTarget!=none)
			camTargetPos=camTarget.location;

		if(aForward!=0 && curCamType!=9){
			if(aForward>0){
				zoomModifier*=1+deltaTime/2;
				if(isWatched)
					SendDistAndZoom(wantedDist,zoomModifier);
			} else {
				zoomModifier/=1+deltaTime/2;
				if(isWatched)
					SendDistAndZoom(wantedDist,zoomModifier);
			}
		}
		switch( curCamType ){
		case 0:
			if(camTarget==none && camSysMode!=9)
				return;
			FovAngle = default.FovAngle/zoomModifier;
			if(bBehindView){
				CameraDist = wantedDist/40;
				if(camSysMode<7){	//chase from behind
					newRot = camTarget.Rotation;
					destyaw = NewRot.Yaw;
					deltayaw = (destyaw & 65535) - (rotation.yaw & 65535);
					if (deltayaw < -32768) deltayaw += 65536;
					else if (deltayaw > 32768) deltayaw -= 65536;
					destpitch = NewRot.pitch;
					deltapitch = destpitch - rotation.pitch;
					
					newrot = rotation;
					newrot.roll=0;
					// updates camera yaw to smoothly rotate to the pawn facing
					newrot.yaw += deltayaw * DeltaTime*2;
					newrot.pitch += deltapitch * DeltaTime*2;
					if(getcamtargetname()=="The Bomb"){  //the bomb rotates madly so set pitch to zero and lower yaw speed
						newRot.pitch=0;
						newRot.yaw*=0.2;
					}
					SetRotation(newrot);
				} else {	//user rotate chase
					newRot=rotation;
					newrot.roll=0;
					UpdateRotation(DeltaTime, 1);
					if(rotation!=newRot && isWatched)
						SendPosAndRot(location,rotation);
				}
			} else {
				if(camSysMode==8){	//pov
					SetRotation(camTarget.rotation);
				} else {		//free flight
					newRot=rotation;
					UpdateRotation(DeltaTime, 1);
					FovAngle = default.FovAngle;
					newPos=location;
					newPos+=aForward*deltaTime*0.15*Vector(rotation);
					newPos-=aStrafe*deltaTime*0.15*Vector(rotation) Cross Vect(0,0,1);
					if(isWatched && (newPos!=location || newRot!=rotation))
						SendPosAndRot(newPos,rotation);
					SetPosition(newPos);
				}
			}
			break;
		case 1:
			if(fixedCams[curcam2].maxRotation<32000){
				newrot = LimitedCameraTrack(DeltaTime);
				SetRotation(newrot);
			} else {
				newrot = CameraTrack2(DeltaTime);
				SetRotation(newrot);
			}
			break;
		case 2:
			target=camTargetPos;
			if(camTarget!=none)
				target+=camTarget.Velocity*0.5;
			if(curCam2==-1 || !WantedCamPos(target, railNodes[curcam2].location, wantedDist, newPos))
				newPos=location;
			
			inHurry=1;
			lastHurry-=DeltaTime;
			if(!inViewLastTimer){
				inHurry=2;
				lastHurry=2;
			} else if (lastHurry<1) lastHurry=1;
			
			wantedSpeed=(newPos-location)*1.3*inHurry;
			curCamSpeed*=1-(DeltaTime*(1.3-Normal(curCamSpeed) Dot Normal(wantedSpeed))*lastHurry);
			speedDif=wantedSpeed-curCamSpeed;
			curCamSpeed+=Normal(speedDif)*500*inHurry*DeltaTime;
			
			newPos=location+curCamSpeed*DeltaTime;
			SetPosition(newPos);
			
			newrot = CameraTrack2(DeltaTime);
			SetRotation(newrot);
			break;
		case 3:
			splines.Move(deltaTime);
			break;
		}
	}
	
	exec function NextWeapon()
	{
		wantedDist*=1.1;
		clientmessage("dist=" $wantedDist);
		if(isWatched)
			SendDistAndZoom(wantedDist,zoomModifier);
	}

	exec function PrevWeapon()
	{
		wantedDist/=1.1;
		clientmessage("dist=" $wantedDist);
		if(isWatched)
			SendDistAndZoom(wantedDist,zoomModifier);
	}

	exec function Fire( optional float F )
	{
		forcedTarget = tvi.GetNextTarget(GetCamTargetName());
		FindCameraTarget();
		if(camTarget!=none)
			camTargetPos=camTarget.location;
		Timer();
	}

	exec function AltFire( optional float F )
	{
		//clientmessage("Showing the menu");	
		tvmenu ();
	/*      camTarget = FindCameraTarget(camTarget);
	redoCamera=true;
		Timer();*/
	}

	function BeginState()
	{

		local Pawn tempPawn;

		if ( Pawn != None )
		{
			SetPosition(Pawn.Location);			
		}
		foreach AllActors(class'Pawn',tempPawn){
			if(tempPawn.PlayerReplicationInfo!=none){
				camTargetName=tempPawn.PlayerReplicationInfo.PlayerName;
				break;
			}
		}
		zoomModifier=1;
		bCollideWorld = true;
		autozoom = true;
		inViewLastTimer=false;
		wantedDist=400;
		camSysMode = 9;	//default to free flight
		SetCamMode(camSysMode);
		SetTimer(0.3, true);
		splines=new class'TribesTVStudioSplineHandler';
		splines.controller=self;
		ServerBeginWatch();
		
		SwitchHud ();
		clientmessage("attract2 mode begin state");
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		bCollideWorld = false;
    	curcam2 = -1;
		FovAngle = default.FovAngle;
		splines=none;
		ServerEndWatch();
	}

	function Timer()
	{
		//local Vector newloc;
		local int newcam,newType;
		local bool inView;
		local float temp;

		camtime += 0.3;
		lastServerPosSet-=0.3;

		//The menu interaction needs to be reminded to update..
		if (tvi != none)
			tvi.Timer ();

		//UpdateCamTarget(0.3);

		bFrozen = false;

		/*      // keep watching a target for a few seconds after it dies
		if (gibwatchtime > 0)
		{
		gibwatchtime -= 0.3;
		if (gibwatchtime <= 0)
		camTarget = None;

			if(gibwatchtime<4){     //reset camera quicker if player respawns
			if(camTarget!=none){
			camTarget=tempPawn;
			gibwatchtime=0;
			redoCamera=true;
			}
			}
			}
			else if ( camTarget != None && camTarget.Health <= 0)
			{
			gibwatchtime = 6;
			//Log("attract: watching gib");
			}
		*/
		// switch targets //
		if (camTarget != camTargetOld)
		{
			camTargetOld=camTarget;
			inViewLastTimer=false;
			if(curCamType==2){
				if(FindMoveCam(newcam,true))
					curCam2=newcam;
				else
					curCam2=-1;
			} else if(curCamType==3){
				splines.FindBestSplineNode(temp,camTargetPos);
				splines.SplineSelected();
			} else if(curCamType==0){
				redoCamera=true;
			}
			
		}

		if(camTarget==none && role < role_authority)
			GetObjectPosFromServer(GetCamTargetName ());

		if(curCamType==1 && curcam2!=-1 && fixedCams[curcam2].maxRotation<32000 && !TestLimitedRotCam(camTargetPos,curcam2))
			redoCamera=true;

		inView=TargetLOS(location,true);

		// switch views //
		if (redoCamera ||
			camtime > 1000 ||
			(curCamType==1 && curcam2!=-1 && VSize(location-camTargetPos)>fixedCams[curcam2].maxDistance) ||
			(curCamType==2 && curcam2==-1) || 
			(curCamType!=0 && (curcam2==-1 || curCamType==1) && !inView && (curCamType!=1 || !inViewLastTimer)))
		{
			bCollideWorld = true;
			camtime = 0;
			redoCamera=false;
			curCamSpeed=Vect(0,0,0);
			lastHurry=1;
			zoomSpeed=0;
			CameraDist = 0;
			CameraDeltaRotation.Pitch = 0;

			// look for a placed camera
			if (camSysMode<6 && FindBestCam(newcam,newType))
			{
				bBehindView = false;
				SetViewTarget(self);
				curcam2 = newcam;
				curCamType=newType;
				switch(curCamType){
				case 1:
					bCollideWorld = false;
					SetPosition(fixedCams[newcam].Location,true);
					FovAngle = fixedCams[newcam].ViewAngle;
					focuspoint = camTargetPos;
					if(fixedCams[newcam].maxRotation<32000){
						SetRotation(fixedCams[newcam].rotation);
					} else {
						SetRotation(CameraTrack2(0));
					}
					break;
				case 2:
//					if(VSize(camTargetPos-location)>3000 || !FindMoveCam(tempCam)){
						SetPosition(railNodes[newcam].Location,true);
						FovAngle = railNodes[newcam].ViewAngle;
						focuspoint = camTargetPos;
						SetRotation(CameraTrack2(0));
//					}
					break;
				case 3:
					bCollideWorld = false;
					splines.SplineSelected();
					break;
				}
				inView=TargetLOS(location);
			}
			// none placed camera mode
			else
			{
				if(camTarget!=none || camSysMode==9){
					FovAngle = default.FovAngle;
					curcam2 = -1;
					curCamType=0;
					switch(camSysMode){
					case 6:		//chase from behind
						SetRotation(camTarget.rotation);
						CameraDeltaRotation.Pitch = -3000;
						if(!bBehindView)
							SetRotation(camTarget.rotation);
						//no break
					case 7:		//user rotate chase
						SetViewTarget(camTarget);
						bBehindView = true;
						CameraDist = 6;
						break;
					case 8:		//pov
						SetViewTarget(camTarget);
						bBehindView = false;
						CameraDist = 0;
						CameraDeltaRotation.Pitch = 0;
						SetRotation(camTarget.rotation);
						break;
					case 9:	//free flight
						SetViewTarget(self);
						bBehindView = false;
						break;
					default:	//placed camera but cant find camera -> time limited chase
						SetViewTarget(camTarget);
						if(!bBehindView){
							SetRotation(camTarget.rotation);
							bBehindView = true;
						}
						CameraDist = 6;
						CameraDeltaRotation.Pitch = -3000;
						camtime = 998;
					}
				} else {
					redoCamera=true;
				}
			}
		}
		inViewLastTimer=inView;

		//switch rail node
		if(curCamType==2){
			if(FindMoveCam(newcam))
				curCam2=newcam;
			else
				curCam2=-1;
		} else if(curCamType==3){
			splines.UpdateGoalNode();
		}
  }
}

function SetTargetAndMode(string target,int mode)
{
	forcedTarget=target;
	if(mode!=camSysMode)
		SetCamMode(mode);
}

function SetPosAndRot(Vector pos,rotator rot)
{
	SetPosition(pos);
	SetRotation(rot);
}

function SetDistAndZoom(float dist,float zoom)
{
	wantedDist=dist;
	zoomModifier=zoom;
}

function WatcherJoined()
{
	SendPosAndRot(location,rotation);
	SendTargetAndMode(GetCamTargetName(),camSysMode);
	SendDistAndZoom(wantedDist,zoomModifier);
}

function SendTargetAndMode(string target,int mode)
{
	TVMutator.UpdateCameraVars(myCamNum,target,mode);
}

function SendPosAndRot(Vector pos,Rotator rot)
{
	TVMutator.UpdateCameraPosRot(myCamNum,pos,rot);
}

function SendDistAndZoom(float dist,float zoom)
{
	TVMutator.UpdateCameraDistZoom(myCamNum,dist,zoom);
}

function SetCamMode(int mode)
{
	zoomModifier=1;
	curcam2=-1;
	camSysMode=mode;
	if(mode<6)
		FillCameraList2();
	else
		wantedDist=300;
	redoCamera=true;
	Timer();
	if(isWatched)
		SendTargetAndMode(GetCamTargetName(),camSysMode);
}

function string GetCamTargetName ()
{
	local string ret;

	if (forcedTarget != "")
		ret=forcedTarget;
	else
		ret=camTargetName;

	if(ret!=oldTarget){
		oldTarget=ret;
		if(isWatched)
			SendTargetAndMode(ret,camSysMode);
	}
	return ret;
}

//Called from the server on the client when a viewcontroller wants a
//new target
function SetCamTarget(string name)
{
	camTargetName = name;
	FindCameraTarget ();
	if(camTarget!=none)
		camTargetPos=camTarget.location;

	Timer ();

	/*
	if(camTargetPriority>prio)
	return;
	camTargetPriority=prio;
	camTargetPriorityDecay=decay;
	camTargetName=name;
	FindCameraTarget();
	Timer(); */
}

//Calculates the total priority for the targets and uses the highest
//runs on the server
function UpdateCamTarget ()
{
	local int i, j;
	local float highest;
	local float highestindex;
	local float curtot;

	highestindex = -1;
	for (i = 0; i < camtargets.length; ++i) {
		curtot = 0;
		for (j = 0; j < camtargets[i].prios.length; ++j) {
			curtot += camtargets[i].prios[j].priority;
		}
		if (curtot >= highest) {
			highest = curtot;
			highestindex = i;
		}
	}

	if (highestindex == -1)
		return;

	if (camtargetname != camTargets[highestindex].name) {
		camTargetName = camTargets[highestindex].name;
		SetCamTarget (camTargetName);
	}


	/*log ("TribesTVStudio: updatecamtarget");
	for (i = 0; i < camtargets.length; ++i) {
	curtot = 0;
	for (j = 0; j < camtargets[i].prios.length; ++j) {
	curtot += camtargets[i].prios[j].priority;
	}

		log ("TribesTVStudio: name: " $ camtargets[i].name $ " prio: " $ curtot);
}*/
}

//Sets priority on a target, called by a viewselector
function SetTargetPriority (string target, float prio, int id)
{
	local int curtarget, curprio, i;

	//log ("TribesTVStudio: calling settargetpriority " $ target $ " - " $ prio $ " - " $ id);

	//Find it in the list
	for (curtarget = 0; curtarget < camtargets.length; ++curtarget) {
		if (camtargets[curtarget].name == target)
			break;
	}

	//Not found?
	if (curtarget == camTargets.length) {
		camTargets.length = camTargets.length + 1;
		camTargets[curtarget].name = target;
	}

	//Check if/where this id has set a priority
	for (curprio = 0; curprio < camtargets[curtarget].prios.length; ++curprio) {
		if (id == camtargets[curtarget].prios[curprio].id)
			break;
	}

	//Remove from the list
	if (prio == 0.0) {

		//Not found
		if (curprio == camtargets[curtarget].prios.length)
			return;

		//Remove it
		for (i = curprio + 1; i < camtargets[curtarget].prios.length; ++i) {
			camtargets[curtarget].prios[i - 1] = camtargets[curtarget].prios[i];
		}
		camtargets[curtarget].prios.length = camtargets[curtarget].prios.length - 1;

		//Last priority? Remove this target from list
		if (camtargets[curtarget].prios.length == 0) {
			for (i = curtarget + 1; i < camtargets.length; i++) {
				camtargets[i-1] = camtargets[i];
			}
			camtargets.length = camtargets.length - 1;
		}
	}

	//Add or update the currently set priority
	else {

		//Not found
		if (curprio == camtargets[curtarget].prios.length) {
			camtargets[curtarget].prios.length = camtargets[curtarget].prios.length + 1;
		}

		camtargets[curtarget].prios[curprio].id = id;
		camtargets[curtarget].prios[curprio].priority = prio;
	}

	//Inefficient to call here, make users call it themselves
	//    UpdateCamTarget ();
}

//Use or don't use this automatic view selector
function ServerSetViewSelector(int vs, bool use)
{
	if (!use) {
		TVMutator.vsList[vs].RemoveController(self);

		//Recalculate what to view from
		UpdateCamTarget ();
	}
	else {
		TVMutator.vsList[vs].AddController(self);
	}
}

//Called clientside, updates current active list (which is clientside)
function SetViewSelector (int vs, bool use)
{
	if (!use)
		vsActive[vs] = 0;
	else
		vsActive[vs] = 1;
	ServerSetViewSelector (vs, use);
}

function ServerSetMetaCamera (int cam)
{
	if (cam != -1)
		tvmutator.watchother (mycamnum, cam);
	else
		tvmutator.stopwatchother (mycamnum);
}

function SetMetaCamera (string mcname)
{
	local int i;
	
	if (mcname == "")
		i = -1;
	else {
		for (i = 0; i < 64; i++) {
			if (mcNames[i] == mcname)
				break;	
		}
	}

	if (i < 64) {
		mcActive = i;
		ServerSetMetaCamera (i);
	}
}

function LoadSettings()
{
	local TribesTVStudioSettings settings;
	local int a;

	foreach AllActors(class'TribesTVStudioSettings', settings){
		for(a=0;a<6;++a){
			sysNames[a]=settings.camSystemName[a];
			sysDists[a]=settings.DesiredRailCamDistance[a];
		}
		attractCamSys=settings.attract2CamSystem;
		pathNodeCamSys=settings.pathNode2CamSystem;
	}
}

function FillCameraList2()
{
	local PathNode mapPath;
	local AttractCamera mapAttract;
	local TribesTVStudioRailNode mapRail;
	local TribesTVStudioFixedCam mapFixed;
	local RailNode rail;
	local FixedCam tempFixed;
	local Vector loc,loc2;
	local Vector hitloc, hitnormal;

	numRail = 0;
	numFixed = 0;

	wantedDist=sysDists[camSysMode];

	if(camSysMode==pathNodeCamSys){
		foreach AllActors(class'PathNode', mapPath)
		{
			loc=mapPath.location;
			loc2=loc;
			loc2.z+=250;
			if(Trace(hitloc, hitnormal, loc, loc2, false)==None){
				loc.z+=150;
			} else {
				loc=hitloc;
				loc.z-=100;
			}

			rail.location=loc;
			rail.maxDistance=5000;
			rail.viewAngle=100;
			rail.minZoomDist=600;
			rail.maxZoomDist=600;
			rail.Priority=1;
			railNodes[numRail++] = rail;
			if (numRail == 2000) break;
		}
	}

	if(camSysMode==attractCamSys){
		foreach AllActors(class'AttractCamera', mapAttract)
		{
			tempFixed.location=mapAttract.location;
			tempFixed.maxDistance=5000;
			tempFixed.viewAngle=mapAttract.viewAngle;
			tempFixed.minZoomDist=mapAttract.minZoomDist;
			tempFixed.maxZoomDist=mapAttract.maxZoomDist;
			tempFixed.maxRotation=32000;
			tempFixed.Priority=1;
			fixedCams[numFixed++] = tempFixed;
			if (numFixed == 2000) break;
		}
	}

	foreach AllActors(class'TribesTVStudioRailNode', mapRail)
	{
		if(mapRail.SystemNum==camSysMode){
			rail.location=mapRail.location;
			rail.maxDistance=mapRail.MaxDistance;
			rail.viewAngle=mapRail.viewAngle;
			rail.minZoomDist=mapRail.minZoomDist;
			rail.maxZoomDist=mapRail.maxZoomDist;
			rail.Priority=mapRail.Priority;
			railNodes[numRail++] = rail;
			if (numRail == 2000) break;
		}
	}
	foreach AllActors(class'TribesTVStudioFixedCam', mapFixed)
	{
		if(mapFixed.SystemNum==camSysMode){
			tempFixed.location=mapFixed.location;
			tempFixed.maxDistance=mapFixed.MaxDistance;
			tempFixed.viewAngle=mapFixed.viewAngle;
			tempFixed.minZoomDist=mapFixed.minZoomDist;
			tempFixed.maxZoomDist=mapFixed.maxZoomDist;
			tempFixed.rotation=mapFixed.rotation;
			tempFixed.maxRotation=mapFixed.maxRotation;
			tempFixed.Priority=mapFixed.Priority;
			fixedCams[numFixed++] = tempFixed;
			if (numFixed == 2000) break;
		}
	}
	splines.FillSplineList(camSysMode);
}

function bool FindBestCam(out int newcam,out int newType)
{
	local int c, bestc,bestType;
	local float dist, bestdist;
	local Vector targetPos;

	bestc = -1;
	bestType=0;

	if(camTarget!=none){
		targetPos=camTarget.location;
		targetPos.z+=30;//camTarget.eyeheight;
	} else {
		targetPos=camTargetPos;
		targetPos.z+=30;
	}

	if(splines.FindBestSplineNode(bestdist,targetPos)){
		bestc=1;
		bestType=3;
	}

	for (c = 0; c < numRail; c++){
		dist = VSize(targetPos - railNodes[c].location);

		if ((bestc == -1 || dist/railNodes[c].Priority < bestdist) && dist < railNodes[c].maxDistance && TargetLOS(railNodes[c].location)){
			bestc = c;
			bestdist = dist/railNodes[c].Priority;
			bestType=2;
		}
	}
	for (c = 0; c < numFixed; c++){
		dist = VSize(targetPos - fixedCams[c].location);

		if ((bestc == -1 || dist/fixedCams[c].priority < bestdist) && dist < fixedCams[c].maxDistance && TargetLOS(fixedCams[c].location)){
			if(fixedCams[c].maxRotation<32000 && !TestLimitedRotCam(targetPos,c))
				continue;
			bestc = c;
			bestdist = dist/fixedCams[c].priority;
			bestType=1;
		}
	}

	if (bestc == -1) return false;

	newcam = bestc;
	newType=bestType;
	return true;
}

function bool TestLimitedRotCam(vector targetPos,int c)
{
	local Rotator targRot;
	local int dif;
	targRot=rotator(targetPos - fixedCams[c].location);

	dif=abs(targRot.yaw-fixedCams[c].rotation.yaw);
	dif=dif%0xffff;
	if(dif>0x7fff)
		dif-=0xffff;
	if(abs(dif)>fixedCams[c].maxRotation+fixedCams[c].viewAngle*0x7fff/180/2.2)
		return false;
	dif=abs(targRot.pitch-fixedCams[c].rotation.pitch);
	dif=dif%0xffff;
	if(dif>0x7fff)
		dif-=0xffff;
	if(abs(dif)>fixedCams[c].maxRotation+fixedCams[c].viewAngle*0x7fff/180/3.5)
		return false;

	return true;
}

function bool FindMoveCam(out int newcam,optional bool restrictiveSearch)
{
	local int c, bestc;
	local float dist, modDist,bestdist, dist2;
	local Vector hitloc, hitnormal;
	local Vector targetDir;
	local Vector targetPos;

	bestc = -1;

	if(camTarget!=none){
		targetPos=camTarget.location;
		targetPos.z+=30;//camTarget.eyeheight;
	} else {
		targetPos=camTargetPos;
		targetPos.z+=30;
	}
	targetDir=targetPos-location;

	if(restrictiveSearch && (!TargetLos(location) || VSize(location - targetPos)>3000))
		return false;

	for (c = 0; c < numRail; c++){
		dist2= VSize(location - railNodes[c].location);	//keep the camera more stable
		dist = VSize(targetPos - railNodes[c].location)+dist2*0.2;	
		modDist=dist/railNodes[c].Priority;
		if((targetDir Dot (railNodes[c].location-location))<=0)
			modDist*=1000;

		if ((bestc == -1 || modDist < bestdist) 
			&& dist < railNodes[c].maxDistance
			&& TargetLOS(railNodes[c].location)
			&& (Trace(hitloc, hitnormal, location, railNodes[c].location, false) == None)){
			bestc = c;
			bestdist = modDist;
		}
	}
	if (bestc == -1) return false;

	newcam = bestc;
	return true;
}

function bool TargetLOS(Vector pos, optional bool testFuture)
{
	local vector v1, v2;
	local Vector hitloc, hitnormal;

	v1=pos;
	if(camTarget!=none){
		v2 = camTarget.location;
		v2.z += 30;//camTarget.eyeheight;
	}else{
		v2 = camTargetPos;
		v2.z += 30;
	}

	v2 += Normal(v1 - v2) * 80;
	if (Trace(hitloc, hitnormal, v1, v2, false) == None)
		return true;

	if(testFuture && camTarget!=none){
		v2 = camTarget.location+camTarget.velocity*0.5;
		v2.z += 30;//camTarget.eyeheight;
		v2 += Normal(v1 - v2) * 80;
		if (Trace(hitloc, hitnormal, v1, v2, false) == None)
			return true;
	}
	return false;
}

function Rotator CameraTrack2(float DeltaTime)
{
	local float dist;
	local Vector lead;
	local float minzoomdist, maxzoomdist, viewangle, viewwidth,wantedFov;
	local Vector targetPos;

	// update focuspoint
	if(camTarget!=none){
		targetPos=camTarget.location + Vect(0,0,2) * camTarget.CollisionHeight;
		lead = targetPos + camTarget.Velocity*0.5;
	} else {
		targetPos=camTargetPos;
		lead = targetPos; // + target.Velocity*0.5;
	}


	dist = VSize(lead - focuspoint);
	if (dist > 20)
	{
		focuspoint += Normal(lead - focuspoint) * dist * DeltaTime * 2.0;
	}

	// adjust zoom within bounds set by active camera (max 150)
	if (autozoom)
	{
		dist = VSize(Location - targetPos);
		if (curcam2 >= 0)
		{
			switch(curCamType){
			case 1:
				minzoomdist = fixedCams[curcam2].minzoomdist;
				maxzoomdist = fixedCams[curcam2].maxzoomdist;
				viewangle = fixedCams[curcam2].ViewAngle;
				break;
			case 2:
				minzoomdist = railNodes[curcam2].minzoomdist;
				maxzoomdist = railNodes[curcam2].maxzoomdist;
				viewangle = railNodes[curcam2].ViewAngle;
				break;
			case 3:
				splines.SetFovValues(minzoomdist,maxzoomdist,viewAngle);
				break;
			}
		}
		else
		{
			minzoomdist = 600;
			maxzoomdist = 1200;
			viewangle = default.FovAngle;
		}
		viewAngle/=zoomModifier;
		if(viewAngle>150)
			viewAngle=150;

		if (dist < minzoomdist || !inViewLastTimer)
		{
			wantedFov = viewangle;
		}
		else
		{
			if (dist > maxzoomdist)
				dist=maxzoomdist;
			viewwidth = minzoomdist*Tan(viewangle*PI/180 / 2);
			wantedFov = Atan(viewwidth, dist) * 180/PI * 2;
		}
		if(wantedFov<fovAngle){
			if(zoomSpeed<0)
				zoomSpeed=0;
			zoomSpeed+=DeltaTime;
			if(zoomSpeed > (fovAngle/wantedFov-1)/(DeltaTime*0.5))
				zoomSpeed=(fovAngle/wantedFov-1)/(DeltaTime*0.5);

			fovAngle/=1+DeltaTime*zoomSpeed*0.5;

		} else {
			if(zoomSpeed>0)
				zoomSpeed=0;
			zoomSpeed-=DeltaTime;
			if(zoomSpeed < -(wantedFov/fovAngle-1)/(DeltaTime*0.5))
				zoomSpeed=-(wantedFov/fovAngle-1)/(DeltaTime*0.5);

			fovAngle*=1-DeltaTime*zoomSpeed*0.5;
		}
		DesiredFOV=fovAngle;
	}
	return Rotator(focuspoint - location);
}

//Tracking function with a limited max rotation
//Doesnt do any zooming
function Rotator LimitedCameraTrack(float DeltaTime)
{
	local float dist;
	local Vector lead;
	local Rotator tempRot;
	local int dif;
	local Vector targetPos;

	if(camTarget!=none){
		targetPos=camTarget.location + Vect(0,0,2) * camTarget.CollisionHeight;
	} else {
		targetPos=camTargetPos;
	}

	if(fixedCams[curcam2].maxRotation==0)
		return fixedCams[curcam2].Rotation;

	// update focuspoint
	lead = targetPos ; // + target.Velocity*0.5;
	dist = VSize(lead - focuspoint);
	if (dist > 20)
	{
		focuspoint += Normal(lead - focuspoint) * dist * DeltaTime * 2.0;
	}

	tempRot=Rotator(focuspoint - location);

	dif=fixedCams[curcam2].rotation.yaw-tempRot.yaw;
	if(dif>0x7fff)
		dif-=0xffff;
	if(dif<-0x7fff)
		dif+=0xffff;

	if(dif>fixedCams[curcam2].maxRotation)
		tempRot.yaw+=dif-fixedCams[curcam2].maxRotation;
	else if(dif<-fixedCams[curcam2].maxRotation)
		tempRot.yaw+=dif+fixedCams[curcam2].maxRotation;

	dif=fixedCams[curcam2].rotation.pitch-tempRot.pitch;
	if(dif>0x7fff)
		dif-=0xffff;
	if(dif<-0x7fff)
		dif+=0xffff;

	if(dif>fixedCams[curcam2].maxRotation)
		tempRot.pitch+=dif-fixedCams[curcam2].maxRotation;
	else if(dif<-fixedCams[curcam2].maxRotation)
		tempRot.pitch+=dif+fixedCams[curcam2].maxRotation;

	return tempRot;
}

function bool WantedCamPos(Vector target, Vector railNode, float size, out Vector pos)
{
	local Vector targVec,railVec;
	local float cDist,closeDistSqr,t;

	if(!inViewLastTimer){
		pos=railNode;
		return true;
	}
	targVec=target-location;
	railVec=Normal(railNode-location);

	cDist=railVec Dot targVec;

	if(cDist<0)
		return false;

	closeDistSqr=targVec Dot targVec-cDist*cDist;

	if(closeDistSqr>size*size){
		t=cDist;
	} else {
		t=cDist-Sqrt(size*size-closeDistSqr);
	}

	pos=location+railVec*t;
	return true;
}

function GetObjectPosFromServer(string name)
{
	local Controller C;
	local xRedFlag rflag;
	local xBlueFlag bflag;
	local xBombFlag bomb;

	if(name=="Red Flag"){
		foreach AllActors(class'xRedFlag',rflag)
		{
			SetClientObjectPos(rflag.Location);
			SetLocation(rflag.Location);
			return;
		}
	}
	if(name=="Blue Flag"){
		foreach AllActors(class'xBlueFlag',bflag)
		{
			SetClientObjectPos(bflag.Location);
			SetLocation(bflag.Location);
			return;
		}
	}
	if(camTargetName=="The Bomb"){
		foreach AllActors(class'xBombFlag',bomb)
		{
			SetClientObjectPos(bomb.Location);
			SetLocation(bomb.Location);
			return;
		}
	}
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (C.Pawn != None) && C.Pawn.PlayerReplicationInfo.PlayerName==name)
		{
			SetClientObjectPos(C.Pawn.Location);
			SetLocation(C.Pawn.Location);
			break;
		}
	}
}

function SetPosition(vector pos,optional bool importantChange)
{
	SetLocation(pos);
	if(role<role_authority && (lastServerPosSet<0 || importantChange)){
		SetLocationServer(pos);
		lastServerPosSet=1;
	}
}

function SetClientObjectPos(Vector pos)
{
	camTargetPos=pos;
}

//If local game it can use a faster version
function FindCameraTarget()
{
	if (role < role_authority)
		FindCameraTargetClient();
	else
		FindCameraTargetServer();
}

//This one is used in a network game
function FindCameraTargetClient()
{
	local Pawn tempPawn;
	local xRedFlag rflag;
	local xBlueFlag bflag;
	local xBombFlag bomb;
	local string targetName;

	targetname = getcamtargetname ();

	camTarget=none;

	if(TargetName=="Red Flag"){
		foreach AllActors(class'xRedFlag',rflag)
		{
			camTarget=rflag;
			return;
		}
	}
	if(TargetName=="Blue Flag"){
		foreach AllActors(class'xBlueFlag',bflag)
		{
			camTarget=bflag;
			return;
		}
	}
	if(TargetName=="The Bomb"){
		foreach AllActors(class'xBombFlag',bomb)
		{
			camTarget=bomb;
			return;
		}
	}
	foreach AllActors(class'Pawn',tempPawn){
		if(tempPawn.PlayerReplicationInfo!=none && tempPawn.PlayerReplicationInfo.PlayerName==TargetName){
			camTarget=tempPawn;
			break;
		}
	}
}

//This is only used in a local game
function FindCameraTargetServer()
{
	local Controller C;
	local xRedFlag rflag;
	local xBlueFlag bflag;
	local xBombFlag bomb;
	local string targetName;

	targetname = getcamtargetname ();

	camTarget=none;

	if(TargetName=="Red Flag"){
		foreach AllActors(class'xRedFlag',rflag)
		{
			camTarget=rflag;
			return;
		}
	}
	if(TargetName=="Blue Flag"){
		foreach AllActors(class'xBlueFlag',bflag)
		{
			camTarget=bflag;
			return;
		}
	}
	if(TargetName=="The Bomb"){
		foreach AllActors(class'xBombFlag',bomb)
		{
			camTarget=bomb;
			return;
		}
	}
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (C.Pawn != None) && C.Pawn.PlayerReplicationInfo.PlayerName==TargetName)
		{
			camTarget=c.pawn;
			break;
		}
	}
}

function SetLocationServer(Vector pos)
{
	SetLocation(pos);
	if (pawn != none)					//fix: borde inte detta gå alltid?
		pawn.SetLocation (pos);
}

function ServerBeginWatch()
{
	if( Role==ROLE_Authority){
		TVMutator.AddActiveCam(self);
	}
}

function ServerEndWatch()
{
	if( Role==ROLE_Authority){
		TVMutator.DeleteActiveCam(self);
	}
}


DefaultProperties
{
	curcam2=-1
  camSysMode=0
  sysNames[4]="Attract cameras"
  sysNames[5]="PathNodes"
  sysDists[0]=400
  sysDists[1]=400
  sysDists[2]=400
  sysDists[3]=400
  sysDists[4]=400
  sysDists[5]=400
  attractCamSys=4
  pathNodeCamSys=5
}
