class CamHUD extends Engine.Interaction;

//#exec texture IMPORT FILE=Textures\bluebackground.tga       NAME=bluebackground MIPS=0
//#exec texture IMPORT FILE=Textures\blackbackground.tga       NAME=blackbackground MIPS=0
//#exec texture IMPORT FILE=Textures\whitebackground.tga       NAME=whitebackground MIPS=0
//#exec texture IMPORT FILE=Textures\greenbackground.tga       NAME=greenbackground MIPS=0


//var vector playeehits[30];


//var bool bDoTick;
var bool drawHelp;
var float speed;
var vector targetloc;
var bool targetlook,drawintro;
var actor target;
var democontroller otherDemo,demo04;
var CamControl other2,cc;
var Knoten other3;
var int i,z; // i nur fuer Schleifen
var Actor targeta,ta;
var Controller C;
var rotator rotat;
var GUIController gc;
var bool bIsPaused,waspressed;
var float demo04speed;
var int lastmouseX,lastmouseY,mouseX,mouseY;
var playerspec ps;
//var actor a;
var bool bViewingdemorec,bDrawdemorec, bViewingcam;
var bool bw,ba,bs,bd,bdown,bup;
//var vector v;
var rotator r,tr;
var bool bshowcoords;
var bool bTypecoords;
var int typecount;
var vector typeloc;
var rotator typerot;
var int typecount2;
var bool bgotoloc;
var int rmode;
var bool bpcam;
var float tempfloat;
var Actor ap;
//var CamControl otherCc;
var camcommands otherCc;
var bool bTargetnone;
var knoten kv;
var bool bfovmode;
var bool bdrawadvanced;
var bool bdech;
var bool bresetemitts;
var int bwhbs;
var float dista;
var float timecount;
var MotionBlur motblur;
var int bmotbur;
var CameraOverlay camoverlay;
var projectile tproj;
var int projcount, proj_anz;
var Texture leveltex;
var bool bwh;
var float temptime;
var float v0,t0;
var bool btimedpath;
var int seektime;
var projectile targeted_proj;
var vector timedvec;
var rotator timedrot;
var bool started;
var bool bfollowtarget;
var float followdist;
var bool bweaponeffects;
var int maxcampoints;
var int flagcount;
var vector distancemeter_pos;
var bool bpathedit;
var vector tv;
var bool bswitched;
var bool tanone;

var float myMouseX;
var float myMouseY;
var Pawn tp;

var playercharactercontroller Cntrl;
var Controller cnt;
var PlayerreplicationInfo pri;


var vector weaponx, weapony, weaponz;
//var TO2_BaseWeapon tw;
var bool bfixedfps,bnewpointtime;
var float kabstand,mabstand;
var actor target_actor;
var bool bIncomingCam;

var bool bFireScreens;
var int ammocount, ammocount2;
var string curweapon;

var posSaver posSave;
var bool bRec_Pos;
var bool bLoad_Pos;


var bool bDrawWeapons;
var bool tempbool;
var playercharactercontroller PC;
var string hitscreenweapons;

var int weaponsty;
var bool bShowFragMsg;
var bool binstantweaponswitch;

var int framecount;

var bool bKillScreens;
var int lastkillscreen;
var int kills;
var int killshotdelay,kSdCount;
var int killscreentimedi;
var float weaponswitchtime;
var byte lastflashcount;

var int seektoframe;
var bool bdrawframenumber;

var int firescreentimedi;
var bool bdofirescreen;
var string watchedname;
var float soundvolume;
var bool bwireframe;
var bool bshowknotendist;


var int democount;
var float rotdiff;
var float rotdiff2;
var int rotdiffcounter;
var int rotdiffcounter2;
var int hitcounttime;
var int shots,shots2;
var int healthmeter[10];
var int hitmeter[10];
var bool bshowMarkers;
var bool bdomarkers;
var float CurMarkTime;
var float tf;
var vector posmarkerspos[150];
var float posmarkerstime[150];
var bool bshowtime;







var bool bdemo04,serverdemo,behindview;



// console commands


exec function pausing()
{
if(!bispaused)
 pc.Level.Pauser = none;
else
 pc.Level.Pauser = pc.PlayerReplicationInfo;
bispaused=!bispaused;
if(bispaused && bpcam && (cc != none))
 cc.settimer(0.005,!bIsPaused);
}


exec function test()
{
local TribesHUDBase hudObjects;
local TribesSpectatorHUDScript other;

 local ZoneInfo o_ZoneInfo;
 foreach pc.allactors(class'zoneinfo', o_ZoneInfo)
   {
    //o_ZoneInfo.bDistanceFog=!o_ZoneInfo.bDistanceFog;
    o_ZoneInfo.DistanceFogEnd=100000;
    /*
    o_ZoneInfo.DistanceFogColor.R=DistanceFogColor.R;
    o_ZoneInfo.DistanceFogColor.G=DistanceFogColor.G;
    o_ZoneInfo.DistanceFogColor.B=DistanceFogColor.B;
    o_ZoneInfo.DistanceFogColor.A=DistanceFogColor.A;
    */
    /*
    if(DistanceFogStart != 0)
     o_ZoneInfo.DistanceFogStart=DistanceFogStart;
    if(DistanceFogEnd != 0)
     o_ZoneInfo.DistanceFogEnd=DistanceFogEnd;
     */
   }

}


exec function killscreens(int speed, optional int framediff)
{
 bKillScreens = !bKillScreens;
 if(speed == 0)
  speed = 1.1;
 else
  killscreentimedi = speed;
 if(framediff != 0)
  killshotdelay = framediff;
 else
  killshotdelay = 2;

 bdrawframenumber = bkillscreens;
 pc.Level.timedilation = killscreentimedi;
}


exec function instantweaponswitch()
{
 binstantweaponswitch = !binstantweaponswitch;
}

exec function weaponstyle(int ws)
{
 weaponsty = ws;
}

exec function showhits()
{
 bdech=!bdech;
 bdrawweapons=!bdrawweapons;
}

exec function resetemitts()
{
 bresetemitts=!bresetemitts;
}



exec function ToggleSSModeb()
{
	if ( !pc.Level.GetLocalPlayerController().myHud.bHideHud )
	{
		//myHUD.bCrosshairShow = false;
		//viewportowner.actor.SetWeaponHand("Hidden");
		bShowFragMsg = false;
		pc.Level.GetLocalPlayerController().myHud.bHideHud = true;
		//pc.TeamBeaconMaxDist = 0;
		//pc.bHideVehicleNoEntryIndicator = true;
	}
	else
	{
		// return to normal
		//myHUD.bCrosshairShow = true;
		//SetWeaponHand("Right");
		bShowFragMsg = false;
		pc.Level.GetLocalPlayerController().myHud.bHideHud = false;
		//pc.TeamBeaconMaxDist = pc.default.TeamBeaconMaxDist;
		//pc.bHideVehicleNoEntryIndicator = false;
	}
}
exec function ToggleSSModec()
{
	if ( !pc.Level.GetLocalPlayerController().myHud.bHideHud )
	{
        pc.Level.GetLocalPlayerController().myHud.bHideHud = true;
		//pc.TeamBeaconMaxDist = 0;
		//pc.bHideVehicleNoEntryIndicator = true;
		bShowFragMsg = true;
		//h.bNoEnemyNames=true;
	}
	else
	{
		pc.Level.GetLocalPlayerController().myHud.bHideHud = false;
		//pc.TeamBeaconMaxDist = pc.default.TeamBeaconMaxDist;
		//pc.bHideVehicleNoEntryIndicator = false;
		bShowFragMsg = false;
		//h.bNoEnemyNames=false;
	}

}


