class VisualEffectsSubsystem extends IGEffectsSystem.EffectsSubsystem
    native
    config(VisualEffects);

enum MatchResult
{
    MatchResult_None,           //no match & no default
    MatchResult_Matched,        //found a match with a non-default material
    MatchResult_UseDefault      //no explicit material matched, but use default
};

var private array<class<Actor> > MatchingEffectClasses;
var private array<class<Actor> > DefaultEffectClasses;
var private array<class<Actor> > SelectedEffectClasses;

var private int CurrentDecal;

// Either a source or an overrideWorldLocation must be specified to identify the location of the new effect
simulated event Actor PlayEffectSpecification(
    EffectSpecification EffectSpec,
    Actor Source,
    optional Actor Target,
    optional Material TargetMaterial,
    optional vector overrideWorldLocation,
    optional rotator overrideWorldRotation,
    optional IEffectObserver Observer)
{
    local VisualEffectSpecification visualEffectSpec;
    local Actor effect;
    local int i;
    local MatchResult result;
    local Vector AdditionalLocationOffset;
	local class<Actor> EffectSpecClass;
	local Vector CullLocation;

	if (EffectSpec == None)
		return None;

    visualEffectSpec = VisualEffectSpecification(EffectSpec);
    assert(visualEffectSpec != None);

    // Clear the effect classes arrays
    MatchingEffectClasses.Remove(0, MatchingEffectClasses.length);
    DefaultEffectClasses.Remove(0, DefaultEffectClasses.length);
    
    // Find the index of the specified material
    for (i=0; i<visualEffectSpec.materialType.length; i++)
    {
		EffectSpecClass = visualEffectSpec.EffectClass[i];
        if (TargetMaterial != None && visualEffectSpec.materialType[i] == TargetMaterial.MaterialVisualType)
        {
            // make sure that the effect class specified actually exists
            // (i.e., could be spawned).
            if (EffectSpecClass == None)
				assertWithDescription(false, "EffectsManager::PlayEffect(): Nonexistent EffectClass specified for effect named "$EffectSpec.name$" materialType "$TargetMaterial.MaterialVisualType);            

            MatchingEffectClasses[MatchingEffectClasses.length] = EffectSpecClass;
            result = MatchResult_Matched;
        }
        
        if (visualEffectSpec.MaterialType[i] == MVT_Default)
        {
            // Make sure that the default effect class specified actually exists
            // (i.e., could be spawned).
            if(EffectSpecClass == None)
				assertWithDescription(false, "EffectsManager::PlayEffect(): Nonexistent *default* EffectClass specified for effect named "$EffectSpec.name);            

            DefaultEffectClasses[DefaultEffectClasses.length] = EffectSpecClass;

            // If we haven't found any match, then use this default
            if (result == MatchResult_None)
                result = MatchResult_UseDefault;
        }
    }

    // Either the default effect was requested, or no effect class was defined
    // for the specified material type and we're falling back to the
    // default. 

    SelectedEffectClasses.Remove(0, SelectedEffectClasses.length);
    switch (result)
    {
        case MatchResult_None:
            // Return because there is no default class to spawn
            return None;
        
        case MatchResult_Matched:
            //copy the matching classes into the selected array (since we can't have reference to an array)
            for (i=0; i<MatchingEffectClasses.length; ++i)
                SelectedEffectClasses[SelectedEffectClasses.length] = MatchingEffectClasses[i];
            break;

        case MatchResult_UseDefault:
            //copy the default classes into the selected array (since we can't have reference to an array)
            for (i=0; i<DefaultEffectClasses.length; ++i)
                SelectedEffectClasses[SelectedEffectClasses.length] = DefaultEffectClasses[i];
            break;
    }

    // Spawn the selected effects.
    // 
    // Note that we'll spawn them at (0,0,0).  This indicates to Actor::PostBeginPlay()
    //  that the Actor's location has not been initialized, so the 'Spawned'
    //  effect event should not be triggered... we'll do that ourselves below.

    for (i=0; i<SelectedEffectClasses.length; ++i)
    {
		// Don't spawn FX if the level's detail level is lower than the detail level
		// required for the effect
		if((SelectedEffectClasses[i].Default.bHighDetail && Level.DetailMode == DM_Low) || 
			(SelectedEffectClasses[i].Default.bSuperHighDetail && Level.DetailMode != DM_SuperHigh))
		{
			if (EffectsSystem.LogEffectEvents)
			{
				log("**** "$Name$" NOT spawning "$SelectedEffectClasses[i]$" because Level is DetailMode="$GetEnum(EDetailMode, Level.DetailMode)$
					" and effect is (bHighDetail="$SelectedEffectClasses[i].Default.bHighDetail$
					", bSuperHighDetail="$SelectedEffectClasses[i].Default.bSuperHighDetail$")");
			}

			// don't spawn this effect because client's detail setting is too low
			continue;
		}
		else if (EffectsSystem.LogEffectEvents)
		{
			log("**** "$Name$" SPAWNING "$SelectedEffectClasses[i]$"; Level is DetailMode="$GetEnum(EDetailMode, Level.DetailMode)$
				" and effect is (bHighDetail="$SelectedEffectClasses[i].Default.bHighDetail$
			    ", bSuperHighDetail="$SelectedEffectClasses[i].Default.bSuperHighDetail$")");
		}
				
#if IG_TRIBES3	// rowan: distance cull fx at spawn
		if (SelectedEffectClasses[i].Default.CullDistance > 0)
		{
			if (overrideWorldLocation != vect(0,0,0))
				CullLocation = overrideWorldLocation;
			else if (Source != None)
				CullLocation = Source.Location;

			if (!Level.GetLocalPlayerController().CheckCullDistance(CullLocation, SelectedEffectClasses[i].Default.CullDistance))
			{
//				log("Distance Culled FX!!!!!");
				continue;
			}
		}
#endif

        if (Source != None)
        {
            // Spawn with owner being the Source Actor, and its tag is the name of the
            // EffectSpecification (to identify it later for stopping).
            effect = ProxySpawn(SelectedEffectClasses[i], Source, EffectSpec.name, vect(0,0,0));
        }
        else
        {
            // Since we have no source, check that we have an overrideWorldLocation... enforce the rule above.
			if (overrideWorldLocation == vect(0,0,0))
			{
				assertWithDescription(false, "EffectsManager::PlayEffect() was called with no Source and no overrideWorldLocation... I don't know where to put the effect!?");
			}

            // Spawn with the outer of this EffectsManager as the owner
            effect = ProxySpawn(SelectedEffectClasses[i], GameInfo(Outer), EffectSpec.name, vect(0,0,0));
        }

        if (effect == None)
        {
			assertWithDescription(false, "VisualEffectsSubsystem.PlayEffectSpecification(): couldn't spawn effect "$EffectSpec.name$" with Source "$Source$" (chose SelectedEffectClasses[i]="$SelectedEffectClasses[i]$")");
		}
		else if (EffectsSystem.LogEffectEvents)
		{
			log("**** "$Name$" ---> Spawn returned: "$effect);
		}

        // If a location is passed explicitly, then use that.
        //otherwise, if the effect should be attached, then attach it.
        //otherwise, if a source was passed, then locate the effect at the source.
        //(we already asserted that we have either a source or an overrideWorldLocation.)
		
		// rowan: runtime handle NULL effect
		if (effect != None)
		{
			if (overrideWorldLocation != vect(0,0,0))
			{
				//use passed location & rotation
				effect.SetLocation(overrideWorldLocation);
				effect.SetRotation(overrideWorldRotation);
			}
			else if (effectSpec.AttachToSource)
			{
				if (Source == None)
					assertWithDescription(false, "EffectsManager: tried to attach effect "$EffectSpec.name$" to None Source");

				if (Source != None)
				{
					if (effectSpec.AttachmentBone == '' || effectSpec.AttachmentBone == 'PIVOT')
					{
						// attach relative to the source's location (its pivot)
						effect.SetBase(Source);
					}
					else if (effectSpec.AttachmentBone == 'CENTER')
					{
						effect.SetBase(Source);
						// attach relative to the source's bounding sphere center
						AdditionalLocationOffset = Source.GetRenderBoundingSphere() - Source.Location;
					}
					else
					{
						// attach to the specified bone
						Source.AttachToBone(effect, effectSpec.AttachmentBone);
					}
				}

				effect.SetRelativeLocation(effectSpec.LocationOffset + AdditionalLocationOffset);
				effect.SetRelativeRotation(effectSpec.RotationOffset);
			}
			else if (Source != None)
			{
				effect.SetLocation(Source.Location);
				effect.SetRotation(Source.Rotation);
			}

			if (effect.IsA('ProjectedDecal'))
			{
				// Invert rotation of the projector to face hit location
				ProjectedDecal(effect).Target = Target;
				ProjectedDecal(effect).SetRotation(rotator(vector(effect.Rotation) * vect(-1,-1,-1)));
				ProjectedDecal(effect).Init();
			}

			if (Observer != None)
				Observer.OnEffectStarted(effect);
		}
    }

    return effect;
}

