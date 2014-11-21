class TribesCheatManager extends ConsoleCommandManager;

var bool animationDebug;

///////////////////////////////////////////////////////////////////////////////////////
// Unreal cheat commands

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

		ClientRestart(Pawn, GetStateName());
		Pawn.SetPhysics(PHYS_Movement);
		Outer.GotoState('CharacterMovement');
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
			ClientMessage(ViewingFrom@first.Name, 'Event');
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

// Tribes cheat commands
// weaponFPOffset
exec function weaponFPOffsetX(float f)
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.X = f;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetY(float f)
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Y = f;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetZ(float f)
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Z = f;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetIncX()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.X += 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetIncY()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Y += 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetIncZ()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Z += 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetDecX()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.X -= 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetDecY()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Y -= 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

exec function weaponFPOffsetDecZ()
{
	local vector v;
	v = Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset();
	v.Z -= 1;

	Character(Level.GetLocalPlayerController().Pawn).Weapon.setFirstPersonOffset(v);
	ClientMessage("Offset is "$Character(Level.GetLocalPlayerController().Pawn).Weapon.getFirstPersonOffset());
}

// setWeaponMesh
// changes the mesh for the first person weapon
exec function setWeaponFPMesh(string meshName)
{
	local Mesh m;

	m = Mesh(DynamicLoadObject(meshName, class'Mesh'));
	if (m == None)
	{
		ClientMessage("Mesh "$meshName$" not found");
	}
	else
	{
        Character(Level.GetLocalPlayerController().Pawn).weapon.firstPersonMesh = m;
		Character(Level.GetLocalPlayerController().Pawn).weapon.selectMesh(true);
	}
}


// runScript
exec function runScript(Name label)
{
	local Script s;

	s = Script(findByLabel(class'Script', label));

	if (s == None)
	{
		ClientMessage("Script "$label$" not found");
	}
	else
	{
		s.executeFromExec();
		LOG("Ran script "$label);
		ClientMessage("Ran script "$label);
	}
}

// setPlayerMesh
exec function setPlayerMesh(string meshName)
{
	local Mesh m;

	m = Mesh(DynamicLoadObject(meshName, class'Mesh'));
	if (m == None)
	{
		ClientMessage("Mesh "$meshName$" not found");
	}
	else
	{
        Level.GetLocalPlayerController().Pawn.LinkMesh(m);
	}
}

exec function giveArmor(class<Armor> c)
{
	ClientMessage("Gave armor "$c.name);
	c.static.equip(Character(Level.GetLocalPlayerController().Pawn));
}

exec function allWeapons()
{
	local class base;
	local class c;
	local Weapon w;

	base = class'Weapon';
	ForEach AllClasses(base, c)
	{
		w = Weapon(Character(Level.GetLocalPlayerController().Pawn).nextEquipment(None, class<Weapon>(c)));
		if (w == None)
			giveWeapon(class<Weapon>(c));
		else
		{
			w.ammoCount = 999;
			w.Skins.Length = 0;
			w.StopAnimating(true);
		}
	}
}

exec function allAmmo()
{
	local Weapon w;

	ForEach DynamicActors(class'Weapon', w)
	{
		if (w.Owner == Level.GetLocalPlayerController().Pawn)
		{
			w.ammoCount = 999;
			w.setHasAmmoSkins();

			if (w.HasAnim('Reload'))
				w.PlayAnim('Reload');
		}
	}
}

exec function fastWeapons()
{
	local Weapon w;

	ForEach DynamicActors(class'Weapon', w)
	{
		if (w.Owner == Level.GetLocalPlayerController().Pawn)
		{
			if (w.roundsPerSecond < 15)
				w.roundsPerSecond = 15;
		}
	}
}

exec function giveWeapon(class<Weapon> c)
{
	Character(Level.GetLocalPlayerController().Pawn).motor.setWeapon(Weapon(Character(Level.GetLocalPlayerController().Pawn).newEquipment(c)));
}

exec function replaceWeapon(class<Weapon> wc)
{
	local Character c;
	local Weapon newWeapon;

	c = Character(Level.GetLocalPlayerController().Pawn);

	if (wc != None && c != None)
	{
		newWeapon = Spawn(wc);
		newWeapon.doSwitch(c);
	}
}

