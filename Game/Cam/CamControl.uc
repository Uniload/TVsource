//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CamControl extends Engine.actor config(RypelCam);


struct TMultiArray {
  var int Y[150];
};
var TMultiArray M[150];

var vector TargetLocation;
var rotator Targetrotation;
var bool C4D_Export;
var bool C4D_Export_Target;
var int drawcount;       // fuer drawkey

var bool  startCam;
var float x_speed;
var int z; // Zaehler fuer Anzahl der Knoten
var int Drawdetail;
var float basic_speed;
var float basic_speed2;     // zwischnespeicher für basic_speed
var bool draw_Spline;
var float fInserttime;
var bool activate_fit;
var bool I_want_to_insert_a_Flag;
var int insert_after_Flag;
var bool remove_the_specified_Flag;
var config int remove_Flag;
var int viewing;
var vector Flag_Locations[150];
var rotator Rotation_At_Flags[150];
var int Flag_Fovs[150];
var float Flag_Dist[150];
var float Flag_Times[150];
var bool usemouse;
var bool combineLoc;
var bool save_mouserotation;
var vector v;
var vector v2;
var float t;
var bool ssw;
var bool b_inAir;


var bool centerUTPlayer;
var bool centerTOPlayer;
var bool centerRocket;
var bool centerHE;
var bool centerConc;
var bool centerKnife;
var string targetList[150];
var string target;
var bool nextTarget;
var float Targeteyeheight;
var actor thisTarget;
var class<Actor> thisTargetClass;
var bool saveTarget;
var float when_to_target[150];
var int wtt_count;
var bool wtt_flags;
var bool markEnd;
var bool smoothTransitions;
var int targetCount;
var int tCount;
var int save_at;
var bool enable2;
var actor tempactor;

var float CurFrame;


var int flag_zaehler;
var float start_CurTime;
var float x[150]; // für Zeitachse

var int p_zaehler;
var int p_zaehler2;
var float p_time;
var int at_zaehler;
var int ka_zaehler;
var float demospeed; // something between
var float demospeed2;
var int dt_zaehler;
var int dt2_zaehler;
var float startzeit;
var bool autostart;
var bool start;
var float iu;
var rotator rotat;
var rotator rotat2;
var Viewer viewer01;
var config bool conf;
var bool drawSplineWasFalse;
var bool justSpawn; // wenn Knoten nur ohne upzudaten gespawnt werden sollen;
var democontroller Demo3;
var float counter;          // für c4d.txt
var bool is_spawning;       // wenn true knoten nicht nach demo3 ausrichten
var vector trc4dexport;



var bool rollplus,rollminus;

var float fov;
var bool fovplus,fovminus;
var float tfov;
var float dist;
var float accel;
var float t0,v0;
var bool bbadaccel;
var bool btimedpath;
var vector timedvec;
var rotator timedrot;
var float carry;
var vector v2old;
var float derivates[150];
var bool bisdrawing;

var int testzaehler;
var float testdist;
var bool bnewpointtime;
var bool bredox;
var float kabstand;
var float mabstand;
var bool bxedited;



var float a_a[150];var float a_b[150]; var float a_c[150]; var float a_d[150];
var float b_a[150];var float b_b[150]; var float b_c[150]; var float b_d[150];
var float c_a[150];var float c_b[150]; var float c_c[150]; var float c_d[150];
var float yaw_a[150];var float yaw_b[150]; var float yaw_c[150]; var float yaw_d[150];
var float pitch_a[150];var float pitch_b[150]; var float pitch_c[150]; var float pitch_d[150];
var float roll_a[150];var float roll_b[150]; var float roll_c[150]; var float roll_d[150];
var float fov_a[150];var float fov_b[150]; var float fov_c[150]; var float fov_d[150];