exec function hitscreens(string weapons, optional int timedi)
{
 hitscreenweapons = weapons;
 bFireScreens=!bFireScreens;
 firescreentimedi = timedi;

 if(timedi == 0)
  firescreentimedi = 1.1;
 else
  firescreentimedi = timedi;
 bdrawframenumber = bFireScreens;
 pc.Level.timedilation = firescreentimedi;
}


// Experimental. Doesent seem to change anyhing in its current state.
exec function setlight(int AmbientBrightness, optional int AmbientHue, optional int AmbientSaturation)
{
 local ZoneInfo o_ZoneInfo;
 foreach pc.allactors(class'zoneinfo', o_ZoneInfo)
   {
    o_ZoneInfo.AmbientBrightness=AmbientBrightness;
    o_ZoneInfo.AmbientHue=AmbientHue;
    o_ZoneInfo.AmbientSaturation=AmbientSaturation;
   }
 }


exec function setfog(color DistanceFogColor,
                           optional int DistanceFogStart, optional int DistanceFogEnd)
{
 local ZoneInfo o_ZoneInfo;
 foreach pc.allactors(class'zoneinfo', o_ZoneInfo)
   {
    o_ZoneInfo.bDistanceFog=true;
    o_ZoneInfo.DistanceFogColor.R=DistanceFogColor.R;
    o_ZoneInfo.DistanceFogColor.G=DistanceFogColor.G;
    o_ZoneInfo.DistanceFogColor.B=DistanceFogColor.B;
    o_ZoneInfo.DistanceFogColor.A=DistanceFogColor.A;
    if(DistanceFogStart != 0)
     o_ZoneInfo.DistanceFogStart=DistanceFogStart;
    if(DistanceFogEnd != 0)
     o_ZoneInfo.DistanceFogEnd=DistanceFogEnd;
   }
 }





exec function patheditmode ()
{
 // RypelCam v1.92-MWatch01
 bpathedit=!bpathedit;
}

function ResetRCamConfig()
{
	if(cc != none)
	{
	cc.destroy();
	foreach pc.AllActors(class'Knoten', other3)
	Other3.destroy();
	}
cc = pc.Spawn(class'CamControl');
cc.conf=true;
cc.PostbeginPlay();
timedvec=cc.timedvec;
timedrot=cc.timedrot;
flagcount=cc.z;
}

function OpenRcamPackage ()
{
local posmarker posm;
	if(cc != none)
	{
	cc.destroy();
	foreach pc.AllActors(class'Knoten', other3)
	Other3.destroy();
	}
cc = pc.Spawn(class'CamControl');
//otherCc = pc.GetEntryLevel().Game.LoadDataObject(class'CamControl', "cc", FileName);
otherCc = findCamCommands();
copy_otherCc();
cc.conf=true;
cc.PostbeginPlay();
for(i=0;i<150;i++)
{
 if(posmarkerstime[i] != 0.0)
 {
  pc.spawn(class'PosMarker',,,posmarkerspos[i]).time=posmarkerstime[i];
  //log(posmarkerstime[i]);
 }
}


timedvec=cc.timedvec;
timedrot=cc.timedrot;
flagcount=cc.z;
}



function SaveRcamPackage ()
{
local posmarker posm;
local int j;
	if(cc != none)
	{
	cc.timedvec=timedvec;
	cc.timedrot=timedrot;
	//otherCc = pc.GetEntryLevel().Game.CreateDataObject(class'CamControl', "cc", FileName);
	otherCc = findCamCommands();
    copy_cc();
	//pc.GetEntryLevel().Game.SavePackage(FileName);
	}
	i=0;
    foreach pc.dynamicactors(class'posmarker',posm)
    {
     posmarkerspos[i]=posm.location;
     posmarkerstime[i]=posm.time;
     //log(posmarkerstime[i]);
     i++;
    }
    for(j=i;j<150;j++)
    {
     posmarkerstime[j] = 0.0;
    }

}



exec function moveto(int newplacex, int newplacey, int newplacez)
{
local vector newplace;
newplace.x=newplacex;
newplace.y=newplacey;
newplace.z=newplacez;
demo04.SetLocation(newplace);
}


exec function mblur(float blur)
{
if(motblur == none)
 {
  motblur=MotionBlur(pc.Level.ObjectPool.AllocateObject(class'MotionBlur'));
  pc.AddCameraEffect(motblur);
  motblur.BlurAlpha=300;
 }
motblur.Alpha=blur;
}

exec function whx()
{
bwh = !bwh;
}

exec function wh(bool b)
{
 bwh = b;
}

exec function fov(int f)
{
 pc.SetFOV(f);
}

exec function togglehideplayers()
{
 foreach pc.DynamicActors(class'Pawn',tp)
  tp.bHidden=!tp.bhidden;
}

exec function seekto(int mins, int seks, float seekspeed)
{
seektime=mins*60+seks;
pc.Level.TimeDilation=seekspeed;
}

exec function seekframe(int frame, float seekspeed)
{
seektoframe=frame;
pc.Level.TimeDilation=seekspeed;
}

exec function timedpath(bool b)
{
 btimedpath = b;
 if(cc != none)
  cc.btimedpath = b;
}

exec function followtarget(float dist)
{
if(dist == 0)
bfollowtarget=false;
else
bfollowtarget=true;
followdist=dist;
}

exec function wireframe(bool b)
{
/*
if(b == true)
pc.RendMap=1; //1,7,9
else
pc.RendMap=5;
*/

if(pc.rendmap == 5)
 pc.rendmap = 1;
else if(pc.rendmap == 1)
 pc.rendmap = 7;
else if(pc.rendmap == 7)
 pc.rendmap = 9;
else if(pc.rendmap == 9)
 pc.rendmap = 5;

}

exec function camspeed(float speed)
{
       cc.basic_speed=speed;
       cc.basic_speed2=speed;
}

function CamCommands findCamCommands ()
{
	local Interaction inter;

	for (i = 0; i < pc.Player.LocalInteractions.Length; i++) {
		inter = pc.Player.LocalInteractions[i];
		if (inter.isA ('CamCommands'))
			return CamCommands (inter);
	}
	return None;
}

exec function levelcolor(string s, bool i)
{
leveltex=none;
switch(i)
{
 case true : bweaponeffects = true; break;
 case false : bweaponeffects = false; break;
}
}


function startcam()
{
local knoten ksc;
local rotknoten rksc;
targeta=none;
tanone=true;
demo04.SetViewTarget(cc);
//demo04.bBehindView=false;
//behindview=false;

if(cc.drawcount == 0)
{
 foreach pc.AllActors(class'Knoten', ksc)
  ksc.bHidden=false;
 foreach pc.AllActors(class'rotknoten', rksc)
  rksc.bHidden=true;
}
v0=0;
t0=pc.Level.TimeSeconds;
cc.startcam=true;
bViewingCam=true;
bViewingdemorec=false;
Viewportowner.bShowWindowsMouse=false;
pc.Level.GetLocalPlayerController().myHud.bHideHud=true;
//h.bCrosshairShow=false;
timecount=pc.level.TimeSeconds;
}



