//-----------------------------------------------------------
//
//-----------------------------------------------------------
#exec texture IMPORT NAME=pWatermark FILE=Textures/watermark.pcx GROUP="HUD" MIPS=ON FLAGS=2 MASKED=1

class TribesTVStudioMutator extends Mutator;

var config string ViewSelectors[10];
var config texture watermark;

var TribesTVStudioViewSelector vsList[10];
var int vsCount;

struct ActiveCamera
{
	var TribesTVStudioTestController controller;
	var int numMetaWatchers;
	var int isWatching;
};

var ActiveCamera activeCams[64];

function PostBeginPlay()
{
    local int i;
    local class<TribesTVStudioViewSelector> vsClass;

    //Change the default controller class to our sublass
    Level.Game.PlayerControllerClassName = "TribesTribesTVStudiotudio.TribesTVStudioTestController";
    Log ("TribesTVStudio: TribesTVStudioMutator.postbeginplay ()");

    //Create the viewselectors
    vsCount = 0;
    for (i = 0; i < 10; ++i) {
        if (ViewSelectors [i] != "") {
            Log ("TribesTVStudio: Spawning viewcontroller " $ ViewSelectors[i]);
            vsClass = class<TribesTVStudioViewSelector>(DynamicLoadObject(ViewSelectors[i], class'Class'));
            vsList[vsCount] = Level.spawn (vsClass);

			//Ask if the VS wants to run
			if (!vslist[vscount].runnable ()) {
				vslist[vscount].destroy ();
				vslist[vscount] = none;
			}

			//If failed init or did not want to run, dont add it to the list
            if (vslist[vscount] == none)
                vscount--;

            vsCount++;
        }
    }

    //Assign them their id's
    for (i = 0; i < vsCount; ++i) {
        vsList[i].AssignID (i);
    }
}

function ModifyPlayer(Pawn Other)
{
    //local TribesTVStudioClientController cc;

    super.ModifyPlayer (Other);
    
/*    
    cc = Level.spawn (class'TribesTVStudioClientController', other);
    other.AddInventory (cc);
    log ("TribesTVStudio: spawning the clientcontroller for " $ other.Controller.playerreplicationinfo.PlayerName); */
}

function ModifyLogin(out string Portal, out string Options)
{
    super.ModifyLogin (Portal, Options);

    //make sure
    Log ("TribesTVStudio: TribesTVStudioMutator.ModifyLogin ()");
    Level.Game.PlayerControllerClassName = "TribesTribesTVStudiotudio.TribesTVStudioTestController";
}

function AddActiveCam(TribesTVStudioTestController cont)
{
	local int a;
	local int i;
	
	for(a=0;a<64;++a){
		if(activeCams[a].controller==none){
			activeCams[a].controller=cont;
			activeCams[a].isWatching=-1;
			activeCams[a].numMetaWatchers=0;
			cont.myCamNum=a;
			
			break;
		}
	}

	//Log ("TribesTVStudio: addactivecam " $ cont.mycamnum $ " - " $ cont.playerreplicationinfo.playername);

	//Update the replicated list in all controllers
	for (i = 0; i < 64; ++i) {

		//only update existing, and also don't add ourselves
		if ((activecams[i].controller != none) && (activecams[i].controller != cont)) {
			//log ("TribesTVStudio: adding to " $ i $ " - " $ a);
			activecams[i].controller.mcNames[a] = cont.playerreplicationinfo.playername;
			cont.mcNames[i]=activecams[i].controller.playerreplicationinfo.playername;
		}
	}	
}

function DeleteActiveCam(TribesTVStudioTestController cont)
{
	local int a;
	local int i;
	
	for(a=0;a<64;++a){
		if(activeCams[a].controller==cont){
			cont.myCamNum=-1;
			if(activeCams[a].isWatching!=-1){
				activeCams[activeCams[a].isWatching].numMetaWatchers--;
				if(activeCams[activeCams[a].isWatching].numMetaWatchers==0)
					activeCams[activeCams[a].isWatching].controller.isWatched=false;
			}
			activeCams[a].isWatching=-1;
			activeCams[a].controller=none;
	
			break;
		}
	}
	
	//Update the replicated list in all controllers
	for (i = 0; i < 64; ++i) {
		if (activecams[i].controller != none) {
			activecams[i].controller.mcNames[a] = "";					
		}
	}	
}

function WatchOther(int watcher,int watched)
{
	if(activeCams[watched].controller==none || activeCams[watcher].controller==none)
		return;
		
	//Make sure only one is watched
	if (activecams[watcher].isWatching != -1) {
		StopWatchOther (watcher);
	}
		
	activeCams[watched].controller.isWatched=true;
	activeCams[watched].controller.WatcherJoined();
	activeCams[watched].numMetaWatchers++;
	activeCams[watcher].isWatching=watched;
}

function StopWatchOther(int watcher)
{
	local int watched;

	//Get the number of the camera we are currently watching
	watched = activecams[watcher].isWatching;
	if (watched == -1) 
		return;
	
	activeCams[watched].numMetaWatchers--;	
	if(activeCams[watched].numMetaWatchers==0)
		activeCams[watched].controller.isWatched=false;
	activeCams[watcher].isWatching=-1;
}

function UpdateCameraVars(int cam,string target,int mode)
{
	local int a;

	for(a=0;a<64;++a){
		if(activeCams[a].isWatching==cam){
			activeCams[a].controller.SetTargetAndMode(target,mode);
		}
	}
}

function UpdateCameraPosRot(int cam,Vector pos,Rotator rot)
{
	local int a;

	for(a=0;a<64;++a){
		if(activeCams[a].isWatching==cam){
			activeCams[a].controller.SetPosAndRot(pos,rot);
		}
	}
}

function UpdateCameraDistZoom(int cam,float dist,float zoom)
{
	local int a;

	for(a=0;a<64;++a){
		if(activeCams[a].isWatching==cam){
			activeCams[a].controller.SetDistAndZoom(dist,zoom);
		}
	}
}

defaultproperties
{
    IconMaterialName="MutatorArt.nosym"
    ConfigMenuClassName=""
    GroupName="TribesTribesTVStudiotudio"
    FriendlyName="TribesTribesTVStudiotudio"
    Watermark=pWatermark
    //texture'TribesTribesTVStudiotudio.pWatermark'
    Description="Add new options for spectators"
	ViewSelectors[0]="TribesTribesTVStudiotudio.TribesTVStudioTesTribesTVStudio"
	ViewSelectors[1]="TribesTribesTVStudiotudio.TribesTVStudioActionVS"
	ViewSelectors[2]="TribesTribesTVStudiotudio.TribesTVStudioFlagVS"
	ViewSelectors[3]="TribesTribesTVStudiotudio.TribesTVStudioBombVS"
}