function PostBeginPlay()
{
local int i;
local Knoten Other;
local democontroller Other2;


foreach AllActors(class'democontroller', Other2)
 {
  Demo3=Other2;
  break;
 }
if(!conf)
 {
  basic_speed=3;// you can set the basic speed here
  basic_speed2=basic_speed;
  startzeit=0; //you can set the starttime for automatic starting here
  autostart=false; //set this to false if you want to start manually
  z=0;
  viewing = 0;
  drawDetail=30;
  usemouse=false;
  foreach AllActors(class'Knoten', Other)
   {
    SetLocation(Other.location);
    break;
   }
 }
else
 {
  is_spawning=true;
  for(i=0;i<z;i++)
   {
    Spawn(class'Knoten',,,Flag_Locations[i]);
   }
  i=0;
  foreach AllActors(class'Knoten', Other)
   {
    Other.setRotation(Rotation_At_Flags[i]);
    Other.fov=Flag_Fovs[i];
    Other.time=Flag_times[i];
    i++;
   }
  updateSplinef(true);
  SetLocation(Flag_Locations[0]);

  //Demo3.SetLocation(location);
 } //else

if(viewer01 == none)
viewer01=Spawn(class'Viewer');

draw_Spline=true;
drawSplineWasFalse = false;
start=!autostart;
I_want_to_insert_a_Flag = false;
conf=false; //nachdem geladen wurde soll die Klasse wie eine ohne config behandelt werden

targetCount = 0;
counter=0;
t=0;
x_speed=10;
C4D_Export=false;
is_spawning=false;
enable2=false;
Demo3.RotationRate.pitch=65536;
self.Tag=demo3.Tag;
//fov=100;
accel=0;

if(thisTarget == none)
thisTarget = Spawn(class'scl');
SetTimer(0.005,true);

} //:::::::::::::: Ende PostBeginPlay ::::::::::::::::://///////


//-------------Start Get´er and Set´er
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
update_flags();
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
     j=0;
     foreach AllActors(class'Knoten', Other)
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
update_flags();
}
function set_Flag_Fovs(float tf, int i)
{
Flag_Fovs[i]=tf;
update_flags();
}
function get_Flag_Fovs(int i, out float tf)
{
tf=Flag_Fovs[i];
}
function set_Flag_Times(float tf, int i)
{
Flag_Times[i]=tf;
update_flags();
}
function get_Flag_Times(int i, out float tf)
{
tf=Flag_Times[i];
}

//-------------End Get´er and Set´er

function update_flags()
{
local int z2,z3;
local knoten other,other10;
local bool negdisp;
local float disp;
local vector tv;
z2=0;
foreach AllActors(class'Knoten', Other)
 {

  if(Other.fov != Flag_Fovs[z2])
   {
    Other.fov=Flag_Fovs[z2];
    if((viewing == z2) && (demo3.viewtarget == viewer01))
     fov = Flag_Fovs[z2];
   }
  if(Other.time != Flag_times[z2])
   {
    Other.time=Flag_times[z2];
   }
  if(Other.Location != Flag_Locations[z2])
   {
    if(!combineLoc)
     {
      Other.SetLocation(Flag_Locations[z2]);
      if(viewing == z2) viewer01.setLocation(Flag_Locations[z2]);
     }
    else
     {
      tv=vect(0,0,0);
      if(Other.Location.x != Flag_Locations[z2].x)
       {
        negDisp = Other.Location.x < Flag_Locations[z2].x;
        disp=abs(Other.Location.X - Flag_Locations[z2].X);
       }
      if(Other.Location.y != Flag_Locations[z2].y)
       {
        negDisp = Other.Location.y < Flag_Locations[z2].y;
        disp=abs(Other.Location.y - Flag_Locations[z2].y);

       }
      if(Other.Location.z != Flag_Locations[z2].z)
       {
        negDisp = Other.Location.z < Flag_Locations[z2].z;
        disp=abs(Other.Location.z - Flag_Locations[z2].z);
       }
      z3=0;
      foreach AllActors(class'Knoten', Other10)
       {
        if(Other10 != Other)
         {
          tv=Other10.location;
          if(Other.Location.x != Flag_Locations[z2].x)
           if(negDisp)
            tv.x=Other10.location.X+disp;
           else
            tv.x = Other10.location.X-disp;
          if(Other.Location.y != Flag_Locations[z2].y)
           if(negDisp)
            tv.y = Other10.location.y+disp;
           else
            tv.y = Other10.location.y-disp;
          if(Other.Location.z != Flag_Locations[z2].z)
           if(negDisp)
            tv.z = Other10.location.z+disp;
           else
            tv.z = Other10.location.z-disp;
          Flag_Locations[z3]=tv;
          Other10.SetLocation(tv);
          if(viewing == z3) viewer01.setLocation(Flag_Locations[z3]);
         }
        z3++;
       }
       Other.SetLocation(Flag_Locations[z2]);
       if(viewing == z2) viewer01.setLocation(Flag_Locations[z2]);
     }
     break;
   }
  if(Other.Rotation != Rotation_At_Flags[z2])
   {
    Other.SetRotation(Rotation_At_Flags[z2]);
    if(viewing == z2) viewer01.setRotation(Rotation_At_Flags[z2]);
    break;
   }
  z2++;
 }
}