exec function setPlayerTeam(name label)
{
	local TeamInfo team;

	team = TeamInfo(findByLabel(class'TeamInfo', label));

	if (team != None)
	{
		Character(Level.GetLocalPlayerController().Pawn).setTeam(TeamInfo(findByLabel(class'TeamInfo', label)));
		ClientMessage("Set team to "$findByLabel(class'TeamInfo', label));
	}
	else
	{
		ClientMessage("Couldn't find team");
	}
}

exec function setArmor(class<Armor> c)
{
	c.static.equip(Character(Pawn));
	ClientMessage("Player equipped with armor "$c.name);
}

exec function setCombatRole(class<CombatRole> c)
{
	local Mesh mesh;

	// change armour
	c.default.armorClass.static.equip(Character(Pawn));

	// change mesh
	mesh = Character(Pawn).team().getMeshForRole(c,
			Pawn.Controller.PlayerReplicationInfo.bIsFemale);
	if (mesh != None)
	{
		Pawn.LinkMesh(mesh);
	}
	else
	{
		log("TribesCheatManager: No mesh defined for combat role "$c$", team "$
				Character(Pawn).team()$
				", bIsFemale "$Pawn.Controller.PlayerReplicationInfo.bIsFemale);
	}
}

exec function killSquad(Name squadLabel)
{
	local SquadInfo squad;
	local int i;

	squad = SquadInfo(findByLabel(class'SquadInfo', squadLabel));

	if (squad != None)
	{
		for (i = 0; i < squad.pawns.length; ++i)
		{
			if (squad.pawns[i].Controller != None)
				squad.pawns[i].Controller.Destroy();
			squad.pawns[i].Destroy();
		}

		squad.pawns.length = 0;
	}
	else
	{
		ClientMessage("Couldn't find squad");
	}
}

exec function campaignNext()
{
	TribesGUIControllerBase(Player.GUIController).FinishCampaignMission();
}

// pending full switch to new hud system

/*
exec function toggleAnimationDebug()
{
    local PlayerCharacterController controller;
    
    controller = PlayerCharacterController(Pawn.Controller);
    
    if (controller!=none)
    {
        animationDebug = !animationDebug;
        
        if (animationDebug)
        {
	        //controller.ClientSetBehindView(true);
            controller.ClientTribesSetHUD("TribesGui.AnimationHUD");
        }
        else
        {
	        //controller.ClientSetBehindView(false);
            controller.ClientTribesSetHUD("TribesGui.TribesHUD");
        }
    }    
}
*/

exec function ToggleSpeechChannelLogging(String channelName)
{
	ConcreteSpeechManager(Level.speechManager).ToggleChannelLogging(channelName);
}

exec function ToggleSpeechChannel(String channelName)
{
	ConcreteSpeechManager(Level.speechManager).ToggleChannel(channelName);
}

exec function ToggleSpeechCategoryFrequency()
{
	ConcreteSpeechManager(Level.speechManager).ToggleCategoryFrequency();
}

exec function ScaleFog(float scale)
{
	local ZoneInfo z;

	ForEach AllActors(class'ZoneInfo', z)
	{
		z.DistanceFogStart *= scale;
		z.DistanceFogEnd *= scale;
	}
}

exec function SetFog(int start, int end)
{
	local ZoneInfo z;

	ForEach AllActors(class'ZoneInfo', z)
	{
		z.DistanceFogStart = start;
		z.DistanceFogEnd = end;
	}
}

exec function superman()
{
	if (!bGodMode)
		god();
	slomo(10);
	ghost();
}

exec function clark()
{
	if (bGodMode)
		god();
	slomo(1);
	walk();
}

exec function killDriver()
{
	if ((Pawn != None) && (Level.TimeSeconds - Pawn.LastStartTime > 1) && Vehicle(Pawn) != None)
		Vehicle(Pawn).positions[Vehicle(Pawn).driverIndex].occupant.TakeDamage(Pawn.health + 1, None, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'DamageType');
}

exec function testIntro()
{
	PlayerCharacterController(Outer).introCameraOldState = Outer.GetStateName();
	Outer.GotoState('SPIntroduction');
}

#if IG_SHARED
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

exec function debugSpeedhack()
{
	PlayerCharacterController(Outer).bDebugSpeedhack = !PlayerCharacterController(Outer).bDebugSpeedhack;
	ClientMessage(PlayerCharacterController(Outer).bDebugSpeedhack);
}