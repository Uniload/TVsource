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
    EffectSpecificationSubClass=class'SoundEffectSpecification'
    bDebugSounds=false
}