function timesangleichen()
{
local float dif;
local int i;
local Knoten Other;
dif=Level.TimeSeconds-Flag_Times[0];
for(i=0; i < z; i++)
{
 Flag_Times[i]=Flag_Times[i]+dif;
 //log(Flag_Times[i]);
}
i=0;
foreach AllActors(class'Knoten', Other)
{
 Other.time=other.time+dif;
}
//log("dif: "@dif);
}


function updateViewer(bool dec)
 {
  if(Demo3.ViewTarget != viewer01)
   {
    Demo3.setViewTarget(viewer01);
    Demo3.bBehindView=true;
    viewer01.changeView(viewing,z-1,false,false);
   }
  else
   viewer01.changeView(viewing,z-1,!dec,dec);
 }

function removeFlag()
 {
  local Knoten Other;
  local int i; i=0;
  foreach AllActors(class'Knoten', Other)
   {
    if(i == remove_Flag)
     Other.destroy();
    i++;
   }
  for(i=remove_Flag;i<z;i++)
   {
    Flag_Locations[i]=Flag_Locations[i+1];
    Rotation_At_Flags[i]=Rotation_At_Flags[i+1];
   }
  z=z-1;
  updateSplinef(true);
 }

function FlagEinfuegen()
{
local Knoten Other;
local vector v10;
local int i;
I_want_to_insert_a_Flag = false;
i=0;
SetTimer(0,false);
foreach AllActors(class'Knoten', Other)
 {
  if(i == z)
  v10=Other.Location;
  i++;
 }
for(i=z-1;i>insert_after_Flag;i--)
 {
  Flag_Locations[i+1]=Flag_Locations[i];
  Rotation_At_Flags[i+1]=Rotation_At_Flags[i];
 }
Flag_Locations[insert_after_Flag+1]=v10;
foreach AllActors(class'Knoten', Other)
Other.destroy();
z=z+1;
justSpawn=true;
for(i=0;i<z;i++)
Spawn(class'Knoten',,,Flag_Locations[i]);
justSpawn=false;
i=0;
foreach AllActors(class'Knoten', Other)
 {
  Other.setRotation(Rotation_At_Flags[i]);
  i++;
 }
updateSplinef(true);
I_want_to_insert_a_Flag = true;
}  //:::::::::: Ende FlagEinfuegen ::::::::::::://///

function updateSplinef(bool draw)
{
local Knoten Other;
local rotknoten Other2;
SetTimer(0.005,false);
z=0;
foreach AllActors(class'Knoten', Other)
 {
  Flag_Locations[z]=Other.Location;
  Rotation_At_Flags[z]=Other.Rotation;
  Flag_Fovs[z]=Other.fov;
  Flag_times[z]=Other.time;
  z++;
 }
foreach AllActors(class'rotknoten', Other2)   // um doppeltes Anzeigen zu verhindern
 {
  Other2.Destroy();
 }
set_x();
KubSplineKoeffNat();
if(draw)
{
 drawPath();
 drawcount=0;
}
else
 drawcount=2;
dist=0;
flag_dist[0]=0;
SetTimer(0.005,true);
} //:::::::::: Ende updateSplinef ::::::::::::::////


