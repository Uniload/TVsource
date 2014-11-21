//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================

class CheatManager extends Core.Object within PlayerController
	native;

var rotator LockedRotation;

#if !IG_TRIBES3 // dbeswick: moved to TribesCheatManager

/* Used for correlating game situation with log file
*/

exec function ReviewJumpSpots(name TestLabel)
{	
	if ( TestLabel == 'Transloc' )
		TestLabel = 'Begin';
	else if ( TestLabel == 'Jump' )
		TestLabel = 'Finished';
	else if ( TestLabel == 'Combo' )
		TestLabel = 'FinishedJumping';
	else if ( TestLabel == 'LowGrav' )
		TestLabel = 'FinishedComboJumping';
	Log("TestLabel is "$TestLabel);
	Level.Game.ReviewJumpSpots(TestLabel);
}

exec function ListDynamicActors()
{
	local Actor A;
	local int i;
	
	ForEach DynamicActors(class'Actor',A)
	{
		i++;
		Log(i@A);
	}
	Log("Num dynamic actors: "$i);
}

exec function FreezeFrame(float DelayTime)
{
	Level.Game.SetPause(true,outer);
	Level.PauseDelay = Level.TimeSeconds + DelayTime;
}

exec function WriteToLog()
{
	Log("NOW!");
}

exec function SetFlash(float F)
{
	FlashScale.X = F;
}

exec function SetFogR(float F)
{
	FlashFog.X = F;
}

exec function SetFogG(float F)
{
	FlashFog.Y = F;
}

exec function SetFogB(float F)
{
	FlashFog.Z = F;
}

exec function KillViewedActor()
{
	if ( ViewTarget != None )
	{
		if ( (Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Controller != None) )
			Pawn(ViewTarget).Controller.Destroy();	
		ViewTarget.Destroy();
		SetViewTarget(None);
	}
}

/* LogScriptedSequences()
Toggles logging of scripted sequences on and off
*/
exec function LogScriptedSequences()
{
//	local AIScript S;

//	ForEach AllActors(class'AIScript',S)
//		S.bLoggingEnabled = !S.bLoggingEnabled;
}

/* Teleport()
Teleport to surface player is looking at
*/
exec function Teleport()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;

	HitActor = Trace(HitLocation, HitNormal, ViewTarget.Location + 10000 * vector(Rotation),ViewTarget.Location, true);
	if ( HitActor == None )
		HitLocation = ViewTarget.Location + 10000 * vector(Rotation);
	else
		HitLocation = HitLocation + ViewTarget.CollisionRadius * HitNormal;

	ViewTarget.SetLocation(HitLocation);
}

/* 
Scale the player's size to be F * default size
*/
exec function ChangeSize( float F )
{
	if ( Pawn.SetCollisionSize(Pawn.Default.CollisionRadius * F,Pawn.Default.CollisionHeight * F) )
	{
		Pawn.SetDrawScale(F);
		Pawn.SetLocation(Pawn.Location);
	}
}

exec function LockCamera()
{
	local vector LockedLocation;
	local rotator LockedRot;
	local actor LockedActor;

	if ( !bCameraPositionLocked )
	{
		PlayerCalcView(LockedActor,LockedLocation,LockedRot);
		Outer.SetLocation(LockedLocation);
		LockedRotation = LockedRot;
		SetViewTarget(outer);
	}
	else
		SetViewTarget(Pawn);

	bCameraPositionLocked = !bCameraPositionLocked;
	bBehindView = bCameraPositionLocked;
	bFreeCamera = false;
}

exec function SetCameraDist( float F )
{
	CameraDist = FMax(F,2);
}

/* Stop interpolation
*/
exec function EndPath()
{
}

/* 
Camera and pawn aren't rotated together in behindview when bFreeCamera is true
*/
exec function FreeCamera( bool B )
{
	bFreeCamera = B;
	bBehindView = B;
}


exec function CauseEvent( name EventName )
{
	TriggerEvent( EventName, Pawn, Pawn);
}

exec function Amphibious()
{
	Pawn.UnderWaterTime = +999999.0;
}
	
exec function Fly()
{
	if ( Pawn == None )
		return;
	Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
	ClientMessage("You feel much lighter");
	Pawn.SetCollision(true, true , true);
	Pawn.bCollideWorld = true;
	bCheatFlying = true;
	Outer.GotoState('PlayerFlying');
}

