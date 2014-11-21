//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVMutator extends Engine.Mutator;

var string origcontroller;
var class<PlayerController> origcclass;

function ModifyLogin(out string Portal, out string Options)
{
	local bool bSeeAll;
	local bool bSpectator;

	log("TribesTVMutator.ModifyLogin");
	
	super.ModifyLogin (Portal, Options);
	
	if (Level.game == none) 
	{
		Log ("TribesTVServer: Level.game is none?");
		return;
	}
	
	if (origcontroller != "") 
	{
	    log("TribesTVServer: origcontroller="$origcontroller);
	
		Level.Game.PlayerControllerClassName = origcontroller;
		Level.Game.PlayerControllerClass = origcclass;
		origcontroller = "";
	}
		
    bSpectator = ( Level.Game.ParseOption( Options, "SpectatorOnly" ) ~= "true" );
    bSeeAll = ( Level.Game.ParseOption( Options, "TribesTVSeeAll" ) ~= "true" );

    log("bSpectator="$bSpectator);
    log("bSeeAll="$bSeeAll);

	if (bSeeAll && bSpectator) 
	{
		Log ("TribesTVServer: Creating TribesTV spectator");
		origcontroller = Level.Game.PlayerControllerClassName;
		origcclass = Level.Game.PlayerControllerClass;
		Level.Game.PlayerControllerClassName = "TribesTVServer.TribesTVSpectator";
		Level.Game.PlayerControllerClass = none;
	}    
}	


event PreBeginPlay()
{
    log("TribesTVMutator.PreBeginPlay");

    super.PreBeginPlay();
}

function bool MutatorIsAllowed()
{
    log("TribesTVMutator.MutatorIsAllowed");
    
    return true;        // hack
}


DefaultProperties
{
    GroupName="Tribes"
    FriendlyName="TribesTVServer"
    Description="Required to support TribesTV SeeAll mode"
}