function Timer()
{
local int j;
local float d1;
local int n;
local Knoten Other;
local rotknoten Other2;
local float tempdist;
local vector v3;

local rotator tr;


if(Demo3.ViewTarget != None)
{
targetLocation=demo3.viewtarget.Location;
targetRotation=demo3.viewtarget.Rotation;
}

if(fovplus)
{
Flag_Fovs[viewing]=Flag_Fovs[viewing]+1;
update_flags();
}
if(fovminus)
{
Flag_Fovs[viewing]=Flag_Fovs[viewing]-1;
update_flags();
}
if(rollplus)
{
rotation_at_flags[viewing].roll=rotation_at_flags[viewing].roll-70;
update_flags();
}
if(rollminus)
{
rotation_at_flags[viewing].roll=rotation_at_flags[viewing].roll+70;
update_flags();
}


if(remove_the_specified_Flag == true)
{
setTimer(0.005,false);
removeFlag();
remove_the_specified_Flag = false;
}

if(autostart == true)
{
start=false;
}
if(autostart == false)
{
start=true;
}
if((draw_Spline == false) && (!drawSplineWasFalse))
{
foreach AllActors(class'Knoten', Other)
Other.bHidden=true;
foreach AllActors(class'rotknoten', Other2)
Other2.bHidden=true;
drawSplineWasFalse=true;
drawcount=1;
}
if((drawSplineWasFalse == true) && (draw_Spline == true))
{
foreach AllActors(class'Knoten', Other)
Other.bHidden=false;
foreach AllActors(class'rotknoten', Other2)
Other2.bHidden=false;
drawSplineWasFalse=false;
drawcount=0;
}


if(startCam == true)
{
basic_speed2=basic_speed;
ssw=true;
startCam = false;
v2=vect(0,0,0);
v=Flag_Locations[0];
rotat=Rotation_At_Flags[0];;
t=0;
p_time=0;
at_zaehler=0;ka_zaehler=0;
dt_zaehler=0;dt2_zaehler=0;
iu=0;
demospeed=1;demospeed2=0;
p_zaehler=0;p_zaehler2=0;
setLocation(v);
setRotation(rotat);
flag_zaehler=1;
wtt_count=0;
tCount=0;
p_time=0;
dist=0;
counter=2;
trc4dexport=vector(rotation);


setTimer(0.005,true);
}

n=z;
if(ssw == true)
{
if(!start){                              //!!!!!!!!!!!ACHTUNG!!!!!!!!!

start = true;
}

if(t>=x[z-1])
{
ssw=false;
Log("This is the end my friend");
}

if((t<x[z-1]) && start)
{

if(btimedpath)
{
  spline_pchip_val ( z, Flag_Times, x, derivates, 1, Level.TimeSeconds,t);
}

for(j=0;j<n-1;j++){
if(t>=x[j])
 if(t<x[j+1]){
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 v3=v2-v;
 norm(d1,v3);
 tempdist=0;
 if(carry != 0)
   tempdist=tempdist+carry;

 testzaehler=0;

 while(!btimedpath && (tempdist < basic_speed2) && (t<x[j+1])){
 testzaehler++;
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 v3=v2-v;
 norm(d1,v3);
 t=t+0.0005;
 dist=dist+d1;
 tempdist=tempdist+d1;
 v=v2;
if((t >= x[flag_zaehler]) && (flag_zaehler < z))
{
/*
log("-----------------");
log("Flag "@flag_zaehler@" reached at "@Level.TimeSeconds);
log("Expected time: "@flag_times[flag_zaehler]);
log("Timeerror: "@abs(level.TimeSeconds-flag_times[flag_zaehler]));
log("Distance: "@dist-flag_dist[flag_zaehler-1]);
log("Expected distance: "@flag_dist[flag_zaehler]-flag_dist[flag_zaehler-1]);
log("Distancerror: "@abs(dist-flag_dist[flag_zaehler-1]-(flag_dist[flag_zaehler]-flag_dist[flag_zaehler-1])));
*/
flag_zaehler++;
}
 } //while
if(btimedpath && (t >= x[flag_zaehler]) && (flag_zaehler < z))
{
/*
log("-----------------");
log("Flag "@flag_zaehler@" reached at "@Level.TimeSeconds);
log("Expected time: "@flag_times[flag_zaehler]);
log("Timeerror: "@abs(level.TimeSeconds-flag_times[flag_zaehler]));
log(t);
log(x[flag_zaehler]);
*/
flag_zaehler++;
}
if(btimedpath || (tempdist >= basic_speed2) && (t<x[j+1])){
 v=v2;
 setLocation(v);
 fov=tfov;
 KubSplineWertYaw(t,j);
 KubSplineWertPitch(t,j);
 KubSplineWertRoll(t,j);
 KubSplineWertFov(t,j);
 carry=0;
 if(!enable2)   // wenn enable dann Sicht auf Target
  setRotation(rotat);
 }
  else
  {
  /*
  log("tempdist: "@tempdist@" basic_speed2: "@basic_speed2);
  log("LevelTimeseconds: "@level.timeseconds);
  spline_pchip_val ( z, Flag_Times, Flag_Dist, derivates, 1, Level.TimeSeconds, carry );
  log("dist: "@dist@" soll-dist: "@carry);
  */
  carry=tempdist;
  }
 }
if(j==n-2)
 if(t==x[j+1]){
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 KubSplineWertYaw(t,j);
 KubSplineWertPitch(t,j);
 KubSplineWertRoll(t,j);
 KubSplineWertFov(t,j);
 v3=v2-v;
 norm(d1,v3);
 dist=dist+d1;
 t=t+0.0005;
 v=v2;
 setLocation(v);
 fov=tfov;
 if(!enable2)  // wenn enable dann Sicht auf Target
 setRotation(rotat);
 }
 }
}
}
if((t>when_to_target[wtt_count]) && (wtt_count < 49))
wtt_count++;
if(enable2)
 {
  tr=rotator(thisTarget.Location - Location);
  tr.roll=rotat.roll;
  setRotation(tr);
 }
if((t >= x[z-1]) && !enable2)
SetTimer(0.05,true);
} ///::::::::::::::: Timer Ende ::::::::::::::::////////////