exec function Walk()
{	
	if ( Pawn != None )
	{
		bCheatFlying = false;
		Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
		Pawn.SetCollision(true, true , true);
		Pawn.bCollideWorld = true;
		Pawn.SetPhysics(PHYS_Walking);
		ClientRestart();
	}
}

exec function Ghost()
{
	if( Pawn != None && !Pawn.IsA('Vehicle') )
	{
		Pawn.UnderWaterTime = -1.0;	
		ClientMessage("You feel ethereal");
		Pawn.SetCollision(false, false, false);
		Pawn.bCollideWorld = false;
		bCheatFlying = true;
		Outer.GotoState('PlayerFlying');
	}
	else
		Log("Can't Ghost In Vehicles");
}

exec function AllAmmo()
{
/*
	local Inventory Inv;

	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		if (Ammunition(Inv)!=None) 
		{
			Ammunition(Inv).AmmoAmount  = 999;
			Ammunition(Inv).MaxAmmo  = 999;				
		}
*/
}	

exec function Invisible(bool B)
{
	Pawn.bHidden = B;

	if (B)
		Pawn.Visibility = 0;
	else
		Pawn.Visibility = Pawn.Default.Visibility;
}
	
exec function God()
{
	if ( bGodMode )
	{
		bGodMode = false;
		ClientMessage("God mode off");
		return;
	}

	bGodMode = true; 
	ClientMessage("God Mode on");
}

exec function SloMo( float T )
{
	Level.Game.SetGameSpeed(T);
	Level.Game.SaveConfig(); 
	Level.Game.GameReplicationInfo.SaveConfig();
}

exec function SetJumpZ( float F )
{
	Pawn.JumpZ = F;
}

exec function SetGravity( float F )
{
	PhysicsVolume.Gravity.Z = F;
}

exec function SetSpeed( float F )
{
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * F;
	Pawn.WaterSpeed = Pawn.Default.WaterSpeed * F;
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;

/*	if ( ClassIsChildOf(aClass, class'AIController') )
	{
		Level.Game.KillBots(Level.Game.NumBots);
		return;
	}
*/
	if ( ClassIsChildOf(aClass, class'Pawn') )
	{
		KillAllPawns(class<Pawn>(aClass));
		return;
	}
	ForEach DynamicActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

// Kill non-player pawns and their controllers
function KillAllPawns(class<Pawn> aClass)
{
	local Pawn P;
	
//	Level.Game.KillBots(Level.Game.NumBots);
	ForEach DynamicActors(class'Pawn', P)
		if ( ClassIsChildOf(P.Class, aClass)
			&& !P.IsPlayerPawn() )
		{
			if ( P.Controller != None )
				P.Controller.Destroy();
			P.Destroy();
		}
}

exec function KillPawns()
{
	KillAllPawns(class'Pawn');
}

/* Avatar()
Possess a pawn of the requested class
*/
exec function Avatar( string ClassName )
{
	local class<actor> NewClass;
	local Pawn P;
		
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		Foreach DynamicActors(class'Pawn',P)
		{
			if ( (P.Class == NewClass) && (P != Pawn) )
			{
				if ( Pawn.Controller != None )
					Pawn.Controller.PawnDied(Pawn);
				Possess(P);
				Log("Avatar "$P.Name$" possessed");
				break;
			}
		}
	}
	else
	{
		Log("Avatar of requested class type not found");
	}
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

	Log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		
		if (Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 ) != None)
		{
			Log("Object created at "$SpawnLoc);
		}
		else
		{
			Log("Creation failed");
		}
	}
	else
	{
		Log("Class was not found");
	}
}