function copy_cc()
{
local vector lv;
local rotator lr;
local float tf;


otherCc.z=cc.z;
otherCc.drawdetail=cc.drawdetail;
otherCc.basic_speed=cc.basic_speed;
otherCc.draw_Spline=cc.draw_Spline;
otherCc.viewing=cc.viewing;
otherCc.timedvec=cc.timedvec;
otherCc.timedrot=cc.timedrot;
otherCc.bxedited=cc.bxedited;
otherCc.kabstand=cc.kabstand;
for(i=0; i < cc.z; i++)
 {
  cc.get_Flag_Locations(i,lv);
  otherCc.set_Flag_Locations(lv,i);
  cc.get_Flag_Rotations(i,lr);
  otherCc.set_Flag_Rotations(lr,i);
  cc.get_Flag_Fovs(i,tf);
  otherCc.set_Flag_Fovs(tf,i);
  cc.get_Flag_Times(i,tf);
  otherCc.set_Flag_Times(tf,i);
  cc.get_x(i,tf);
  otherCc.set__x(tf,i);
 }
}
function copy_otherCc()
{
local vector lv;
local rotator lr;
local float tf;
cc.z=otherCc.z;
cc.drawdetail=otherCc.drawdetail;
cc.basic_speed=otherCc.basic_speed;
cc.draw_Spline=otherCc.draw_Spline;
cc.viewing=otherCc.viewing;
cc.timedvec=otherCc.timedvec;
cc.timedrot=otherCc.timedrot;
cc.bxedited=otherCc.bxedited;
cc.kabstand=otherCc.kabstand;
for(i=0; i < otherCc.z; i++)
 {
  otherCc.get_Flag_Locations(i,lv);
  cc.set_Flag_Locations(lv,i);
  otherCc.get_Flag_Rotations(i,lr);
  cc.set_Flag_Rotations(lr,i);
  otherCc.get_Flag_Fovs(i,tf);
  cc.set_Flag_Fovs(tf,i);
  otherCc.get_Flag_Times(i,tf);
  cc.set_Flag_Times(tf,i);
  log("Flag_Times[i] = "@ tf);
  otherCc.get_x(i,tf);
  cc.set__x(tf,i);
 }
}


