//-----------------------------------------------------------
// New cam commands.
//-----------------------------------------------------------
class CamCommands extends Engine.Interaction;

var config bool bRocketExplodeRadiusCrash;		// rocket fix
var config bool bHideEmitters;				// for hiding zero-emitters
var int TickedFrames;
var int Ticks;
var bool bStopAtNextFrame;
var bool bOnlyThisOneRocket;
var int OnlyThis;
var config float ExplodeRadius;
var bool bGetDefaultParameters;

// for saving purposes
var int z,drawdetail,viewing;
var bool draw_Spline,bxedited;
var vector timedvec;
var rotator timedrot;
var float kabstand,basic_speed;
var vector Flag_Locations[150];
var rotator Rotation_At_Flags[150];
var int Flag_Fovs[150];
var float Flag_Times[150];
var float x[150]; // für Zeitachse

var CamHUD CH;

var float dFovAngle;

//-------------Start Get´er and Set´er for recreating camcontrol
function get_x(int i, out float fl)
{
fl=x[i];
}
function set__x(float fl, int i)
{
x[i]=fl;
}

function get_Flag_Locations(int i, out vector fl)
{
fl=Flag_Locations[i];
}
function set_Flag_Locations(vector fl, int i)
{
Flag_Locations[i]=fl;
//update_flags();
}
function get_Flag_Rotations(int i, out rotator fr)
{
fr=Rotation_At_Flags[i];
}
function set_Flag_Rotations(rotator fr, int i)
{
local knoten other,knoten2;
local int j;
Rotation_At_Flags[i]=fr;
     /*
     j=0;
     foreach pc.AllActors(class'Knoten', Other)
     {
      if((i == 0) && (j == 1))
       {
        knoten2=Other;
        break;
       }
      if(j==i-1)
       {
       knoten2=Other;
       break;
       }
      j++;
     }

     if(knoten2 != none)
      {
       Rotation_At_Flags[i].yaw=fr.yaw;
       Rotation_At_Flags[i].pitch=fr.pitch;
       if(abs(Rotation_At_Flags[i].yaw - knoten2.rotation.yaw) > 32768)
       {
       while(abs(Rotation_At_Flags[i].yaw - knoten2.rotation.yaw) > 32768)
        {
         if(Rotation_At_Flags[i].yaw > knoten2.rotation.yaw)
          Rotation_At_Flags[i].yaw=Rotation_At_Flags[i].yaw-65536;
         else
          Rotation_At_Flags[i].yaw=Rotation_At_Flags[i].yaw+65536;
        }
       }
       else
       Rotation_At_Flags[i].yaw=fr.yaw;
       if(abs(Rotation_At_Flags[i].pitch - knoten2.rotation.pitch) > 32768)
       {
       while(abs(Rotation_At_Flags[i].pitch - knoten2.rotation.pitch) > 32768)
       if(Rotation_At_Flags[i].pitch > knoten2.rotation.pitch)
       Rotation_At_Flags[i].pitch=Rotation_At_Flags[i].pitch-65536;
       else
       Rotation_At_Flags[i].pitch=Rotation_At_Flags[i].pitch+65536;
       }
       else
       Rotation_At_Flags[i].pitch=fr.pitch;
       }
      */
//update_flags();
}
function set_Flag_Fovs(float tf, int i)
{
Flag_Fovs[i]=tf;
//update_flags();
}
function get_Flag_Fovs(int i, out float tf)
{
tf=Flag_Fovs[i];
}
function set_Flag_Times(float tf, int i)
{
Flag_Times[i]=tf;
//update_flags();
}
function get_Flag_Times(int i, out float tf)
{
tf=Flag_Times[i];
}

//-------------End Get´er and Set´er




static final operator(18) int % (int A, int B)
{
  return A - (A / B) * B;
}

function HideAllDefaultEmitters(bool bHide)
{
}

function CamHUD findCamHUD ()
{
	local Interaction inter;
	local int i;

	for (i = 0; i < ViewportOwner.Actor.Player.LocalInteractions.Length; i++)
	{
		inter = ViewportOwner.Actor.Player.LocalInteractions[i];
		if (inter.isA ('CamHUD'))
			return CamHUD (inter);
	}
	return None;
}

exec function ResetRcamConfig()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;