// ckline NOTE: keeping this function around even though it's no longer needed now that we don't 
// use a projector pool. However, it's potentially a good place to hook in functionality needed
// to finish implementing LogState()
simulated function Actor ProxySpawn(class<actor> SpawnClass, actor SpawnOwner, name SpawnTag, vector SpawnLocation)
{
    local Actor Result;

    Result = SpawnOwner.Spawn(SpawnClass, SpawnOwner, SpawnTag, SpawnLocation);
    //Log("VisualFX: "$SpawnOwner$".Spawn("$SpawnClass$","$SpawnOwner$","$SpawnTag$","$SpawnLocation$") returned "$Result);

    return Result;
}

simulated event StopEffectSpecification(
    EffectSpecification EffectSpec,
    Actor Source)
{
    local Actor effect;

    //stop effects with tag=effectTag
    //if Source is specified, then only stop those whose owner is Source
    foreach DynamicActors(class'Actor', effect, EffectSpec.name)
        if (source == None || effect.Owner == source)
            StopEffect(effect, true);  //TMC TODO confirm assumption: visual effects explicitly stopped want to be stopped over time (respawnDeadParticles=false, but let existing particles live-out their lifetimes)
}

simulated function StopEffect(Actor it, bool stopOverTime)
{
    if (stopOverTime && it.IsA('Emitter'))
        Emitter(it).Kill();
    else
        it.Destroy();
}