function norm(out float f2,vector v3){
f2 = sqrt((v3.X)*(v3.X)+(v3.Y)*(v3.Y)+(v3.Z)*(v3.Z));
}


function KubSplineWertX(float t, int j)
{
v2.X=a_a[j]+a_b[j]*(t-x[j])+a_c[j]*(t-x[j])*(t-x[j])+a_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertY(float t, int j)
{
v2.Y=b_a[j]+b_b[j]*(t-x[j])+b_c[j]*(t-x[j])*(t-x[j])+b_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertZ(float t, int j)
{
v2.Z=c_a[j]+c_b[j]*(t-x[j])+c_c[j]*(t-x[j])*(t-x[j])+c_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertYaw(float t, int j)
{
rotat.yaw=yaw_a[j]+yaw_b[j]*(t-x[j])+yaw_c[j]*(t-x[j])*(t-x[j])+yaw_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertPitch(float t, int j)
{
rotat.pitch=pitch_a[j]+pitch_b[j]*(t-x[j])+pitch_c[j]*(t-x[j])*(t-x[j])+pitch_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertRoll(float t, int j)
{
rotat.roll=roll_a[j]+roll_b[j]*(t-x[j])+roll_c[j]*(t-x[j])*(t-x[j])+roll_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}
function KubSplineWertFov(float t, int j)
{
tfov=fov_a[j]+fov_b[j]*(t-x[j])+fov_c[j]*(t-x[j])*(t-x[j])+fov_d[j]*(t-x[j])*(t-x[j])*(t-x[j]);
}


function equalArray(float a1[150], out float b1[150])
{
local int i;
for(i=0;i<150;i++)
b1[i]=a1[i];
}

function Cholesky(float k[150], out float erg[150]){
local int n;
local int i;
local float d[150];
local float g[150];
local float z1[150];
local float e[150];
n=z-3;
for(i=0;i<=n;i++){
d[i]=0;g[i]=0;e[i]=0;z1[i]=0;erg[i]=0;
}
d[0]=M[0].Y[0];
for (i=1;i<=n;i++){
    g[i-1]=M[i].Y[i-1]/d[i-1];
    d[i]=M[i].Y[i]-g[i-1]*M[i].Y[i-1];
}
d[n]=M[n].Y[n]-M[n].Y[n-1]*g[n-1];
z1[0]=k[0];
for (i=1;i<=n;i++)
    z1[i]=k[i]-g[i-1]*z1[i-1];
for (i=0;i<=n;i++)
    e[i]=z1[i]/d[i];
erg[n]=e[n];
for (i=n-1;i>=0;i--)
    erg[i]=e[i]-g[i]*erg[i+1];
}


function KubSplineKoeffNat(){
local int n;
local float k[150],y[150],h1[150];
local float ska[150],skb[150],skc[150],skd[150];
local int i,h,o,j;
n=z-1;   // !!!!!!!!!!!!!!

// Matrix M mit 0 vorinitialisieren
  for(i=0;i<150;i++)
  for(j=0;j<150;j++)
  M[i].Y[j]=0;

for(i=0;i<=n;i++){
ska[i]=0;skb[i]=0;skc[i]=0;skd[i]=0;
}
h=7;o=0;
//if(roteingetragen) h=6;
//else h=3;
for(o=0;o<h;o++){
if(o==0)
for(i=0;i<150;i++)
y[i]=Flag_Locations[i].X;
if(o==1)
for(i=0;i<150;i++)
y[i]=Flag_Locations[i].Y;
if(o==2)
for(i=0;i<150;i++)
y[i]=Flag_Locations[i].Z;
if(o==3)
for(i=0;i<150;i++)
y[i]=Rotation_At_Flags[i].Yaw;
if(o==4)
for(i=0;i<150;i++)
y[i]=Rotation_At_Flags[i].Pitch;
if(o==5)
for(i=0;i<150;i++)
y[i]=Rotation_At_Flags[i].Roll;
if(o==6)
for(i=0;i<150;i++)
y[i]=Flag_Fovs[i];
//erster und letzter Koeffizient, sowie b(1) und b(n) werden gleich auf 0
//die anderen ci´s werden durch aufstellen der Matrix und anschließende
//Anwendung der Cholesky-Zerlegung berechnet
skc[0]=0;
skc[n]=0;
skb[0]=0;
skb[n]=0;
for (j=1; j<=n-1;j++)
    skb[j]=3*((y[j+1]-y[j])/(x[j+1]-x[j]) - (y[j]-y[j-1])/(x[j]-x[j-1]));
M[0].Y[0]=2*(x[2]-x[0]);
M[0].Y[1]=x[2]-x[1];
for (i=0; i<=n-4;i++){
    M[i+1].Y[i]=1*(x[i+2]-x[i+1]);
    M[i+1].Y[i+1]=2*(x[i+3]-x[i+1]);
    M[i+1].Y[i+2]=1*(x[i+3]-x[i+2]);
}
M[n-2].Y[n-3]=1*(x[n-1]-x[n-2]);
M[n-2].Y[n-2]=2*(x[n]-x[n-2]);
for (i=1;i<=n-1;i++)
    k[i-1]=skb[i];
Cholesky(k,h1);
//da h c(1) bis c(n) enthält braucht es diese kleine for schleife um nicht
//c(0) zu überschreiben:
for (i=1;i<=n-1;i++)
    skc[i]=h1[i-1];

//Berechnung der di´s und bi´s aus den ci´s,den xi´s und den yi´s
for (i=0; i<=n-1; i++){
    skd[i]=(skc[i+1]-skc[i])/(3*(x[i+1]-x[i]));
    skb[i]=(y[i+1]-y[i])/(x[i+1]-x[i]) - ((x[i+1]-x[i])*(skc[i+1]+2*skc[i]))/3;
}
equalArray(y,ska);
for (i=0;i<n;i++)
    k[i]=0;
if(o==0){
equalArray(ska,a_a);equalArray(skb,a_b);equalArray(skc,a_c);equalArray(skd,a_d);
}
if(o==1){
equalArray(ska,b_a);equalArray(skb,b_b);equalArray(skc,b_c);equalArray(skd,b_d);
}
if(o==2){
equalArray(ska,c_a);equalArray(skb,c_b);equalArray(skc,c_c);equalArray(skd,c_d);
}
if(o==3){
equalArray(ska,yaw_a);equalArray(skb,yaw_b);equalArray(skc,yaw_c);equalArray(skd,yaw_d);
}
if(o==4){
equalArray(ska,pitch_a);equalArray(skb,pitch_b);equalArray(skc,pitch_c);equalArray(skd,pitch_d);
}
if(o==5){
equalArray(ska,roll_a);equalArray(skb,roll_b);equalArray(skc,roll_c);equalArray(skd,roll_d);
}
if(o==6){
equalArray(ska,fov_a);equalArray(skb,fov_b);equalArray(skc,fov_c);equalArray(skd,fov_d);
}
}// for o
}

function edit_x(int i, bool bminus)
{
 local rotknoten other2;
 local int j;
 local float tempdiff;
  bxedited = true;

 if(i == 0)
  return;
 tempdiff = (x[i] - x[i-1])/7;
 if(bminus)
  {
   if((x[i] - tempdiff) > x[i-1])
    for(j=i;j<z;j++)
     x[j]= x[j] - tempdiff;
  }
 else
  {
   for(j=i;j<z;j++)
    x[j]= x[j] + tempdiff;
  }
 KubSplineKoeffNat();

 foreach AllActors(class'rotknoten', Other2)   // um doppeltes Anzeigen zu verhindern
 {
  Other2.Destroy();
 }
 drawPath();
 drawcount=0;
 }


function set_x(){
local float zeitpunkt;
local int i;
local float t2;
zeitpunkt=0;
x[0]=0;
if(!bxedited)
{
 kabstand = VSize(Flag_Locations[1]-Flag_Locations[0]);
 mabstand = kabstand;
 for(i=1;i<z;i++)
  {
  t2=VSize(Flag_Locations[i]-Flag_Locations[i-1]);
  if(t2 < kabstand)
   kabstand = t2;
  else if(t2 > mabstand)
   mabstand = t2;
  }

for(i=1;i<z;i++)
x[i] = x[i-1] + 2*(VSize(Flag_Locations[i]-Flag_Locations[i-1])/kabstand);
}
else
 x[z-1] = x[z-2] + 2*(VSize(Flag_Locations[z-1]-Flag_Locations[z-2])/kabstand);
}// set_X


//-------------------------------------------------------
function drawpath(){
local int n;
local int j;
local float d1,tempdist;
local vector v3;
flag_dist[0]=0;
t=0;
v=vect(0,0,0);
v2=vect(0,0,0);
v=Flag_Locations[0];
n=z;
t=0;
dist=0;
while(t<x[z-1])
{
bisdrawing=true;
for(j=0;j<n-1;j++){    //for(j=1;j<n;j++){
if(t>=x[j])
 if(t<x[j+1]){
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 v3=v2-v;
 norm(d1,v3);
 tempdist=0;
 if(carry != 0)
   tempdist=carry;

 while((tempdist < drawDetail) && (t<x[j+1])){
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 v3=v2-v;
 norm(d1,v3);
 t=t+0.005;
 tempdist=tempdist+d1;
 dist=dist+d1;
 v=v2;
 flag_dist[j+1]=dist;
 }
 if((tempdist >= drawDetail) && (t<x[j+1])){
 v=v2;
 Spawn(class'rotknoten',,,v);
 flag_dist[j+1]=dist;
 carry=0;
 }
 else
  carry=tempdist;
 }
if(j==n-2)
 if(t==x[j+1]){
 KubSplineWertX(t,j);
 KubSplineWertY(t,j);
 KubSplineWertZ(t,j);
 v3=v2-v;
 norm(d1,v3);
 dist=dist+d1;
 flag_dist[j+1]=dist;
 t=t+0.005;
 v=v2;
 Spawn(class'rotknoten',,,v);
 }
 }
}
 if(bisdrawing)
  {
   bisdrawing=false;
   }
}

//------------------------------ timespline functions --------------------------//////////
//function [ fe, next, ierr ] = chfev ( x1, x2, f1, f2, d1, d2, ne, xe )
function chfev(float x1, float x2, float f1, float f2, float d1, float d2, int ne, float xe,
                     out float fe, int next[2])
{
 local float h,xmi,xma,delta,del1,del2,c2,c3,lx;
 h = x2 - x1;
 next[0] = 0;
 next[1] = 0;
 if(h < 0.0)
  xmi = h;
 else
  xmi = 0.0;
  //xmi = min ( 0.0, h );
 if(h > 0.0)
  xma = h;
 else
  xma = 0.0;
  //xma = max ( 0.0, h );
  delta = ( f2 - f1 ) / h;
  del1 = ( d1 - delta ) / h;
  del2 = ( d2 - delta ) / h;
  c2 = -( del1 + del1 + del2 );
  c3 = ( del1 + del2 ) / h;
 lx = xe - x1;
 fe = f1 + lx * ( d1 + lx * ( c2 + lx * c3 ) );
 if ( lx < xmi )
  next[0] = next[0] + 1;
 if ( xma < lx )
  next[1] = next[1] + 1;

}
//function value = pchst ( arg1, arg2 )
function pchst(float arg1, float arg2, out float value)
{
 if ( arg1 == 0.0 )
    value = 0.0;
  else if ( arg1 < 0.0 )
   {
    if ( arg2 < 0.0 )
      value = 1.0;
    else if ( arg2 == 0.0 )
      value = 0.0;
    else if ( 0.0 < arg2 )
      value = -1.0;
   }
  else if ( 0.0 < arg1 )
   {
    if ( arg2 < 0.0 )
      value = -1.0;
    else if ( arg2 == 0.0 )
      value = 0.0;
    else if ( 0.0 < arg2 )
      value = 1.0;
   }
}
//function d = spline_pchip_set ( n, x, f )
function spline_pchip_set(int n, float x[150], float f[150], out float d[150])
{
  local int nless1,i;
  local float h1,h2,hsum,hsumt3,dmax,dmin,drat1,drat2,w1,w2,del1,del2,dsave,value1,value2,temp;
  nless1 = n - 1;
  h1 = x[1] - x[0];
  del1 = ( f[1] - f[0] ) / h1;
  dsave = del1;
  if ( n == 2 )
   {
    d[0] = del1;
    d[n-1] = del1;
    return;
   }
  h2 = x[2] - x[1];
  del2 = ( f[2] - f[1] ) / h2;
  hsum = h1 + h2;
  w1 = ( h1 + hsum ) / hsum;
  w2 = -h1 / hsum;
  d[0] = w1 * del1 + w2 * del2;

 pchst ( d[0], del1, value1 );
 pchst ( del1, del2, value2 );
 if ( value1 <= 0.0 )
  d[0] = 0.0;
 else if ( value2 < 0.0 )
  {
   dmax = 3.0 * del1;
   if ( abs ( dmax ) < abs ( d[0] ) )
    d[0] = dmax;
  }

  for (i=2;i<=nless1;i++)
   {
    if ( 2 < i )
     {
      h1 = h2;
      h2 = x[i] - x[i-1];
      hsum = h1 + h2;
      del1 = del2;
      del2 = ( f[i] - f[i-1] ) / h2;
     }
    d[i-1] = 0.0;
    pchst ( del1, del2, temp );
    if ( temp < 0.0 )
     {
      dsave = del2;
     }
    else if ( temp == 0.0 )
      if ( del2 != 0.0D+00 )
        dsave = del2;
    if(temp > 0.0)
     {
      hsumt3 = 3.0 * hsum;
      w1 = ( hsum + h1 ) / hsumt3;
      w2 = ( hsum + h2 ) / hsumt3;
      dmax = fmax ( abs ( del1 ), abs ( del2 ) );
      dmin = fmin ( abs ( del1 ), abs ( del2 ) );
      drat1 = del1 / dmax;
      drat2 = del2 / dmax;
      d[i-1] = dmin / ( w1 * drat1 + w2 * drat2 );
     }
    }


  w1 = -h2 / hsum;
  w2 = ( h2 + hsum ) / hsum;
  d[n-1] = w1 * del1 + w2 * del2;

  pchst ( d[n-1], del2, value1 );
  pchst ( del1, del2, value2 );
  if ( value1 <= 0.0 )
    d[n-1] = 0.0;
  else if ( value2 < 0.0 )
   {
    dmax = 3.0 * del2;
    if ( abs ( dmax ) < abs ( d[n-1] ) )
      d[n-1] = dmax;
   }
}

//function fe = spline_pchip_val ( n, x, f, d, ne, xe )
function spline_pchip_val(int n, float x[150], float f[150], float d[150], int ne, float xe, out float fe)
{
  local int j_first,j_save,ir,j,i,j_new;
  local int next[2];
  local float nj;

  j_first = 1;
  ir = 2;

  while ( true )
  {
    if ( ne < j_first )
      break;
    j_save = ne + 1;

    //for j = j_first : ne
    for(j=j_first; j<=ne; j++)
      if ( x[ir-1] <= xe )
       {
        j_save = j;
        if ( ir == n )
          j_save = ne + 1;
        break;
       }
       j = j_save;

    nj = j - j_first;
    if ( nj != 0 )
    {
     chfev ( x[ir-2], x[ir-1], f[ir-2], f[ir-1], d[ir-2], d[ir-1],  nj, xe, fe, next );
    if ( next[0] != 0 )
     {
        //log("klaro");
        if ( ir > 2 )
         {
          j_new = -1;
            if ( xe < x[ir-2] )
             {
              j_new = 1;
              break;
             }
          j = j_new;
          //for i = 1 : ir-1
          for(i=1;i<=ir-1;i++)
            if ( xe < x[i-1] )
              break;
          ir = 1;
         }
     }
    j_first = j;

  }

    ir = ir + 1;

    if ( n < ir )
      break;

 }
}

function inittimespline()
{
spline_pchip_set ( z, Flag_Times, x, derivates );
}


function evaltimespline(float t, out float erg) // only for testing
{
local int n;
local float lx[150],f[150],d[150],fe;
n=10;
lx[0]=0;lx[1]=2;lx[2]=4;lx[3]=6;lx[4]=8;lx[5]=10;lx[6]=12;lx[7]=14;lx[8]=16;lx[9]=18;
f[0]=1;f[1]=3;f[2]=4;f[3]=6;f[4]=10;f[5]=11;f[6]=13;f[7]=14;f[8]=16;f[9]=20;
//x=[ 0 2 4 6 8 10 12 14 16 18 ];
//f=[ 1 3 4 6 10 11 13 14 16 20 ];
spline_pchip_set ( n, lx, f, d );
spline_pchip_val ( n, lx, f, d, 1, t, fe );
erg=fe;
log("klaro: "@d[2]);
}

defaultproperties
{
     Texture=Texture'Engine_res.S_Camera'
     DrawScale=2.000000
     bAlwaysTick=True
     CollisionRadius=0.000000
     Mass=0.000000
}