exec function PlayersOnly()
{
	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function CheatView( class<actor> aClass, optional bool bQuiet )
{
	ViewClass(aClass,bQuiet,true);
}

// ***********************************************************
// Navigation Aids (for testing)

// remember spot for path testing (display path using ShowDebug)
// DLB Controller clean pass: removed AI logic
/*exec function RememberSpot()
{
	if ( Pawn != None )
		Destination = Pawn.Location;
	else
		Destination = Location;
}*/

// ***********************************************************
// Changing viewtarget

exec function ViewSelf(optional bool bQuiet)
{
	bBehindView = false;
	bViewBot = false;
	if ( Pawn != None )
		SetViewTarget(Pawn);
	else
		SetViewTarget(outer);
	if (!bQuiet )
		ClientMessage(OwnCamera, 'Event');
	FixFOV();
}

exec function ViewPlayer( string S )
{
	local Controller P;

	for ( P=Level.ControllerList; P!=None; P= P.NextController )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.PlayerName ~= S) )
			break;

	if ( P.Pawn != None )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event');
		SetViewTarget(P.Pawn);
	}

	bBehindView = ( ViewTarget != Pawn );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function ViewActor( name ActorName)
{
	local Actor A;

	ForEach AllActors(class'Actor', A)
		if ( A.Name == ActorName || A.Label == ActorName )
		{
			SetViewTarget(A);
// IGA >>> More descriptive message on camera cycle for debugging
			ClientMessage(ViewingFrom@A.Name, 'Event');
// IGA
			bBehindView = true;
			return;
		}
}

exec function ViewFlag()
{
/*
	local Controller C;
	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.HasFlag != None) )
		{
			SetViewTarget(C.Pawn);
			return;
		}
*/

}
		
exec function ViewBot()
{
	local actor first;
	local bool bFound;
	local Controller C;

	bViewBot = true;
	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.Pawn != None) )
	{
		if ( bFound || (first == None) )
		{
			first = C.Pawn;
			if ( bFound )
				break;
		}
		if ( C.Pawn == ViewTarget ) 
			bFound = true;
	}  

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = true;
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor other, first;
	local bool bFound;

	if ( !bCheat && (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

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
		if ( !bQuiet )
		{
// IGA >>> More descriptive message on camera cycle for debugging
			ClientMessage(ViewingFrom@first.Name, 'Event');
// IGA <<<
//			if ( Pawn(first) != None )
//				ClientMessage(ViewingFrom@First.GetHumanReadableName(), 'Event');
//			else
//				ClientMessage(ViewingFrom@first, 'Event');
// IGA
		}
		SetViewTarget(first);
		bBehindView = ( ViewTarget != outer );

		if ( bBehindView )
			ViewTarget.BecomeViewTarget();

		FixFOV();
	}
	else
		ViewSelf(bQuiet);
}

exec function Loaded()
{
	if( Level.NetMode!=NM_Standalone )
		return;

    AllWeapons();
    AllAmmo();
}

exec function AllWeapons() 
{
	if( (Level.NetMode!=NM_Standalone) || (Pawn == None) )
		return;

	Pawn.GiveWeapon("WarClassLight.WeapCOGAssaultRifle");
	Pawn.GiveWeapon("WarClassLight.WeapCOGLightPlasma");
	Pawn.GiveWeapon("WarClassLight.WeapCOGPistol");
	Pawn.GiveWeapon("WarClassHeavy.WeapCOGMinigun");
	Pawn.GiveWeapon("WarClassLight.WeapGeistSniperRifle");
	Pawn.GiveWeapon("WarClassLight.WeapGeistGrenadeLauncher");
}
#endif

#if IG_MOJO // rowan:
exec function Cutscene(name cutsceneName)
{
	Level.PlayMojoCutscene(cutsceneName);
}
exec function PlayAllCS()
{
	Level.PlayAllMojoCutscenes();
}
#endif

#if IG_SHARED && !IG_TRIBES3 // dbeswick: moved to TribesCheatManager
exec function EditObjectAtCrosshair()
{
	local Vector startTrace, hitLocation, hitNormal, endTrace;
	local Actor hit;

	if (Pawn != None)
		startTrace = Pawn.Location + Pawn.EyePosition();
	else
		startTrace = Location;

	endTrace = startTrace + Vector(Rotation) * 500000;

	if (Pawn != None)
		hit = Pawn.Trace(hitLocation, hitNormal, endTrace, startTrace, true); 
	else
		hit = Trace(hitLocation, hitNormal, endTrace, startTrace, true); 

	if (hit != None)
		ConsoleCommand("editobject " $ hit.Name $ " ReuseWindow=1");
}
#endif

#if IG_TRIBES3 // dbeswick
exec function findCamels()
{
	local Actor a;

	log("Looking for camelheads...");

	ForEach AllActors(class'Actor', a)
	{
		if (a.Texture == class'Actor'.default.Texture && a.DrawType == DT_Sprite && a.bHidden == false)
			LOG(a$"'s camelhead is showing, class is"@a.class);
	}
}
#endif

defaultproperties
{
}
