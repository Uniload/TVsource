// ====================================================================
//  Class:  TribesGui.TribesOptionsAudioMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class MyOptionsAudioPanel extends TribesGui.TribesOptionsAudioPanel;

var float OriginalGameSpeed;
var playercharactercontroller My_Controller;
var GUIController gc;
var CamHUD overlay;
var CamCommands overlaytwo;
var playercharactercontroller tempplayercharactercontroller;
var float NormalSpeed;

function CamHUD findCamHUD ()
{
	local Interaction inter;
	local int i;

	for (i = 0; i < PlayerOwner().Player.LocalInteractions.Length; i++) {
		inter = PlayerOwner().Player.LocalInteractions[i];
		if (inter.isA ('CamHUD'))
			return CamHUD (inter);
	}
	return None;
}

function CamCommands findCamCommands ()
{
	local Interaction inter;
	local int i;

	for (i = 0; i < PlayerOwner().Player.LocalInteractions.Length; i++) {
		inter = PlayerOwner().Player.LocalInteractions[i];
		if (inter.isA ('CamCommands'))
			return CamCommands (inter);
	}
	return None;
}


function InitComponent(GUIComponent MyOwner)
{
Super.InitComponent(MyOwner);
}

function InternalOnShow()
{
local tribeshudbase other_hud;
local democontroller o_demo;
local Actor ta;
local CamHudTimer cht;
local mutator tempmut;

OriginalGameSpeed = PlayerOwner().level.TimeDilation;

    if(!PlayerOwner().bDemoOwner)
     return;
	if (findCamCommands () == None)
	{
	overlaytwo = CamCommands (Playerowner().Player.InteractionMaster.AddInteraction("Cam.CamCommands", Playerowner().player));

	}

    if (findCamHUD () == None)
	{
        overlay = CamHUD (Playerowner().Player.InteractionMaster.AddInteraction("Cam.CamHUD", Playerowner().player));
        //overlay.disable('Tick');
    //overlay.gc=MyController;
	overlay.bIsPaused=false;
	//overlay.serverdemo=true;
	overlay.bDrawdemorec=false;
	overlay.bViewingdemorec=true;
	overlay.demo04speed=17;
	//overlay.bViewingdemorec=false;
	overlay.typecount=0;
	overlay.typecount2=10000;
	overlay.bTargetnone=false;
	overlay.dista=0;
	overlay.timecount=0;
	overlay.followdist=60;
	overlay.bfixedfps=false;
	overlay.kills=0; // players score

    overlay.pc=playercharactercontroller(overlay.viewportowner.actor);
    overlay.pc.Level.GetLocalPlayerController().myHud.pausedmessage=" ";

    //overlay.rHudAct = overlay.pc.Spawn(class'rHudBase');
       //overlay.bdrawweapons = true;

    //overlay.weaponCont = overlay.pc.GetEntryLevel().Game.LoadDataObject(class'weaponSaver', "ws", "weapondata");

   /*
   foreach overlay.ViewportOwner.Actor.AllActors(class'Actor', ta)
   {
    ta.CullDistance = 0;
   }
   */

   foreach overlay.viewportowner.actor.AllActors(class'democontroller', o_demo)
       {
        overlay.serverdemo = true;
        overlay.bdrawweapons = false;
       }
	//overlay.curweapon="Assault Rifle";
	//overlay.viewportowner.actor.SetWeaponHand("Right");
	//overlay.bdemo04=false;
	cht = overlay.PC.spawn(class'CamHudTimer');
	cht.overlay=overlay;
	//overlay.PC.Level.pauser=overlay.pc.PlayerReplicationInfo;
    //Playerowner().SetHand(1);
	}



}

function InternalOnHide()
{

}

defaultproperties
{
}