// Print the current effects to the log
simulated function LogState()
{
//    local int i;
//    local String StateString;

    Log("----------------------------------------------------------------");
    Log("|              VISUAL EFFECTS SUBSYSTEM STATE                   |");
    Log("----------------------------------------------------------------");

Log("| WARNING: LogState() not yet implemented for visual effects subsystem");
// TODO: implement this function for visual effects with output similar to sound effects
//
//    Log("| Existing effects:");
//    for (i = 0; i < CurrentSounds.Length; ++i)
//    {
//        StateString = "None";
//        if (CurrentSounds[i] != None) { StateString = CurrentSounds[i].toString(); }
//        Log("|   #"$i$": "$StateString);
//    }
    Log("----------------------------------------------------------------");
}

simulated event OnEffectSpawned(Actor SpawnedEffect)
{
	if (SpawnedEffect != None && SpawnedEffect.bNeedLifetimeEffectEvents)
	{
		SpawnedEffect.TriggerEffectEvent('Spawned');
		SpawnedEffect.TriggerEffectEvent('Alive');
	}
}

defaultproperties
{
     EventResponse(0)="SpinfusorProjectileHit"
     EventResponse(1)="DynamicGlassDestroyed"
     EventResponse(2)="DynamicRockDestroyed"
     EventResponse(3)="DynamicRockRockyDestroyed"
     EventResponse(4)="DynamicRockWastelandDestroyed"
     EventResponse(5)="CharacterMovementThrustLoop_BloodEagleLight"
     EventResponse(6)="MortarProjectileHit"
     EventResponse(7)="CharacterDamagedByMovement"
     EventResponse(8)="ChaingunProjectileHit"
     EventResponse(9)="MortarProjectileAlive"
     EventResponse(10)="GrenadeLauncherProjectileAlive"
     EventResponse(11)="GrenadeLauncherProjectileHit_Explode"
     EventResponse(12)="DynamicCeramicDestroyed"
     EventResponse(13)="DynamicRockWastelandChunkDestroyed"
     EventResponse(14)="CharacterMovementThrustLoop_Mercury"
     EventResponse(15)="CharacterMovementThrustLoop_PhoenixLight"
     EventResponse(16)="CharacterMovementThrustLoop_ImperialLight"
     EventResponse(17)="CharacterMovementThrustLoop_PhoenixMedium"
     EventResponse(18)="CharacterMovementThrustLoop_BloodEagleMedium"
     EventResponse(19)="CharacterMovementThrustLoop_ImperialMedium"
     EventResponse(20)="CharacterMovementThrustLoop_ImperialMediumFem"
     EventResponse(21)="CharacterMovementThrustLoop_PhoenixMediumFem"
     EventResponse(22)="RocketPodProjectileHit"
     EventResponse(23)="RocketPodProjectileJet"
     EventResponse(24)="SniperRifleProjectileHit"
     EventResponse(25)="SpinfusorFired_Spinfusor_steam"
     EventResponse(26)="ChaingunFired_ChainGunHeld"
     EventResponse(27)="ChaingunFired_Chaingun"
     EventResponse(28)="SpinfusorFired_Spinfusorheld"
     EventResponse(29)="BlasterFired_Blaster"
     EventResponse(30)="BlasterFired_BlasterHeld"
     EventResponse(31)="InventoryStationPlatformLoadoutChanged"
     EventResponse(32)="InventoryStationInventoryStationActivating"
     EventResponse(33)="ChaingunSteam_Chaingun"
     EventResponse(34)="GrenadelauncherSteam1_GrenadeLauncher"
     EventResponse(35)="GrenadeLauncherSteam2_GrenadeLauncher"
     EventResponse(36)="GrenadeLauncherFired_Grenadelauncher"
     EventResponse(37)="RocketPodSteam"
     EventResponse(38)="CharacterMovementThrustLoop_BloodEagleHeavy"
     EventResponse(39)="CharacterMovementThrustLoop_ImperialHeavy"
     EventResponse(40)="CharacterMovementThrustLoop_PhoenixHeavy"
     EventResponse(41)="SpinfusorFired_Spinfusor"
     EventResponse(42)="SpinfusorProjectileAlive"
     EventResponse(43)="DynamicTreeDestroyed"
     EventResponse(44)="DynamicTreeWastelandDestroyed"
     EventResponse(45)="DynamicTreeWastelandChunkDestroyed"
     EventResponse(46)="PodThrottleForwardOrThrust_Right"
     EventResponse(47)="PodThrottleForwardOrThrust_Left"
     EventResponse(48)="PodThrottleBack_Right"
     EventResponse(49)="PodThrottleBack_Left"
     EventResponse(50)="PodStrafeRight"
     EventResponse(51)="PodStrafeLeft"
     EventResponse(52)="RocketPodFired_RocketPod"
     EventResponse(53)="RocketPodFired_RocketPodHeld"
     EventResponse(54)="GrenadeLauncherFired_GrenadeLauncherHeld"
     EventResponse(55)="CharacterMovementThrustLoop_ImperialLightFem"
     EventResponse(56)="DynamicGlassDestroyed_Glass1024"
     EventResponse(57)="DynamicCeramicBlackDestroyed"
     EventResponse(58)="DynamicMetalDestroyed_PowerGeneratorTop"
     EventResponse(59)="DynamicRockImperialStoneDestroyed"
     EventResponse(60)="HandGrenadeProjectileHit"
     EventResponse(61)="CharacterMovementThrustLoop_ImperialLightJulia_Right"
     EventResponse(62)="CharacterMovementThrustLoop_ImperialLightJulia_Left"
     EventResponse(63)="BaseDeployableDeploy"
     EventResponse(64)="BlasterFired_Blaster_Energy"
     EventResponse(65)="DynamicBaseObjectChunkAlive"
     EventResponse(66)="DynamicBaseObjectPannelDestroyed"
     EventResponse(67)="BaseDeviceDamagedLoop"
     EventResponse(68)="BaseDeviceDestructedLoop"
     EventResponse(69)="CharacterMovementThrustLoop_BloodEagleLightFem"
     EventResponse(70)="CharacterMovementThrustLoop_BloodEagleMediumFem"
     EventResponse(71)="CharacterMovementThrustLoop_ImperialMediumVictoria"
     EventResponse(72)="CharacterMovementThrustLoop_PhoenixHeavyJericho"
     EventResponse(73)="CharacterMovementThrustLoop_PhoenixMediumDaniel"
     EventResponse(74)="CharacterMovementThrustLoop_PhoenixLightFem"
     EventResponse(75)="CaptureFlagBeagleIdling"
     EventResponse(76)="CaptureFlagPhoenixIdling"
     EventResponse(77)="CaptureFlagImperialIdling"
     EventResponse(78)="ResupplyStationSteam"
     EventResponse(79)="CharacterMovementEnterWater_Medium"
     EventResponse(80)="SkeletalDecorationSteamVent"
     EventResponse(81)="DynamicMetalBarrelDestroyed"
     EventResponse(82)="DynamicMetalCrateDestroyed"
     EventResponse(83)="DynamicGlassDestroyed_WindowLargeWithGlass"
     EventResponse(84)="DynamicGlassDestroyed_WindowSmallWithGlass"
     EventResponse(85)="SkeletalDecorationChunk_Drill"
     EventResponse(86)="VehicleDestroyed"
     EventResponse(87)="AntiAircraftProjectileHit"
     EventResponse(88)="SentryProjectileHit"
     EventResponse(89)="PodWeaponProjectileHit"
     EventResponse(90)="PodWeaponProjectileAlive"
     EventResponse(91)="TurretSentryWeaponFired_TurretSentryFPS"
     EventResponse(92)="TurretSentryWeaponFired_TurretSentry"
     EventResponse(93)="AntiAircraftWeaponFired_TurretBuggy"
     EventResponse(94)="ProjectileBurnerBurningAreaAlive"
     EventResponse(95)="MortarFired_Mortar"
     EventResponse(96)="ChainGunFired_HeavyChainGun"
     EventResponse(97)="SpinFusorFired_HeavySpinFusor"
     EventResponse(98)="SpinFusorFired_HeavySpinFusorHeld"
     EventResponse(99)="ChainGunFired_HeavyChainGunHeld"
     EventResponse(100)="RocketPodFired_HeavyRocketPod"
     EventResponse(101)="RocketPodFired_HeavyRocketPodHeld"
     EventResponse(102)="DynamicSmokeDummyChunkSpawned"
     EventResponse(103)="GrapplerFired_Grappler"
     EventResponse(104)="DynamicGlassDestroyed_WindowPlain"
     EventResponse(105)="DynamicGlassDestroyed_TacticalDisplay"
     EventResponse(106)="DynamicBurningSpawned"
     EventResponse(107)="DynamicSmokingSpawned"
     EventResponse(108)="mortarFired_Mortarheld"
     EventResponse(109)="BuggyrightRearSkidding"
     EventResponse(110)="BuggyThrustingLoop"
     EventResponse(111)="BuggyEngineIdling"
     EventResponse(112)="AssaultShipTurningForceLeft"
     EventResponse(113)="AssaultShipTurningForceRight"
     EventResponse(114)="AssaultShipThrottleForward_Left"
     EventResponse(115)="AssaultShipThrottleForward_Right"
     EventResponse(116)="TurretMortarWeaponFired_TurretMortarFPS"
     EventResponse(117)="AntiAircraftWeaponFired_AssaultShipGun"
     EventResponse(118)="TurretMortarWeaponFired_TurretMortar"
     EventResponse(119)="DynamicSandBagSmallDestroyed"
     EventResponse(120)="DynamicSandBagDestroyed"
     EventResponse(121)="BucklerProjectileAlive"
     EventResponse(122)="BurnerProjectileAlive"
     EventResponse(123)="BucklerProjectileLost"
     EventResponse(124)="BucklerProjectileBounce"
     EventResponse(125)="EnergyBladeFired_Blade"
     EventResponse(126)="EnergyBladeFired_BladeHeld"
     EventResponse(127)="DynamicGlassDestroyed_Screen"
     EventResponse(128)="CatapultCatapulted"
     EventResponse(129)="EmergencyStationSteam"
     EventResponse(130)="VehicleSpawnPointSteam_VehicleSpawnBuggy"
     EventResponse(131)="MPGoalScored_TeamInfoImperial"
     EventResponse(132)="BurnerFired_Burner"
     EventResponse(133)="CharacterRepairPackTendril"
     EventResponse(134)="StaticMeshAttachmentActivating_RepairPack"
     EventResponse(135)="StaticMeshAttachmentActive_EnergyPack"
     EventResponse(136)="StaticMeshAttachmentActivating_EnergyPack"
     EventResponse(137)="StaticMeshAttachmentActivating_ShieldPack"
     EventResponse(138)="StaticMeshAttachmentActivating_SpeedPack"
     EventResponse(139)="CharacterSpeedPackActive"
     EventResponse(140)="RookBurning"
     EventResponse(141)="BucklerFired_Buckler"
     EventResponse(142)="RocketPodFired_RocketPod_Steam"
     EventResponse(143)="GrapplerProjectileHit"
     EventResponse(144)="DynFirePotfireworks"
     EventResponse(145)="InventoryStationDeployableSteam"
     EventResponse(146)="BaseDeviceDestructedStart"
     EventResponse(147)="VehicleSpawnPointSteam_VehicleSpawnPod"
     EventResponse(148)="VehicleSpawnPointSteam_VehicleSpawnAssaultShip"
     EventResponse(149)="ProjectileGloraxHit"
     EventResponse(150)="ProjectileGloraxAlive"
     EventResponse(151)="CharacterMovementSkiGroundedLoop"
     EventResponse(152)="SpawnArrayPlayerSpawned"
     EventResponse(153)="StaticMeshActorCameraFlash"
     EventResponse(154)="StaticMeshActorActorSteam"
     EventResponse(155)="SpawnArrayPlayerSpawned_Steam01"
     EventResponse(156)="SpawnArrayPlayerSpawned_Steam02"
     EventResponse(157)="SpawnArrayPlayerSpawned_Steam03"
     EventResponse(158)="SpawnArrayPlayerSpawned_Steam04"
     EventResponse(159)="DynamicGlassDestroyed_SensorGridScr"
     EventResponse(160)="DeployedTurretDestroyed"
     EventResponse(161)="MPCheckPointPassed_MPCheckpoint"
     EventResponse(162)="AntiAircraftWeaponFired_TurretBuggyFPS"
     EventResponse(163)="TurretAntiAircraftWeaponFired_TurretbuggyFPS"
     EventResponse(164)="PodFired"
     EventResponse(165)="TurretAntiAircraftWeaponFired_TurretAA"
     EventResponse(166)="MPCheckpointPassed_MPCheckpointTrials"
     EventResponse(167)="DynamicMetalVehicleChunkSpawned"
     EventResponse(168)="DynamicMetalVehicleChunkDestroyed"
     EventResponse(169)="ProjectileGloraxFired"
     EventResponse(170)="PodDiving"
     EventResponse(171)="PodDiving_Right"
     EventResponse(172)="PodDiving_LeftJet"
     EventResponse(173)="PodDiving_RightJet"
     EventResponse(174)="AssaultShipDiving_Left"
     EventResponse(175)="AssaultShipDiving_Right"
     EventResponse(176)="BaseDeployableSpawnDeploy"
     EventResponse(177)="DeployedInventoryStationDestroyed"
     EventResponse(178)="DeployedCatapultDestroyed"
     EventResponse(179)="ShockMineExplode"
     EventResponse(180)="CharacterMovementThrustUnderWaterloop"
     EventResponse(181)="BlasterProjectileHit"
     EventResponse(182)="MPFuelDepotActive_Jet01"
     EventResponse(183)="CatapultDeployableCatapulted"
     EventResponse(184)="CharacterMovementLeaveWater_Tiny"
     EventResponse(185)="CharacterMovementLeaveWater_Medium"
     EventResponse(186)="CharacterMovementLeaveWater_Large"
     EventResponse(187)="CharacterMovementUnderWaterLoop"
     EventResponse(188)="CharacterMovementUnderWaterLoop_LeftArm"
     EventResponse(189)="CharacterMovementUnderWaterLoop_RightArm"
     EventResponse(190)="CharacterMovementLeaveWater_Small"
     EventResponse(191)="CharacterMovementEnterWater_Small"
     EventResponse(192)="CharacterMovementEnterWater_Large"
     EventResponse(193)="CharacterMovementEnterWater_Tiny"
     EventResponse(194)="BlasterFired_HeavyBlasterHeld"
     EventResponse(195)="GrenadeLauncherFired_HeavyGrenadeLauncherHeld"
     EventResponse(196)="BlasterFired_HeavyBlaster"
     EventResponse(197)="GrenadeLauncherFired_HeavyGrenadeLauncher"
     EventResponse(198)="CharacterMovementskimloop"
     EventResponse(199)="BurnerprojectileIgnition"
     EventResponse(200)="DeployedTurretFired"
     EventResponse(201)="FuelDepotDefaultLiftOff_Engine01"
     EventResponse(202)="FuelDepotDefaultLiftOff_Engine02"
     EventResponse(203)="FuelDepotDefaultLiftOff_Engine03"
     EventResponse(204)="FuelDepotDefaultLiftOff_Engine04"
     EventResponse(205)="FuelDepotDefaultLiftoff_Jets"
     EventResponse(206)="BurnerProjectileHit"
     EventResponse(207)="TeamScoreFireworkteamScoredLoop"
     EventResponse(208)="BuggyleftFrontSkidding"
     EventResponse(209)="BuggyrightFrontSkidding"
     EventResponse(210)="ChaingunProjectiledecal"
     EventResponse(211)="PowerIndicatorPowerOff"
     EventResponse(212)="AssaultShipleftEngineDust"
     EventResponse(213)="AssaultShiprightEngineDust"
     EventResponse(214)="BuggyThrottleForward"
     EventResponse(215)="BuggyThrottleBack"
     EventResponse(216)="BuggyThrottleForward_SpeedDust"
     EventResponse(217)="BuggyLeftRearSkidding"
     EventResponse(218)="DynamicMetalLargeAlive_StorageUnitBiggerDestroyed"
     EventResponse(219)="DynamicMetalExplosiveAlive_StorageUnitBigger"
     EventResponse(220)="PodengineDust"
     EventResponse(221)="explosionLargeExploded"
     EventResponse(222)="explosionMediumExploded"
     EventResponse(223)="explosionSmallExploded"
     EventResponse(224)="CharacterMovementSkiLoop_BootLeft"
     EventResponse(225)="CharacterMovementSkiLoop_BootRight"
     EventResponse(226)="CharacterMovementSkiLoop_IMperialHeavy_RightBoot"
     EventResponse(227)="CharacterMovementSkiLoop_ImperialHeavy_LeftBoot"
     EventResponse(228)="CharacterMovementSkiLoop_PhoenixHeavy_RightBoot"
     EventResponse(229)="CharacterMovementSkiLoop_PhoenixHeavy_BootLeft"
     EventResponse(230)="CharacterMovementSkiLoop_BloodeagleHeavy_BootRight"
     EventResponse(231)="CharacterMovementSkiLoop_BloodEagleHeavy_BootLeft"
     EventResponse(232)="CharacterMovementSkiLoop_PhoenixHeavyJericho_BootRight"
     EventResponse(233)="CharacterMovementSkiLoop_PhoenixHeavyJericho_BootLeft"
     EventResponse(234)="DynamicMetalVehicleBitAlive"
     EventResponse(235)="DynamicMetalVehicleBitDestroyed"
     EventResponse(236)="BurnerFired_HeavyBurner"
     EventResponse(237)="BurnerFired_HeavyburnerHeld"
     EventResponse(238)="BurnerFired_Burnerheld"
     EventResponse(239)="DynGlassWindowSlantPaneDestroyed"
     EventResponse(240)="CharacterMovementCollision_Extreme"
     EventResponse(241)="MPFuelCellDenominationTenCarrying"
     EventResponse(242)="SentryProjectileDECAL"
     EventResponse(243)="WeaponTurretSentryNotZoomedFired_tankgunner"
     EventResponse(244)="TankWeaponFired_TankCannon"
     EventResponse(245)="ProjectileMortarTankAlive"
     EventResponse(246)="ProjectileMortarHit_Rocket"
     EventResponse(247)="TankThrottleForward"
     EventResponse(248)="TankTankBoost_right"
     EventResponse(249)="TankTankBoost_Left"
     EventResponse(250)="AssaultShipFired_AssaultShip"
     EventResponse(251)="CharacterMovementThrustLoop_JuliaChild"
     EventResponse(252)="BucklerProjectileHit"
     EventResponse(253)="BucklerBucklerDeflect_Buckler"
     EventResponse(254)="CaptureFlagNeutralIdling"
     EventResponse(255)="AssaultShipEngineIdling_left"
     EventResponse(256)="AssaultShipEngineIdling_Right"
     EventResponse(257)="BucklerBucklerDeflect_BucklerHeld"
     EventResponse(258)="bucklerbucklerchecked_buckler"
     EventResponse(259)="bucklerbucklerchecked_bucklerheld"
     EventResponse(260)="AssaultShipStrafeLeftOrThrust"
     EventResponse(261)="AssaultShipStrafeRightOrThrust"
     EventResponse(262)="ChaingunFired_Chaingun_shell"
     EventResponse(263)="ChaingunProjectileWaterEnter"
     EventResponse(264)="ChaingunProjectileWaterLeave"
     EventResponse(265)="ProjectileBurnerTurretHit"
     EventResponse(266)="ProjectileBurnerTurretIgnition"
     EventResponse(267)="ProjectileBurnerTurretBurningAreaAlive"
     EventResponse(268)="DeployedTurretSpaceshipFired"
     EventResponse(269)="DynamicMetalExplosiveDestroyed_StorageUnitBigger"
     EventResponse(270)="ProjectileMortarBombHit"
     EventResponse(271)="ProjectileMortarBombAlive"
     EventResponse(272)="EnergyBladeFired_HeavyBlade"
     EventResponse(273)="EnergyBladeFired_HeavyBladeHeld"
     EventResponse(274)="VehicleCollision"
     EventResponse(275)="DynamicPhoenixTowerPanelAlive_explosion"
     EventResponse(276)="DynamicPhoenixTowerPanelAlive_FireTrail"
     EventResponse(277)="Skeletal_dogfight2dogfightexplode"
     EventResponse(278)="DeployedRepairerRepairPackTendril"
     EventResponse(279)="DynBallDestroyed"
     EventResponse(280)="skel_escapepodanimescapepodjet"
     EventResponse(281)="DynamicMetalExplosiveDestroyed"
     EventResponse(282)="EnergybladeHit"
     EventResponse(283)="MPTerritoryRepairPackTendril"
     EventResponse(284)="WeaponTurretSentryNotZoomedFired_tankturretFPS"
     EventResponse(285)="TurretBurnerWeaponFired_TurretBurnerFPS"
     EventResponse(286)="TurretBurnerWeaponFired_TurretBurner"
     EventResponse(287)="DeployedRepairerDestroyed"
     EventResponse(288)="BucklerFired_BucklerHeld"
     EventResponse(289)="MPGoalScored_TeamInfoBeagle"
     EventResponse(290)="MPGoalScored_TeamInfoPhoenix"
     EventResponse(291)="CharacterMovementCollision_Large"
     EventResponse(292)="CharacterMovementCollision_Medium"
     EventResponse(293)="CharacterMovementCollision_Small"
     EventResponse(294)="StaticMeshActorfireworks"
     EventResponse(295)="CharacterMovementCollision_Tiny"
     EventResponse(296)="DynamicMetalVehiclePannelDestroyed"
     EventResponse(297)="DynamicMetalDestroyed_DoorLocked"
     EventResponse(298)="RocketPodProjectileDud"
     EventResponse(299)="SkeletalDecorationCorridorDeath"
     EventResponse(300)="SkeletalDecorationOnFire_Head"
     EventResponse(301)="SkeletalDecorationOnFire_Bottom"
     EventResponse(302)="SkeletalDecorationOnFire_Arm"
     EventResponse(303)="SkeletalDecorationDiningRoom01"
     EventResponse(304)="SkeletalDecorationDiningRoom02"
     EventResponse(305)="DynamicRockImperialStoneDestroyed_SewerCeiling"
     EventResponse(306)="SkeletalDecorationBoom"
     EventResponse(307)="SkeletalDecorationSpinHit01"
     EventResponse(308)="SkeletalDecorationjetpackbe01"
     EventResponse(309)="SkeletalDecorationJetpackIM01"
     EventResponse(310)="SkeletalDecorationJetpackIM02"
     EventResponse(311)="SkeletalDecorationJetpackBE02"
     EventResponse(312)="SkeletalDecorationChainGunSHells"
     EventResponse(313)="SkeletalDecorationChaingunMuzzleEntry01"
     EventResponse(314)="SkeletalDecorationChaingunMuzzleEntry02"
     EventResponse(315)="SkeletalDecorationChaingunMuzzleEntry03"
     EventResponse(316)="SkeletalDecorationSpinMflash01"
     EventResponse(317)="SkeletalDecorationChaingunMuzzleEntry04"
     EventResponse(318)="SkeletalDecorationSpinMflash02"
     EventResponse(319)="SkeletalDecorationChainGunHit01"
     EventResponse(320)="SkeletalDecorationChainGunHit02"
     EventResponse(321)="SkeletalDecorationChainGunHit03"
     EventResponse(322)="SkeletalDecorationChainGunHit04"
     EventResponse(323)="DynStorageUnitDestroyed"
     EventResponse(324)="DynamicMetalComputerDestroyed"
     EventResponse(325)="DynamicMetalComputerLargeDestroyed"
     EventResponse(326)="DynBoulderPointyDestroyed"
     EventResponse(327)="DynBoulderSquareDestroyed"
     EventResponse(328)="SpinfusorProjectileDecal"
     EventResponse(329)="GrenadeLauncherProjectileDecal"
     EventResponse(330)="MortarProjectiledecal"
     EventResponse(331)="PodWeaponProjectiledecal"
     EventResponse(332)="RocketPodProjectiledecal"
     EventResponse(333)="HandGrenadeProjectiledecal"
     EventResponse(334)="ProjectileMortarBombDecal"
     EventResponse(335)="ProjectileMortarTankdecal"
     EventResponse(336)="RabbitFlagCarrying"
     EventResponse(337)="RabbitFlagidling"
     EventResponse(338)="DeployedTurretSpaceshipDestroyed"
     EventResponse(339)="VehicleWaterEnter"
     EventResponse(340)="VehicleWaterLeave"
     EventResponse(341)="SkeletalDecorationLeftBackJet_AshipEntry"
     EventResponse(342)="SkeletalDecorationRightBackJet_AshipEntry"
     EventResponse(343)="SkeletalDecorationAshipFire_AshipEntry"
     EventResponse(344)="HandGrenadeProjectileAlive"
     EventResponse(345)="ProjectileChaingunSentryDeployableHit"
     EventResponse(346)="ExplosionSpaceshipPannelExploded"
     EffectSpecificationSubClass=Class'VisualEffectSpecification'
}
