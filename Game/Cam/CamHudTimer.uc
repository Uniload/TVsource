//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CamHudTimer extends Engine.Actor;

var CamHUD overlay;

function PostBeginPlay()
{
SetTimer(0.5,true);
}

function Timer()
{
local multiplayercharacter tp;
if(overlay.bswitched)
foreach DynamicActors(class'multiplayercharacter', tp)
if(overlay.watchedName == tp.playerreplicationinfo.playername)
{
overlay.bswitched = false;

     overlay.demo04.setViewtarget(tp);
     overlay.pc.bBehindView=true;
     overlay.behindview=overlay.pc.bBehindView;
     overlay.target=overlay.demo04.ViewTarget;
     overlay.target_actor=overlay.target;
     overlay.bTargetnone = false;
     overlay.watchedname = pawn(overlay.demo04.viewtarget).playerreplicationinfo.playername;


}
}

defaultproperties
{
     bHidden=True
     bAlwaysTick=True
}
