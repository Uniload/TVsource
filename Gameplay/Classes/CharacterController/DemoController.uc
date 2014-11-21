// Tribes Demo Recording Controller

class DemoController extends PlayerCharacterController;

var bool bTempBehindView;
var bool bFoundPlayer;

simulated event PostBeginPlay()
{
    log("DemoController.PostBeginPlay");

	clientTribesSetHUD("TribesGUI.TribesCharacterHUD");

	Super.PostBeginPlay();
	
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bOutOfLives = true;
}

simulated function InitPlayerReplicationInfo()
{
    log("DemoController.InitPlayerReplicationInfo");

	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName="DemoController";
	PlayerReplicationInfo.bIsSpectator = true;
	PlayerReplicationInfo.bOnlySpectator = true;
	PlayerReplicationInfo.bOutOfLives = true;
	PlayerReplicationInfo.bWaitingPlayer = false;
}

simulated exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor other, first;
	local bool bFound;

	first = None;

	ForEach AllActors( aClass, other )
	{
		if ( bFound || (first == None) )
		{
			first = other;
			if ( bFound )
				break;
		}
		if ( other == ViewTarget ) 
			bFound = true;
	}  

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = ( ViewTarget != self );

		if ( bBehindView )
			ViewTarget.BecomeViewTarget();
	}
	else
		SetViewTarget(self);
}

//==== Called during demo playback ============================================

exec function DemoViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound;

    // view next player
    if ( PlayerCharacterController(RealViewTarget) != None )
		PlayerCharacterController(RealViewTarget).DemoViewer = None;

	foreach DynamicActors(class'Controller', C)
		if ( (C == self) || (PlayerCharacterController(C) == None) || !PlayerCharacterController(C).IsSpectating() )
		{
			if ( (GameReplicationInfo == None) && (PlayerCharacterController(C) != None) )
				GameReplicationInfo = PlayerCharacterController(C).GameReplicationInfo;
			if ( Pick == None )
				Pick = C;
			if ( bFound )
			{
				Pick = C;
				break;
			}
			else
				bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
		}
    
    SetViewTarget(Pick);

    if ( PlayerCharacterController(RealViewTarget) != None )
		PlayerCharacterController(RealViewTarget).DemoViewer = self;
}

auto simulated state Spectating
{
    exec function Fire( optional float F )
    {
        log("DemoController.Spectating.Fire");
    
        bBehindView = false;
        demoViewNextPlayer();
    }

    exec function AltFire( optional float F )
    {
        log("DemoController.Spectating.AltFire");
    
        bBehindView = !bBehindView;
    }
    
	event PlayerTick( float DeltaTime )
	{
		Super.PlayerTick( DeltaTime );

		// attempt to find a player to view.
		if( Role == ROLE_AutonomousProxy && (RealViewTarget==None || RealViewTarget==Self) && !bFoundPlayer )
		{
			DemoViewNextPlayer();
			if( RealViewTarget!=None && RealViewTarget!=Self ) 
				bFoundPlayer = true;		
		}
			
		// hack to go to 3rd person during deaths
		if( RealViewTarget!=None && RealViewTarget.Pawn==None )
		{
			if( !bTempBehindView )
			{
				bTempBehindView = true;
				bBehindView = true;
			}
		}
		else if( bTempBehindView )
		{
			bBehindView = false;
			bTempBehindView = false;
		}
	}   
}

simulated event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local PlayerCharacterController pc;

    if (ViewTarget != NONE &&
        Pawn(ViewTarget) != NONE &&
        Pawn(ViewTarget).Controller != NONE &&
        PlayerCharacterController(Pawn(ViewTarget).Controller) != NONE)
    {
        pc = PlayerCharacterController(Pawn(ViewTarget).Controller);
        pc.bBehindView = bBehindView;

        ViewActor = ViewTarget;

        CameraLocation = ViewTarget.Location;
		CameraLocation.Z += Pawn(ViewTarget).BaseEyeHeight;

        if (Character(ViewTarget)!=None && ViewTarget.Physics==PHYS_Movement)
            CameraRotation = Character(ViewTarget).movementSimProxyRotation;
        else
            CameraRotation = pc.Rotation;
    }
    else
       Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation );
}

defaultproperties
{
	RemoteRole=ROLE_AutonomousProxy
    PlayerReplicationInfoClass=Class'Gameplay.TribesReplicationInfo'
	bDemoOwner=1
}


/*
   local Rotator R;
   local PlayerCharacterController pc;

   if(ViewTarget != NONE &&
      Pawn(ViewTarget) != NONE &&
      Pawn(ViewTarget).Controller != NONE &&
      PlayerCharacterController(Pawn(ViewTarget).Controller) != NONE)
   {
      pc = PlayerCharacterController(Pawn(ViewTarget).Controller);
      ViewActor = ViewTarget;
      CameraLocation = pc.Location;
      CameraRotation = pc.Rotation;

      pc.bBehindView = bBehindView;

      pc.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);

      return;
   }
   
   if( RealViewTarget != None )
   {
      R = RealViewTarget.Rotation;
   }
   
   Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation );
   
   if( RealViewTarget != None )
   {
      if ( !bBehindView )
      {
         CameraRotation = R;
         if ( Pawn(ViewTarget) != None )
            CameraLocation.Z += Pawn(ViewTarget).BaseEyeHeight; // FIXME TEMP
      }
      RealViewTarget.SetRotation(R);
   }
*/