function bool KeyEvent (EInputKey key, EInputAction action, float delta)
{
	local vector v;
    local rotknoten rk2;
    local vector tvect;
    local bool ballowedflag;
    local TribesHUDBase other_hud;
    local democontroller o_demo;
    local CamHudTimer cht;
    local knoten other;
    local PosMarker posm;

    local multiplayercharacter mpc;


 if (Action == IST_Press)
  {
   if(!bdemo04)
   {
    foreach pc.AllActors(class'democontroller', otherDemo)
       {
        demo04=otherDemo;
        bdemo04=true;
        //pc=playercharactercontroller(other.realviewtarget);
        break;
       }
    ps=pc.spawn(class'playerspec');
   }
   if(cc == none)
   foreach pc.AllActors(class'camcontrol', other2)
      {
       cc=other2;
       speed=cc.basic_speed2;
       other2.fov=pc.DefaultFOV;
       cc.btimedpath=btimedpath;
       break;
      }
   if(!bdemo04)
    {
     demo04=pc.spawn(class'democontroller');
   	 demo04.setViewTarget(pc.Pawn);
     serverdemo=false;
     bViewingdemorec=true;
    }
   if(key == 113)             // 'F2'
   {
    if(!bispaused)
     pc.level.pauser=pc.playerreplicationinfo;
    else
     pc.level.pauser=none;
     bispaused=!bispaused;
   }

   if(key == 38)           // 'up'
   {
    if(demo04.ViewTarget==cc.viewer01)
    {
        cc.get_Flag_Rotations(cc.viewing, tr);
        tr.pitch = tr.pitch + demo04speed;
        cc.set_Flag_rotations(tr,cc.viewing);
        cc.update_flags();
    }
   }
    if(key == 37)           // 'left'
   {
    if(demo04.ViewTarget==cc.viewer01)
    {
        cc.get_Flag_Rotations(cc.viewing, tr);
        tr.yaw = tr.yaw - demo04speed;
        cc.set_Flag_rotations(tr,cc.viewing);
        cc.update_flags();
    }
   }
   if(key == 39)           // 'right'
   {
    if(demo04.ViewTarget==cc.viewer01)
    {
        cc.get_Flag_Rotations(cc.viewing, tr);
        tr.yaw = tr.yaw + demo04speed;
        cc.set_Flag_rotations(tr,cc.viewing);
        cc.update_flags();
    }
   }
   if(key == 40)           // 'back'
   {
    if(demo04.ViewTarget==cc.viewer01)
    {
        cc.get_Flag_Rotations(cc.viewing, tr);
        tr.pitch = tr.pitch - demo04speed;
        cc.set_Flag_rotations(tr,cc.viewing);
        cc.update_flags();
    }
   }
   if(key == 79)           // 'O'
   {
    bfovmode=!bfovmode;
   }
   if(key == 74)           // 'J'
   {
    bdrawadvanced = !bdrawadvanced;
   }

   if(key == 90)            // knoten neu setzen
    {
     z=0;
     cc.set_flag_locations(demo04.viewtarget.location, cc.viewing);
     cc.set_flag_rotations(demo04.viewtarget.Rotation, cc.viewing);
    if(bnewpointtime)
    {
     cc.set_Flag_Times(pc.Level.TimeSeconds, cc.viewing);
     cc.inittimespline();
    }
     foreach pc.AllActors(class'Knoten', kv)
      {
       cc.get_Flag_Locations(z,v);
       if(kv.Location != v)
        {
         cc.get_Flag_Rotations(z,rotat);
         kv.SetLocation(v);
         kv.SetRotation(rotat);
         if(cc.viewing == z)
          {
           cc.viewer01.setLocation(v);
           cc.viewer01.setRotation(rotat);
          }
        }
       z++;
      }
     cc.save_mouserotation=true;
     cc.updateSplinef(true);
     kabstand=cc.kabstand;
     mabstand=cc.mabstand;
    }


   if(key == 66)
   {
    bnewpointtime=!bnewpointtime;
   }

   If(Key == 1)
    {
     pc.bHideFirstPersonWeapon=false;
     bDrawdemorec=true;
     pc.Level.GetLocalPlayerController().myHud.bHideHud=false;
     //h.bCrosshairShow=true;
     //h.bshowpersonalinfo=true;
     //h.bshowweaponinfo=true;
     if(!serverdemo)
     {
     //h.bshowpersonalinfo=false;
     //h.bshowweaponinfo=false;
     if(!tanone)
     {
      demo04.SetViewTarget(targeta);
      targeta.bHidden=false;
     }

     tv=demo04.viewtarget.location;
     //demo04.ViewClass(class'pawn');
     demo04.demoviewnextplayer();
     pc.bbehindview=false;
     behindview=false;
     if(bViewingdemorec && (tv == demo04.viewtarget.location))
      bViewingdemorec = false;

     bViewingCam=false;
     if((demo04.ViewTarget.owner != none) && !bViewingdemorec)
     {
      bViewingdemorec=true;
      demo04.DemoViewNextPlayer();
      targeta=none;
      tanone=true;
      //h.bShowWeaponBar=true;
      //h.bshowpersonalinfo=true;
      //h.bshowweaponinfo=true;
      demo04.ViewTarget.bHidden=false;
     }
     else
      {
       watchedname = pawn(demo04.viewtarget).playerreplicationinfo.playername;
       //h.bShowWeaponBar=false;
       bViewingdemorec=false;
       demo04.ViewTarget.bHidden=true;
       targeta=demo04.ViewTarget;
       tanone=false;
       ps.setlocation(targeta.location);
       ps.setrotation(targeta.rotation);
       demo04.SetViewTarget(ps);
      }
      pc.bBehindView=behindview;
      if(!tanone)
       targeta.bHidden=!BehindView;
      Viewportowner.bShowWindowsMouse=false;
      pc.SetViewTarget(demo04);
      }
      else if(Viewportowner.bShowWindowsMouse)
       Viewportowner.bShowWindowsMouse=false;
    }
   If(Key == 2)
    {
     pc.bBehindView=!pc.bBehindView;
     if(!tanone)
      targeta.bHidden=!pc.bBehindView;
     behindview=pc.bBehindView;
    }
   If(Key == 85)
    {
     demo04.bCollideWorld=!demo04.bCollideWorld;
    }
   If(Key == 78)       // 'N' Showtime
    {
     bshowtime=!bshowtime;
     pc.Level.GetLocalPlayerController().myHud.bHideHud=!bshowtime;
     //h.bshowpersonalinfo=false;
     //h.bshowweaponinfo=false;
     //h.bShowWeaponBar=false;
     //h.bCrosshairShow=!pc.Level.GetLocalPlayerController().myHud.bHideHud;
    }
   If(Key == 70)       // 'F' Showframes
    {
     bdrawframenumber = !bdrawframenumber;
    }

   If(Key == 49)           // 1
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=0;
       cc.basic_speed2=0;
       speed=0;
      }
     else
      demo04speed=0;
    }
   If(Key == 50)           // 2
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=0.5;
       cc.basic_speed2=0.5;
       speed=0.5;
      }
     else
      demo04speed=0.5;
    }
   If(Key == 51)           // 3
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=1.5;
       cc.basic_speed2=1.5;
       speed=1.5;
      }
     else
      demo04speed=1.5;
    }
   If(Key == 52)           // 4
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=3;
       cc.basic_speed2=3;
       speed=3;
      }
     else
      demo04speed=3;
    }
   If(Key == 118)           // F7
   {
    SaveRcamPackage();
   }
   If(Key == 119)           // F8
   {
    OpenRcamPackage();
   }
   If(Key == 120)           // F9
   {
    //if(!bwireframe)
     wireframe(true);
    //else
     //wireframe(false);
    //bwireframe=!bwireframe;
   }
   If(Key == 121)           // F10
   {
    bshowknotendist=!bshowknotendist;
   }

   If(Key == 122)           // F11
   {
    bshowMarkers=!bshowMarkers;
   }
   If(Key == 123)           // F12
   {
    tf=CurMarkTime;
    foreach pc.allactors(class'PosMarker',posm)
    {
     if(posm.time > CurMarkTime)
      {
       CurMarkTime = posm.time;
       break;
      }
    }
    if(CurMarkTime == tf)
     foreach pc.allactors(class'PosMarker',posm)
     {
      CurMarkTime = posm.time;
      break;
     }
   }

   If(Key == 53)           // 5
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=10;
       cc.basic_speed2=10;
       speed=10;
      }
     else
      demo04speed=10;
    }
   If(Key == 112)           // F1
    {
     test();
    }
   If(Key == 114)           // F3
    {
     patheditmode();
    }
   If(Key == 115)           // F4
    {
     btimedpath = false;
     serverdemo=false;
     bIsPaused=false;
     bDrawdemorec=false;
     bViewingdemorec=true;
     started=false;
     demo04speed=17;
     typecount=0;
     typecount2=10000;
     bTargetnone=false;
     dista=0;
     timecount=0;
     followdist=60;
     bfixedfps=false;
     kills=0; // players score
     bdemo04=false;
     foreach pc.AllActors(class'Actor', ta)
     {
      ta.CullDistance = 0;
     }
	 cht = PC.spawn(class'CamHudTimer');
	 cht.overlay=self;
	}
   If(Key == 116)           // F5
    {
	 if(!btimedpath)
      timedpath(true);
     else
      timedpath(false);
     btimedpath=btimedpath;
    }
   If(Key == 117)           // F6
    {
     bdoMarkers = !bdoMarkers;
    }

   If(Key == 54)           // 6
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=20;
       cc.basic_speed2=20;
       speed=20;
      }
     else
      demo04speed=20;
    }
   If(Key == 55)           // 7
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=30;
       cc.basic_speed2=30;
       speed=30;
      }
     else
      demo04speed=30;
    }
   If(Key == 56)           // 8
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=45;
       cc.basic_speed2=45;
       speed=45;
      }
     else
      demo04speed=45;
    }
   If(Key == 57)           // 9
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=60;
       cc.basic_speed2=60;
       speed=60;
      }
     else
      demo04speed=60;
    }
   If(Key == 101)
    {
     ballowedflag=true;
     if(flagcount >= 2)
     {
      tvect=distancemeter_pos;
      if(((VSize(demo04.ViewTarget.location - tvect)
          /kabstand) > 15) || (mabstand/
          (VSize(demo04.ViewTarget.location - tvect)) > 15))
       {
       ballowedflag=false;
       pc.clientmessage("RypelCam Error: desired Campointlocation too far or too near to last Campoint!");
       }
      }
     if((demo04.ViewTarget.location - tvect) == vect(0,0,0))
      {
       ballowedflag = false;
       pc.clientmessage("RypelCam Error: desired Campointlocation too far or too near to last Campoint!");
      }

     if(ballowedflag)
     {
     if(flagcount >= 1)
      {
       tvect=distancemeter_pos;
       if(flagcount == 1)
        {
         kabstand=(VSize(demo04.ViewTarget.location - tvect));
         mabstand=(VSize(demo04.ViewTarget.location - tvect));
        }
       if((VSize(demo04.ViewTarget.location - tvect) < kabstand))
        kabstand = (VSize(demo04.ViewTarget.location - tvect));
       if((VSize(demo04.ViewTarget.location - tvect) > mabstand))
        mabstand = (VSize(demo04.ViewTarget.location - tvect));
      }

     pc.ConsoleCommand("fixedfps"@30);
     demo04.Spawn(class'Knoten',,,demo04.viewtarget.location).fov=pc.DefaultFOV;
     flagcount++;
     if(flagcount>=4) // gib Knoten 4 das Kommando die Interpolation neu zu zeichnen
     foreach pc.AllActors(class'Knoten', Other)
      if((Other.zeichner == true))
       Other.updateSpline();

     if(bdoMarkers)
     {
      if(btargetnone)
       foreach pc.visibleactors(class'multiplayercharacter',mpc)
        demo04.Spawn(class'PosMarker',,,mpc.location,mpc.rotation).time=pc.level.timeseconds;
      else
        demo04.Spawn(class'PosMarker',,,target.location,target.rotation).time=pc.level.timeseconds;
      pc.consolecommand("shot");
     }


     distancemeter_pos=demo04.viewtarget.location;


     if(timedvec == vect(0,0,0))
      {
       timedvec = pc.Pawn.Location;
       timedrot = pc.Pawn.rotation;
       if(serverdemo)
        {
         foreach pc.dynamicactors(class'Pawn', tp)
              {
               timedvec=tp.location;
               timedrot=tp.rotation;
               break;
              }

        }
       }
     }
    }
   If(Key == 75)
    {
     //pc.bHideFirstPersonWeapon=true;
     bfollowtarget=false;
     demo04.SetViewTarget(demo04);
     pc.SetViewTarget(demo04);
     bviewingcam=true;
     targeta=none;
     tanone=true;
     bViewingdemorec=false;
     if(!serverdemo)
     Viewportowner.bShowWindowsMouse=true;
     pc.Level.GetLocalPlayerController().myHud.bHideHud=true;
     //h.bCrosshairShow=false;
     pc.bBehindView=true;
     behindview=pc.bBehindView;
     cc.fov=pc.DefaultFOV;
     pc.SetFOV(pc.DefaultFOV);
     if(cc.drawcount != 3)
      {
        cc.draw_Spline=true;
        cc.drawSplineWasFalse=true;
        cc.drawcount = 3;
      }
    }
   If(Key == 99)
    {
     if(!cc.bisdrawing)
      {
       demo04.SetViewTarget(demo04);
       cc.updateSplinef(true);
       startcam();
      }
    }
   If(Key == 76)
    {
     bDrawdemorec=!bDrawdemorec;
     Viewportowner.bShowWindowsMouse=!Viewportowner.bShowWindowsMouse;
    }
   If(Key == 107)
    {
     if(bpathedit)
      {
       cc.viewer01.changeView(cc.viewing,cc.z-1,true,false);
       if(cc.viewing == 0)
        cc.viewer01.changeView(cc.viewing,cc.z-1,true,false);
      }
     else
      {
     targeta=none;
     tanone=true;
     cc.updateViewer(false);
     demo04.bBehindView=true;
     behindview=true;
     bViewingCam=true;
     bViewingdemorec=false;
     Viewportowner.bShowWindowsMouse=false;
      }
    }
   If(Key == 109)
    {
    if(bpathedit)
     {
      cc.viewer01.changeView(cc.viewing,cc.z-1,false,true);
      if(cc.viewing == 0)
       cc.viewer01.changeView(cc.viewing,cc.z-1,false,true);
     }
     else
      {
     targeta=none;
     tanone=true;
     cc.updateViewer(true);
     demo04.bBehindView=true;
     behindview=true;
     bViewingCam=true;
     bViewingdemorec=false;
     Viewportowner.bShowWindowsMouse=false;
      }
    }
   If(Key == 35)
    {
     if(rmode < 7)
      rmode=rmode+1;
     else
      rmode = 1;
     pc.RendMap=rmode;
    }
   If(Key == 80)
    {
     bpcam=!bpcam;
    }
   If(Key == 105)
    {
     cc.Spawn(class'drawkey');
    }
   If(Key == 190)
    {
     bshowCoords=!bshowCoords;
    }
   If(Key == 97)
    {
     if(bpathedit)
     {
     cc.edit_x(cc.viewing,true);
     }
     else
     {
     if(demo04.ViewTarget == cc)
      {
       if(cc.basic_speed - cc.basic_speed/5 > 0)
        {
         cc.basic_speed=cc.basic_speed-cc.basic_speed/5;
         cc.basic_speed2=cc.basic_speed2-cc.basic_speed/5;
         speed=cc.basic_speed;
        }
      }
     else if(demo04.ViewTarget == demo04)
      {
       demo04speed=demo04speed-demo04speed/5;
       if(demo04speed < 0)
        demo04speed=0;
      }
      }
    }
   If(Key == 82)
    {
     if(demo04.ViewTarget == cc)
      {
       if(cc.basic_speed - 0.7 > 0)
        {
         cc.basic_speed=cc.basic_speed-0.7;
         cc.basic_speed2=cc.basic_speed2-0.7;
         speed=cc.basic_speed;
        }
      }
     else if(demo04.ViewTarget == demo04)
      {
       demo04speed=demo04speed-0.7;
       if(demo04speed < 0)
        demo04speed=0;
      }
    }
   If(Key == 98)
    {
    if(bpathedit)
     {
     cc.edit_x(cc.viewing,false);
     }
     else
      {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=cc.basic_speed+cc.basic_speed/5;
       cc.basic_speed2=cc.basic_speed2+cc.basic_speed2/5;
       speed=cc.basic_speed;
      }
     else if(demo04.ViewTarget == demo04)
      demo04speed=demo04speed+demo04speed/5;
    }
    }

   If(Key == 84)
    {
     if(demo04.ViewTarget == cc)
      {
       cc.basic_speed=cc.basic_speed+0.7;
       cc.basic_speed2=cc.basic_speed2+0.7;
       speed=cc.basic_speed;
      }
     else if(demo04.ViewTarget == demo04)
      demo04speed=demo04speed+1;
    }
   If(Key == 96)
    {
     demo04.ViewClass(class'multiplayercharacter');
    // bviewingdemorec=false;
     //bviewingcam=false;
     pc.bBehindView=true;
     behindview=pc.bBehindView;
     target=demo04.ViewTarget;
     target_actor=target;
     bTargetnone = false;
     watchedname = pawn(demo04.viewtarget).playerreplicationinfo.playername;
    }
