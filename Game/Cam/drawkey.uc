//-----------------------------------------------------------
//
//-----------------------------------------------------------
class drawkey extends Engine.Pawn;
var float speed;

function PostBeginPlay()
{
local CamControl Cam;
local rotknoten other2;
local knoten other3;
local posmarker posm;



foreach AllActors(class'CamControl', Cam)
{
if(Cam.drawcount == 0)
{
 Cam.draw_Spline=false;
 Cam.bhidden = true;
 foreach AllActors(class'posmarker', posm)
  posm.bHidden=true;
}
if(Cam.drawcount == 1)
{
 foreach AllActors(class'Knoten', other3)
  other3.bHidden=false;
 foreach AllActors(class'rotknoten', other2)
  other2.bHidden=true;
 foreach AllActors(class'posmarker', posm)
  posm.bHidden=false;
 Cam.bhidden = false;
}
if(Cam.drawcount == 2)
{
 foreach AllActors(class'posmarker', posm)
  posm.bHidden=false;
 Cam.draw_Spline=true;
 Cam.bhidden = false;
}
Cam.drawcount++;
if(Cam.drawcount == 3)
 Cam.drawcount=0;
break;
}



other2.destroy();
}

defaultproperties
{
     bHidden=True
     bAlwaysTick=True
     bCollideActors=False
     bCollideWorld=False
}
