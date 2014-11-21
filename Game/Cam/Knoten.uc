//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Knoten extends Engine.actor;

#exec new STATICMESH FILE=Models\arrowCenterMesh.ase  NAME=arrowMesh
#exec texture IMPORT FILE=Textures\arrowtex.tga       NAME=arrowtex MIPS=0


var float dct;
var int i;
var vector v;
var rotator rotat;
var bool zeichner;
var int z; // Zaehler fuer Anzahl der Knoten
var CamControl cc;
var bool hasSpawnedcc;
var bool b;
var bool b2;
var Knoten knoten2,other;
var int fov;
var float time;
function PostBeginPlay()
{

    //local RotKnoten2 r;
    //local actor k;
    //local Knoten Other;
    local CamControl Other2;
    local democontroller Other3;
    hasSpawnedcc=false;

    z=0; zeichner = false;
    rotat=rot(0,0,0);
    setRotation(rotat);
    b=false;
    b2=false;


    time=Level.Timeseconds;
    foreach AllActors(class'CamControl', Other2)
    {
     b = Other2.I_want_to_insert_a_Flag;
     b2 = other2.is_spawning;
     cc=Other2;
    }

    foreach AllActors(class'Knoten', Other)
    {
     z++;
    }

    if(!b2 && !cc.justspawn)
    {
     knoten2=self;
     i=0;
     foreach AllActors(class'Knoten', Other)
     {
      i++;
      if(i==z-1)
       knoten2=Other;
     }

     foreach AllActors(class'democontroller', Other3)
      {
       rotat.yaw=Other3.viewtarget.rotation.yaw;
       rotat.pitch=Other3.viewtarget.rotation.pitch;
       if(abs(rotat.yaw - knoten2.rotation.yaw) > 32768)
       {
       while(abs(rotat.yaw - knoten2.rotation.yaw) > 32768)
        {
         if(rotat.yaw > knoten2.rotation.yaw)
          rotat.yaw=rotat.yaw-65536;
         else
          rotat.yaw=rotat.yaw+65536;
        }
       }
       else
       rotat.yaw=Other3.viewtarget.Rotation.yaw;
       if(abs(rotat.pitch - knoten2.rotation.pitch) > 32768)
       {
       while(abs(rotat.pitch - knoten2.rotation.pitch) > 32768)
       if(rotat.pitch > knoten2.rotation.pitch)
       rotat.pitch=rotat.pitch-65536;
       else
       rotat.pitch=rotat.pitch+65536;
       }
       else
       rotat.pitch=Other3.viewtarget.Rotation.pitch;
       setlocation(Other3.viewtarget.Location);
       setRotation(rotat);
       break;
      }
    }


    if(!b)
    {
    if(z==4) // Interpolation kann beginnen
     zeichner=true; // dieser Knoten wird jetzt die Interpolation zeichnen
    }
    if(b)
    cc.FlagEinfuegen();

    /*
    log("jj2");
    log(location);
           log("rot2");
       log(Other3.ViewTarget.rotation);
       log(Other3.Rotation);
    */
}

function updateSpline()
{
 local CamControl OtherCC;
 foreach AllActors(class'CamControl', OtherCC)
 {
 hasSpawnedcc=true;     // also es ist schon ein cc per ini geladen worden
 cc=OtherCC;
 }
 if(!hasSpawnedcc)
 {
 cc = Spawn(class'CamControl');
 hasSpawnedcc=true;
 }
 if((!cc.conf) && (!cc.justSpawn)) cc.updateSplinef(true);
}

defaultproperties
{
     Texture=Texture'Engine_res.Havok.S_HkActor'
     AmbientGlow=50
     bUnlit=True
     bAlwaysTick=True
}