GC.OpenMenu("Cam.UT2K4_CamSave_Reset");
}

exec function CamConfigMenu()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;

GC.OpenMenu("Cam.UT2K4_Cam_Control");
}

exec function OpenDialog()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;

GC.OpenMenu("Cam.UT2K4_CamSave_OpenDialog");
}

exec function SaveDialog()
{
local GUIController GC;

CH = findCamHUD ();


	if ( CH != None )
	{

	GC = GUIController(ViewportOwner.GUIController);


		if (GC==None)
		return;

		if ( CH.CC != None )
		{
		GC.OpenMenu("Cam.UT2K4_CamSave_SaveDialog");
		}
		else
		{
		GC.OpenMenu("Cam.UT2K4_CamSave_SaveError");
		}
	}
}

exec function ReplaceName(string ReplacebleName,string ReplaceOnName)
{
local PlayerReplicationInfo PRI;

	Foreach ViewportOwner.Actor.AllActors(class'PlayerReplicationInfo', PRI)
	{
		if ( PRI.PlayerName ~=  ReplacebleName )
		PRI.PlayerName = ReplaceOnName;
	}
}

/* TimeDilation()
For user time dilation control
*/
exec function TimeDilation(float td)
{
	if ( td > 0 )
	{
	viewportowner.actor.Level.TimeDilation=td;
	}
}

/* summon()
engine.cheatmanager.summon() analog
*/
exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		if ( viewportowner.actor.Pawn != None )
			SpawnLoc = viewportowner.actor.Pawn.Location;
		else
			SpawnLoc = vect(0,0,0);
		Viewportowner.Actor.Spawn( NewClass,,,SpawnLoc );
	}
}

/* NextFrame()
For exact transition from frame to frame
*/
exec function NextFrame(int NumOfFrames)
{
	if(viewportowner.actor.Level.Pauser != None)
	{
	if ( NumOfFrames <= 0 )
	TickedFrames=1;
	else
	if (NumOfFrames>0)
	TickedFrames=NumOfFrames;
	bStopAtNextFrame=true;
	viewportowner.actor.Pause();
	viewportowner.actor.Level.TimeDilation=1.1;
	}

	CH = findCamHUD ();
  //CH.recoil[CH.recoilcount] = Pawn(CH.pc.ViewTarget).getviewrotation();
  //CH.recoilcount = (CH.recoilcount+1) % 10;

}

/* CamProperties()
rcam settings
*/
exec function CamProperties()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;

GC.OpenMenu("Cam.UT2K4_Cam_Properties");
}

function bool GetCurrectDemo()
{
return false;
}

/* DemoInfo()
For image of full demo information
*/
exec function DemoInfo()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;
	if ( GetCurrectDemo() )
	GC.OpenMenu("Cam.UT2K4_Cam_Demo_Info");
}

/* Seek()
Intarfaced seeking
*/
exec function Seek()
{
local GUIController GC;

GC = GUIController(ViewportOwner.GUIController);

	if (GC==None)
	return;

GC.OpenMenu("Cam.UT2K4_Seek_com");
}

/* ExplodeAllRockets()
Aviable on currect tick
*/



exec function kOnlyThis(int b)
{
OnlyThis = b;
}

exec function bExplodeOnlyOne(bool b)
{
bOnlyThisOneRocket = b;
}

/* AutoRocketExplode()
Defaul - Enable. Fix of rocket explode.
*/
exec function AutoRocketExplode(bool b)
{
bRocketExplodeRadiusCrash = b;
}

exec function ExpRad(float NewRadius)  // my rad exp
{
ExplodeRadius = NewRadius;
}

function PostRender(Canvas canvas)
{

}



function Tick(float deltatime)
{
	if (bStopAtNextFrame)
	{
	Ticks+=1;
		if (Ticks>TickedFrames)
		{
		Ticks=0;
		viewportowner.actor.Pause();
		bStopAtNextFrame=False;
		}
	}

	if (bGetDefaultParameters)
	GetDefault();
}

function GetDefault()
{
dFovAngle = viewportowner.actor.FOVAngle;
bGetDefaultParameters = False;
}

defaultproperties
{
     bRocketExplodeRadiusCrash=True
     bHideEmitters=True
     ExplodeRadius=1.500000
     bGetDefaultParameters=True
     bVisible=True
     bRequiresTick=True
}
