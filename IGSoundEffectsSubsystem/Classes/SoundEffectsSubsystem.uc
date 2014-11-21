class SoundEffectsSubsystem extends IGEffectsSystem.EffectsSubsystem
    implements Engine.IInterestedActorDestroyed
    config(SoundEffects)
    native;

// =============================================================================
//  SoundEffectsSubsystem
// 
// 
//  The SoundEffectsSubsystem is the manager class for the sound system.  It contains the public 
//  interface that the EffectsSystem deals with.  Most of the functionality is handled in native
//  code, except for overriden script functions from the base class, EffectsSubsystem, though these
//  are kept small and generally rely on native functions anyway.  This class has the responsibility
//  of creating and maintaining the list of currently playing soundinstances.  
//
// ==============================================================================

// Constants
const kMaxSounds        = 80;
const kMaxInstances     = 80;
const kNoTime           = 1000000000.0;

// ==============================================================================
// Variables
// ==============================================================================

// SoundInstanceBank is an ActorBank which handles pooling soundinstances that are no longer in the 
// CurrentSounds array.  Each sound currently playing has a corresponding SoundInstance that encapsulates
// the instance data, and handles updating the sound.  When a new sound plays, a SoundInstance is withdrawn
// from the SoundInstanceBank and added to the CurrentSounds array.  When a sound stops, it is removed from
// the CurrentSounds and deposited into the SoundInstanceBank.  Note: SoundInstances perform no updating 
// functionality while in the SoundInstanceBank.
var private transient ActorBank             SoundInstanceBank;      // Bank of unused SoundInstances.
var private transient array<SoundInstance>  CurrentSounds;          // Currently playing SoundInstances.

// State flags....
var private bool                            bSoundsArePaused;       // Whether all sounds are paused
var private bool                            GameStarted;            // Whether the game has started or not
var private config bool                     bDebugSounds;           // Whether we should log out all sorts of debug info.

// Native functions...
// Tell the sound system that the give sound will loop
native static function                      SetNativeLooping (Level inSoundLevel, sound inSound);
// Return a debug string describing the state of the sound system
native final function string                GetSoundDebugText ();

// Stopping sound functionality....
native final function bool                  StopSound(Actor Source, Sound Sound);
// Stop all SoundInstances being played on the given actor
native final function                       StopMySchemas (Actor inSource);
// Stop all SoundInstances being played currently
native final function                       StopAllSchemas();
// Stop all looping schemas that the specified actor is playing
native final function                       StopMyLoopingSchemas(Actor inSource);
// Returns if the given specification is playing on the given actor
native final function bool                  IsSchemaPlaying (Actor inSource, name SpecificationName);

// These private functions handle instance creation/deletion/updating. 
native private final function bool          CanStartInstance(SoundInstance inInstance);
native private final function               KillInstance(SoundInstance inInstance);
native private final function               AddToCurrentSounds (SoundInstance inInstance);
// CreateSoundInstance withdraws a SoundInstance from a bank, which could possibly cause the creation of a soundinstance
// TODO: Maybe should be called "GetSoundInstance" or something?
native private final function SoundInstance CreateSoundInstance ();

native private final function NativeInitialize();

// Overridable delegate for withdrawn behavior 
function OnBankWithdrawn(Actor inActorWithdrawn)
{
    assertWithDescription( inActorWithdrawn.IsA( 'SoundInstance' ), "Withdrawing a non-SoundInstance from the bank!" );
    inActorWithdrawn.OptimizeIn();
}

// Overridable delegate for deposited behavior 
function OnBankDeposited(Actor inActorDeposited)
{
    local SoundInstance BankedInstance;
    assertWithDescription( inActorDeposited.IsA( 'SoundInstance' ), "Depositing a non-SoundInstance from the bank!" );
    
    // Make sure the sound was stopped before hand...
    BankedInstance = SoundInstance(inActorDeposited);
    if ( BankedInstance.SoundHandle != -1 )
        assertWithDescription( false, "Error, SoundInstance "$BankedInstance$" is being deposited in the bank but it wasn't stopped." );

    if (bDebugSounds)
    {
    	log("Actor: "$BankedInstance$" was deposited");
    }
    inActorDeposited.OptimizeOut();
}

// PreBeginPlay override handles initialization of any necessary data
simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    RegisterNotifyGameStarted();

	if (Outer.Name != 'Entry')
		Level.RegisterNotifyActorDestroyed(Self);

    // Create sound instance bank
    SoundInstanceBank = Spawn(class'ActorBank');
    SoundInstanceBank.Initialize( class'SoundInstance' );

    SoundInstanceBank.OnWithdrawn = OnBankWithdrawn;
    SoundInstanceBank.OnDeposited = OnBankDeposited;

	NativeInitialize();
}

function OnOtherActorDestroyed(Actor ActorBeingDestroyed)
{
    //log("Actor"$ActorBeingDestroyed$" was destroyed");
    StopMyLoopingSchemas(ActorBeingDestroyed);
}

// GameStarted notification function, sets the GameStarted flag to true...
simulated function OnGameStarted() { GameStarted=true; }

// GetSoundMaterialFlags is used to get the pertinent flag from the Material.  Sometimes the sound designer
// will set the SoundFlag directly, other times, when the MaterialSoundType is not set, the visual effect
// flag will be used. 
simulated function int GetSoundMaterialFlags(Material inMaterial)
{
    // HACK: set the SoundEffectSubsystem's TextureFlags from the passed material (if any)
    if (inMaterial != None)
    {
        if (inMaterial.MaterialSoundType != 0)
            return inMaterial.MaterialSoundType;
        else
            return inMaterial.MaterialVisualType;
    }
    return 0;
}

// This EffectSubsystem overriden function plays the given effect specification.  This will result in the creation and 
// updating of a new SoundInstance if necessary.
simulated event Actor PlayEffectSpecification(EffectSpecification GenericSchema,
                                                 Actor Source,
                                                 optional Actor Target,
                                                 optional Material TargetMaterial,
                                                 optional vector overrideWorldLocation,
                                                 optional rotator overrideWorldRotation,
                                                 optional IEffectObserver Observer)
{
    local SoundInstance NewInstance;
    local SoundEffectSpecification Schema;
    local bool bInstanceValid;

	if (GenericSchema == None)
		return None;

    if (bDebugSounds)
    {
        log( "[SOUNDEFFECTS] - EffectSpecification Triggered!  Specification: "$GenericSchema$", on Actor: "$Source$" and Material: "$TargetMaterial);
    }

    Schema = SoundEffectSpecification(GenericSchema);
    //log("Playeffectspec: "$GenericSchema$" with observer: "$Observer);
    assert(Schema != None);

    // Create a new sound instance
    NewInstance = CreateSoundInstance();
    if (NewInstance != None)
    {
        // Construct the soundinstance based on the Specification...
        bInstanceValid = Schema.ConstructSoundInstance(NewInstance, GetSoundMaterialFlags(TargetMaterial), Source, GameStarted);

#if !IG_TRIBES3 // Alex: sound effect observers were causing clean up crashes - we do not use this functionality so it has been culled
        // SetObserver as soon as Instance is constructed, previously it was set after the next !bInstanceValid || !CanStartInstance() 
        // conditional.  Set it here so OnEffectStopped is called correctly if the NewInstance doesn't play.
        if (Observer != None)
            NewInstance.SetObserver(Observer);
#endif

        if ( !bInstanceValid  || !CanStartInstance(NewInstance) )
        {
            if (bDebugSounds)
            {
                log( "[SOUNDEFFECTS] - ERROR! Sound could not be started!" );
            }
            KillInstance (NewInstance);
            return None;
        }         

        if ( bDebugSounds )
            log( "New Instance:"$NewInstance$" Instantiated: "$NewInstance.toString() );

        // SoundInstance is ok to be played...
        AddToCurrentSounds(NewInstance);
        if ( bDebugSounds )
            log( "About to play New Instance: "$NewInstance.toString() );
               
        // Tell the instance it's been properly initialized...
        NewInstance.OnFinishedInitialized();

        // Play the sound and shiznits....
        NewInstance.Play();
    }
    return NewInstance;    // SoundEffectSubsystems create SoundInstances which are Actors and can be returned here to
                           // implement the normal behavior of an EffectsSubsystem
}

// This EffectSubsystem overriden function stops the given effect specification.  This will result in stopping the 
// sound in the lower level unreal code, removing the SoundInstance from the CurrentSounds.
simulated event StopEffectSpecification(EffectSpecification EffectSpec, Actor Source)
{
    local int i;
    assertWithDescription(source != None, "StopSchema called with NULL source.");

    // Check through currently playing sounds and stop instances
    // with this object and schema.
    for (i = CurrentSounds.Length-1; i >= 0; --i)
    {
        if (CurrentSounds[i] != None)
        {
            if (CurrentSounds[i].Source == source && CurrentSounds[i].SchemaName == EffectSpec.Name)
                KillInstance (CurrentSounds[i]);
        }
    }
}


// These pause functions call a console command which causes the lower level unreal code to pause 
// all sounds.  Note: This functionality is likely to chaange....
simulated function PauseAllSchemas ()
{
        if (!bSoundsArePaused)
        {
                ConsoleCommand ("PauseSounds");
                bSoundsArePaused = true;
        }
}
simulated function UnpauseAllSchemas ()
{
        if (bSoundsArePaused)
        {
                ConsoleCommand ("UnpauseSounds");
                bSoundsArePaused = false;
        }
}


// PlayMarkerSounds plays sounds triggered by walking into a given SoundMarker.  Sounds played will stop the previous
// marker sound and start a new one.
simulated function PlayMarkerSounds (Actor inSource, string inSoundID1, string inSoundID2)
{
    local bool bPlaySound1;
    local bool bPlaySound2;
    local int i;
    
    bPlaySound1 = true;
    bPlaySound2 = true;

    // Stop any marker sounds currently playing (that aren't also played by *this* marker)

    for (i = 0; i < CurrentSounds.Length; ++i)
        if (CurrentSounds[i] != None && CurrentSounds[i].Source != None)
            if (CurrentSounds[i].Source.IsA ('SoundMarker'))
                if (string(CurrentSounds[i].SchemaName) == inSoundID1)
                    // Sound 1 is already playing
                    bPlaySound1 = false;
                else if (string(CurrentSounds[i].SchemaName) == inSoundID2)
                    // Sound 2 is already playing
                    bPlaySound2 = false; 
                else
                    KillInstance (CurrentSounds[i]);

    // Play the new sound(s)
    if (inSoundID1 != "" && GetSpecificationByString(inSoundID1) != None && bPlaySound1)
        PlayEffectSpecification(GetSpecificationByString(inSoundID1), inSource);

    if (inSoundID2 != "" && GetSpecificationByString(inSoundID2) != None && bPlaySound2)
        PlayEffectSpecification(GetSpecificationByString(inSoundID2), inSource);
}

// Print the current sounds and sound instances to the log
simulated function LogState()
{
    local int i;
    local String StateString;

    Log("----------------------------------------------------------------");
    Log("|              SOUND EFFECTS SUBSYSTEM STATE                   |");
    Log("----------------------------------------------------------------");
    Log("| Existing sounds:");
    for (i = 0; i < CurrentSounds.Length; ++i)
    {
        StateString = "None";
        if (CurrentSounds[i] != None) { StateString = CurrentSounds[i].toString(); }
        Log("|   #"$i$": "$StateString);
    }
    Log("----------------------------------------------------------------");
}

// Native c++ .h interface....
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
private: 
    void RemoveFromCurrentSounds (ASoundInstance* inInstance);
    // Handles cases where a new sound can overwrite an old sound
    UBOOL HandleOverlap (ASoundInstance* inExistingSound, ASoundInstance* inNewSound);
    UBOOL IsBeingDelayed(ASoundInstance* inInstance);
    UBOOL IsSchemaPlaying(AActor* inSource, FName schemaName);
    class USoundEffectSpecification* GetSpecificationByName( FName SchemaName );
    UBOOL CanStartInstance(ASoundInstance* inInstance);

    // Stop instance will just stop the sample playing, while leaving the SoundInstance updating, this 
    // should NEVER be called by anything outside of ASoundInstance of ASoundEffectsSubsystem.  This is used
    // for non-seamless loops where there is a random delay between loop iterations.  
    void StopInstance (ASoundInstance* inInstance);
    // Requires ASoundInstance to be a friend...
    friend class ASoundInstance;

    // When the UAudioSubsystem stops a sound sample for whatever reason, we need to make sure and cleanup SoundInstance's
    // that reference the sample
    void OnSubsystemStoppedSound( int StoppedHandle );
    // Requires this function to be a friend...
    friend static void GlobalSoundStoppedByAudioSubsystem( int SoundIndex );

    static UAudioSubsystem* AudioSubsystem;

public:
    // Used to register names for events in this package
    void InitExecution();
    void PostScriptDestroyed();
    
    // Returns the duration of the sound
    static FLOAT GetSoundInstanceDuration(ASoundInstance* inInstance);

    // Returns the current UAudioSubsystem...
    static UAudioSubsystem* GetAudio();

    // Stops a sound from playing the actual sound, though it still updates.  Used when a sound is too far away to hear
    void MuteInstance (ASoundInstance* inInstance);
    void UnMuteInstance (ASoundInstance* inInstance);

    // Instance handling functions
    void PlayInstance (ASoundInstance* inInstance);
    void KillInstance (ASoundInstance* inInstance);

}