///////////////////////////////////
//Demopausecam Controls:
///////////////////////////////////////////7
   If(key == 19)
    {
     bIsPaused=!bIsPaused;
     if(bpcam)
      cc.settimer(0.005,!bIsPaused);
    }

   If(((Key == 87) && bIsPaused) || ((Key == 87) && !serverdemo))
    {
     bw=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
      if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
   If(((Key == 83) && bIsPaused) || ((Key == 83) && !serverdemo))
    {
     bs=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
       if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
   If(((Key == 65) && bIsPaused) || ((Key == 65) && !serverdemo))
    {
     ba=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
       if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
   If(((Key == 68) && bIsPaused) || ((Key == 68) && !serverdemo))
    {
     bd=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
       if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
   If(((Key == 16) && bIsPaused) || ((Key == 16) && !serverdemo))
    {
     bdown=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
      if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
   If(((Key == 32) && bIsPaused) || ((Key == 32) && !serverdemo))
    {
     bup=true;
     if(bDrawdemorec)
      Viewportowner.bShowWindowsMouse=true;
      mouseX=Viewportowner.WindowsMouseX;
      mouseY=Viewportowner.WindowsMouseY;
      if(!waspressed)
        {
         lastmouseX=mouseX;
         lastmouseY=mouseY;
        }
       waspressed=true;
    }
///////////////////////////////////
//Demopausecam Controls End
///////////////////////////////////////////7
   If(Key == 102)
    {
     i=0;  //RadiusActors (class<Actor> BaseClass, out Actor Actor, float Radius, optional vector Loc)
     foreach pc.radiusActors(class'projectile', tproj, 2000, demo04.viewtarget.location)
     {
       //if(projcount == i)
        //{
         demo04.SetLocation(tproj.Location-vector(tproj.Rotation)*60);
         demo04.SetRotation(rotator(tproj.location-demo04.location));
         target=tproj;
         targeted_proj=tproj;
       // }
       //i++;
       break;

     }
     projcount++;
     proj_anz = i;
     projcount = projcount % proj_anz;
     demo04.ViewClass(class'democontroller');
     pc.SetViewTarget(demo04);

     //demo04.setviewtarget(target);
     bfollowtarget=true;

     bviewingcam=true;
     targeta=none;
     tanone=true;
     bViewingdemorec=false;
     pc.Level.GetLocalPlayerController().myHud.bHideHud=true;
     //h.bCrosshairShow=false;

     pc.bBehindView=true;
     behindview=pc.bBehindView;
     bTargetnone = false;
    }
   If(Key == 106)
    {
     targetlook=!targetlook;
     if(!bTargetnone)
      {
       if(targetlook && (target != None))
        cc.enable2=true;
       else
        cc.enable2=false;
      }
     else
      cc.enable2=false;
    }
   If(Key == 103)
    {
     if(bfovmode)
      {
       if(cc.fovplus)
        {
         cc.fovplus=false;
         cc.updateSplinef(true);
        }
       else
        cc.fovplus=true;
      }
     else
     {
     if(cc.rollplus)
      {
       cc.rollplus=false;
       cc.updateSplinef(true);
      }
     else
      cc.rollplus=true;
     }
    }
   If(Key == 104)
    {
     if(bfovmode)
      {
       if(cc.fovminus)
        {
         cc.fovminus=false;
         cc.updateSplinef(true);
        }
       else
        cc.fovminus=true;
      }
     else
     {
     if(cc.rollminus)
      {
       cc.rollminus=false;
       cc.updateSplinef(true);
      }
     else
     cc.rollminus=true;
     }
    }
   If(Key == 72)
    {
     drawHelp=!drawhelp;
    }
   If(Key == 73)
    {
     drawintro=!drawintro;
    }
   If(Key == 100)
    {
     flagcount--;
     Z=0;
     foreach pc.AllActors(class'Knoten', other3)
      {
       z++;
      }
     i=1;
     if(z == 4)
      {
       cc.destroy();
       cc = none;
      }
     else if(z > 4)
      {
       cc.SetTimer(0.0,false);
       cc.z=cc.z-1;
      }
     foreach pc.AllActors(class'Knoten', other3)
      {
       if(i == z)
        Other3.destroy();
       else
        distancemeter_pos=Other3.location;
       i++;
      }
     if(z > 4)
     {
      cc.updateSplinef(true);
      kabstand=cc.kabstand;
      mabstand=cc.mabstand;
     }
     else
     {
      foreach pc.AllActors(class'rotknoten', rk2)
        rk2.bHidden=true;

      tvect=vect(0,0,0);
      kabstand=0;
      mabstand=0;
      foreach pc.allActors(class'Knoten', other3)
      {
       if(tvect != vect(0,0,0))
       {
        if((VSize(other3.location-tvect) < kabstand) || (kabstand == 0))
         kabstand = VSize(other3.location-tvect);
        if((VSize(other3.location-tvect) > mabstand) || (mabstand == 0))
         mabstand = VSize(other3.location-tvect);
       }
        tvect = other3.location;
       }


    }
    }
  }
  if (Action == IST_Release)
   {
    if((Key == 87) || (Key == 83) || (Key == 65) || (Key == 68)|| (Key == 32)|| (Key == 16))
     {
      waspressed=false;
      if(key == 87)
       bw=false;
      if(key == 83)
       bs=false;
      if(key == 65)
       ba=false;
      if(key == 68)
       bd=false;
      if(key == 16)
       bdown=false;
      if(key == 32)
       bup=false;
     }
   }

	return false;
}

function bool HasMouseMoved( optional float ErrorMargin )
{
	return Abs(viewportowner.windowsMouseX - LastMouseX) > Abs(ErrorMargin) || Abs(viewportowner.windowsMouseY - LastMouseY) > Abs(ErrorMargin);
}


function NotifylevelChange()
{
   log(framecount);
   log("gg");
   bshowmarkers = false;
  //pc.player.InteractionMaster.RemoveInteraction(self);
  //pc.player.InteractionMaster.RemoveInteraction(findCamCommands());
  //cc.destroy();
}


function Tick(float deltatime)
{
if(bispaused)
 pc.Level.GetLocalPlayerController().myHud.pausedmessage=" ";

if(!serverdemo)
{
/*
if((demo04 != None) && !bViewingdemorec && !bViewingcam)
{
 if(!tanone && (targeta != none))
  {
   tanone=false;
   ps.setlocation(targeta.location + pawn(targeta).EyePosition());
   tr=normalize(targeta.rotation);
   //tr.pitch=(256 * Pawn(targeta).ViewPitch) & 65535;
   demo04.viewtarget.setrotation(tr);
  }
 else
  {
   tanone=true;
   bswitched=true;
   demo04.ViewClass(class'pawn');
   demo04.DemoViewNextPlayer();
   if(demo04.ViewTarget.owner != none)
   {
    bviewingdemorec=true;
    h.bShowWeaponBar=true;
    h.bshowpersonalinfo=true;
    h.bshowweaponinfo=true;
    demo04.ViewTarget.bHidden=false;
   }
   else
    {
     demo04.ViewTarget.bHidden=true;
     targeta=demo04.ViewTarget;
     tanone=false;
     demo04.SetViewTarget(ps);
    }
  }
 if(pc.viewtarget != demo04.ViewTarget)
  pc.SetViewTarget(demo04.viewtarget);
 if((pc.bBehindView) && !behindview)
  pc.bBehindView=false;
}
*/
if((demo04 != none) && (bViewingCam))
{
 if(pc.viewtarget != demo04.viewtarget)
  pc.SetViewTarget(demo04.viewtarget);
 if((pc.bBehindView) && !behindview)
  pc.bBehindView=false;
 if((!pc.bBehindView) && behindview)
  pc.bBehindView=true;
}
}
if(bgotoloc)
{
  tv=typeloc;
  demo04.setLocation(tv);
  demo04.setrotation(typerot);
  bgotoloc=false;
}
if(bw)
 {
  tv=demo04.Location;
     r=demo04.Rotation;
  mouseX=Viewportowner.WindowsMouseX;
       if(bDrawdemorec)
        Viewportowner.bShowWindowsMouse=true;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
       tv=tv+vector(r)*demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
 }
if(bs)
 {
  tv=demo04.Location;
     r=demo04.Rotation;
  mouseX=Viewportowner.WindowsMouseX;
       if(bDrawdemorec)
        Viewportowner.bShowWindowsMouse=true;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
      tv=tv-vector(r)*demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
 }
if(ba)
{
tv=demo04.Location;
     r=demo04.Rotation;
       mouseX=Viewportowner.WindowsMouseX;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
       tr=r;
       tr.yaw=tr.yaw+16384;
       tr.pitch=0;
       tv=tv-vector(tr)*demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
}
if(bd)
{
     tv=demo04.Location;
     r=demo04.Rotation;
       mouseX=Viewportowner.WindowsMouseX;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
       tr=r;
       tr.yaw=tr.yaw-16384;
       tr.pitch=0;
       tv=tv-vector(tr)*demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
}
if(bdown)
{
     tv=demo04.Location;
     r=demo04.Rotation;
       mouseX=Viewportowner.WindowsMouseX;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
       tr=r;
       tr.yaw=tr.yaw-16384;
       tr.pitch=0;
       tv.z=tv.z-demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
}
if(bup)
{
     tv=demo04.Location;
     r=demo04.Rotation;
       mouseX=Viewportowner.WindowsMouseX;
       mouseY=Viewportowner.WindowsMouseY;
       r.Yaw=r.yaw+(mouseX-lastmouseX)*100;
       r.pitch=r.pitch-(mouseY-lastmouseY)*100;
       tr=r;
       tr.yaw=tr.yaw-16384;
       tr.pitch=0;
       tv.z=tv.z+demo04speed;
       demo04.SetLocation(tv);
       demo04.SetRotation(r);
       lastmouseX=mouseX;
       lastmouseY=mouseY;
}

if((cc != none) && (bviewingcam))
if(demo04.viewtarget != none)
if((demo04.ViewTarget==cc) || (demo04.ViewTarget==cc.viewer01))
if(pc.FovAngle != cc.fov)
 pc.SetFOV(cc.fov);


if(!bTargetnone)
 {
  if((target != none) && (cc != none))
   cc.thisTarget.setlocation(target.location);
  if(target == none)
   {
    bTargetnone=true;
    //if(!bviewingcam && !bviewingdemorec)
     //bswitched=true;
   }
 }
if((seektime != 0) && (pc.GameReplicationInfo.RemainingTime <= seektime))
{
     pc.Level.Pauser = pc.PlayerReplicationInfo;
     pc.Level.TimeDilation=1.1;
     bispaused=true;
     seektime=0;
}
if((seektoframe != 0) && (seektoframe <= framecount))
{
     pc.Level.Pauser = pc.PlayerReplicationInfo;
     pc.Level.TimeDilation=1.1;
     bispaused=true;
     seektoframe=0;
}


if(serverdemo && btimedpath && !started)
foreach pc.dynamicactors(class'Pawn', tp)
{
if((abs(tp.location.x - timedvec.X) <= 2)
&& (abs(tp.location.y - timedvec.y) <= 2)
&& (abs(tp.Rotation.yaw - timedrot.yaw) <= 2))
{
 pc.ConsoleCommand("fixedfps"@30);
 //bispaused=true;
 //pc.Level.Pauser = pc.PlayerReplicationInfo;
 seektime=0;
 cc.timesangleichen();
 cc.inittimespline();
 log("Time: "@pc.level.TimeSeconds);
 log("serverdemo");
 startcam();
 started=true;
}
break;
}

if(!serverdemo && btimedpath && !started)
if(((pc.pawn != none)
&& (abs(pc.pawn.location.x - timedvec.X) <= 2)
&& (abs(pc.pawn.location.y - timedvec.y) <= 2)
&& (abs(pc.pawn.Rotation.yaw - timedrot.yaw) <= 2)))
{
pc.ConsoleCommand("fixedfps"@30);

//pc.clientmessage(abs(viewportowner.actor.pawn.location.x - timedvec.X));
//viewportowner.actor.clientmessage(abs(viewportowner.actor.pawn.location.y - timedvec.y));
//viewportowner.actor.clientmessage(abs(viewportowner.actor.pawn.Rotation.yaw - timedrot.yaw));
seektime=0;
cc.timesangleichen();
cc.inittimespline();
log("Time: "@pc.level.TimeSeconds);
startcam();
started=true;
}
if(!btargetnone && bfollowtarget)
{
 demo04.SetLocation(target.Location-vector(target.Rotation)*followdist);
 demo04.SetRotation(rotator(target.location-demo04.location));
}

if(bIncomingCam)
{
 demo04.SetViewTarget(demo04);
 cc.setlocation(target_actor.location);
 demo04.setviewtarget(cc);
 cc.SetRotation(rotator(target.location - cc.location));
}


   if(bKillScreens)
  {
   if(kSdCount == killshotdelay)
    {
     pc.level.timedilation = 1.1;
     pc.ConsoleCommand("Shot");
     kSdCount = 0;
     pc.Level.timedilation = killscreentimedi;
     lastkillscreen = framecount;
    }
   }


   if((bviewingcam) && (demo04 != none) && (demo04.viewtarget != none) && !bshowtime)
    {
     pc.setrotation(demo04.viewtarget.rotation);
     if(!pc.Level.GetLocalPlayerController().myHud.bHideHud)
      pc.Level.GetLocalPlayerController().myHud.bHideHud=true;
    }


   /*
   make
   class'GrapplerProjectile'
   class'GrapplerRope'
   invisible
   */
}


function PostRender(Canvas canvas)
{
   local Pawn xp;
   local Pawn tempPawn;
   local Emitter emit;
   local Tribeshudbase other_hud;
   local PosMarker posm;

   local float tf2;
   local float tf3;


    if(pc == none)
    pc=playercharactercontroller(viewportowner.actor);

   if(pc.ViewTarget == none)
    pc.setviewtarget(viewportowner.actor);


  if(pc.Level.Pauser == none)
   framecount++;

  if(bshowMarkers)
   {
    Canvas.SetPos(0,0);
    foreach pc.dynamicactors(class'PosMarker',posm)
    {
     if(posm.time == CurMarkTime)
     {
      tv=WorldToScreen(posm.location);
      if (!(tv.X <= 0 || tv.X >= Canvas.ClipX || tv.Y <= 0 || tv.Y >= Canvas.ClipY))
       {
        Canvas.Style = pc.ERenderStyle.STY_Alpha;
        Canvas.Font=Canvas.MedFont;
        Canvas.SetDrawColor(0,0,255);
        Canvas.SetPos(tv.x,tv.y);
        Canvas.DrawText("  <-"@posm.time);
       }
     }
    }
   }
  if(bshowknotendist && cc != none)
  {
    i=1;
    foreach pc.visibleactors(class'Knoten',other3)
    {
     tv=WorldToScreen(other3.location);
     Canvas.Style = pc.ERenderStyle.STY_Alpha;
     Canvas.Font=Canvas.MedFont;
     Canvas.SetDrawColor(0,0,255);
     Canvas.SetPos(tv.x,tv.y);
     Canvas.DrawText("  <-"@i@VSize(demo04.ViewTarget.location - other3.location));
     i++;
    }
  }

       if(leveltex != none)
       {
                       Canvas.OrgX=0;
                       Canvas.OrgY=0;
                       Canvas.SetPos(0,0);
                       Canvas.drawRect(leveltex,2000,2000);
                       if(!bweaponeffects)
                       {
                       foreach  pc.visibleactors(class'Pawn',xp,,demo04.viewtarget.location)
                        if(xp.location != pc.viewtarget.location)
                         Canvas.DrawActor(xp,false,false);
                       foreach  pc.visibleactors(class'Projectile',tproj,,demo04.viewtarget.location)
                       Canvas.DrawActor(tproj,false,true);
                       }
                       if(bweaponeffects)
                       foreach pc.visibleactors(class'Actor',ta)
                        {
                       if(ta.isA('Pawn'))
                        if(ta.location != pc.viewtarget.location)
                         Canvas.DrawActor(ta,false,true);
                        }
       }

       if(bwh)
       {
       foreach  pc.dynamicactors(class'Pawn',temppawn)
        if(((temppawn.location + temppawn.EyePosition()) != pc.viewtarget.location)
                               && (temppawn.location != pc.viewtarget.location))
       {
          Canvas.DrawActor(temppawn,false,true);
        /*
          tv=WorldToScreen(temppawn.location);
          Canvas.Style = pc.ERenderStyle.STY_Alpha;
          Canvas.Font=Canvas.TinyFont;
          Canvas.SetPos(tv.x,tv.y);
          tv=vect(0,0,0);
          tv.x=temppawn.Health;
          if(pawn(pc.viewtarget).controller.cansee(temppawn))
           tv.y=1;
          Canvas.DrawText(int(tv.x)@","@int(tv.y));
        */
       }

       foreach  pc.allactors(class'Projectile',tproj)
        Canvas.DrawActor(tproj,false,true);
       }
    Canvas.Font=Canvas.TinyFont;
  Canvas.bCenter = false;
  Canvas.SetPos(5, 100);
    if(drawhelp && !drawintro && !bdrawadvanced)
   {
    Canvas.Style = 1;
    Canvas.SetDrawColor(0,250,255);
    Canvas.Style = 3;
    Canvas.SetDrawColor(255,255,255);

    Canvas.DrawText(" H: turns Helpinfo on/off");
    Canvas.DrawText(" K: changes view to speccam");
    Canvas.DrawText(" Num'5': places new Campoint");
    Canvas.DrawText(" Num'4': removes last Campoint");
    Canvas.DrawText(" Num'3': starts Cam");
    Canvas.DrawText(" Num'+': views next Campoint");
    Canvas.DrawText(" Num'-': views previous Campoint");
    Canvas.DrawText(" Current Number of Campoints: "@flagcount@"/150");
    Canvas.SetDrawColor(0,255,0);
    if(cc != none)
    Canvas.DrawText(" selected Campoint(change with Num+/Num-): "@cc.viewing+1);
    Canvas.SetDrawColor(255,255,255);
    Canvas.DrawText(" 'Z': move selected Campoint to current spectatorcam location/rotation");
    Canvas.DrawText(" 'B': 'Z' also assigns the Campoint a new time(for timed path mode) false/true. Currently: "@bnewpointtime);
    Canvas.DrawText(" ");
    Canvas.DrawText(" Num'9': changes drawmode(3 different drawmodes)");
    Canvas.DrawText(" ");
    Canvas.DrawText(" !! SEE THE INCLUDED HTML TUTORIAL FOR ALL THE KEYBINDS !!");
    /*
    if(!Viewportowner.bShowWindowsMouse)
     {
      Canvas.DrawText(" Num'1': decreases speed");
      Canvas.DrawText(" Num'2': increases speed");
     }
    */
    Canvas.DrawText(" '1'-'9': for changing speed quickly");
    Canvas.SetDrawColor(0,255,0);
    if((demo04.ViewTarget == demo04) && !viewportowner.bshowwindowsmouse)
     Canvas.DrawText(" spectatorspeed = "@demo04speed);
    else
     Canvas.DrawText(" Camspeed = "@speed);
    Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText(" 'J': show advanced features");
   }
   if(bdrawadvanced)
    {
     Canvas.Style = 3;
     Canvas.SetDrawColor(255,255,255);
     Canvas.DrawText(" 'O': toggle rollmode/fovmode");
     if(!bfovmode)
      Canvas.DrawText(" currently in rollmode(num7/num8 will change roll)");
     else
      Canvas.DrawText(" currently in fovmode(num7/num8 will change fov)");
     Canvas.DrawText(" Num'7': increase roll/fov for current Campoint");
     Canvas.DrawText(" Num'8': decrease roll/fov for current Campoint");
     Canvas.DrawText(" 'U': speccam can go through walls on/off");
     Canvas.DrawText(" '.': shows coordinates, rotation, fov of current location on/off");
     Canvas.DrawText(" 'N': show time on/off");
     Canvas.DrawText(" 'P': when you pause the demo the Cam also stops on/off");
     Canvas.DrawText(" Num'0': selects a Player target");
     Canvas.DrawText(" Num'6': selects a Projectile target");
     if(!bTargetnone)
      {
       Canvas.SetDrawColor(0,255,0);
       if(target != none)
        {
         Canvas.bCenter=true;
         Canvas.DrawText(" Target: "@target@"  look at Target: "@targetlook);
        }
       else
        bTargetnone = true;
        Canvas.bCenter=false;
      }
     Canvas.DrawText(" Num'x': makes the Cam look at the Target");

     Canvas.DrawText(" 'J': close");
   }
   if(drawintro)
    {
    }
   if(bDrawdemorec && !bViewingcam && !serverdemo)
    {
     Canvas.Style = 3;
     Canvas.SetDrawColor(0,255,0);

     if(demo04.viewtarget == demo04)
     {
      demo04.setviewtarget(pc.viewtarget);

     }
     else if(bviewingdemorec && (demo04.viewtarget != none) && (pawn(demo04.viewtarget).playerreplicationinfo != none))
     {
      if(demo04.viewtarget != pc.viewtarget)
       demo04.setviewtarget(pc.viewtarget);
      //Canvas.DrawText(" Now Viewing From: "@pawn(demo04.viewtarget).playerreplicationinfo.playername@" - demorecorder");
     }
     else
     {
     if((demo04.viewtarget != none) && !tanone)
     {
      //Canvas.DrawText(" Now Viewing From: "@pawn(targeta).playerreplicationinfo.playername@" health: ");
      //Canvas.DrawText(" Primary Ammo: "@Pawn(pc.viewtarget).DesiredRotation);
     }
     Canvas.SetDrawColor(255,255,255);
     }
     //Canvas.DrawText(" Disable/Enable this text with 'L'");
    }
   if(bshowcoords)
    {
     Canvas.Style = 3;
     Canvas.SetDrawColor(255,255,255);
     Canvas.DrawText(" X = "@demo04.ViewTarget.location.x);
     Canvas.DrawText(" Y = "@demo04.ViewTarget.location.y);
     Canvas.DrawText(" Z = "@demo04.ViewTarget.location.z);
     Canvas.DrawText(" Yaw = "@demo04.ViewTarget.rotation.yaw);
     Canvas.DrawText(" Pitch = "@demo04.ViewTarget.rotation.pitch);
     Canvas.DrawText(" Roll = "@demo04.ViewTarget.rotation.roll);
     if(cc != none)
     Canvas.DrawText(" Fov = "@cc.fov);

     //if(!tanone)
      //Canvas.DrawText(" pitch = "@Pawn(targeta).ViewPitch);


     if(flagcount > 0)
     {
      Canvas.DrawText("");
      Canvas.DrawText(" Current Distance to last Campoint: "@VSize(demo04.ViewTarget.location - distancemeter_pos));
      if(flagcount >= 2)
      Canvas.DrawText("Campoint near enough to last Campoint: "@!(((VSize(demo04.ViewTarget.location - distancemeter_pos)
          /kabstand) > 15) || (mabstand/
          (VSize(demo04.ViewTarget.location - distancemeter_pos)) > 15)));

     }
    }


 if(bdrawframenumber)
 {
  Canvas.Style = pc.ERenderStyle.STY_Alpha;
  Canvas.Font=Canvas.MedFont;
  Canvas.SetDrawColor(255,255,255);
  //Canvas.DrawText(" Frame(deactivate with 'F') "@framecount,false);
  Canvas.DrawText(" Speccing: "@pawn(demo04.viewtarget).playerreplicationinfo.playername,false);
 }
 if(bKillScreens)
  {
   if(kSdCount > 0)
    kSdCount++;
   else if(Pawn(pc.viewtarget).playerreplicationinfo.score > kills)
    {
     pc.level.timedilation = 1.1;
          pc.ConsoleCommand("Shot");
     kSdCount = 1;
     kills=Pawn(pc.viewtarget).playerreplicationinfo.score;
    }
   } //bKillScreens

}// End of PostRender

defaultproperties
{
     weaponsty=1
     bVisible=True
     bRequiresTick=True
}
