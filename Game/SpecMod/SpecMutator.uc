class SpecMutator extends GamePlay.Mutator Config(User);

var SpecCameraPointManager CameraManager;
var SpecInteraction interaction;
var bool initialized;

function ModifyPlayer(Pawn Other)
{
    local bool hasSpec;
    local SpecPlayerInfo spi;	

    Super.ModifyPlayer(Other);

    hasSpec=false;

    foreach Other.ChildActors(class'SpecPlayerInfo', spi)
    {
	hasSpec=true;
    }

    if(hasSpec==false)
    {
    	Other.Spawn(class'SpecPlayerInfo', Other).PlayerReplicationInfo = Other.PlayerReplicationInfo;
    }
}

function RemoveSpecPlayerInfo(Pawn Other)
{
    local SpecPlayerInfo spi;

    foreach Other.ChildActors(class'SpecPlayerInfo', spi)
    {
	spi.Destroy();
    }
    
}

simulated function Tick(float DeltaTime)
{
    local SpecTeamInfo teamInfo;
    local SpecTeamInfo foundTeamInfo;
    local string teamName;
    local PowerGenerator pg;
    local PlayerCharacterController PCC;
    local PlayerController PC;
    local SpecPlayerInfo resSpi;
    local SpecPlayerInfo spi;
    local Character c;
    local Pawn pawn;
    local bool hasSpi;
    local BaseInfo bi;

    if (Role == ROLE_Authority)
    {
	foreach AllActors(class 'BaseInfo', bi)
	{
		foundTeamInfo=None;

		foreach bi.ChildActors(class'SpecTeamInfo', teamInfo)
		{
		    foundTeamInfo=teamInfo;
		}

		if(foundTeamInfo==None)
		{
		    foundTeamInfo=bi.Spawn(class'SpecTeamInfo', bi);
		    foundTeamInfo.localizedName=bi.team.localizedName;
		}
		
		foundTeamInfo.GeneratorHealthTotal=0;
		foundTeamInfo.GeneratorHealthMaxTotal=0;
	}

	// summate all generator damage
	foreach AllActors(class 'PowerGenerator', pg)
	{
		foundTeamInfo=None;

		foreach pg.ownerBase.ChildActors(class'SpecTeamInfo', teamInfo)
		{
			foundTeamInfo=teamInfo;
		}
	
		foundTeamInfo.GeneratorHealthTotal+=pg.health;
		foundTeamInfo.GeneratorHealthMaxTotal+=pg.healthMaximum;
	}

	foreach AllActors(class 'PlayerCharacterController', PCC)
	{
		resSpi=None;

		foreach PCC.ChildActors(class'SpecPlayerInfo', spi)
		{
		    resSpi=spi;
		}

		if(resSpi==None)
		{
		    resSpi=PCC.Spawn(class'SpecPlayerInfo', PCC);
		    resSpi.Controller = PCC;
		}
		
		if(PCC.PlayerReplicationInfo.bIsSpectator==true)
		{
			if(resSpi.IsFreeLook==false && resSpi.AttachedActor!=None)
   			{
   			    PCC.SetRotation(resSpi.AttachedActor.Rotation);
   			    PCC.ClientSetRotation(resSpi.AttachedActor.Rotation);
   			}
		}
	}

        for (pawn = Level.PawnList; pawn != None; pawn = pawn.NextPawn)
        {
		c = Character(pawn);

		foreach pawn.ChildActors(class'SpecPlayerInfo', spi)
		{
		    if(c.health <= 0)
		    {
			spi.Destroy();
		    }
		    else
		    {
        	    	spi.energy = c.energy;
		    	spi.energyMax = c.energyMaximum;
		    }
 		}
        }
    }
    else
    {
    	PC = Level.GetLocalPlayerController();
	
	// Remove interaction when needed
	if (PC.PlayerReplicationInfo.bIsSpectator==false && interaction != None)
	{
		PC.Player.InteractionMaster.RemoveInteraction(interaction);
		interaction = None;
    	}

	// Run a check to see whether this mutator should create an interaction for the player
	if (PC.PlayerReplicationInfo.bIsSpectator==true && interaction == None)
	{
        	interaction = SpecInteraction(PC.Player.InteractionMaster.AddInteraction("SpecMod.SpecInteraction", PC.Player));
		interaction.RegisterMutator(Self);
	}

	// ensure the CameraManager is instanciated for every level
    	if(CameraManager==None || string(CameraManager.Name) != Level.Title)
   	{
    		CameraManager=new(None, Level.Title) class'SpecCameraPointManager';
		CameraManager.EnsureCameras();
    	}   
    }
}

defaultproperties
{
     ConfigMenuClassName="SpecMod.SpecMutator"
     GroupName="SpecMod"
     FriendlyName="Spectator Mod"
     Description="Changes Spec Mode"
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=true
     initialized=false
}