defaultproperties
{
     EventResponse(0)="EnergybladeEquipped"
     EventResponse(1)="EnergybladeFired"
     EventResponse(2)="EnergybladeRecoiled"
     EventResponse(3)="EnergybladeHit"
     EventResponse(4)="BlasterCocked"
     EventResponse(5)="BlasterEquipped"
     EventResponse(6)="BlasterFired"
     EventResponse(7)="BlasterProjectileAlive"
     EventResponse(8)="BlasterProjectileHit"
     EventResponse(9)="BucklerCaught"
     EventResponse(10)="BucklerEquipped"
     EventResponse(11)="BucklerFired"
     EventResponse(12)="BucklerIdle"
     EventResponse(13)="BucklerProjectileAlive"
     EventResponse(14)="BucklerProjectileBounce"
     EventResponse(15)="BucklerProjectileHit"
     EventResponse(16)="BurnerCocked"
     EventResponse(17)="BurnerEquipped"
     EventResponse(18)="BurnerFired"
     EventResponse(19)="BurnerIdle"
     EventResponse(20)="BurnerUnequipped"
     EventResponse(21)="BurnerProjectileAlive"
     EventResponse(22)="BurnerProjectileHit"
     EventResponse(23)="ChainGunEquipped"
     EventResponse(24)="ChainGunFired"
     EventResponse(25)="ChainGunFiredEmpty"
     EventResponse(26)="ChainGunFlapBounced"
     EventResponse(27)="ChainGunMagazinePulledOut"
     EventResponse(28)="ChainGunStarterPulled"
     EventResponse(29)="ChainGunStarterPulledEmpty"
     EventResponse(30)="ChainGunStarterRewound"
     EventResponse(31)="GrapplerCableRewinding"
     EventResponse(32)="GrapplerCableRewound"
     EventResponse(33)="GrapplerEquipped"
     EventResponse(34)="GrapplerFired"
     EventResponse(35)="GrapplerGrabbed"
     EventResponse(36)="GrapplerProjectileHit"
     EventResponse(37)="GrenadeLauncherChamberFilled"
     EventResponse(38)="GrenadeLauncherChamberRotated"
     EventResponse(39)="GrenadeLauncherEquipped"
     EventResponse(40)="GrenadeLauncherFired"
     EventResponse(41)="GrenadeLauncherFiredEmpty"
     EventResponse(42)="GrenadeLauncherMagazinePulledOut"
     EventResponse(43)="GrenadeLauncherRecoiled"
     EventResponse(44)="GrenadeLauncherProjectileAlive"
     EventResponse(45)="GrenadeLauncherProjectileBounce"
     EventResponse(46)="GrenadeLauncherProjectileHit"
     EventResponse(47)="GrenadeLauncherProjectileHit_Lo"
     EventResponse(48)="MortarBarrelRotated"
     EventResponse(49)="MortarChamberRotated"
     EventResponse(50)="MortarEquipped"
     EventResponse(51)="MortarFired"
     EventResponse(52)="MortarFiredEmpty"
     EventResponse(53)="MortarMagazinePulledOut"
     EventResponse(54)="MortarRecoiled"
     EventResponse(55)="MortarProjectileAlive"
     EventResponse(56)="MortarProjectileBounce"
     EventResponse(57)="MortarProjectileHit"
     EventResponse(58)="MortarProjectileHit_Lo"
     EventResponse(59)="RocketPodChamberFilled"
     EventResponse(60)="RocketPodCocked"
     EventResponse(61)="RocketPodEquipped"
     EventResponse(62)="RocketPodFired"
     EventResponse(63)="RocketPodFiredEmpty"
     EventResponse(64)="RocketPodMagazinePulledOut"
     EventResponse(65)="RocketPodProjectileAlive"
     EventResponse(66)="RocketPodProjectileHit"
     EventResponse(67)="SniperRifleEquipped"
     EventResponse(68)="SniperRifleFired"
     EventResponse(69)="SniperRifleFiredEmpty"
     EventResponse(70)="SniperRifleShellEjected"
     EventResponse(71)="SniperRifleShellBounced"
     EventResponse(72)="SniperRifleProjectileHit"
     EventResponse(73)="SpinfusorCocked"
     EventResponse(74)="SpinfusorEquipped"
     EventResponse(75)="SpinfusorFired"
     EventResponse(76)="SpinfusorFiredEmpty"
     EventResponse(77)="SpinfusorIdle"
     EventResponse(78)="SpinfusorMagazinePulledOut"
     EventResponse(79)="SpinfusorProjectileAlive"
     EventResponse(80)="SpinfusorProjectileHit"
     EventResponse(81)="ProjectileMortarBombAlive"
     EventResponse(82)="ProjectileMortarBombHit"
     EventResponse(83)="ProjectileMortarBombHit_Lo"
     EventResponse(84)="TankWeaponFired"
     EventResponse(85)="ProjectileMortarTankAlive"
     EventResponse(86)="ProjectileMortarTankHit"
     EventResponse(87)="ProjectileMortarTankHit_Lo"
     EventResponse(88)="TurretMortarWeaponFired"
     EventResponse(89)="TurretMortarWeaponBarrelRotated"
     EventResponse(90)="AntiAircraftWeaponFired"
     EventResponse(91)="AntiAircraftWeaponRecoiled"
     EventResponse(92)="TurretAntiAircraftWeaponFired"
     EventResponse(93)="TurretAntiAircraftWeaponRecoiled"
     EventResponse(94)="AntiAircraftProjectileAlive"
     EventResponse(95)="AntiAircraftProjectileHit"
     EventResponse(96)="TankGunnerWeaponFired"
     EventResponse(97)="TurretSentryWeaponFired"
     EventResponse(98)="SentryProjectileHit"
     EventResponse(99)="PodWeaponProjectileAlive"
     EventResponse(100)="PodWeaponProjectileHit"
     EventResponse(101)="TurretBurnerWeaponFired"
     EventResponse(102)="TurretBurnerWeaponCocked"
     EventResponse(103)="CharacterFootWalk_BloodEagleHeavy"
     EventResponse(104)="CharacterFootWalk_BloodEagleLight"
     EventResponse(105)="CharacterFootWalk_BloodEagleLightFem"
     EventResponse(106)="CharacterFootWalk_BloodEagleMedium"
     EventResponse(107)="CharacterFootWalk_BloodEagleMediumFem"
     EventResponse(108)="CharacterFootWalk_BloodEagleMediumSeti"
     EventResponse(109)="CharacterFootWalk_CivilianMaleBeagle"
     EventResponse(110)="CharacterFootWalk_CivilianMaleImperial"
     EventResponse(111)="CharacterFootWalk_CivilianMalePhoenix"
     EventResponse(112)="CharacterFootWalk_CivilianMalePrisoner"
     EventResponse(113)="CharacterFootWalk_Daniel"
     EventResponse(114)="CharacterFootWalk_Gaius"
     EventResponse(115)="CharacterFootWalk_ImperialHeavy"
     EventResponse(116)="CharacterFootWalk_ImperialLight"
     EventResponse(117)="CharacterFootWalk_ImperialLightAlbrecht"
     EventResponse(118)="CharacterFootWalk_ImperialLightFem"
     EventResponse(119)="CharacterFootWalk_ImperialLightJulia"
     EventResponse(120)="CharacterFootWalk_ImperialMedium"
     EventResponse(121)="CharacterFootWalk_ImperialMediumFem"
     EventResponse(122)="CharacterFootWalk_ImperialMediumVictoria"
     EventResponse(123)="CharacterFootWalk_Jericho"
     EventResponse(124)="CharacterFootWalk_JuliaChild"
     EventResponse(125)="CharacterFootWalk_Mercury"
     EventResponse(126)="CharacterFootWalk_MercuryDamage"
     EventResponse(127)="CharacterFootWalk_Olivia"
     EventResponse(128)="CharacterFootWalk_PhoenixHeavy"
     EventResponse(129)="CharacterFootWalk_PhoenixHeavyJericho"
     EventResponse(130)="CharacterFootWalk_PhoenixLight"
     EventResponse(131)="CharacterFootWalk_PhoenixLightFem"
     EventResponse(132)="CharacterFootWalk_PhoenixMedium"
     EventResponse(133)="CharacterFootWalk_PhoenixMediumDaniel"
     EventResponse(134)="CharacterFootWalk_PhoenixMediumEsther"
     EventResponse(135)="CharacterFootWalk_PhoenixMediumFem"
     EventResponse(136)="CharacterFootWalk_PrincessVictoria"
     EventResponse(137)="CharacterFootWalk_Tiberius"
     EventResponse(138)="CharacterFootRun_BloodEagleHeavy"
     EventResponse(139)="CharacterFootRun_BloodEagleLight"
     EventResponse(140)="CharacterFootRun_BloodEagleLightFem"
     EventResponse(141)="CharacterFootRun_BloodEagleMedium"
     EventResponse(142)="CharacterFootRun_BloodEagleMediumFem"
     EventResponse(143)="CharacterFootRun_BloodEagleMediumSeti"
     EventResponse(144)="CharacterFootRun_CivilianMaleBeagle"
     EventResponse(145)="CharacterFootRun_CivilianMaleImperial"
     EventResponse(146)="CharacterFootRun_CivilianMalePhoenix"
     EventResponse(147)="CharacterFootRun_CivilianMalePrisoner"
     EventResponse(148)="CharacterFootRun_Daniel"
     EventResponse(149)="CharacterFootRun_Gaius"
     EventResponse(150)="CharacterFootRun_ImperialHeavy"
     EventResponse(151)="CharacterFootRun_ImperialLight"
     EventResponse(152)="CharacterFootRun_ImperialLightAlbrecht"
     EventResponse(153)="CharacterFootRun_ImperialLightFem"
     EventResponse(154)="CharacterFootRun_ImperialLightJulia"
     EventResponse(155)="CharacterFootRun_ImperialMedium"
     EventResponse(156)="CharacterFootRun_ImperialMediumFem"
     EventResponse(157)="CharacterFootRun_ImperialMediumVictoria"
     EventResponse(158)="CharacterFootRun_Jericho"
     EventResponse(159)="CharacterFootRun_JuliaChild"
     EventResponse(160)="CharacterFootRun_Mercury"
     EventResponse(161)="CharacterFootRun_MercuryDamage"
     EventResponse(162)="CharacterFootRun_Olivia"
     EventResponse(163)="CharacterFootRun_PhoenixHeavy"
     EventResponse(164)="CharacterFootRun_PhoenixHeavyJericho"
     EventResponse(165)="CharacterFootRun_PhoenixLight"
     EventResponse(166)="CharacterFootRun_PhoenixLightFem"
     EventResponse(167)="CharacterFootRun_PhoenixMedium"
     EventResponse(168)="CharacterFootRun_PhoenixMediumDaniel"
     EventResponse(169)="CharacterFootRun_PhoenixMediumEsther"
     EventResponse(170)="CharacterFootRun_PhoenixMediumFem"
     EventResponse(171)="CharacterFootRun_PrincessVictoria"
     EventResponse(172)="CharacterFootRun_Tiberius"
     EventResponse(173)="CharacterFootSprint_BloodEagleHeavy"
     EventResponse(174)="CharacterFootSprint_BloodEagleLight"
     EventResponse(175)="CharacterFootSprint_BloodEagleLightFem"
     EventResponse(176)="CharacterFootSprint_BloodEagleMedium"
     EventResponse(177)="CharacterFootSprint_BloodEagleMediumFem"
     EventResponse(178)="CharacterFootSprint_BloodEagleMediumSeti"
     EventResponse(179)="CharacterFootSprint_CivilianMaleBeagle"
     EventResponse(180)="CharacterFootSprint_CivilianMaleImperial"
     EventResponse(181)="CharacterFootSprint_CivilianMalePhoenix"
     EventResponse(182)="CharacterFootSprint_CivilianMalePrisoner"
     EventResponse(183)="CharacterFootSprint_Daniel"
     EventResponse(184)="CharacterFootSprint_Gaius"
     EventResponse(185)="CharacterFootSprint_ImperialHeavy"
     EventResponse(186)="CharacterFootSprint_ImperialLight"
     EventResponse(187)="CharacterFootSprint_ImperialLightAlbrecht"
     EventResponse(188)="CharacterFootSprint_ImperialLightFem"
     EventResponse(189)="CharacterFootSprint_ImperialLightJulia"
     EventResponse(190)="CharacterFootSprint_ImperialMedium"
     EventResponse(191)="CharacterFootSprint_ImperialMediumFem"
     EventResponse(192)="CharacterFootSprint_ImperialMediumVictoria"
     EventResponse(193)="CharacterFootSprint_Jericho"
     EventResponse(194)="CharacterFootSprint_JuliaChild"
     EventResponse(195)="CharacterFootSprint_Mercury"
     EventResponse(196)="CharacterFootSprint_MercuryDamage"
     EventResponse(197)="CharacterFootSprint_Olivia"
     EventResponse(198)="CharacterFootSprint_PhoenixHeavy"
     EventResponse(199)="CharacterFootSprint_PhoenixHeavyJericho"
     EventResponse(200)="CharacterFootSprint_PhoenixLight"
     EventResponse(201)="CharacterFootSprint_PhoenixLightFem"
     EventResponse(202)="CharacterFootSprint_PhoenixMedium"
     EventResponse(203)="CharacterFootSprint_PhoenixMediumDaniel"
     EventResponse(204)="CharacterFootSprint_PhoenixMediumEsther"
     EventResponse(205)="CharacterFootSprint_PhoenixMediumFem"
     EventResponse(206)="CharacterFootSprint_PrincessVictoria"
     EventResponse(207)="CharacterFootSprint_Tiberius"
     EventResponse(208)="CharacterMovementJump_BloodEagleHeavy"
     EventResponse(209)="CharacterMovementJump_BloodEagleLight"
     EventResponse(210)="CharacterMovementJump_BloodEagleLightFem"
     EventResponse(211)="CharacterMovementJump_BloodEagleMedium"
     EventResponse(212)="CharacterMovementJump_BloodEagleMediumFem"
     EventResponse(213)="CharacterMovementJump_BloodEagleMediumSeti"
     EventResponse(214)="CharacterMovementJump_CivilianMaleBeagle"
     EventResponse(215)="CharacterMovementJump_CivilianMaleImperial"
     EventResponse(216)="CharacterMovementJump_CivilianMalePhoenix"
     EventResponse(217)="CharacterMovementJump_CivilianMalePrisoner"
     EventResponse(218)="CharacterMovementJump_Daniel"
     EventResponse(219)="CharacterMovementJump_Gaius"
     EventResponse(220)="CharacterMovementJump_ImperialHeavy"
     EventResponse(221)="CharacterMovementJump_ImperialHeavyJericho"
     EventResponse(222)="CharacterMovementJump_ImperialLight"
     EventResponse(223)="CharacterMovementJump_ImperialLightAlbrecht"
     EventResponse(224)="CharacterMovementJump_ImperialLightFem"
     EventResponse(225)="CharacterMovementJump_ImperialLightJulia"
     EventResponse(226)="CharacterMovementJump_ImperialMedium"
     EventResponse(227)="CharacterMovementJump_ImperialMediumFem"
     EventResponse(228)="CharacterMovementJump_ImperialMediumVictoria"
     EventResponse(229)="CharacterMovementJump_Jericho"
     EventResponse(230)="CharacterMovementJump_JuliaChild"
     EventResponse(231)="CharacterMovementJump_Mercury"
     EventResponse(232)="CharacterMovementJump_MercuryDamage"
     EventResponse(233)="CharacterMovementJump_Olivia"
     EventResponse(234)="CharacterMovementJump_PhoenixHeavy"
     EventResponse(235)="CharacterMovementJump_PhoenixHeavyJericho"
     EventResponse(236)="CharacterMovementJump_PhoenixLight"
     EventResponse(237)="CharacterMovementJump_PhoenixLightFem"
     EventResponse(238)="CharacterMovementJump_PhoenixMedium"
     EventResponse(239)="CharacterMovementJump_PhoenixMediumDaniel"
     EventResponse(240)="CharacterMovementJump_PhoenixMediumEsther"
     EventResponse(241)="CharacterMovementJump_PhoenixMediumFem"
     EventResponse(242)="CharacterMovementJump_PrincessVictoria"
     EventResponse(243)="CharacterMovementJump_Tiberius"
     EventResponse(244)="CharacterGesturedUpwards_BloodEagleHeavy"
     EventResponse(245)="CharacterGesturedUpwards_ImperialHeavy"
     EventResponse(246)="CharacterGesturedUpwards_ImperialHeavyJericho"
     EventResponse(247)="CharacterGesturedUpwards_PhoenixHeavy"
     EventResponse(248)="CharacterGesturedUpwards_PhoenixHeavyJericho"
     EventResponse(249)="CharacterGesturedDownwards_BloodEagleHeavy"
     EventResponse(250)="CharacterGesturedDownwards_ImperialHeavy"
     EventResponse(251)="CharacterGesturedDownwards_ImperialHeavyJericho"
     EventResponse(252)="CharacterGesturedDownwards_PhoenixHeavy"
     EventResponse(253)="CharacterGesturedDownwards_PhoenixHeavyJericho"
     EventResponse(254)="CharacterHitLatch"
     EventResponse(255)="CharacterHitWindow"
     EventResponse(256)="CharacterHitWindow_BloodEagleHeavy"
     EventResponse(257)="CharacterHitWindow_ImperialHeavy"
     EventResponse(258)="CharacterHitWindow_ImperialHeavyJericho"
     EventResponse(259)="CharacterHitWindow_PhoenixHeavy"
     EventResponse(260)="CharacterHitWindow_PhoenixHeavyJericho"
     EventResponse(261)="CharacterItemThrown"
     EventResponse(262)="CharacterPushedButtonA"
     EventResponse(263)="CharacterPushedButtonB"
     EventResponse(264)="CharacterTapped"
     EventResponse(265)="AmbientSoundAlarmBreakout"
     EventResponse(266)="AmbientSoundAlarmGenerator"
     EventResponse(267)="AmbientSoundAlarmGeneratorUrgent"
     EventResponse(268)="AmbientSoundAlarmGravityLost"
     EventResponse(269)="AmbientSoundAlarmPrison"
     EventResponse(270)="AmbientSoundAlarmSetiTurret"
     EventResponse(271)="AmbientSoundAntiGravOff"
     EventResponse(272)="AmbientSoundAntiGravOn"
     EventResponse(273)="AmbientSoundBridgeCollapse"
     EventResponse(274)="AmbientSoundCatapultDoorActivate"
     EventResponse(275)="AmbientSoundCatapultDoorGo"
     EventResponse(276)="AmbientSoundCrowdAw"
     EventResponse(277)="AmbientSoundCrowdBoo"
     EventResponse(278)="AmbientSoundCrowdChant"
     EventResponse(279)="AmbientSoundCrowdCheer"
     EventResponse(280)="AmbientSoundCrowdMurmer"
     EventResponse(281)="AmbientSoundDoorHingedGratingGo"
     EventResponse(282)="AmbientSoundDoorPhoenixGo"
     EventResponse(283)="AmbientSoundDoorPhoenixStop"
     EventResponse(284)="AmbientSoundDoorSmashed"
     EventResponse(285)="AmbientSoundEscapePodLaunch"
     EventResponse(286)="AmbientSoundExploBigDoor"
     EventResponse(287)="AmbientSoundExploPanel"
     EventResponse(288)="AmbientSoundExploShaft"
     EventResponse(289)="AmbientSoundExploSpaceship"
     EventResponse(290)="AmbientSoundGloraxRustle"
     EventResponse(291)="AmbientSoundLapRegister"
     EventResponse(292)="AmbientSoundLightningRodHit"
     EventResponse(293)="AmbientSoundMainGateActivate"
     EventResponse(294)="AmbientSoundMainGateGo"
     EventResponse(295)="AmbientSoundMainGateStop"
     EventResponse(296)="AmbientSoundQuakeSpaceship"
     EventResponse(297)="AmbientSoundRecalibPoweringUp"
     EventResponse(298)="AmbientSoundRoundBegin"
     EventResponse(299)="AmbientSoundRoundOver"
     EventResponse(300)="AmbientSoundThunder"
     EventResponse(301)="AmbientSoundTowerChuteActivate"
     EventResponse(302)="AmbientSoundTowerChuteGo"
     EventResponse(303)="AmbientSoundTowerChuteStop"
     EventResponse(304)="AmbientSoundTrialBegin"
     EventResponse(305)="AmbientSoundTrialFailure"
     EventResponse(306)="AmbientSoundTrialGoalScored"
     EventResponse(307)="AmbientSoundTrialSuccess"
     EventResponse(308)="AmbientSoundWalkwayCollapse"
     EventResponse(309)="AmbientSoundHackedLocked"
     EventResponse(310)="AmbientSoundAlarmIntruder"
     EventResponse(311)="AmbientSoundBattleRages"
     EventResponse(312)="AmbientSoundBattleRagesVehicles"
     EventResponse(313)="AmbientSoundVentDestroyed"
     EventResponse(314)="AmbientSoundAccessGranted"
     EventResponse(315)="AmbientSoundRockStaircaseCrumbles"
     EventResponse(316)="AmbientSoundRockBridgeCrumbles"
     EventResponse(317)="AmbientSoundDoorHanger"
     EventResponse(318)="AmbientSoundFloorDestroyed"
     EventResponse(319)="AmbientSoundBasePowerDown"
     EventResponse(320)="AmbientSoundBasePowerDownDistant"
     EventResponse(321)="AmbientSoundVirusInserted"
     EventResponse(322)="AmbientSoundBarrierDown"
     EventResponse(323)="AmbientSoundBarrierDeactivated"
     EventResponse(324)="AmbientSoundBattleRagesMuffled"
     EventResponse(325)="AmbientSoundTeleport"
     EventResponse(326)="AmbientSoundAlive_electrical"
     EventResponse(327)="AmbientSoundAlive_mechanical"
     EventResponse(328)="AmbientSoundAlive_blizzard"
     EventResponse(329)="AmbientSoundAlive_leaves"
     EventResponse(330)="AmbientSoundAlive_shaft"
     EventResponse(331)="AmbientSoundAlive_skyscraper"
     EventResponse(332)="AmbientSoundAlive_rocktumble"
     EventResponse(333)="AmbientSoundAlive_spaceship"
     EventResponse(334)="AmbientSoundAlive_steamloop"
     EventResponse(335)="MoverOpening"
     EventResponse(336)="MoverOpened"
     EventResponse(337)="MoverClosing"
     EventResponse(338)="MoverClosed"
     EventResponse(339)="SoundMarkerdummyevent"
     EventResponse(340)="SoundMarkerm01dummyevent"
     EventResponse(341)="AmbientSoundAlive_computers"
     EventResponse(342)="AmbientSoundAlive_computer_loop1"
     EventResponse(343)="AmbientSoundAlive_elec_hum"
     EventResponse(344)="AmbientSoundAlive_Hollow2"
     EventResponse(345)="AmbientSoundAlive_lighthum"
     EventResponse(346)="AmbientSoundAlive_server"
     EventResponse(347)="AmbientSoundAlive_ring1"
     EventResponse(348)="AmbientSoundAlive_synth"
     EventResponse(349)="AmbientSoundAlive_cavedrip"
     EventResponse(350)="AmbientSoundAlive_windhowl"
     EventResponse(351)="AmbientSoundAlive_base"
     EventResponse(352)="AmbientSoundAlive_throb"
     EventResponse(353)="AmbientSoundAlive_ring3"
     EventResponse(354)="AmbientSoundAlive_turret_loop"
     EventResponse(355)="AmbientSoundAlive_beep1"
     EventResponse(356)="AmbientSoundAlive_hum"
     EventResponse(357)="HandGrenadeProjectileHit"
     EventResponse(358)="AmbientSoundAlive_windlonely"
     EventResponse(359)="AmbientSoundAlive_ring3a"
     EventResponse(360)="AmbientSoundAlive_m04shaft"
     EventResponse(361)="AmbientSoundAlive_m04servers"
     EventResponse(362)="AmbientSoundAlive_m06tonebeep"
     EventResponse(363)="AmbientSoundAlive_computers2"
     EventResponse(364)="AmbientSoundAlive_belt"
     EventResponse(365)="PodEngineIdling"
     EventResponse(366)="PodEngineAccelerating"
     EventResponse(367)="PodEngineDecelerating"
     EventResponse(368)="PodThrusting"
     EventResponse(369)="PodDiving"
     EventResponse(370)="PodDriverEntered"
     EventResponse(371)="BuggyDriverEntered"
     EventResponse(372)="BuggyEngineIdling"
     EventResponse(373)="MPFlagReturned"
     EventResponse(374)="MPFlagPickedUp"
     EventResponse(375)="MPFlagDropped"
     EventResponse(376)="MPBallThrown"
     EventResponse(377)="MPBallBounce"
     EventResponse(378)="MPBallPickedUp"
     EventResponse(379)="AmbientSoundAlive_hum2"
     EventResponse(380)="AmbientSoundAlive_lighthum2"
     EventResponse(381)="AmbientSoundAlive_windwindow"
     EventResponse(382)="AmbientSoundAlive_watersewer"
     EventResponse(383)="AmbientSoundAlive_windhowl2"
     EventResponse(384)="AmbientSoundAlive_Fan"
     EventResponse(385)="AmbientSoundAlive_m03crowdamb1"
     EventResponse(386)="AmbientSoundAlive_m03crowdamb2"
     EventResponse(387)="AmbientSoundAlive_m03crowdamb3"
     EventResponse(388)="AmbientSoundAlive_m03crowdcheer"
     EventResponse(389)="AmbientSoundAlive_m03pa"
     EventResponse(390)="AmbientSoundAlive_m10waterfall"
     EventResponse(391)="AmbientSoundAlive_m10sewerpump"
     EventResponse(392)="AmbientSoundAlive_m10crickets"
     EventResponse(393)="BaseDeviceTeamChanged"
     EventResponse(394)="InventoryStationPanelExtendedBeg"
     EventResponse(395)="InventoryStationPanelExtendedEnd"
     EventResponse(396)="InventoryStationPanelRetractedBeg"
     EventResponse(397)="InventoryStationPanelRetractedEnd"
     EventResponse(398)="InventoryStationArmLoop"
     EventResponse(399)="InventoryStationArmStopped"
     EventResponse(400)="InventoryStationArmStarted"
     EventResponse(401)="BaseDeviceDestructed_exp"
     EventResponse(402)="BaseDeviceDamagedLoop_smoke"
     EventResponse(403)="BaseDeviceDestructedLoop_fire"
     EventResponse(404)="BaseDeviceDisabledLoop_sparks"
     EventResponse(405)="BaseDeviceDisabled"
     EventResponse(406)="BaseDeviceDisabledLoop_hum"
     EventResponse(407)="BaseDeployableDeploy"
     EventResponse(408)="BaseDeviceDestructedLoop_smoke"
     EventResponse(409)="DynamicBaseObjectPannelDestroyed"
     EventResponse(410)="BaseDeviceDestructed_powerlost"
     EventResponse(411)="InventoryStationInventoryStationActivating"
     EventResponse(412)="InventoryStationPlatformLoadoutChanged"
     EventResponse(413)="TurretPanelClosing"
     EventResponse(414)="TurretPanelOpening"
     EventResponse(415)="TurretRotateStarted"
     EventResponse(416)="TurretRotateLoop"
     EventResponse(417)="TurretRotateStopped"
     EventResponse(418)="SensorTowerRotateLoop"
     EventResponse(419)="SensorTowerDamagedLoop"
     EventResponse(420)="SensorTowerRepairing"
     EventResponse(421)="TurretKickedBack"
     EventResponse(422)="BaseDeviceRepaired"
     EventResponse(423)="VehicleSpawnPointDoorsOpened"
     EventResponse(424)="VehicleSpawnPointDoorsClosed"
     EventResponse(425)="VehicleSpawnPointPylonsUp"
     EventResponse(426)="VehicleSpawnPointPylonsDown"
     EventResponse(427)="ResupplyStationActiveLoop"
     EventResponse(428)="ResupplyStationPanelUp"
     EventResponse(429)="ResupplyStationPanelDown"
     EventResponse(430)="BaseDeviceDamagedLoop_crunch"
     EventResponse(431)="SpawnArrayActiveLoop"
     EventResponse(432)="CatapultCatapulted"
     EventResponse(433)="EmergencyStationDoorOpening"
     EventResponse(434)="EmergencyStationDoorClosing"
     EventResponse(435)="BaseDeployableSpawnPanelOpening"
     EventResponse(436)="BaseDeployableSpawnPanelClosing"
     EventResponse(437)="BaseDeployableSpawnDoorOpening"
     EventResponse(438)="BaseDeployableSpawnDoorClosing"
     EventResponse(439)="BaseObjectVehicleSpawnDoorsOpened"
     EventResponse(440)="BaseObjectVehicleSpawnDoorsClosed"
     EventResponse(441)="BaseObjectVehicleSpawnPylonsUp"
     EventResponse(442)="BaseObjectVehicleSpawnPylonsDown"
     EventResponse(443)="PowerGeneratorActiveLoop"
     EventResponse(444)="EnergyBarrierActiveLoop"
     EventResponse(445)="SwitchStationGearsBeg"
     EventResponse(446)="SwitchStationGearsSpinning"
     EventResponse(447)="SwitchStationGearsEnd"
     EventResponse(448)="MPFlagAlive"
     EventResponse(449)="MPBallAlive"
     EventResponse(450)="MPBallCaught"
     EventResponse(451)="MPBallCaptured"
     EventResponse(452)="MPBallGoalPostHit"
     EventResponse(453)="MPBallAttached"
     EventResponse(454)="MPFlagCapturePointAlive"
     EventResponse(455)="MPFlagCapturePointFlagStolen"
     EventResponse(456)="MPCheckPointAlive"
     EventResponse(457)="MPCheckPointPassed"
     EventResponse(458)="MPCheckPointFailed"
     EventResponse(459)="MPFlagCaught"
     EventResponse(460)="MPFlagThrown"
     EventResponse(461)="MPFlagAttached"
     EventResponse(462)="MPTargetDestroyed"
     EventResponse(463)="CharacterMovementSkiGroundedLoop"
     EventResponse(464)="AmbientSoundAlive_m09waterpool"
     EventResponse(465)="AmbientSoundAlive_m11creaking"
     EventResponse(466)="AmbientSoundAlive_m11rocketexhaust"
     EventResponse(467)="AmbientSoundAlive_hollow3"
     EventResponse(468)="StaticMeshAttachmentActivatingStarted_Pack"
     EventResponse(469)="StaticMeshAttachmentDeactivating_Pack"
     EventResponse(470)="PackCharged"
     EventResponse(471)="ShockMineDeployableRotating"
     EventResponse(472)="ShockMineDeployableDeployed"
     EventResponse(473)="CatapultDeployableDeployed"
     EventResponse(474)="ShockMineExplode"
     EventResponse(475)="TurretDeployableRotating"
     EventResponse(476)="TurretDeployableDeployed"
     EventResponse(477)="TurretDeployableTargetLocked"
     EventResponse(478)="SensorDeployableDeployed"
     EventResponse(479)="SensorDeployableRotating"
     EventResponse(480)="InventoryStationDeployableUse"
     EventResponse(481)="InventoryStationDeployableDeployed"
     EventResponse(482)="PlayerCharacterMovementUnderwaterLoop"
     EventResponse(483)="EquipmentPickup"
     EventResponse(484)="MPGoalScored"
     EventResponse(485)="CharacterPackEnergyActive"
     EventResponse(486)="CharacterPackShieldActive"
     EventResponse(487)="CharacterPackSpeedActive"
     EventResponse(488)="CharacterPackRepairActive"
     EventResponse(489)="CharacterMovementThrustStart_BloodEagleHeavy"
     EventResponse(490)="CharacterMovementThrustStart_BloodEagleLight"
     EventResponse(491)="CharacterMovementThrustStart_BloodEagleLightFem"
     EventResponse(492)="CharacterMovementThrustStart_BloodEagleMedium"
     EventResponse(493)="CharacterMovementThrustStart_BloodEagleMediumFem"
     EventResponse(494)="CharacterMovementThrustStart_ImperialHeavy"
     EventResponse(495)="CharacterMovementThrustStart_ImperialLight"
     EventResponse(496)="CharacterMovementThrustStart_ImperialLightFem"
     EventResponse(497)="CharacterMovementThrustStart_ImperialLightJulia_Left"
     EventResponse(498)="CharacterMovementThrustStart_ImperialLightJulia_Right"
     EventResponse(499)="CharacterMovementThrustStart_ImperialMedium"
     EventResponse(500)="CharacterMovementThrustStart_ImperialMediumFem"
     EventResponse(501)="CharacterMovementThrustStart_ImperialMediumVictoria"
     EventResponse(502)="CharacterMovementThrustStart_Mercury"
     EventResponse(503)="CharacterMovementThrustStart_PhoenixHeavy"
     EventResponse(504)="CharacterMovementThrustStart_PhoenixHeavyJericho"
     EventResponse(505)="CharacterMovementThrustStart_PhoenixLight"
     EventResponse(506)="CharacterMovementThrustStart_PhoenixLightFem"
     EventResponse(507)="CharacterMovementThrustStart_PhoenixMedium"
     EventResponse(508)="CharacterMovementThrustStart_PhoenixMediumDaniel"
     EventResponse(509)="CharacterMovementThrustStart_PhoenixMediumFem"
     EventResponse(510)="CharacterMovementThrustLoop_BloodEagleHeavy"
     EventResponse(511)="CharacterMovementThrustLoop_BloodEagleLight"
     EventResponse(512)="CharacterMovementThrustLoop_BloodEagleLightFem"
     EventResponse(513)="CharacterMovementThrustLoop_BloodEagleMedium"
     EventResponse(514)="CharacterMovementThrustLoop_BloodEagleMediumFem"
     EventResponse(515)="CharacterMovementThrustLoop_ImperialHeavy"
     EventResponse(516)="CharacterMovementThrustLoop_ImperialLight"
     EventResponse(517)="CharacterMovementThrustLoop_ImperialLightFem"
     EventResponse(518)="CharacterMovementThrustLoop_ImperialLightJulia_Left"
     EventResponse(519)="CharacterMovementThrustLoop_ImperialLightJulia_Right"
     EventResponse(520)="CharacterMovementThrustLoop_ImperialMedium"
     EventResponse(521)="CharacterMovementThrustLoop_ImperialMediumFem"
     EventResponse(522)="CharacterMovementThrustLoop_ImperialMediumVictoria"
     EventResponse(523)="CharacterMovementThrustLoop_Mercury"
     EventResponse(524)="CharacterMovementThrustLoop_PhoenixHeavy"
     EventResponse(525)="CharacterMovementThrustLoop_PhoenixHeavyJericho"
     EventResponse(526)="CharacterMovementThrustLoop_PhoenixLight"
     EventResponse(527)="CharacterMovementThrustLoop_PhoenixLightFem"
     EventResponse(528)="CharacterMovementThrustLoop_PhoenixMedium"
     EventResponse(529)="CharacterMovementThrustLoop_PhoenixMediumDaniel"
     EventResponse(530)="CharacterMovementThrustLoop_PhoenixMediumFem"
     EventResponse(531)="CharacterMovementThrustStop_BloodEagleHeavy"
     EventResponse(532)="CharacterMovementThrustStop_BloodEagleLight"
     EventResponse(533)="CharacterMovementThrustStop_BloodEagleLightFem"
     EventResponse(534)="CharacterMovementThrustStop_BloodEagleMedium"
     EventResponse(535)="CharacterMovementThrustStop_BloodEagleMediumFem"
     EventResponse(536)="CharacterMovementThrustStop_ImperialHeavy"
     EventResponse(537)="CharacterMovementThrustStop_ImperialLight"
     EventResponse(538)="CharacterMovementThrustStop_ImperialLightFem"
     EventResponse(539)="CharacterMovementThrustStop_ImperialLightJulia_Left"
     EventResponse(540)="CharacterMovementThrustStop_ImperialLightJulia_Right"
     EventResponse(541)="CharacterMovementThrustStop_ImperialMedium"
     EventResponse(542)="CharacterMovementThrustStop_ImperialMediumFem"
     EventResponse(543)="CharacterMovementThrustStop_ImperialMediumVictoria"
     EventResponse(544)="CharacterMovementThrustStop_Mercury"
     EventResponse(545)="CharacterMovementThrustStop_PhoenixHeavy"
     EventResponse(546)="CharacterMovementThrustStop_PhoenixHeavyJericho"
     EventResponse(547)="CharacterMovementThrustStop_PhoenixLight"
     EventResponse(548)="CharacterMovementThrustStop_PhoenixLightFem"
     EventResponse(549)="CharacterMovementThrustStop_PhoenixMedium"
     EventResponse(550)="CharacterMovementThrustStop_PhoenixMediumDaniel"
     EventResponse(551)="CharacterMovementThrustStop_PhoenixMediumFem"
     EventResponse(552)="CharacterMovementSkiGroundedStart"
     EventResponse(553)="CharacterMovementSkiGroundedStop"
     EventResponse(554)="CharacterMovementEnterWater"
     EventResponse(555)="CharacterMovementLeaveWater"
     EventResponse(556)="PlayerControllerWatched_STY_RoundLargeButton"
     EventResponse(557)="PlayerControllerPressed_STY_RoundLargeButton"
     EventResponse(558)="PlayerControllerWatched_STY_RoundButton"
     EventResponse(559)="PlayerControllerPressed_STY_RoundButton"
     EventResponse(560)="PlayerControllerWatched_STY_RoundTab"
     EventResponse(561)="PlayerControllerPressed_STY_RoundTab"
     EventResponse(562)="PlayerControllerWatched_STY_CheckBoxButton"
     EventResponse(563)="PlayerControllerPressed_STY_CheckBoxButton"
     EventResponse(564)="PlayerControllerCarryablePickedUp"
     EventResponse(565)="PlayerControllerCarryableDropped"
     EventResponse(566)="PlayerControllerCarryableReturned"
     EventResponse(567)="PlayerControllerCapturableCaptured"
     EventResponse(568)="PlayerControllerGoalScored"
     EventResponse(569)="CharacterMovementSwimStart"
     EventResponse(570)="CharacterMovementSwimStop"
     EventResponse(571)="PlayerControllerHitNoise"
     EventResponse(572)="FuelDepotDefaultActiveLoop"
     EventResponse(573)="FuelDepotDefaultActivateGo"
     EventResponse(574)="FuelDepotDefaultActivateStop"
     EventResponse(575)="FuelDepotDefaultDeactivateGo"
     EventResponse(576)="FuelDepotDefaultDeactivateStop"
     EventResponse(577)="FuelDepotDefaultLiftOff"
     EventResponse(578)="FuelCellPlacedDenominationDefaultActiveLoop"
     EventResponse(579)="FuelDepotDefaultFull_Jets"
     EventResponse(580)="FuelDepotDefaultSteal"
     EventResponse(581)="MPCarryableContainerDeposited"
     EventResponse(582)="BuggyleftFrontSkidding"
     EventResponse(583)="BuggyLeftRearSkidding"
     EventResponse(584)="BuggyrightFrontSkidding"
     EventResponse(585)="BuggyrightRearSkidding"
     EventResponse(586)="BuggyThrottleBack"
     EventResponse(587)="BuggyThrottleForward"
     EventResponse(588)="VehicleSpawnedFromSpawnPoint"
     EventResponse(589)="TankEngineIdling"
     EventResponse(590)="TankThrottleForward"
     EventResponse(591)="TankThrottleBack"
     EventResponse(592)="TankStrafeLeft"
     EventResponse(593)="TankStrafeRight"
     EventResponse(594)="TankDriverEntered"
     EventResponse(595)="VehicleDestroyed"
     EventResponse(596)="AssaultShipThrottleForward"
     EventResponse(597)="AssaultShipEngineIdling"
     EventResponse(598)="AssaultShipEngineAccelerating"
     EventResponse(599)="AssaultShipEngineDecelerating"
     EventResponse(600)="PodStrafeLeft"
     EventResponse(601)="PodStrafeRight"
     EventResponse(602)="PodThrottleBack_Left"
     EventResponse(603)="PodThrottleBack_Right"
     EventResponse(604)="PodThrottleForward_Left"
     EventResponse(605)="PodThrottleForward_Right"
     EventResponse(606)="AssaultShipThrusting_Left"
     EventResponse(607)="AssaultShipThrusting_Right"
     EventResponse(608)="AssaultShipStrafeLeft"
     EventResponse(609)="AssaultShipStrafeRight"
     EventResponse(610)="deployedTurretDetectedEnemy"
     EventResponse(611)="AmbientSoundAlive_m10cricketslo"
     EventResponse(612)="CharacterAmmoPickup"
     EventResponse(613)="FX_SparkAlive"
     EventResponse(614)="FX_continuous_SteamAlive"
     EventResponse(615)="StaticMeshActorfireworks"
     EventResponse(616)="PodFired"
     EventResponse(617)="AssaultShipFired"
     EventResponse(618)="TankTankBoost"
     EventResponse(619)="explosionSmallExploded"
     EventResponse(620)="explosionMediumExploded"
     EventResponse(621)="explosionLargeExploded"
     EventResponse(622)="DynamicPhoenixTowerPanelAlive_explosion"
     EventResponse(623)="Skeletal_dogfight2dogfightexplode"
     EventResponse(624)="FX_Barrier_CollisionDamageSpawned"
     EventResponse(625)="FX_Dirt_CollisionDamageSpawned"
     EventResponse(626)="FX_DirtMedium_CollisionDamageSpawned"
     EventResponse(627)="FX_Snow_CollisionDamageSpawned"
     EventResponse(628)="FX_SnowMedium_CollisionDamageSpawned"
     EventResponse(629)="FX_SnowSmall_CollisionDamageSpawned"
     EventResponse(630)="FX_Vehicle_CollisionDamageSpawned"
     EventResponse(631)="FX_BitsBlack_DestroyedSpawned"
     EventResponse(632)="CharacterPackEnergyCharged"
     EventResponse(633)="CharacterPackSpeedCharged"
     EventResponse(634)="CharacterPackRepairCharged"
     EventResponse(635)="CharacterPackShieldCharged"
     EventResponse(636)="DynamicBaseObjectChunkSpawned"
     EventResponse(637)="DynamicMetalVehicleChunkSpawned"
     EventResponse(638)="DynamicMetalVehicleBitSpawned"
     EventResponse(639)="DynamicBurningSpawned"
     EventResponse(640)="DynamicPhoenixTowerPanelAlive_FireTrail"
     EventResponse(641)="RookBurning"
     EventResponse(642)="DynamicCeramicDestroyed"
     EventResponse(643)="DynamicCeramicBlackDestroyed"
     EventResponse(644)="DynamicGlassDestroyed_WindowSmallWithGlass"
     EventResponse(645)="DynamicGlassDestroyed_WindowPlain"
     EventResponse(646)="DynamicGlassDestroyed_WindowLargeWithGlass"
     EventResponse(647)="DynamicMetalComputerLargeDestroyed"
     EventResponse(648)="DynamicMetalExplosiveDestroyed"
     EventResponse(649)="DynamicMetalComputerDestroyed"
     EventResponse(650)="DynamicRockWastelandDestroyed"
     EventResponse(651)="DynamicGlassDestroyed"
     EventResponse(652)="DynamicGlassDestroyed_Glass1024"
     EventResponse(653)="DynamicRockImperialStoneDestroyed"
     EventResponse(654)="DynGlassWindowSlantPaneDestroyed"
     EventResponse(655)="DynamicMetalDestroyed_PowerGeneratorTop"
     EventResponse(656)="DynamicRockDestroyed"
     EventResponse(657)="DynamicRockRockyDestroyed"
     EventResponse(658)="DynamicSandBagSmallDestroyed"
     EventResponse(659)="DynamicSandBagDestroyed"
     EventResponse(660)="DynamicGlassDestroyed_SensorGridScr"
     EventResponse(661)="DynamicRockWastelandChunkDestroyed"
     EventResponse(662)="DynamicTreeWastelandChunkDestroyed"
     EventResponse(663)="DynamicMetalExplosiveDestroyed_StorageUnitBigger"
     EventResponse(664)="DynamicGlassDestroyed_TacticalDisplay"
     EventResponse(665)="DynamicGlassDestroyed_Screen"
     EventResponse(666)="DynamicTreeDestroyed"
     EventResponse(667)="DynamicTreeWastelandDestroyed"
     EventResponse(668)="DynamicMetalVehicleChunkDestroyed"
     EventResponse(669)="DynamicMetalVehicleBitDestroyed"
     EventResponse(670)="DynamicMetalVehiclePannelDestroyed"
     EventResponse(671)="BaseDeviceDestructedStart"
     EventResponse(672)="DynFuelTankDestroyed"
     EventResponse(673)="DeployedCatapultDestroyed"
     EventResponse(674)="DeployedInventoryStationDestroyed"
     EventResponse(675)="DeployedRepairerDestroyed"
     EventResponse(676)="DeployedTurretDestroyed"
     EventResponse(677)="ProjectileGloraxHit"
     EventResponse(678)="SkeletalDecorationBoom"
     EventResponse(679)="SkeletalDecorationCorridorDeath"
     EventResponse(680)="SkeletalDecorationDiningRoom01"
     EventResponse(681)="DynamicMetalDestroyed_DoorLocked"
     EventResponse(682)="DynBallDestroyed"
     EventResponse(683)="DynamicMetalBarrelDestroyed"
     EventResponse(684)="DynamicMetalCrateDestroyed"
     EventResponse(685)="DynamicRockImperialStoneDestroyed_SewerCeiling"
     EventResponse(686)="SkeletalDecorationDiningRoom02"
     EventResponse(687)="ProjectileMortarHit_Rocket"
     EventResponse(688)="SkeletalDecorationOnFire"
     EventResponse(689)="DynFirePotfireworks"
     EventResponse(690)="ResupplyStationSteam"
     EventResponse(691)="CatapultDeployableCatapulted"
     EventResponse(692)="InventoryStationDeployableSteam"
     EventResponse(693)="BaseDeployableSpawnDeploy"
     EventResponse(694)="EmergencyStationSteam"
     EventResponse(695)="ProjectileBurnerTurretHit"
     EventResponse(696)="ProjectileBurnerTurretBurningAreaAlive"
     EventResponse(697)="ProjectileBurnerBurningAreaAlive"
     EventResponse(698)="ProjectileGloraxAlive"
     EventResponse(699)="ProjectileGloraxFired"
     EventResponse(700)="MPCheckpointPassed_MPCheckpointTrials"
     EventResponse(701)="TeamScoreFireworkteamScoredLoop"
     EventResponse(702)="SpawnArrayPlayerSpawned_beam"
     EventResponse(703)="SpawnArrayPlayerSpawned_steam"
     EventResponse(704)="SkeletalDecorationSteamVent"
     EventResponse(705)="VehicleSpawnPointSteam_VehicleSpawnBuggy"
     EventResponse(706)="VehicleSpawnPointSteam_VehicleSpawnAssaultShip"
     EventResponse(707)="VehicleSpawnPointSteam_VehicleSpawnPod"
     EventResponse(708)="BlastDoorAOpening"
     EventResponse(709)="BlastDoorAOpened"
     EventResponse(710)="BlastDoorAClosing"
     EventResponse(711)="BlastDoorAClosed"
     EventResponse(712)="BlastDoorBOpening"
     EventResponse(713)="BlastDoorBOpened"
     EventResponse(714)="BlastDoorBClosing"
     EventResponse(715)="BlastDoorBClosed"
     EventResponse(716)="SpawnDoor01Opening"
     EventResponse(717)="SpawnDoor01Closing"
     EventResponse(718)="SpawnDoor01Opened"
     EventResponse(719)="SpawnDoor01Closed"
     EventResponse(720)="SpawnDoor02Opening"
     EventResponse(721)="SpawnDoor02Closing"
     EventResponse(722)="SpawnDoor02Opened"
     EventResponse(723)="SpawnDoor02Closed"
     EventResponse(724)="DanSpawnDoor01Opening"
     EventResponse(725)="DanSpawnDoor01Closing"
     EventResponse(726)="DanSpawnDoor01Opened"
     EventResponse(727)="DanSpawnDoor01Closed"
     EventResponse(728)="DanSpawnDoor02Opening"
     EventResponse(729)="DanSpawnDoor02Closing"
     EventResponse(730)="DanSpawnDoor02Opened"
     EventResponse(731)="DanSpawnDoor02Closed"
     EventResponse(732)="DoorLargeLeftOpening"
     EventResponse(733)="DoorLargeLeftClosing"
     EventResponse(734)="DoorLargeLeftOpened"
     EventResponse(735)="DoorLargeLeftClosed"
     EventResponse(736)="DoorLargeRightOpening"
     EventResponse(737)="DoorLargeRightClosing"
     EventResponse(738)="DoorLargeRightOpened"
     EventResponse(739)="DoorLargeRightClosed"
     EventResponse(740)="DoorSmallLeftOpening"
     EventResponse(741)="DoorSmallLeftClosing"
     EventResponse(742)="DoorSmallLeftOpened"
     EventResponse(743)="DoorSmallLeftClosed"
     EventResponse(744)="DoorSmallRightOpening"
     EventResponse(745)="DoorSmallRightClosing"
     EventResponse(746)="DoorSmallRightOpened"
     EventResponse(747)="DoorSmallRightClosed"
     EventResponse(748)="CharacterMovementThrustLoop_JuliaChild"
     EventResponse(749)="DeployedTurretFired"
     EventResponse(750)="DeployedTurretSpaceshipFired"
     EventResponse(751)="DeployedTurretSpaceshipDestroyed"
     EventResponse(752)="CharacterRepairPackStart"
     EventResponse(753)="CharacterRepairPackStop"
     EventResponse(754)="DeployedRepairerRepairPackStart"
     EventResponse(755)="DeployedRepairerRepairPackStop"
     EventResponse(756)="MPTerritoryRepairPackStart"
     EventResponse(757)="MPTerritoryRepairPackStop"
     EventResponse(758)="BuggyThrustingLoop"
     EventResponse(759)="VehicleCollision"
     EventResponse(760)="AmbientSoundAlive_Hollow"
     EventResponse(761)="AmbientSoundAlive_a01Hollow"
     EventResponse(762)="FX_FireAlive"
     EventResponse(763)="AmbientSoundAlive_a01ElecHum"
     EventResponse(764)="AmbientSoundAlive_a01RingTone"
     EventResponse(765)="AmbientSoundAlive_a01EngRoom"
     EventResponse(766)="AmbientSoundAlive_a01Static"
     EventResponse(767)="AmbientSoundAlive_a01Alarm"
     EventResponse(768)="DynamicCeramicCollision"
     EventResponse(769)="DynamicGlassCollision"
     EventResponse(770)="DynamicMetalCollision"
     EventResponse(771)="DynamicSandbagCollision"
     EventResponse(772)="DynamicTreeCollision"
     EventResponse(773)="ChunkPillarACollision"
     EventResponse(774)="ChunkDressingCandleStickACollision"
     EventResponse(775)="ChunkTableLampACollision"
     EventResponse(776)="ChunkDressingTrayACollision"
     EventResponse(777)="DynDressingCandleStickCollision"
     EventResponse(778)="DynDressingFruitTrayCollision"
     EventResponse(779)="DynDressingTrayCollision"
     EventResponse(780)="DynTileACollision"
     EventResponse(781)="DynTileBCollision"
     EventResponse(782)="DynTileCCollision"
     EventResponse(783)="DynDressingFruitAppleCollision"
     EventResponse(784)="DynDressingFruitMelonCollision"
     EventResponse(785)="DynDressingFruitPearCollision"
     EventResponse(786)="DynFormalTableChunk01Collision"
     EventResponse(787)="DynFormalTableChunk02Collision"
     EventResponse(788)="DynFormalTableChunk03Collision"
     EventResponse(789)="DynFormalTableChunk04Collision"
     EventResponse(790)="DynLoungeCollisioin"
     EventResponse(791)="DynPedistalCollision"
     EventResponse(792)="DynPedistalBustCollision"
     EventResponse(793)="DynTableLampCollision"
     EventResponse(794)="DynTableLampTallCollision"
     EventResponse(795)="DynThronCollision"
     EventResponse(796)="RemTableLampTallCollision"
     EventResponse(797)="RenTableLampCollision"
     EventResponse(798)="ChunkGlass1024dCollision"
     EventResponse(799)="DynGlassWindoSlantPaneCollision"
     EventResponse(800)="ChunkDebrisPanelCollision"
     EventResponse(801)="ChunkDebrisPlatesCollision"
     EventResponse(802)="ChunkDestroyableClutterDCollision"
     EventResponse(803)="ChunkLampACollision"
     EventResponse(804)="ChunkLightPoleACollision"
     EventResponse(805)="ChunkLightPoleBCollision"
     EventResponse(806)="ChunkLightPoleCCollision"
     EventResponse(807)="ChunkPowerGeneratorACollision"
     EventResponse(808)="ChunkPowerGeneratorBCollision"
     EventResponse(809)="ChunkSewerCeilingCCollision"
     EventResponse(810)="ChunkTollBoothACollision"
     EventResponse(811)="ChunkTollBoothECollision"
     EventResponse(812)="ChunkWalkwayACollision"
     EventResponse(813)="ChunkWalkwayBCollision"
     EventResponse(814)="ChunkWalkwayCCollision"
     EventResponse(815)="ChunkBarrelCCollision"
     EventResponse(816)="DynSatelliteDishPannel02ChunkACollision"
     EventResponse(817)="DynSatelliteDishPannel02Collision"
     EventResponse(818)="ChunkPodDoorBCollision"
     EventResponse(819)="ChunkPodDoorCCollision"
     EventResponse(820)="DynamicMetalBarrelCollision"
     EventResponse(821)="DynamicMetalComputerLargeCollision"
     EventResponse(822)="DynamicMetalCrateCollision"
     EventResponse(823)="DynamicMetalLargeCollision"
     EventResponse(824)="DynamicMetalRailingCollision"
     EventResponse(825)="ChunkBalconyBustedCollision"
     EventResponse(826)="ChunkBalconyChunkACollision"
     EventResponse(827)="ChunkBalconyChunkBCollision"
     EventResponse(828)="ChunkBalconyChunkCCollision"
     EventResponse(829)="ChunkBalconyChunkDCollision"
     EventResponse(830)="ChunkCargoStairsACollision"
     EventResponse(831)="ChunkCargoStairsBCollision"
     EventResponse(832)="ChunkCargoStairsCCollision"
     EventResponse(833)="ChunkDestroyableCeilingACollision"
     EventResponse(834)="ChunkDestroyableClutterACollision"
     EventResponse(835)="ChunkDestroyableClutterBCollision"
     EventResponse(836)="ChunkDestroyableClutterCCollision"
     EventResponse(837)="ChunkDestroyableFloorACollision"
     EventResponse(838)="ChunkDestroyableFloorBCollision"
     EventResponse(839)="ChunkPodDoorDCollision"
     EventResponse(840)="DynBalconyPalaceCollision"
     EventResponse(841)="DynCargoStairsCollision"
     EventResponse(842)="DynDestroyableClutterCollision"
     EventResponse(843)="DynBeamBrokenCollision"
     EventResponse(844)="DynCarRoofCollision"
     EventResponse(845)="DynChandelierCollision"
     EventResponse(846)="DynChandelierLargeCollision"
     EventResponse(847)="DynCraneCollision"
     EventResponse(848)="DynCraneGearCollision"
     EventResponse(849)="DynDebrisPlanelCollision"
     EventResponse(850)="DynDebrisPlatesCollision"
     EventResponse(851)="DynamicObjectCollision"
     EventResponse(852)="DynamicRockCollision"
     EventResponse(853)="BlockChunk01Collision"
     EventResponse(854)="BlockChunk02Collision"
     EventResponse(855)="BlockChunk03Collision"
     EventResponse(856)="PillarShard01Collision"
     EventResponse(857)="PillarShard02Collision"
     EventResponse(858)="PillarShard03Collision"
     EventResponse(859)="DynamicTreeWastelandChunkCollision"
     EventResponse(860)="ProjectileChaingunCutsceneHit"
     EventResponse(861)="TankLanded"
     EventResponse(862)="TankJetClosing"
     EventResponse(863)="TankJetOpening"
     EventResponse(864)="TankBumped"
     EventResponse(865)="AssaultShipHatchClosing"
     EventResponse(866)="AssaultShipHatchOpening"
     EventResponse(867)="BuggyHatchClosing"
     EventResponse(868)="BuggyHatchOpening"
     EventResponse(869)="PlayerControllerPressed_STY_Browser"
     EventResponse(870)="PlayerControllerPressed_STY_InvButton"
     EventResponse(871)="PlayerControllerPressed_STY_InvSelectArrow"
     EventResponse(872)="PlayerControllerPressed_STY_InvTab"
     EventResponse(873)="PlayerControllerPressed_STY_InvWeaponButton"
     EventResponse(874)="PlayerControllerPressed_STY_leftArrow"
     EventResponse(875)="PlayerControllerPressed_STY_ListBox"
     EventResponse(876)="PlayerControllerPressed_STY_rightArrow"
     EventResponse(877)="PlayerControllerPressed_STY_Scrollzone"
     EventResponse(878)="PlayerControllerPressed_STY_Slider"
     EventResponse(879)="PlayerControllerPressed_STY_SquareButton"
     EventResponse(880)="PlayerControllerPressed_STY_StretchedButton"
     EventResponse(881)="PlayerControllerPressed_STY_RoundLargeButtonAnim"
     EventResponse(882)="PlayerControllerWatched_STY_Browser"
     EventResponse(883)="PlayerControllerWatched_STY_InvButton"
     EventResponse(884)="PlayerControllerWatched_STY_InvSelectArrow"
     EventResponse(885)="PlayerControllerWatched_STY_InvTab"
     EventResponse(886)="PlayerControllerWatched_STY_InvWeaponButton"
     EventResponse(887)="PlayerControllerWatched_STY_leftArrow"
     EventResponse(888)="PlayerControllerWatched_STY_ListBox"
     EventResponse(889)="PlayerControllerWatched_STY_rightArrow"
     EventResponse(890)="PlayerControllerWatched_STY_RoundLargeButtonAnim"
     EventResponse(891)="PlayerControllerWatched_STY_Scrollzone"
     EventResponse(892)="PlayerControllerWatched_STY_Slider"
     EventResponse(893)="PlayerControllerWatched_STY_SquareButton"
     EventResponse(894)="PlayerControllerWatched_STY_StretchedButton"
     EventResponse(895)="VehicleWaterEnter"
     EventResponse(896)="VehicleWaterLeave"
     EventResponse(897)="DynamicObjectWaterEnter"
     EventResponse(898)="ChaingunProjectileWaterEnter"
     EventResponse(899)="ChaingunProjectileWaterLeave"
     EventResponse(900)="ChaingunProjectileHit"
     EventResponse(901)="EmergencyStationActiveLoop"
     EventResponse(902)="InventoryStationActiveLoop"
     EventResponse(903)="BaseDeployableSpawnActiveLoop"
     EventResponse(904)="SwitchStationActiveLoop"
     EventResponse(905)="TerritoryActiveLoop"
     EventResponse(906)="FuelCellDefaultPickedUp"
     EventResponse(907)="MPFuelCellDenominationFivePickedUp"
     EventResponse(908)="MPFuelCellDenominationTenPickedUp"
     EventResponse(909)="FuelCellPlacedDenominationTenPickedUp"
     EventResponse(910)="FuelCellPlacedDenominationFivePickedUp"
     EventResponse(911)="PlayerControllerFuelDropped"
     EventResponse(912)="PlayerControllerFuelPickedUp"
     EventResponse(913)="CharacterMovementskimloop"
     EventResponse(914)="CharacterMovementSkimStart"
     EventResponse(915)="CharacterMovementSkimStop"
     EventResponse(916)="CharacterFootWalk_CivilianDaniel"
     EventResponse(917)="CharacterFootWalk_Livia"
     EventResponse(918)="CharacterFootRun_CivilianDaniel"
     EventResponse(919)="CharacterFootRun_Livia"
     EventResponse(920)="CharacterFootSprint_CivilianDaniel"
     EventResponse(921)="CharacterFootSprint_Livia"
     EventResponse(922)="CharacterMovementCollision_Extreme"
     EventResponse(923)="CharacterMovementCollision_Large"
     EventResponse(924)="CharacterMovementCollision_Medium"
     EventResponse(925)="CharacterMovementCollision_Small"
     EventResponse(926)="CharacterMovementCollision_Tiny"
     EventResponse(927)="CharacterMovementCollision_CivilianDaniel_Tiny"
     EventResponse(928)="CharacterMovementCollision_CivilianMaleBeagle_Tiny"
     EventResponse(929)="CharacterMovementCollision_CivilianMaleImperial_Tiny"
     EventResponse(930)="CharacterMovementCollision_CivilianMalePhoenix_Tiny"
     EventResponse(931)="CharacterMovementCollision_CivilianMalePrisoner_Tiny"
     EventResponse(932)="CharacterMovementCollision_Daniel_Tiny"
     EventResponse(933)="CharacterMovementCollision_Gaius_Tiny"
     EventResponse(934)="CharacterMovementCollision_Jericho_Tiny"
     EventResponse(935)="CharacterMovementCollision_Livia_Tiny"
     EventResponse(936)="CharacterMovementCollision_Olivia_Tiny"
     EventResponse(937)="CharacterMovementCollision_PrincessVictoria_Tiny"
     EventResponse(938)="CharacterMovementCollision_Tiberius_Tiny"
     EventResponse(939)="CharacterMovementCollision_JuliaChild_Tiny"
     EventResponse(940)="CharacterMovementCollision_BloodEagleHeavy_Tiny"
     EventResponse(941)="CharacterMovementCollision_ImperialHeavy_Tiny"
     EventResponse(942)="CharacterMovementCollision_PhoenixHeavy_Tiny"
     EventResponse(943)="CharacterMovementCollision_PhoenixHeavyJericho_Tiny"
     EventResponse(944)="CharacterMovementCollision_BloodEagleMedium_Tiny"
     EventResponse(945)="CharacterMovementCollision_BloodEagleMediumFem_Tiny"
     EventResponse(946)="CharacterMovementCollision_BloodEagleMediumSeti_Tiny"
     EventResponse(947)="CharacterMovementCollision_ImperialMedium_Tiny"
     EventResponse(948)="CharacterMovementCollision_ImperialMediumFem_Tiny"
     EventResponse(949)="CharacterMovementCollision_ImperialMediumVictoria_Tiny"
     EventResponse(950)="CharacterMovementCollision_PhoenixMedium_Tiny"
     EventResponse(951)="CharacterMovementCollision_PhoenixMediumDaniel_Tiny"
     EventResponse(952)="CharacterMovementCollision_PhoenixMediumEsther_Tiny"
     EventResponse(953)="CharacterMovementCollision_PhoenixMediumFem_Tiny"
     EventResponse(954)="CharacterMovementCollision_BloodEagleLight_Tiny"
     EventResponse(955)="CharacterMovementCollision_BloodEagleLightFem_Tiny"
     EventResponse(956)="CharacterMovementCollision_ImperialLight_Tiny"
     EventResponse(957)="CharacterMovementCollision_ImperialLightAlbrecht_Tiny"
     EventResponse(958)="CharacterMovementCollision_ImperialLightFem_Tiny"
     EventResponse(959)="CharacterMovementCollision_ImperialLightJulia_Tiny"
     EventResponse(960)="CharacterMovementCollision_Mercury_Tiny"
     EventResponse(961)="CharacterMovementCollision_MercuryDamage_Tiny"
     EventResponse(962)="CharacterMovementCollision_PhoenixLight_Tiny"
     EventResponse(963)="CharacterMovementCollision_PhoenixLightFem_Tiny"
     EventResponse(964)="CharacterMovementCollision_CivilianDaniel_Small"
     EventResponse(965)="CharacterMovementCollision_CivilianMaleBeagle_Small"
     EventResponse(966)="CharacterMovementCollision_CivilianMaleImperial_Small"
     EventResponse(967)="CharacterMovementCollision_CivilianMalePhoenix_Small"
     EventResponse(968)="CharacterMovementCollision_CivilianMalePrisoner_Small"
     EventResponse(969)="CharacterMovementCollision_Daniel_Small"
     EventResponse(970)="CharacterMovementCollision_Gaius_Small"
     EventResponse(971)="CharacterMovementCollision_Jericho_Small"
     EventResponse(972)="CharacterMovementCollision_Livia_Small"
     EventResponse(973)="CharacterMovementCollision_Olivia_Small"
     EventResponse(974)="CharacterMovementCollision_PrincessVictoria_Small"
     EventResponse(975)="CharacterMovementCollision_Tiberius_Small"
     EventResponse(976)="CharacterMovementCollision_JuliaChild_Small"
     EventResponse(977)="CharacterMovementCollision_BloodEagleHeavy_Small"
     EventResponse(978)="CharacterMovementCollision_ImperialHeavy_Small"
     EventResponse(979)="CharacterMovementCollision_PhoenixHeavy_Small"
     EventResponse(980)="CharacterMovementCollision_PhoenixHeavyJericho_Small"
     EventResponse(981)="CharacterMovementCollision_BloodEagleMedium_Small"
     EventResponse(982)="CharacterMovementCollision_BloodEagleMediumFem_Small"
     EventResponse(983)="CharacterMovementCollision_BloodEagleMediumSeti_Small"
     EventResponse(984)="CharacterMovementCollision_ImperialMedium_Small"
     EventResponse(985)="CharacterMovementCollision_ImperialMediumFem_Small"
     EventResponse(986)="CharacterMovementCollision_ImperialMediumVictoria_Small"
     EventResponse(987)="CharacterMovementCollision_PhoenixMedium_Small"
     EventResponse(988)="CharacterMovementCollision_PhoenixMediumDaniel_Small"
     EventResponse(989)="CharacterMovementCollision_PhoenixMediumEsther_Small"
     EventResponse(990)="CharacterMovementCollision_PhoenixMediumFem_Small"
     EventResponse(991)="CharacterMovementCollision_BloodEagleLight_Small"
     EventResponse(992)="CharacterMovementCollision_BloodEagleLightFem_Small"
     EventResponse(993)="CharacterMovementCollision_ImperialLight_Small"
     EventResponse(994)="CharacterMovementCollision_ImperialLightAlbrecht_Small"
     EventResponse(995)="CharacterMovementCollision_ImperialLightFem_Small"
     EventResponse(996)="CharacterMovementCollision_ImperialLightJulia_Small"
     EventResponse(997)="CharacterMovementCollision_Mercury_Small"
     EventResponse(998)="CharacterMovementCollision_MercuryDamage_Small"
     EventResponse(999)="CharacterMovementCollision_PhoenixLight_Small"
     EventResponse(1000)="CharacterMovementCollision_PhoenixLightFem_Small"
     EventResponse(1001)="CharacterMovementCollision_CivilianDaniel_Medium"
     EventResponse(1002)="CharacterMovementCollision_CivilianMaleBeagle_Medium"
     EventResponse(1003)="CharacterMovementCollision_CivilianMaleImperial_Medium"
     EventResponse(1004)="CharacterMovementCollision_CivilianMalePhoenix_Medium"
     EventResponse(1005)="CharacterMovementCollision_CivilianMalePrisoner_Medium"
     EventResponse(1006)="CharacterMovementCollision_Daniel_Medium"
     EventResponse(1007)="CharacterMovementCollision_Gaius_Medium"
     EventResponse(1008)="CharacterMovementCollision_Jericho_Medium"
     EventResponse(1009)="CharacterMovementCollision_Livia_Medium"
     EventResponse(1010)="CharacterMovementCollision_Olivia_Medium"
     EventResponse(1011)="CharacterMovementCollision_PrincessVictoria_Medium"
     EventResponse(1012)="CharacterMovementCollision_Tiberius_Medium"
     EventResponse(1013)="CharacterMovementCollision_JuliaChild_Medium"
     EventResponse(1014)="CharacterMovementCollision_BloodEagleHeavy_Medium"
     EventResponse(1015)="CharacterMovementCollision_ImperialHeavy_Medium"
     EventResponse(1016)="CharacterMovementCollision_PhoenixHeavy_Medium"
     EventResponse(1017)="CharacterMovementCollision_PhoenixHeavyJericho_Medium"
     EventResponse(1018)="CharacterMovementCollision_BloodEagleMedium_Medium"
     EventResponse(1019)="CharacterMovementCollision_BloodEagleMediumFem_Medium"
     EventResponse(1020)="CharacterMovementCollision_BloodEagleMediumSeti_Medium"
     EventResponse(1021)="CharacterMovementCollision_ImperialMedium_Medium"
     EventResponse(1022)="CharacterMovementCollision_ImperialMediumFem_Medium"
     EventResponse(1023)="CharacterMovementCollision_ImperialMediumVictoria_Medium"
     EventResponse(1024)="CharacterMovementCollision_PhoenixMedium_Medium"
     EventResponse(1025)="CharacterMovementCollision_PhoenixMediumDaniel_Medium"
     EventResponse(1026)="CharacterMovementCollision_PhoenixMediumEsther_Medium"
     EventResponse(1027)="CharacterMovementCollision_PhoenixMediumFem_Medium"
     EventResponse(1028)="CharacterMovementCollision_BloodEagleLight_Medium"
     EventResponse(1029)="CharacterMovementCollision_BloodEagleLightFem_Medium"
     EventResponse(1030)="CharacterMovementCollision_ImperialLight_Medium"
     EventResponse(1031)="CharacterMovementCollision_ImperialLightAlbrecht_Medium"
     EventResponse(1032)="CharacterMovementCollision_ImperialLightFem_Medium"
     EventResponse(1033)="CharacterMovementCollision_ImperialLightJulia_Medium"
     EventResponse(1034)="CharacterMovementCollision_Mercury_Medium"
     EventResponse(1035)="CharacterMovementCollision_MercuryDamage_Medium"
     EventResponse(1036)="CharacterMovementCollision_PhoenixLight_Medium"
     EventResponse(1037)="CharacterMovementCollision_PhoenixLightFem_Medium"
     EventResponse(1038)="CharacterMovementCollision_CivilianDaniel_Large"
     EventResponse(1039)="CharacterMovementCollision_CivilianMaleBeagle_Large"
     EventResponse(1040)="CharacterMovementCollision_CivilianMaleImperial_Large"
     EventResponse(1041)="CharacterMovementCollision_CivilianMalePhoenix_Large"
     EventResponse(1042)="CharacterMovementCollision_CivilianMalePrisoner_Large"
     EventResponse(1043)="CharacterMovementCollision_Daniel_Large"
     EventResponse(1044)="CharacterMovementCollision_Gaius_Large"
     EventResponse(1045)="CharacterMovementCollision_Jericho_Large"
     EventResponse(1046)="CharacterMovementCollision_Livia_Large"
     EventResponse(1047)="CharacterMovementCollision_Olivia_Large"
     EventResponse(1048)="CharacterMovementCollision_PrincessVictoria_Large"
     EventResponse(1049)="CharacterMovementCollision_Tiberius_Large"
     EventResponse(1050)="CharacterMovementCollision_JuliaChild_Large"
     EventResponse(1051)="CharacterMovementCollision_BloodEagleHeavy_Large"
     EventResponse(1052)="CharacterMovementCollision_ImperialHeavy_Large"
     EventResponse(1053)="CharacterMovementCollision_PhoenixHeavy_Large"
     EventResponse(1054)="CharacterMovementCollision_PhoenixHeavyJericho_Large"
     EventResponse(1055)="CharacterMovementCollision_BloodEagleMedium_Large"
     EventResponse(1056)="CharacterMovementCollision_BloodEagleMediumFem_Large"
     EventResponse(1057)="CharacterMovementCollision_BloodEagleMediumSeti_Large"
     EventResponse(1058)="CharacterMovementCollision_ImperialMedium_Large"
     EventResponse(1059)="CharacterMovementCollision_ImperialMediumFem_Large"
     EventResponse(1060)="CharacterMovementCollision_ImperialMediumVictoria_Large"
     EventResponse(1061)="CharacterMovementCollision_PhoenixMedium_Large"
     EventResponse(1062)="CharacterMovementCollision_PhoenixMediumDaniel_Large"
     EventResponse(1063)="CharacterMovementCollision_PhoenixMediumEsther_Large"
     EventResponse(1064)="CharacterMovementCollision_PhoenixMediumFem_Large"
     EventResponse(1065)="CharacterMovementCollision_BloodEagleLight_Large"
     EventResponse(1066)="CharacterMovementCollision_BloodEagleLightFem_Large"
     EventResponse(1067)="CharacterMovementCollision_ImperialLight_Large"
     EventResponse(1068)="CharacterMovementCollision_ImperialLightAlbrecht_Large"
     EventResponse(1069)="CharacterMovementCollision_ImperialLightFem_Large"
     EventResponse(1070)="CharacterMovementCollision_ImperialLightJulia_Large"
     EventResponse(1071)="CharacterMovementCollision_Mercury_Large"
     EventResponse(1072)="CharacterMovementCollision_MercuryDamage_Large"
     EventResponse(1073)="CharacterMovementCollision_PhoenixLight_Large"
     EventResponse(1074)="CharacterMovementCollision_PhoenixLightFem_Large"
     EventResponse(1075)="CharacterMovementCollision_CivilianDaniel_Extreme"
     EventResponse(1076)="CharacterMovementCollision_CivilianMaleBeagle_Extreme"
     EventResponse(1077)="CharacterMovementCollision_CivilianMaleImperial_Extreme"
     EventResponse(1078)="CharacterMovementCollision_CivilianMalePhoenix_Extreme"
     EventResponse(1079)="CharacterMovementCollision_CivilianMalePrisoner_Extreme"
     EventResponse(1080)="CharacterMovementCollision_Daniel_Extreme"
     EventResponse(1081)="CharacterMovementCollision_Gaius_Extreme"
     EventResponse(1082)="CharacterMovementCollision_Jericho_Extreme"
     EventResponse(1083)="CharacterMovementCollision_Livia_Extreme"
     EventResponse(1084)="CharacterMovementCollision_Olivia_Extreme"
     EventResponse(1085)="CharacterMovementCollision_PrincessVictoria_Extreme"
     EventResponse(1086)="CharacterMovementCollision_Tiberius_Extreme"
     EventResponse(1087)="CharacterMovementCollision_JuliaChild_Extreme"
     EventResponse(1088)="CharacterMovementCollision_BloodEagleHeavy_Extreme"
     EventResponse(1089)="CharacterMovementCollision_ImperialHeavy_Extreme"
     EventResponse(1090)="CharacterMovementCollision_PhoenixHeavy_Extreme"
     EventResponse(1091)="CharacterMovementCollision_PhoenixHeavyJericho_Extreme"
     EventResponse(1092)="CharacterMovementCollision_BloodEagleMedium_Extreme"
     EventResponse(1093)="CharacterMovementCollision_BloodEagleMediumFem_Extreme"
     EventResponse(1094)="CharacterMovementCollision_BloodEagleMediumSeti_Extreme"
     EventResponse(1095)="CharacterMovementCollision_ImperialMedium_Extreme"
     EventResponse(1096)="CharacterMovementCollision_ImperialMediumFem_Extreme"
     EventResponse(1097)="CharacterMovementCollision_ImperialMediumVictoria_Extreme"
     EventResponse(1098)="CharacterMovementCollision_PhoenixMedium_Extreme"
     EventResponse(1099)="CharacterMovementCollision_PhoenixMediumDaniel_Extreme"
     EventResponse(1100)="CharacterMovementCollision_PhoenixMediumEsther_Extreme"
     EventResponse(1101)="CharacterMovementCollision_PhoenixMediumFem_Extreme"
     EventResponse(1102)="CharacterMovementCollision_BloodEagleLight_Extreme"
     EventResponse(1103)="CharacterMovementCollision_BloodEagleLightFem_Extreme"
     EventResponse(1104)="CharacterMovementCollision_ImperialLight_Extreme"
     EventResponse(1105)="CharacterMovementCollision_ImperialLightAlbrecht_Extreme"
     EventResponse(1106)="CharacterMovementCollision_ImperialLightFem_Extreme"
     EventResponse(1107)="CharacterMovementCollision_ImperialLightJulia_Extreme"
     EventResponse(1108)="CharacterMovementCollision_Mercury_Extreme"
     EventResponse(1109)="CharacterMovementCollision_MercuryDamage_Extreme"
     EventResponse(1110)="CharacterMovementCollision_PhoenixLight_Extreme"
     EventResponse(1111)="CharacterMovementCollision_PhoenixLightFem_Extreme"
     EventResponse(1112)="CharacterMovementCollisionFeet_Extreme"
     EventResponse(1113)="CharacterMovementCollisionFeet_Large"
     EventResponse(1114)="CharacterMovementCollisionFeet_Medium"
     EventResponse(1115)="CharacterMovementCollisionFeet_Small"
     EventResponse(1116)="CharacterMovementCollisionFeet_Tiny"
     EventResponse(1117)="CharacterMovementCollisionFeet_CivilianDaniel_Tiny"
     EventResponse(1118)="CharacterMovementCollisionFeet_CivilianMaleBeagle_Tiny"
     EventResponse(1119)="CharacterMovementCollisionFeet_CivilianMaleImperial_Tiny"
     EventResponse(1120)="CharacterMovementCollisionFeet_CivilianMalePhoenix_Tiny"
     EventResponse(1121)="CharacterMovementCollisionFeet_CivilianMalePrisoner_Tiny"
     EventResponse(1122)="CharacterMovementCollisionFeet_Daniel_Tiny"
     EventResponse(1123)="CharacterMovementCollisionFeet_Gaius_Tiny"
     EventResponse(1124)="CharacterMovementCollisionFeet_Jericho_Tiny"
     EventResponse(1125)="CharacterMovementCollisionFeet_Livia_Tiny"
     EventResponse(1126)="CharacterMovementCollisionFeet_Olivia_Tiny"
     EventResponse(1127)="CharacterMovementCollisionFeet_PrincessVictoria_Tiny"
     EventResponse(1128)="CharacterMovementCollisionFeet_Tiberius_Tiny"
     EventResponse(1129)="CharacterMovementCollisionFeet_JuliaChild_Tiny"
     EventResponse(1130)="CharacterMovementCollisionFeet_BloodEagleHeavy_Tiny"
     EventResponse(1131)="CharacterMovementCollisionFeet_ImperialHeavy_Tiny"
     EventResponse(1132)="CharacterMovementCollisionFeet_PhoenixHeavy_Tiny"
     EventResponse(1133)="CharacterMovementCollisionFeet_PhoenixHeavyJericho_Tiny"
     EventResponse(1134)="CharacterMovementCollisionFeet_BloodEagleMedium_Tiny"
     EventResponse(1135)="CharacterMovementCollisionFeet_BloodEagleMediumFem_Tiny"
     EventResponse(1136)="CharacterMovementCollisionFeet_BloodEagleMediumSeti_Tiny"
     EventResponse(1137)="CharacterMovementCollisionFeet_ImperialMedium_Tiny"
     EventResponse(1138)="CharacterMovementCollisionFeet_ImperialMediumFem_Tiny"
     EventResponse(1139)="CharacterMovementCollisionFeet_ImperialMediumVictoria_Tiny"
     EventResponse(1140)="CharacterMovementCollisionFeet_PhoenixMedium_Tiny"
     EventResponse(1141)="CharacterMovementCollisionFeet_PhoenixMediumDaniel_Tiny"
     EventResponse(1142)="CharacterMovementCollisionFeet_PhoenixMediumEsther_Tiny"
     EventResponse(1143)="CharacterMovementCollisionFeet_PhoenixMediumFem_Tiny"
     EventResponse(1144)="CharacterMovementCollisionFeet_BloodEagleLight_Tiny"
     EventResponse(1145)="CharacterMovementCollisionFeet_BloodEagleLightFem_Tiny"
     EventResponse(1146)="CharacterMovementCollisionFeet_ImperialLight_Tiny"
     EventResponse(1147)="CharacterMovementCollisionFeet_ImperialLightAlbrecht_Tiny"
     EventResponse(1148)="CharacterMovementCollisionFeet_ImperialLightFem_Tiny"
     EventResponse(1149)="CharacterMovementCollisionFeet_ImperialLightJulia_Tiny"
     EventResponse(1150)="CharacterMovementCollisionFeet_Mercury_Tiny"
     EventResponse(1151)="CharacterMovementCollisionFeet_MercuryDamage_Tiny"
     EventResponse(1152)="CharacterMovementCollisionFeet_PhoenixLight_Tiny"
     EventResponse(1153)="CharacterMovementCollisionFeet_PhoenixLightFem_Tiny"
     EventResponse(1154)="CharacterMovementCollisionFeet_CivilianDaniel_Small"
     EventResponse(1155)="CharacterMovementCollisionFeet_CivilianMaleBeagle_Small"
     EventResponse(1156)="CharacterMovementCollisionFeet_CivilianMaleImperial_Small"
     EventResponse(1157)="CharacterMovementCollisionFeet_CivilianMalePhoenix_Small"
     EventResponse(1158)="CharacterMovementCollisionFeet_CivilianMalePrisoner_Small"
     EventResponse(1159)="CharacterMovementCollisionFeet_Daniel_Small"
     EventResponse(1160)="CharacterMovementCollisionFeet_Gaius_Small"
     EventResponse(1161)="CharacterMovementCollisionFeet_Jericho_Small"
     EventResponse(1162)="CharacterMovementCollisionFeet_Livia_Small"
     EventResponse(1163)="CharacterMovementCollisionFeet_Olivia_Small"
     EventResponse(1164)="CharacterMovementCollisionFeet_PrincessVictoria_Small"
     EventResponse(1165)="CharacterMovementCollisionFeet_Tiberius_Small"
     EventResponse(1166)="CharacterMovementCollisionFeet_JuliaChild_Small"
     EventResponse(1167)="CharacterMovementCollisionFeet_BloodEagleHeavy_Small"
     EventResponse(1168)="CharacterMovementCollisionFeet_ImperialHeavy_Small"
     EventResponse(1169)="CharacterMovementCollisionFeet_PhoenixHeavy_Small"
     EventResponse(1170)="CharacterMovementCollisionFeet_PhoenixHeavyJericho_Small"
     EventResponse(1171)="CharacterMovementCollisionFeet_BloodEagleMedium_Small"
     EventResponse(1172)="CharacterMovementCollisionFeet_BloodEagleMediumFem_Small"
     EventResponse(1173)="CharacterMovementCollisionFeet_BloodEagleMediumSeti_Small"
     EventResponse(1174)="CharacterMovementCollisionFeet_ImperialMedium_Small"
     EventResponse(1175)="CharacterMovementCollisionFeet_ImperialMediumFem_Small"
     EventResponse(1176)="CharacterMovementCollisionFeet_ImperialMediumVictoria_Small"
     EventResponse(1177)="CharacterMovementCollisionFeet_PhoenixMedium_Small"
     EventResponse(1178)="CharacterMovementCollisionFeet_PhoenixMediumDaniel_Small"
     EventResponse(1179)="CharacterMovementCollisionFeet_PhoenixMediumEsther_Small"
     EventResponse(1180)="CharacterMovementCollisionFeet_PhoenixMediumFem_Small"
     EventResponse(1181)="CharacterMovementCollisionFeet_BloodEagleLight_Small"
     EventResponse(1182)="CharacterMovementCollisionFeet_BloodEagleLightFem_Small"
     EventResponse(1183)="CharacterMovementCollisionFeet_ImperialLight_Small"
     EventResponse(1184)="CharacterMovementCollisionFeet_ImperialLightAlbrecht_Small"
     EventResponse(1185)="CharacterMovementCollisionFeet_ImperialLightFem_Small"
     EventResponse(1186)="CharacterMovementCollisionFeet_ImperialLightJulia_Small"
     EventResponse(1187)="CharacterMovementCollisionFeet_Mercury_Small"
     EventResponse(1188)="CharacterMovementCollisionFeet_MercuryDamage_Small"
     EventResponse(1189)="CharacterMovementCollisionFeet_PhoenixLight_Small"
     EventResponse(1190)="CharacterMovementCollisionFeet_PhoenixLightFem_Small"
     EventResponse(1191)="CharacterMovementCollisionFeet_CivilianDaniel_Medium"
     EventResponse(1192)="CharacterMovementCollisionFeet_CivilianMaleBeagle_Medium"
     EventResponse(1193)="CharacterMovementCollisionFeet_CivilianMaleImperial_Medium"
     EventResponse(1194)="CharacterMovementCollisionFeet_CivilianMalePhoenix_Medium"
     EventResponse(1195)="CharacterMovementCollisionFeet_CivilianMalePrisoner_Medium"
     EventResponse(1196)="CharacterMovementCollisionFeet_Daniel_Medium"
     EventResponse(1197)="CharacterMovementCollisionFeet_Gaius_Medium"
     EventResponse(1198)="CharacterMovementCollisionFeet_Jericho_Medium"
     EventResponse(1199)="CharacterMovementCollisionFeet_Livia_Medium"
     EventResponse(1200)="CharacterMovementCollisionFeet_Olivia_Medium"
     EventResponse(1201)="CharacterMovementCollisionFeet_PrincessVictoria_Medium"
     EventResponse(1202)="CharacterMovementCollisionFeet_Tiberius_Medium"
     EventResponse(1203)="CharacterMovementCollisionFeet_JuliaChild_Medium"
     EventResponse(1204)="CharacterMovementCollisionFeet_BloodEagleHeavy_Medium"
     EventResponse(1205)="CharacterMovementCollisionFeet_ImperialHeavy_Medium"
     EventResponse(1206)="CharacterMovementCollisionFeet_PhoenixHeavy_Medium"
     EventResponse(1207)="CharacterMovementCollisionFeet_PhoenixHeavyJericho_Medium"
     EventResponse(1208)="CharacterMovementCollisionFeet_BloodEagleMedium_Medium"
     EventResponse(1209)="CharacterMovementCollisionFeet_BloodEagleMediumFem_Medium"
     EventResponse(1210)="CharacterMovementCollisionFeet_BloodEagleMediumSeti_Medium"
     EventResponse(1211)="CharacterMovementCollisionFeet_ImperialMedium_Medium"
     EventResponse(1212)="CharacterMovementCollisionFeet_ImperialMediumFem_Medium"
     EventResponse(1213)="CharacterMovementCollisionFeet_ImperialMediumVictoria_Medium"
     EventResponse(1214)="CharacterMovementCollisionFeet_PhoenixMedium_Medium"
     EventResponse(1215)="CharacterMovementCollisionFeet_PhoenixMediumDaniel_Medium"
     EventResponse(1216)="CharacterMovementCollisionFeet_PhoenixMediumEsther_Medium"
     EventResponse(1217)="CharacterMovementCollisionFeet_PhoenixMediumFem_Medium"
     EventResponse(1218)="CharacterMovementCollisionFeet_BloodEagleLight_Medium"
     EventResponse(1219)="CharacterMovementCollisionFeet_BloodEagleLightFem_Medium"
     EventResponse(1220)="CharacterMovementCollisionFeet_ImperialLight_Medium"
     EventResponse(1221)="CharacterMovementCollisionFeet_ImperialLightAlbrecht_Medium"
     EventResponse(1222)="CharacterMovementCollisionFeet_ImperialLightFem_Medium"
     EventResponse(1223)="CharacterMovementCollisionFeet_ImperialLightJulia_Medium"
     EventResponse(1224)="CharacterMovementCollisionFeet_Mercury_Medium"
     EventResponse(1225)="CharacterMovementCollisionFeet_MercuryDamage_Medium"
     EventResponse(1226)="CharacterMovementCollisionFeet_PhoenixLight_Medium"
     EventResponse(1227)="CharacterMovementCollisionFeet_PhoenixLightFem_Medium"
     EventResponse(1228)="CharacterMovementCollisionFeet_CivilianDaniel_Large"
     EventResponse(1229)="CharacterMovementCollisionFeet_CivilianMaleBeagle_Large"
     EventResponse(1230)="CharacterMovementCollisionFeet_CivilianMaleImperial_Large"
     EventResponse(1231)="CharacterMovementCollisionFeet_CivilianMalePhoenix_Large"
     EventResponse(1232)="CharacterMovementCollisionFeet_CivilianMalePrisoner_Large"
     EventResponse(1233)="CharacterMovementCollisionFeet_Daniel_Large"
     EventResponse(1234)="CharacterMovementCollisionFeet_Gaius_Large"
     EventResponse(1235)="CharacterMovementCollisionFeet_Jericho_Large"
     EventResponse(1236)="CharacterMovementCollisionFeet_Livia_Large"
     EventResponse(1237)="CharacterMovementCollisionFeet_Olivia_Large"
     EventResponse(1238)="CharacterMovementCollisionFeet_PrincessVictoria_Large"
     EventResponse(1239)="CharacterMovementCollisionFeet_Tiberius_Large"
     EventResponse(1240)="CharacterMovementCollisionFeet_JuliaChild_Large"
     EventResponse(1241)="CharacterMovementCollisionFeet_BloodEagleHeavy_Large"
     EventResponse(1242)="CharacterMovementCollisionFeet_ImperialHeavy_Large"
     EventResponse(1243)="CharacterMovementCollisionFeet_PhoenixHeavy_Large"
     EventResponse(1244)="CharacterMovementCollisionFeet_PhoenixHeavyJericho_Large"
     EventResponse(1245)="CharacterMovementCollisionFeet_BloodEagleMedium_Large"
     EventResponse(1246)="CharacterMovementCollisionFeet_BloodEagleMediumFem_Large"
     EventResponse(1247)="CharacterMovementCollisionFeet_BloodEagleMediumSeti_Large"
     EventResponse(1248)="CharacterMovementCollisionFeet_ImperialMedium_Large"
     EventResponse(1249)="CharacterMovementCollisionFeet_ImperialMediumFem_Large"
     EventResponse(1250)="CharacterMovementCollisionFeet_ImperialMediumVictoria_Large"
     EventResponse(1251)="CharacterMovementCollisionFeet_PhoenixMedium_Large"
     EventResponse(1252)="CharacterMovementCollisionFeet_PhoenixMediumDaniel_Large"
     EventResponse(1253)="CharacterMovementCollisionFeet_PhoenixMediumEsther_Large"
     EventResponse(1254)="CharacterMovementCollisionFeet_PhoenixMediumFem_Large"
     EventResponse(1255)="CharacterMovementCollisionFeet_BloodEagleLight_Large"
     EventResponse(1256)="CharacterMovementCollisionFeet_BloodEagleLightFem_Large"
     EventResponse(1257)="CharacterMovementCollisionFeet_ImperialLight_Large"
     EventResponse(1258)="CharacterMovementCollisionFeet_ImperialLightAlbrecht_Large"
     EventResponse(1259)="CharacterMovementCollisionFeet_ImperialLightFem_Large"
     EventResponse(1260)="CharacterMovementCollisionFeet_ImperialLightJulia_Large"
     EventResponse(1261)="CharacterMovementCollisionFeet_Mercury_Large"
     EventResponse(1262)="CharacterMovementCollisionFeet_MercuryDamage_Large"
     EventResponse(1263)="CharacterMovementCollisionFeet_PhoenixLight_Large"
     EventResponse(1264)="CharacterMovementCollisionFeet_PhoenixLightFem_Large"
     EventResponse(1265)="CharacterMovementCollisionFeet_CivilianDaniel_Extreme"
     EventResponse(1266)="CharacterMovementCollisionFeet_CivilianMaleBeagle_Extreme"
     EventResponse(1267)="CharacterMovementCollisionFeet_CivilianMaleImperial_Extreme"
     EventResponse(1268)="CharacterMovementCollisionFeet_CivilianMalePhoenix_Extreme"
     EventResponse(1269)="CharacterMovementCollisionFeet_CivilianMalePrisoner_Extreme"
     EventResponse(1270)="CharacterMovementCollisionFeet_Daniel_Extreme"
     EventResponse(1271)="CharacterMovementCollisionFeet_Gaius_Extreme"
     EventResponse(1272)="CharacterMovementCollisionFeet_Jericho_Extreme"
     EventResponse(1273)="CharacterMovementCollisionFeet_Livia_Extreme"
     EventResponse(1274)="CharacterMovementCollisionFeet_Olivia_Extreme"
     EventResponse(1275)="CharacterMovementCollisionFeet_PrincessVictoria_Extreme"
     EventResponse(1276)="CharacterMovementCollisionFeet_Tiberius_Extreme"
     EventResponse(1277)="CharacterMovementCollisionFeet_JuliaChild_Extreme"
     EventResponse(1278)="CharacterMovementCollisionFeet_BloodEagleHeavy_Extreme"
     EventResponse(1279)="CharacterMovementCollisionFeet_ImperialHeavy_Extreme"
     EventResponse(1280)="CharacterMovementCollisionFeet_PhoenixHeavy_Extreme"
     EventResponse(1281)="CharacterMovementCollisionFeet_PhoenixHeavyJericho_Extreme"
     EventResponse(1282)="CharacterMovementCollisionFeet_BloodEagleMedium_Extreme"
     EventResponse(1283)="CharacterMovementCollisionFeet_BloodEagleMediumFem_Extreme"
     EventResponse(1284)="CharacterMovementCollisionFeet_BloodEagleMediumSeti_Extreme"
     EventResponse(1285)="CharacterMovementCollisionFeet_ImperialMedium_Extreme"
     EventResponse(1286)="CharacterMovementCollisionFeet_ImperialMediumFem_Extreme"
     EventResponse(1287)="CharacterMovementCollisionFeet_ImperialMediumVictoria_Extreme"
     EventResponse(1288)="CharacterMovementCollisionFeet_PhoenixMedium_Extreme"
     EventResponse(1289)="CharacterMovementCollisionFeet_PhoenixMediumDaniel_Extreme"
     EventResponse(1290)="CharacterMovementCollisionFeet_PhoenixMediumEsther_Extreme"
     EventResponse(1291)="CharacterMovementCollisionFeet_PhoenixMediumFem_Extreme"
     EventResponse(1292)="CharacterMovementCollisionFeet_BloodEagleLight_Extreme"
     EventResponse(1293)="CharacterMovementCollisionFeet_BloodEagleLightFem_Extreme"
     EventResponse(1294)="CharacterMovementCollisionFeet_ImperialLight_Extreme"
     EventResponse(1295)="CharacterMovementCollisionFeet_ImperialLightAlbrecht_Extreme"
     EventResponse(1296)="CharacterMovementCollisionFeet_ImperialLightFem_Extreme"
     EventResponse(1297)="CharacterMovementCollisionFeet_ImperialLightJulia_Extreme"
     EventResponse(1298)="CharacterMovementCollisionFeet_Mercury_Extreme"
     EventResponse(1299)="CharacterMovementCollisionFeet_MercuryDamage_Extreme"
     EventResponse(1300)="CharacterMovementCollisionFeet_PhoenixLight_Extreme"
     EventResponse(1301)="CharacterMovementCollisionFeet_PhoenixLightFem_Extreme"
     EffectSpecificationSubClass=Class'SoundEffectSpecification'
}
