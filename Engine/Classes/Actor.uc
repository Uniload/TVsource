//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.  
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display 
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Core.Object
	abstract
	threaded
	native
	nativereplication;

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop,
	LT_FadeOut
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
#if IG_RENDERER // rowan: only support these light types
	LE_Pointlight,
	LE_Sunlight,
	LE_Spotlight,
#else
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Sunlight,
	LE_QuadraticNonIncidence
#endif // IG
} LightEffect;

// Lighting info.
var(LightColor) float
	LightBrightness;
var(Lighting) float
	LightRadius;
var(LightColor) byte
	LightHue,
	LightSaturation;
var(Lighting) byte
	LightPeriod,
	LightPhase,
	LightCone;

#if IG_TRIBES3 // Alex: disables copying of instances of this Actor in UnrealEd
var bool bDisableEditorCopying;
#endif

#if IG_SHADOWS // rowan: SHADOW
var(Lighting) bool bCastsVolumetricShadows;		// light casts volumetric shadows
var(Lighting) bool bDisableShadowOptimisation;	// disable shadow clipping for this light source
var(Lighting) bool bDisableBspVolumetrics;		// disable volumetric shadows and illumination for bsp surfaces affected by this light source
var(Display)  bool bVolumetricShadowCast        "If true, lights with bCastsVolumetricShadows=true will cast volumetric shadows from this actor";
#endif // IG

#if IG_BUMPMAP // rowan: new bump params
// force lights to require an extra pass on bump mapped objects (not go into approximation stream)
var(Lighting) bool bDoNotApproximateBumpmap;
var(Display) float BumpmapLODScale;
#endif

#if IG_SHARED // ckline: lights and projectors can be flagged to only affect the zone they're in
var() bool bOnlyAffectCurrentZone "If this flag is set to TRUE on a light or projector, that light/projector will only affect actors and BSP that are in the same zone at the light/projector.";
#endif

#if IG_SHARED	// rowan: new light stuff
var(Lighting) float MaxTraceDistance;		//max raytrace distance for sunlights in unrealed
var(Advanced)	bool bImportantActor;				// lets the light scalability system know taht it should never cull this light
var(Display) bool bGetOverlayMaterialFromBase;	// inherit your base's overlay
var(Display) bool bGetSkinFromBase;				// inherit your base's skin
#endif

#if IG_SHARED	// rowan: post render callback for fun stuff
var bool bNeedPostRenderCallback;
#endif

#if IG_EXTERNAL_CAMERAS
// If this flag is set to TRUE then this object will be considered a 
// mirror, and be optimized as such in the renderer when rendering 
// external cameras
var bool  bIsMirror;
#endif

#if IG_TRIBES3
var const bool bIsVehicle;        // glenn: i suck and i need to check if an actor is a vehicle at a place where i dont have access to AVehicle in native code =(
#endif

#if IG_TRIBES3	// rowan: for cutscene characters, update their bound using char root motion
var(Display) bool bUseRootMotionBound;
#endif

#if IG_TRIBES3 // Alex: when considering network relevancy always treat as visible regardless of bHidden
var bool bNetworkRelevancyVisible;
#endif

#if IG_TRIBES3 // Paul: SpeechTag, used as a key to lookup speech files
var(DynamicSpeech) String SpeechTag	"Used as a full or partial key to lookup speech files int the Dynamic Speech system";
#endif // IG_TRIBES3

#if IG_TRIBES3_PHYSICS // Paul: variables required for interacting with Karma through unified physics interface

// accumulators for holding forces applied to karma objects
// through the addForce & addTorque commands
var private Vector forceAccumulator;
var private Vector torqueAccumulator;

// Need to maintain our own velocity & position, because they will get 
// clobbered if the karma object is awake when you explicitly set it.
// WARNING: the unified velocity & position variables are NOT to be 
// relied upon for anything other than the unified physics API!!!
var private bool bUnifiedPositionChanged;
var private Vector unifiedPosition;
var private bool bUnifiedVelocityChanged;
var private Vector unifiedVelocity;

#endif

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
    PHYS_Karma_Deprecated,
    PHYS_KarmaRagDoll_Deprecated,
	PHYS_Havok,
	PHYS_HavokSkeletal,
#if IG_TRIBES3_MOVEMENT
	PHYS_Movement,
#endif
} Physics;

// Drawing effect.
var(Display) const enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_FluidSurface,
#if IG_FLUID_VOLUME // rowan: draw type for fluid volume objects
	DT_FluidVolume,
#endif
} DrawType;

var(Display) const StaticMesh StaticMesh;		// StaticMesh if DrawType=DT_StaticMesh

// Owner.
var const Actor	Owner;			// Owner actor.
var const Actor	Base;           // Actor we're standing on.

struct ActorRenderDataPtr { var int Ptr; };
struct LightRenderDataPtr { var int Ptr; };

var const native ActorRenderDataPtr	ActorRenderData;
var const native LightRenderDataPtr	LightRenderData;
var const native int				RenderRevision;

#if IG_SHARED	// rowan: sub visibility actors
var const bool UsesSubVisibility;
#endif

enum EFilterState
{
	FS_Maybe,
	FS_Yes,
	FS_No
};

var const native EFilterState	StaticFilterState;

struct BatchReference
{
	var int	BatchIndex,
			ElementIndex;
};

var const native array<BatchReference>	StaticSectionBatches;

#if IG_SHARED // ckline: ForcedVisibilityZoneTag can be used to limit projection to actors in specific zone
var(Display) const name	ForcedVisibilityZoneTag "If set to something other than None, this actor will only render if the Tag of the ZoneInfo of its current zone is set to the same name.\n\nAdditionally, if the actor is a projector it will only project onto actors that are also in the correct zone.";
#else
var(Display) const name	ForcedVisibilityZoneTag; // Makes the visibility code treat the actor as if it was in the zone with the given tag.
#endif

// Lighting.
var(Lighting) bool	     bSpecialLit;			// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows;			// Light casts actor shadows.
var(Lighting) bool	     bCorona;			   // Light uses Skin as a corona.
var(Lighting) bool		 bLightingVisibility;	// Calculate lighting visibility for this actor with line checks.
var(Display) bool		 bUseDynamicLights;
var bool				 bLightChanged;			// Recalculate this light's lighting now.

//	Detail mode enum.

enum EDetailMode
{
	DM_Low,
	DM_High,
	DM_SuperHigh
};

// Flags.
var			  const bool	bStatic;			// Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced)		bool	bHidden;			// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;			// Cannot be deleted during play.
var			  const	bool	bDeleteMe;			// About to be deleted.
#if IG_SHARED	// rowan: Optimisation: ability to disable touch and tick
var					bool	bDisableTick;
var					bool	bDisableTouch;
#endif
// IGA <<< Bool bTicked changed to int called LastTick
//var transient const bool		bTicked;				// Actor has been updated.
// IGA
var(Lighting)		bool	bDynamicLight;		// This light is dynamic.
var					bool	bTimerLoop;			// Timer loops (else is one-shot).
var					bool    bOnlyOwnerSee;		// Only owner can see this actor.
var(Advanced)		bool    bHighDetail;		// Only show up in high or super high detail mode.
var(Advanced)		bool	bSuperHighDetail;	// Only show up in super high detail mode.
var					bool	bOnlyDrawIfAttached;	// don't draw this actor if not attached (useful for net clients where attached actors and their bases' replication may not be synched)
var(Advanced)		bool	bStasis;			// In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var					bool	bTrailerAllowRotation; // If PHYS_Trailer and want independent rotation control.
var					bool	bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.
var					bool	bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
#if IG_TRIBES3 // Alex:
var(Advanced)		bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
#else
var					bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
#endif
var(Display)		bool    bAcceptsProjectors;	// Projectors can project onto this actor
#if IG_SHARED // ckline: selectively prevent actors from receiving ShadowProjector shadows
var(Display)		bool    bAcceptsShadowProjectors "If false, ShadowProjectors (e.g., player shadows) will not project onto this actor. This parameter is ignored unless bAcceptsProjectors=true.";
#endif
var					bool	bOrientOnSlope;		// when landing, orient base on slope of floor
var			  const	bool	bOnlyAffectPawns;	// Optimisation - only test ovelap against pawns. Used for influences etc.
var(Display)		bool	bDisableSorting;	// Manual override for translucent material sorting.
var(Movement)		bool	bIgnoreEncroachers; // Ignore collisions between movers and 

var					bool    bShowOctreeNodes;
var					bool    bWasSNFiltered;      // Mainly for debugging - the way this actor was inserted into Octree.

// Networking flags
var			  const	bool	bNetTemporary;				// Tear-off simulation in network play.
var					bool	bOnlyRelevantToOwner;			// this actor is only relevant to its owner.
var transient const	bool	bNetDirty;					// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var					bool	bAlwaysRelevant;			// Always relevant for network.
var					bool	bReplicateInstigator;		// Replicate instigator to client (used by bNetTemporary projectiles).
var					bool	bReplicateMovement;			// if true, replicate movement/location related properties
var					bool	bSkipActorPropertyReplication; // if true, don't replicate actor class variables for this actor
var					bool	bUpdateSimulatedPosition;	// if true, update velocity/location after initialization for simulated proxies
var					bool	bTearOff;					// if true, this actor is no longer replicated to new clients, and 
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
var					bool	bOnlyDirtyReplication;		// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics) 
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var					bool	bReplicateAnimations;		// Should replicate SimAnim
var const           bool    bNetInitialRotation;        // Should replicate initial rotation
var					bool	bCompressedPosition;		// used by networking code to flag compressed position replication
var					bool	bAlwaysZeroBoneOffset;		// if true, offset always zero when attached to skeletalmesh

#if IG_TRIBES3 // Alex: ignored when determining whether or not a character can move between points
var (Navigation) bool bNavigationRelevant;
var (Navigation) bool bOverruleNavigationRelevant;
#endif

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole RemoteRole, Role;
var const transient int		NetTag;
var const float NetUpdateTime;	// time of last update
var float NetUpdateFrequency; // How many seconds between net updates.
var float NetPriority; // Higher priorities means update it more frequently.
var Pawn                  Instigator;    // Pawn responsible for damage caused by this actor.
#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
var(Sound) sound          AmbientSound;  // Ambient sound effect.
#endif
var const name			AttachmentBone;		// name of bone to which actor is attached (if attached to center of base, =='')

var       const LevelInfo Level;         // Level this actor is on.
var transient const Level	XLevel;			// Level object.
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.

#if IG_TRIBES3_MOVEMENT
var name MovementObjectClass;
var const MovementObject movementObject;
#endif

#if IG_TRIBES3_STATICMESH_SOCKETS	// glenn: support for staticmesh sockets
enum SocketCoordinates
{
	SOCKET_World,       // socket in world coordinates (default)
	SOCKET_Local,       // socket in local object coordinates
};
#endif

#if IG_ACTOR_GROUPING // ryan: Actor grouping
var const array<Object> OwnerGroups;
#endif

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

// Havok rigid body state
struct HavokRigidBodyState
{
	var vector  Position;
	var quat	Quaternion;
	var vector	LinVel;
	var vector	AngVel;
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.

#if IG_TRIBES3 // karl: Bool bTicked changed to int called LastTick
var transient const int		LastTick;			// Tick where Actor was updated.
#endif

#if IG_TRIBES3	// michaelj:  Added variables that allow filtering on level load
var(Filter) class<GameInfo>						exclusiveToGameInfo		"This Actor will only appear in the specified game type.";
var(Filter) array< class<GameInfo> >			gameInfoExclusions		"This Actor won't appear in any of the specified game types.";
var(Filter) array< class<GameInfo> >			gameInfoInclusions		"This Actor will appear in the specified game types even if the game types exist in an exclusion filter.";
var(Filter) int									maxDifficulty;
var(Filter) int									minDifficulty;
var(Filter) int									maxNumPlayers;
var(Filter) int									minNumPlayers;
#endif

var const PointRegion     Region;        // Region this actor is in.
var				float       TimerRate;		// Timer event, 0=no timer.
var(Display) const mesh		Mesh;			// Mesh if DrawType=DT_Mesh.
var transient float		LastRenderTime;	// last time this actor was rendered.
var(Events) name			Tag;			// Actor's tag name.
var transient array<int>  Leaves;		 // BSP leaves this actor is in.
var(Events) name          Event;         // The event this actor causes.
//var Inventory             Inventory;     // Inventory chain.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var transient MeshInstance MeshInstance;	// Mesh instance.
var(Display) float		  LODBias;
var(Object) name InitialState;
var(Object) name Group;

// Internal.
var const array<Actor>    Touching;		 // List of touching actors.
var const transient array<int>  OctreeNodes;// Array of nodes of the octree Actor is currently in. Internal use only.
var const transient Box	  OctreeBox;     // Actor bounding box cached when added to Octree. Internal use only.
var const transient vector OctreeBoxCenter;
var const transient vector OctreeBoxRadii;
var const actor           Deleted;       // Next actor in just-deleted chain.
var const float           LatentFloat;   // Internal latent function use.
#if IG_SHARED   //tcohen: make FinishAnim() more reliable
var const array<byte>	  LatentAnimChannelCount;	 //when FinishAnim() is called, this is set to the value of AnimationCount on the animation channel that we're blocked on.  Its used to detect if another animation starts playing before we execPollFinishAnim().
#endif

// Internal tags.
var const native int CollisionTag;
var const transient int JoinedTag;

// The actor's position and rotation.
var const	PhysicsVolume	PhysicsVolume;	// physics volume this actor is currently in
var(Placement) const vector	Location;		// Actor's location; use Move to set.
var(Placement) const rotator Rotation;		// Rotation.
var(Movement) vector		Velocity;		// Velocity.
var			  vector        Acceleration;	// Acceleration.

var const vector CachedLocation;
var const Rotator CachedRotation;
var Matrix CachedLocalToWorld;

// Attachment related variables
var(Movement)	name	AttachTag;
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const vector		RelativeLocation;	// location relative to base/bone (valid if base exists)
var const rotator		RelativeRotation;	// rotation relative to base/bone (valid if base exists)

var(Movement) bool bHardAttach;             // Uses 'hard' attachment code. bBlockActor and bBlockPlayer must also be false.
											// This actor cannot then move relative to base (setlocation etc.).
											// Dont set while currently based on something!
											// 
var const     Matrix    HardRelMatrix;		// Transform of actor in base's ref frame. Doesn't change after SetBase.

// Projectors
struct ProjectorRenderInfoPtr { var int Ptr; };	// Hack to to fool C++ header generation...
struct StaticMeshProjectorRenderInfoPtr { var int Ptr; };
var const native array<ProjectorRenderInfoPtr> Projectors;// Projected textures on this actor
var const native array<StaticMeshProjectorRenderInfoPtr>	StaticMeshProjectors;

//-----------------------------------------------------------------------------
// Display properties.

var(Display) Material		Texture;			// Sprite texture.if DrawType=DT_Sprite
var StaticMeshInstance		StaticMeshInstance; // Contains per-instance static mesh data, like static lighting data.
var(Display) const editconst deepcopy model	Brush;				// Brush if DrawType=DT_Brush.
var(Placement) const float	DrawScale;			// Scaling factor, 1.0=normal size.
var(Placement) const vector	DrawScale3D;		// Scaling vector, (1.0,1.0,1.0)=normal size.
var(Display) vector			PrePivot;			// Offset from box center for drawing.
var(Display) array<Material> Skins;				// Multiple skin support - not replicated.
var			Material		RepSkin;			// replicated skin (sets Skins[0] if not none)
var(Display) byte			AmbientGlow;		// Ambient brightness, or 255=pulsing.
var(Display) byte           MaxLights;          // Limit to hardware lights active on this primitive.
var(Display) ConvexVolume	AntiPortal;			// Convex volume used for DT_AntiPortal
var(Display) float          CullDistance;       // 0 == no distance cull, < 0 only drawn at distance > 0 cull at distance
var(Display) float			ScaleGlow;			

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Additive,
	STY_Subtractive,
	STY_Particle,
	STY_AlphaZ,
} Style;

// Display.
var(Display)  bool      bUnlit;					// Lights don't affect actor.
var(Display)  bool      bShadowCast;			// Casts static shadows.
var(Display)  bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)  bool		bUseLightingFromBase;	// Use Unlit/AmbientGlow from Base

// Advanced.
var			  bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced) bool		bGameRelevant;			// Always relevant for game
var(Advanced) bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var			  bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced) bool		bMovable;				// Actor can be moved.
var			  bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var(Advanced) bool		bCanBeDamaged;			// can take damage
var(Advanced) bool		bShouldBaseAtStartup;	// if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var			  bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called 
												// during deletion process before bDeleteMe is set).
var					bool	bAnimByOwner;		// Animation dictated by owner.
var(Display) 		bool	bOwnerNoSee;		// Everything but the owner can see this actor.
var(Advanced)		bool	bCanTeleport;		// This actor can be teleported.
var					bool	bClientAnim;		// Don't replicate any animations - animation done client-side
var					bool    bDisturbFluidSurface; // Cause ripples when in contact with FluidSurface.
var			  const	bool	bAlwaysTick;		// Update even when players-only.

//-----------------------------------------------------------------------------
// Sound.

#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
// Ambient sound.
var(Sound) float        SoundRadius;			// Radius of ambient sound.
var(Sound) byte         SoundVolume;			// Volume of ambient sound.
var(Sound) byte         SoundPitch;				// Sound pitch shift, 64.0=none.
#endif

#if (IG_SHARED && !IG_EFFECTS) // david: Added this variable so we can turn off the default light brightness->sound volume behaviour
var(Sound) bool         bScaleVolumeByLightBrightness;
#endif

// Sound occlusion
enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};

var(Sound) ESoundOcclusion SoundOcclusion;		// Sound occlusion approach.

#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
var(Sound) bool				bFullVolume;		// Whether to apply ambient attenuation.
#endif

// Carlos:  The effects system handles this in a completely different fashion.  This was used previously to have sounds
// cut off other sounds playing in the same slot.  This has been superceded by the Monophonic system in the ig effects system. 
#if !IG_EFFECTS     
// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};
#endif // IG_EFFECTS

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};


#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
// Regular sounds.
var(Sound) float TransientSoundVolume;	// default sound volume for regular sounds (can be overridden in playsound)
var(Sound) float TransientSoundRadius;	// default sound radius for regular sounds (can be overridden in playsound)
#endif

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius;		// Radius of collision cyllinder.
var(Collision) const float CollisionHeight;		// Half-height cyllinder.

// Collision flags.
var(Collision) const bool bCollideActors;		// Collides with other actors.
var(Collision) bool       bCollideWorld;		// Collides with the world.
var(Collision) bool       bBlockActors;			// Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;		// Blocks other player actors.
var(Collision) bool       bProjTarget;			// Projectiles should potentially target this actor.
#if IG_TRIBES3 // Ryan: PHYS_Projectile was not enough to identify all our projectiles
var(Collision) bool       bProjectile;			// This actor is a projectile
var(Collision) bool		  bSkipEncroachment;	// This actor does not encroach
#endif // IG
var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
var(Collision) bool       bAutoAlignToTerrain;  // Auto-align to terrain in the editor
var(Collision) bool		  bUseCylinderCollision;// Force axis aligned cylinder collision (useful for static mesh pickups, etc.)
var(Collision) const bool bBlockKarma;			// Block actors being simulated with Karma.
var(Collision) const bool bBlockHavok;			// Block actors being simulated with Havok.

#if IG_TRIBES3 // Alex: use Havok tunneling prevention code
var(Havok) bool bEnableHavokBackstep;
#endif

#if IG_TRIBES3 // Alex: performing client side Havok physics - server side physics shall effectively ignore this actor
var(Havok) bool bClientHavokPhysics;
#endif

#if IG_TRIBES3 // Alex:
var(Collision) const bool bDisableHavokCollisionWhenAttached; // disable Havok collision when hard attached to an object
#endif

var       			bool    bNetNotify;         // actor wishes to be notified of replication events

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging
var(Movement) float		  GravityScale;		// Multiplier for the effect of gravity on this actor

const MAXSTEPHEIGHT = 35.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor
					   
// ifdef WITH_KARMA

// Used to avoid compression
struct KRBVec
{
	var float	X, Y, Z;
};

struct KRigidBodyState
{
	var KRBVec	Position;
	var Quat	Quaternion;
	var KRBVec	LinVel;
	var KRBVec	AngVel;
};
					   
//var(Karma) deepcopy editinline KarmaParamsCollision KParams; // Parameters for Karma Collision/Dynamics.
//var const native int KStepTag;

#if IG_TRIBES3 // Alex: do not expose to UnrealEd
var export editinline HavokObject HavokData; // Havok Dynamics info
#else
var(Havok) export editinline HavokObject HavokData; // Havok Dynamics info
#endif

#if IG_TRIBES3 // Alex: If not None an instance constructed and assigned to HavokData in HavokInitActor.
var(Havok) class<HavokObject> havokDataClass;
#endif

#if IG_TRIBES3 // Alex: in Havok units
var vector havokAngularVelocity;
#endif

#if IG_SHARED // Alex:
var private vector havokGameTickForce;
var private vector havokGameTickForcePosition;
#endif

#if IG_TRIBES3  // glenn: fastest rotating body speed in skeletal body (used for working out how fast a ragdoll is spinning)
var const float havokSkeletalRotationSpeed;
#endif

// endif

//-----------------------------------------------------------------------------
// Animation replication (can be used to replicate channel 0 anims for dumb proxies)
struct AnimRep
{
	var name AnimSequence; 
	var bool bAnimLoop;	
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};
var transient AnimRep		  SimAnim;		   // only replicated if bReplicateAnimations is true

//-----------------------------------------------------------------------------
// Forces.

enum EForceType
{
	FT_None,
	FT_DragAlong,
};

var (Force) EForceType	ForceType;
var (Force)	float		ForceRadius;
var (Force) float		ForceScale;


//-----------------------------------------------------------------------------
// Networking.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bRepClientDemo;		// True if remote client is recording demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.
var const bool bDemoOwner;			// Demo recording driver owns this actor.
var bool	   bNoRepMesh;			// don't replicate mesh

//Editing flags
#if IG_ACTOR_GROUPING // Ryan: Don't allow hiding and unhidding from the properties window
var const bool        bHiddenEd;     // Is hidden during editing.
    #if IG_NOCOPY // ckline: Never export a non-default value of bHiddenEdGroup, else a pasted actora that was copied from an actor in a hidden group will be hidden and difficult to unhide.
        // use nocopy keyword to prevent copying of bHiddenEdGroup
        var const nocopy bool bHiddenEdGroup;// Is hidden by the group brower.
    #else
        // UObject::ExportProperties will prevent copying of bHiddenEdGroup via a slower property name check
var const bool        bHiddenEdGroup;// Is hidden by the group brower.
    #endif
#else
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bHiddenEdGroup;// Is hidden by the group brower.
#endif // IG
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.
var	bool				  bObsolete;	 // actor is obsolete - warn level designers to remove it
var(Collision) bool		  bPathColliding;// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var transient bool		  bPathTemp;	 // Internal/path building
var	bool				  bScriptInitialized; // set to prevent re-initializing of actors spawned during level startup
var(Advanced) bool        bLockLocation; // Prevent the actor from being moved in the editor.

var Class<LocalMessage> MessageClass;

#if IG_EFFECTS // tcohen: startup time optimization: most actors don't care about Alive or Spawned events. Saves TONS of time in debug builds by avoiding no-op triggers of Spawned and Alive events.
// If false (the default), then TriggerEffectEvent() calls on this Actor that occur 
// before the game starts (i.e., before first Tick()) will be ignored.
// If true, then effect events that happen before the game starts (such as
// 'Alive' and 'Spawned' events) will be queued and triggered once the game starts
var(Advanced) bool bTriggerEffectEventsBeforeGameStarts;    
var(Advanced) bool bNeedLifetimeEffectEvents;
#endif

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};


// double click move direction.
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};

#if IG_ACTOR_LABEL // david: Labels
// Script variables
var() Name Label				"This object's label for use within the GUI editing system, and scripting (not mandatory)";
var bool bReplicateLabel; // label is not replicated unless this is true
#endif

#if IG_SCRIPTING // david: Script
// Script variables
var() const String TriggeredBy		"This actor only receives messages from actors that have a matching label";
#endif

#if IG_SHARED // ckline: notifications upon Pawn death and Actor destruction
var(Advanced) bool bSendDestructionNotification "If true, all registered IInterestedActorDestroyed objects will be notified when this actor is destroyed. NOTE: this setting is ignored if bStatic=true."; 
#endif

#if IG_UC_LATENT_STACK_CLEANUP // Ryan: Latent stack cleanup
var transient noexport private const Array<INT> LatentStackLocations;
#endif

#if IG_SHARED // johna: support for AddDebugMessage()
// Adds a line of text to be displayed in front of the actor (if the actor is visible)
// Only valid for the current update, so it must be called each update
native function AddDebugMessage(string NewMessage, optional color NewMessageColor);
#endif // IG_SHARED 

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Location
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Location;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& ((DrawType == DT_Mesh) || (DrawType == DT_StaticMesh))
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Rotation;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& RemoteRole<=ROLE_SimulatedProxy )
		Base,bOnlyDrawIfAttached;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& RemoteRole<=ROLE_SimulatedProxy && (Base != None) && !Base.bWorldGeometry)
#if IG_TRIBES3 // Alex:
		RelativeRotation, RelativeLocation;
#else
		RelativeRotation, RelativeLocation, AttachmentBone;
#endif

#if IG_TRIBES3 // Alex:
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& RemoteRole<=ROLE_SimulatedProxy && (Base != None) && (!Base.bWorldGeometry || Base.DrawType == DT_Mesh))
		AttachmentBone;
#endif

	// Physics
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition))
						|| ((RemoteRole == ROLE_DumbProxy) && (Physics == PHYS_Falling || Physics==PHYS_Movement)))  )
		Velocity;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (((RemoteRole == ROLE_SimulatedProxy) && bNetInitial)
						|| (RemoteRole == ROLE_DumbProxy)) )
		Physics;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (RemoteRole <= ROLE_SimulatedProxy) && (Physics == PHYS_Rotating) )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
	// Ambient sound.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;
#endif

#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) && (AmbientSound!=None))
		SoundRadius, SoundVolume, SoundPitch;
#endif

	// Animation. 
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) 
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) && bReplicateAnimations )
		SimAnim;

#if IG_SHARED // Alex: required to fix SimAnim not playing animation in some instances
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) 
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) )
		bReplicateAnimations;
#endif

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		bHidden, bHardAttach;

	// Properties changed using accessor functions (Owner, rendering, and collision)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty )
		Owner, DrawScale, DrawType, bCollideActors,bCollideWorld,bOnlyOwnerSee,Texture,Style, RepSkin;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty 
					&& (bCollideActors || bCollideWorld) )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Properties changed only when spawning or in script (relationships, rendering, lighting)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		Role,RemoteRole,bNetOwner,LightType,bTearOff;

/*
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && bNetOwner )
		Inventory;
*/

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && bReplicateInstigator )
		Instigator;

	// Infrequently changed mesh properties
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (DrawType == DT_Mesh) )
		AmbientGlow,bUnlit,PrePivot;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && !bNoRepMesh && (DrawType == DT_Mesh) )
		Mesh;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
				&& bNetDirty && (DrawType == DT_StaticMesh) )
		StaticMesh;

	// Infrequently changed lighting properties.
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (LightType != LT_None) )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase, bSpecialLit;

	// replicated functions
	unreliable if( bDemoRecording )
		DemoPlaySound;

#if IG_ACTOR_LABEL // david: added ability to replicate label (not normally needed)
	reliable if ( Role == ROLE_Authority && bReplicateLabel && bNetDirty )
		Label;
#endif
}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

#if IG_SHARED	// rowan: rendering stuff
simulated event Material GetOverlayMaterial(int Index)
{
	if (Base != None && bGetOverlayMaterialFromBase)
		return Base.GetOverlayMaterial(Index);

	return None;
}
#endif

#if IG_TRIBES3 // Ryan: allow IsOverlapping to be called from script
native function bool IsOverlapping(Actor Other);
#endif // IG

#if IG_TRIBES3	// Marc: loop through all nearby pawns that have a controller
native final iterator function nearbyControlledPawns( Vector CenterLocation, float Radius, out Pawn Pawn, optional name matchTag );
#endif

#if IG_SCRIPTING // david: functions to find objects by their script label
// findByLabel
// Finds the first actor with label
function Actor findByLabel(class<Actor> actorClass, Name label, optional bool checkDead)
{
	local Actor a;
	local Pawn p;
	local class<Actor> findClass;

	if (actorClass != None)
	{
		findClass = actorClass;
	}
	else
	{
		findClass = class'Actor';
	}

	ForEach DynamicActors(findClass, a)
	{
		if (a.label == label)
		{
			if (!checkDead)
			{
						return a;
				}
			else
			{
				p = Pawn(a);

				if (p != None)
				{
					if (p.isAlive())
						return a;
				}
				else return a;
			}
		}
	}

	return None;
}

// Iterator for all actors with label (same as findByLabel but for all matches, not just the first)
native final iterator function actorLabel(class<Actor> actorClass, out Actor foundActor, Name label);

// findStaticByLabel
// Finds the first actor with label including static actors
function Actor findStaticByLabel(class<Actor> actorClass, Name label, optional bool checkDead)
{
	local Actor a;
	local Pawn p;
	local class<Actor> findClass;

	if (actorClass != None)
	{
		findClass = actorClass;
	}
	else
	{
		findClass = class'Actor';
	}

	ForEach AllActors(findClass, a)
	{
		if (a.label == label)
		{
			if (!checkDead)
			{
						return a;
				}
			else
			{
				p = Pawn(a);

				if (p != None)
				{
					if (p.isAlive())
						return a;
				}
				else return a;
			}
		}
	}

	return None;
}

#if IG_TRIBES3 // Alex:
function classConstruct()
{
	bNavigationRelevant = true;
}
#endif

// Iterator for all actors with label including static actors (same as findStaticByLabel but for all matches, not just the first)
native final iterator function staticActorLabel(class<Actor> actorClass, out Actor foundActor, Name label);
#endif

#if IG_UC_ACTOR_ALLOCATOR // karl: Added Actor Allocator
// Called by new operator (on the default object of a particular class).  
// Allocates and returns an object of that class.
native static function Object Allocate( Object Context, Object Outer, optional string n, optional INT flags, optional Object Template );

// Constructor
overloaded native function Construct();
overloaded native function Construct( actor Owner, optional name Tag, 
				  optional vector Location, optional rotator Rotation);
#endif

// Latent functions.
#if IG_UC_THREADED // karl: Moved sleep to Object
#else
native(256) final latent function Sleep( float Seconds );
#endif

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );
native final function SetDrawScale(float NewScale);
native final function SetDrawScale3D(vector NewScale3D);
native final function SetStaticMesh(StaticMesh NewStaticMesh);
native final function SetDrawType(EDrawType NewDrawType);

#if IG_TRIBES3 // Ryan: Need to be able to access materials for controllable material types
native final function Material GetMaterial(int Index);
native final function Material ShallowCopyMaterial(Material src, Actor owner);
#endif // IG

// Movement.
native(266) final function bool Move( vector Delta );
native(267) final function bool SetLocation( vector NewLocation );
native(299) final function bool SetRotation( rotator NewRotation );
#if IG_TRIBES3 // david: TestMove returns true if a given move is valid for the actor (i.e. unobstructed) but doesn't move the actor
native final function bool TestMove( vector Location, rotator Rotation );
#endif

// SetRelativeRotation() sets the rotation relative to the actor's base
native final function bool SetRelativeRotation( rotator NewRotation );
native final function bool SetRelativeLocation( vector NewLocation );

native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase, optional vector NewFloor );
native(272) final function SetOwner( actor NewOwner );

#if IG_TRIBES3	// marc: make an actor dormant for level designers
// "onOff": true: make dormant; false: wake up
function makeDormant( bool onOff )
{
	local Pawn pawn;

	pawn = Pawn(self);

	if ( onOff )
	{
		//log( "Making" @ name @ "dormant" );
		if ( pawn != None )
		{
			level.AI_Setup.stopActions( pawn );
			pawn.AI_LOD_LevelOrig = pawn.AI_LOD_Level;
			level.AI_Setup.setAILOD( pawn, AILOD_NONE );
		}
		SetPhysics(PHYS_None);					// stop physics
		bHidden = true;							// make invisible
		setCollision( false, false, false );	// disable collisions
	}
	else
	{
		//log( "Waking" @ name @ "up" );
		SetPhysics(default.Physics);			// restore physics
		bHidden = default.bHidden;				// make visible
		setCollision( default.bCollideActors, default.bBlockActors, default.bBlockPlayers );	// enable collisions
		if ( pawn != None )
		{
			level.AI_Setup.setAILOD( pawn, pawn.AI_LOD_LevelOrig );
			pawn.rematchGoals();
		}
	}
}
#endif

//=============================================================================
// Animation.

native final function string GetMeshName();

// Animation functions.
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );

#if IG_ANIM_ADDITIVE_BLENDING // darren: additive anim blending
// Additively blends the animation specified by Sequence in the given
// channel. PlayAnimAdditive uses the first frame of animation specified
// by RefSequence as a reference, and blends the differences between
// this reference and each frame of the Sequence animation. If
// RefSequence is NULL, the first frame of the Sequence is used
// as the reference. [darren]
native final function PlayAnimAdditive( name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional name RefSequence );
#endif

native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(294) final function TweenAnim( name Sequence, float Time, optional int Channel );
native(282) final function bool IsAnimating(optional int Channel);
native(261) final latent function FinishAnim(optional int Channel);
native(263) final function bool HasAnim( name Sequence );
native final function StopAnimating( optional bool ClearAllButBase );
native final function FreezeAnimAt( float Time, optional int Channel);
native final function SetAnimFrame( float Time, optional int Channel, optional int UnitFlag );
native final function bool IsTweening(int Channel);

#if IG_TRIBES3 // Ryan:
simulated function PlayScriptedAnim(name AnimToPlay)
{
	PlayAnim(AnimToPlay);
}
#endif

#if IG_SHARED
// Get the length (in seconds) of an animation
native final function float GetAnimLength( name Sequence, optional float Rate, optional float TweenTime, optional int Channel);
#endif

// ifdef WITH_LIPSINC
native final function PlayLIPSincAnim(
	name                LIPSincAnimName,
	optional float		Volume,
	optional float		Radius,
	optional float		Pitch,
	optional bool		bPositional
    );

native final function StopLIPSincAnim();

native final function bool HasLIPSincAnim( name LIPSincAnimName );
native final function bool IsPlayingLIPSincAnim();
native final function string CurrentLIPSincAnim();

#if IG_TRIBES3 // dbeswick:
native final function float GetLIPSincAnimDuration( name LIPSincAnimName );
#endif

// LIPSinc Animation notifications.
event LIPSincAnimEnd();
// endif

// Animation notifications.
event AnimEnd( int Channel );
native final function EnableChannelNotify ( int Channel, int Switch );
native final function int GetNotifyChannel();

// Skeletal animation.
simulated native final function LinkSkelAnim( MeshAnimation Anim, optional mesh NewMesh );
simulated native final function LinkMesh( mesh NewMesh, optional bool bKeepAnim );
native final function BoneRefresh();

native final function AnimBlendParams( int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName, optional bool bGlobalPose);
native final function AnimBlendToAlpha( int Stage, float TargetAlpha, float TimeInterval );

native final function coords  GetBoneCoords(   name BoneName
#if IG_SHARED // johna: optionally include offset to socket if BoneName is the name of a socket
			  // -if BoneName is the name of a bone, bGetSocketCoords has no effect
			  // -if BoneName is the name of a socket and bGetSocketCoords is false, the function returns the coords of the bone the socket is attached to
			  // -if BoneName is the name of a socket and bGetSocketCoords is true, the function returns the coords of the socket (i.e., get the current world space location of the socket)
											, optional bool bGetSocketCoords 
#endif
											);
native final function rotator GetBoneRotation( name BoneName, optional int Space );

native final function vector  GetRootLocation();
native final function rotator GetRootRotation();
native final function vector  GetRootLocationDelta();
native final function rotator GetRootRotationDelta();

#if IG_TRIBES3 // Alex:
native final function vector GetMeshOrigin();
#endif

native final function bool  AttachToBone( actor Attachment, name BoneName );
native final function bool  DetachFromBone( actor Attachment );
#if IG_SHARED // ckline: forcibly update the position of an Actor's attachments, even if the Actor is not visible
// Causes all attachments to have their positions/rotations updated, regardless of 
// whether or not this actor is visible. 
native final function UpdateAttachmentLocations();
#endif

native final function LockRootMotion( int Lock );
native final function SetBoneScale( int Slot, optional float BoneScale, optional name BoneName );

native final function SetBoneDirection( name BoneName, rotator BoneTurn, optional vector BoneTrans, optional float Alpha, optional int Space );
native final function SetBoneLocation( name BoneName, optional vector BoneTrans, optional float Alpha );
native final function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha );
native final function GetAnimParams( int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate );
native final function bool AnimIsInGroup( int Channel, name GroupName );  

//=========================================================================
// Rendering.

native final function plane GetRenderBoundingSphere();
native final function DrawDebugLine( vector LineStart, vector LineEnd, byte R, byte G, byte B); // SLOW! Use for debugging only!

//=========================================================================
// Physics.

native final function DebugClock();
native final function DebugUnclock();

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

native final function OnlyAffectPawns(bool B);

// ifdef WITH_KARMA
//native final function Quat KGetRBQuaternion();
//
//native final function KGetRigidBodyState(out KRigidBodyState RBstate);
//native final function KDrawRigidBodyState(KRigidBodyState RBState, bool AltColour); // SLOW! Use for debugging only!
//native final function vector KRBVecToVector(KRBVec RBvec);
//native final function KRBVec KRBVecFromVector(vector v);
//
//native final function KSetMass( float mass );
//native final function float KGetMass();
//
//// Set inertia tensor assuming a mass of 1. Scaled by mass internally to calculate actual inertia tensor.
//native final function KSetInertiaTensor( vector it1, vector it2 );
//native final function KGetInertiaTensor( out vector it1, out vector it2 );
//
//native final function KSetDampingProps( float lindamp, float angdamp );
//native final function KGetDampingProps( out float lindamp, out float angdamp );
//
//native final function KSetFriction( float friction );
//native final function float KGetFriction();
//
//native final function KSetRestitution( float rest );
//native final function float KGetRestitution();
//
//native final function KSetCOMOffset( vector offset );
//native final function KGetCOMOffset( out vector offset );
//native final function KGetCOMPosition( out vector pos ); // get actual position of actors COM in world space
//
//native final function KSetImpactThreshold( float thresh );
//native final function float KGetImpactThreshold();
//
//native final function KWake();
//native final function bool KIsAwake();
//native final function KAddImpulse( vector Impulse, vector Position, optional name BoneName );
//
//native final function KSetStayUpright( bool stayUpright, bool allowRotate );
//native final function KSetStayUprightParams( float stiffness, float damping );
//
//native final function KSetBlockKarma( bool newBlock );
//
//native final function KSetActorGravScale( float ActorGravScale );
//native final function float KGetActorGravScale();
//
//// Disable/Enable Karma contact generation between this actor, and another actor.
//// Collision is on by default.
//native final function KDisableCollision( actor Other );
//native final function KEnableCollision( actor Other );
//
//// Ragdoll-specific functions
//native final function KSetSkelVel( vector Velocity, optional vector AngVelocity, optional bool AddToCurrent );
//native final function float KGetSkelMass();
//native final function KFreezeRagdoll();
//
//// You MUST turn collision off (KSetBlockKarma) before using bone lifters!
//native final function KAddBoneLifter( name BoneName, InterpCurve LiftVel, float LateralFriction, InterpCurve Softness ); 
//native final function KRemoveLifterFromBone( name BoneName ); 
//native final function KRemoveAllBoneLifters(); 
//
//// Used for only allowing a fixed maximum number of ragdolls in action.
//native final function KMakeRagdollAvailable();
//native final function bool KIsRagdollAvailable();
//
//// event called when Karmic actor hits with impact velocity over KImpactThreshold
//event KImpact(actor other, vector pos, vector impactVel, vector impactNorm); 
//
//// event called when karma actor's velocity drops below KVelDropBelowThreshold;
//event KVelDropBelow();
//
//// event called when a ragdoll convulses (see KarmaParamsSkel)
//event KSkelConvulse();

// ---------------------
// Paul: These event functions are now implemented with the unified physics
// inteface near the bottom of the file.
// ---------------------

// event called just before sim to allow user to 
// NOTE: you should ONLY put numbers into Force and Torque during this event!!!!
//event KApplyForce(out vector Force, out vector Torque);

// This is called from inside C++ physKarma at the appropriate time to update state of Karma rigid body.
// If you return true, newState will be set into the rigid body. Return false and it will do nothing.
//event bool KUpdateState(out KRigidBodyState newState);*/

// endif

// Unreal Havok
#if !IG_SHARED	// rowan: added new version of this that supports activation and deactivation
native final function HavokActivate();
#endif
native final function bool HavokIsActive();

native final function HavokImpartImpulse( vector Impulse, vector Position, optional name BoneName );
native final function HavokImpartForce( vector Force, vector Position, optional name BoneName );

// You can do this though HGetState / HavokUpdateState, but here is a quicker, specific to 
// just the velocities. If BoneName is None for a skeletal system, the last traced bone is used.
// If you just set one bone in a skeletal system you will be introducing error into the system.
#if IG_SHARED // ckline: if socket name specified, return velocity of bone socket is associated with
//   Note: if HavokGet{Linear/Angular}Velocity is passed the name of a socket, the function will 
//   return the velocity of the bone to which the socket is attached.
#endif
native final function vector HavokGetLinearVelocity( optional name BoneName ); // in Unreal units
native final function vector HavokGetAngularVelocity( optional name BoneName ); // in Unreal units
native final function HavokSetLinearVelocity( vector Linear, optional name BoneName ); // in Unreal units
native final function HavokSetAngularVelocity( vector Angular, optional name BoneName ); // in Unreal units
native final function HavokSetLinearVelocityAll( vector Linear ); // Only really for Skeletal systems.
#if IG_SHARED // ckline: can set havok damping from script
// Set linear/angular damping on an actor. If this actor is a ragdoll, damping
// will be applied to all bones unless a specific BoneName is specified.
// Damping must be non-negative. As a reference, the default linear damping 
// on a rigid body is 0, and the default angular damping is 0.5.
native final function HavokSetLinearDamping(float Damping, optional name BoneName); 
native final function HavokSetAngularDamping(float Damping, optional name BoneName); 
#endif
native final function name HavokGetLastTracedBone();
#if IG_SHARED	// rowan: IG extensions to havok integration
native final function HavokImpartCOMImpulse( vector Impulse, optional name BoneName );	// apply impulse at exact havok COM
native final function HavokActivate(optional bool Activate);
#endif
#if IG_SHARED // ckline: change bBlockHavok at runtime
native final function HavokSetBlocking(bool blockHavok); // default param value is false
#endif

#if IG_TRIBES3	// michaelj:  Added positional and COM Havok functions
native final function vector HavokGetPosition( optional name BoneName ); // in Unreal units
native final function HavokSetPosition( vector Linear, optional name BoneName ); // in Unreal units
native final function HavokSetCOM( vector Offset, optional name BoneName ); // in Unreal units
native final function HavokImpartLinearForceAll( vector Force );	// apply linear force to each component of a ragdoll
#endif

#if IG_TRIBES3 // Alex:
native final function HavokSetRotation(quat newRotation);
#endif

#if IG_TRIBES3  // glenn: added havok get center of mass
native final function vector HavokGetCenterOfMass();
#endif

#if IG_SHARED // Alex: Imparts a force for the duration of a game tick. HavokImpartForce only applies force for the
		// duration of a Havok tick. This function can only be called once per tick per actor, previous calls are
		// ignored otherwise. Force is actually applied in the next game tick.
native final function HavokSetGameTickForce(vector Force, vector Position);
#endif

// If you change the state and return true for this event, you will directly
// effect the pos and rot of the given body. Note that this will cause the body to 
// effectlively teleport to that state, so make sure that that state is valid!
native final function HavokGetState(out HavokRigidBodyState state, optional name BoneName);
event bool HavokUpdateState(out HavokRigidBodyState newState);

// Pairwise Collision Detection filter. THIS CAUSES SLOW DOWN AT RUNTIME (LIST CHECKS IN COLLISION CALLBACKS) 
// Try to use Collision Groups in the HavokRigidBidy instead (see after these funcs):
native final function HavokSlowSetCollisionEnabled( actor Other, bool Enabled, optional name BoneNameA, optional name BoneNameB );

// Change the Collision Groups info for this body.
// 32768 system groups, 32 layers, 64 subpart ids. See the HavokRigidBody.uc  for more info.
native final function HavokCollisionGroupChange( int layer, int systemGroup, int subpartID, int	subpartIgnoreID, optional name BoneName );

// Call this after causing HavokQuit to be called (through SetPhysics( PHYS_None ) for instance if  
// you want to reset the animation flags so that the Havok pose is no longer the one used 
// and the animation is in full control. The first PHYSICAL bone in the hierarchy will be kept 
// the same orientation (by changing the Actor pos after refreshing the pose) and the actor pos 
// will remain unchanged. Thus you should be able to predict, given an animation set,
// where the pose will be at the end of this call.
native final function HavokReturnSkeletalActorToAnimationSystem(); 

// end Unreal Havok

// Timing
native final function Clock(out float time);
native final function UnClock(out float time);

//=========================================================================
// Music

native final function int PlayMusic( string Song, float FadeInTime );
native final function StopMusic( int SongHandle, float FadeOutTime );
native final function StopAllMusic( float FadeOutTime );


//=========================================================================
// Engine notification functions.

//
// Major notifications.
//
#if IG_SWAT // SWAT untriggers 'alive' and triggers 'destroyed' in specific Handlers for ReactiveWorldObjects
simulated event Destroyed();
#else
simulated event Destroyed()
{
#if IG_EFFECTS
	if (bNeedLifetimeEffectEvents)
	{
		UntriggerEffectEvent('Alive');
	}
#endif
}
#endif
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );
event PostNetReceive(); 

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
event Timer();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event PhysicsVolumeChange( PhysicsVolume NewVolume );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event FinishedInterpolation()
{
	bInterpolating = false;
}

event EndedRotation();			// called when rotation completes
event UsedBy( Pawn user ); // called if this Actor was touching a Pawn who pressed Use

#if IG_TRIBES3	// rowan: extended touch for projectiles
event ProjectileTouch( Actor Other, vector TouchLocation, vector TouchNormal );
#endif

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );

#if IG_EFFECTS  //tcohen: hooked for use by effects system
final
#endif
#if IG_TRIBES3 // Ryan: damage is a float       
// glenn: projectileFactor to allow different knockback for projectiles against live characters vs. ragdolls and havok objects
event TakeDamage( float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
#else
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
#endif // IG
{
//#if IG_EFFECTS
//    TakeDamageEffectsHook();
//#endif

    PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

//final function TakeDamageEffectsHook()
//{
//#if IG_EFFECTS
//    if (IsA('Pawn') && Pawn(self).Health <= 0)
//        TriggerEffectEvent('DamagedDead');
//    else
//        TriggerEffectEvent('Damaged');
//#endif
//}

#if IG_TRIBES3 // Ryan: damage is a float       glenn: add optional projectile factor [0,1]
event PostTakeDamage( float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor);
#else
event PostTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);
#endif // IG

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
//
native(277) final function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent,
	optional out material Material
);

#if IG_TRIBES3		// marc: optimized version of trace for AI
native(553) final function Actor AITrace
(
	vector          TraceEnd,
	optional vector TraceStart,
	optional vector Extent
);
#endif

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop );

//=============================================================================
// Sound functions.

/* Play a sound effect.
*/
native(264) final function int PlaySound
(
	sound				Sound,
#if !IG_EFFECTS
	optional ESoundSlot Slot,
#endif
	optional float		Volume,
	optional bool		bNoOverride,
#if IG_EFFECTS
	optional float		InnerRadius,
	optional float		OuterRadius,
#else
	optional float		Radius,
#endif
	optional float		Pitch,
#if IG_EFFECTS
	optional int       	Flags,
    optional float      FadeInTime,
#endif
	optional bool		        Attenuate,
    optional float              AISoundRadius,
    optional Name               SoundCategory
);

/* play a sound effect, but don't propagate to a remote owner
 (he is playing the sound clientside)
 */
native simulated final function PlayOwnedSound
(
	sound				Sound,
#if !IG_EFFECTS
	optional ESoundSlot Slot,
#endif
	optional float		Volume,
	optional bool		bNoOverride,
#if IG_EFFECTS
	optional float		InnerRadius,
	optional float		OuterRadius,
#else
	optional float		Radius,
#endif
	optional float		Pitch,
#if IG_EFFECTS
    optional int        Flags,
    optional float      FadeInTime,
#endif
	optional bool		Attenuate
);

native simulated event DemoPlaySound
(
	sound				Sound,
#if !IG_EFFECTS
	optional ESoundSlot Slot,
#endif
	optional float		Volume,
	optional bool		bNoOverride,
#if IG_EFFECTS
	optional float		InnerRadius,
	optional float		OuterRadius,
#else
	optional float		Radius,
#endif
	optional float		Pitch,
#if IG_EFFECTS
        optional int		Flags,
        optional float      FadeInTime,
#endif
	optional bool		Attenuate
);

/* Get a sound duration.
*/
native final function float GetSoundDuration( sound Sound );

#if IG_TRIBES3	// rowan: need this extra control over sounds for mojo
native final function InterruptSound(sound Sound);
native final function PauseSound(sound Sound);
native final function ResumeSound(sound Sound);
final function PlayLoopedSound
(
	sound				Sound,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		InnerRadius,
	optional float		OuterRadius,
	optional float		Pitch,
	optional int       	Flags,
	optional bool		        Attenuate,
    optional float              AISoundRadius,
    optional Name               SoundCategory
)
{
	PlaySound(Sound, Volume, bNoOverride, InnerRadius, OuterRadius, Pitch, 2 | Flags, 0, Attenuate, AISoundRadius, SoundCategory);
}

// Paul: added PlayStream forthe purposes of playing 
// streamed sounds from the GUI
native simulated final function PlayStream
(
	String				StreamPath,
	optional float		Volume,
	optional float		InnerRadius,
	optional float		OuterRadius,
	optional float		Pitch,
	optional int        Flags,
	optional float      FadeInTime
 );

#endif

//=============================================================================
// Force Feedback.
// jdf ---
native(566) final function PlayFeedbackEffect( String EffectName );
native(567) final function StopFeedbackEffect( optional String EffectName ); // Pass no parameter or "" to stop all
native(568) final function bool ForceFeedbackSupported( optional bool Enable );
// --- jdf

//=============================================================================
// AI functions.

/* Inform other creatures that you've made a noise
 they might hear (they are sent a HearNoise message)
 Senders of MakeNoise should have an instigator if they are not pawns.
*/
native(512) final function MakeNoise( float Loudness );

/* PlayerCanSeeMe returns true if any player (server) or the local player (standalone
or client) has a line of sight to actor's location.
*/
native(532) final function bool PlayerCanSeeMe();

native final function vector SuggestFallVelocity(vector Destination, vector Start, float MaxZ, float MaxXYSpeed);
 
//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
static native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native final function bool GetCacheEntry( int Num, out string GUID, out string Filename );
native final function bool MoveCacheEntry( string GUID, optional string NewFilename );  

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

/* AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow
*/
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* DynamicActors() only iterates through the non-static actors on the list (still relatively slow, bu
 much better than AllActors).  This should be used in most cases and replaces AllActors in most of 
 Epic's game code. 
*/
native(313) final iterator function DynamicActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* ChildActors() returns all actors owned by this actor.  Slow like AllActors()
*/
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );

/* BasedActors() returns all actors based on the current actor (slow, like AllActors)
*/
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );

/* TouchingActors() returns all actors touching the current actor (fast)
*/
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );

/* TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
*/
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );

/* RadiusActors() returns all actors within a give radius.  Slow like AllActors().  Use CollidingActors() or VisibleCollidingActors() instead if desired actor types are visible
(not bHidden) and in the collision hash (bCollideActors is true)
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* VisibleActors() returns all visible actors within a radius.  Slow like AllActors().  Use VisibleCollidingActors() instead if desired actor types are 
in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );

/* VisibleCollidingActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash
*/
#if IG_SHARED // tcohen: Can iterate over VisibleCollidingActors that implement an Interface.
native(312) final iterator function VisibleCollidingActors ( class<object> BaseClass, out object Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden
#if IG_TRIBES3 // Ryan: added optional box text
															, optional bool bUseBoxCheck, optional Actor checkActor, optional bool bIgnoreStatic
#endif // IG
															);
#else
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );
#endif

/* CollidingActors() returns colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() for reasonably small radii since it uses the collision hash
*/
native(321) final iterator function CollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

//=============================================================================
// Color functions
native(549) static final operator(20) color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

/* RenderOverlays()
called by player's hud to request drawing of actor specific overlays onto canvas
*/
function RenderOverlays(Canvas Canvas);


//=============================================================================
// Scripted Texture Support

// RenderTexture
// Called when this actor is expected to render into the texture
event RenderTexture(ScriptedTexture Tex);
#if IG_EXTERNAL_CAMERAS
// Called to notify this class that the scripted texture is being rendered, client has a chance to modify revision in this call to
// receive a RenderTexture call when it's time.
event PreScriptedTextureRendered(ScriptedTexture Tex);
#endif

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
#if !IG_TRIBES3 // dbeswick: This method is too unreliable for our game. We need to move this to SpawnActor native code.
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.BaseMutator.CheckRelevance(Self) )
		Destroy();
#endif
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Core.Object OptionalObject )
{
	Level.Game.BroadcastLocalized( self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Called immediately after gameplay begins.
//
simulated event PostBeginPlay()
{
#if IG_EFFECTS
    //Please Note:
    //Actors that are spawned at zero, and whose real location are calculated later
    //  (eg. immediately attached to something else, like attached visual effects,)
    //  should TriggerEffectEvent('Spawned') after their location is set, or they
    //  are attached to their host.
    if (bNeedLifetimeEffectEvents && Location != vect(0,0,0))
    {
        TriggerEffectEvent('Spawned');
        TriggerEffectEvent('Alive');
    }
#endif
}

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay();

#if IG_SHARED // karl: called after savegame is loaded
event PostLoadGame();
#endif

simulated event UpdatePrecacheRenderData()
{
	local int i;
	for ( i=0; i<Skins.Length; i++ )
		Level.AddPrecacheMaterial(Skins[i]);

	if ( (DrawType == DT_StaticMesh) && !bStatic && !bNoDelete )
		Level.AddPrecacheStaticMesh(StaticMesh);

	if ( DrawType == DT_Mesh && Mesh != None)
		Level.AddPrecacheMesh(Mesh);
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Actor directHitActor, optional Vector directHitDirection )
{
	local actor victim;
#if IG_TRIBES3 // Alex:
	local array<Actor> hurtRadiusFamilyMembers;
	local int index;
	local bool found;
#else
	local float falloff;
	local float Distance;
	local vector position;
	local vector direction;
#endif
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	
	foreach VisibleCollidingActors(class 'Actor', victim, DamageRadius, HitLocation, true, true, self, true)
	{
		if ((victim != self) && (Victim.Role==ROLE_Authority))
		{
#if IG_TRIBES3 // Alex:

			// Do not apply damage to hurt radius family members. Instead cache the closest member of each family and apply damage after.
			if (victim.getHurtRadiusParent() != None)
			{
				found = false;
				for (index = 0; index < hurtRadiusFamilyMembers.length; ++index)
				{
					if (hurtRadiusFamilyMembers[index].getHurtRadiusParent() == victim.getHurtRadiusParent())
					{
						// replace existing one with this one if closer
						if (VSizeSquared(HitLocation - victim.unifiedGetPosition()) <
								VSizeSquared(HitLocation - hurtRadiusFamilyMembers[index].unifiedGetPosition()))
						{
							hurtRadiusFamilyMembers[index] = victim;
						}
						found = true;
						break;
					}
				}

				if (!found)
				{
					// new family so add it
					hurtRadiusFamilyMembers.length = 1 + hurtRadiusFamilyMembers.length;
					hurtRadiusFamilyMembers[hurtRadiusFamilyMembers.length - 1] = victim;
				}
				continue;
			}

			processHurtRadiusVictim(victim, DamageAmount, DamageRadius, DamageType, Momentum, HitLocation, directHitActor, directHitDirection);
#else
		    if (victim!=directHitActor)
			{
		        // indirect hit: radial splash damage and knockback
		        
		        //log("indirect hit");
    		
                position = victim.unifiedGetPosition();         // glenn: works for havok objects (somewhat)
    		
			    direction = position - HitLocation;
			    Distance = FMax(1,VSize(direction));
			    direction = direction / Distance; 

                // note: simple radial falloff to object center
                // long thin objects may need some special attention here!

                // what you really want is to find the nearest feature on the object
                // and use that distance for the falloff - not the distance to the object center!

			    falloff = 1.0 - FClamp((Distance - victim.CollisionRadius) / DamageRadius, 0.0, 1.0);

			    Victim.TakeDamage
				(
				    falloff * DamageAmount,
					Instigator, 
				    HitLocation,                            // glenn: note changed here because upright cylinder approximation makes *very* little sense for non-characters
				    (falloff * Momentum * direction),
					DamageType
				);
			} 
		    else
		{
		        // direct hit: full damage and knockback in specified direction
		        
		        //log("direct hit: "$directHitActor.name$" -> "$directHitDirection);
		        
			    Victim.TakeDamage
			(
				    DamageAmount,
				Instigator, 
				    HitLocation,
				    directHitDirection * Momentum,
				DamageType
			);
		} 
#endif
		}
	}

#if IG_TRIBES3 // Alex:
	// apply damage to hurt radius families
	for (index = 0; index < hurtRadiusFamilyMembers.length; ++index)
	{
		processHurtRadiusVictim(hurtRadiusFamilyMembers[index], DamageAmount, DamageRadius, DamageType, Momentum, HitLocation, directHitActor, directHitDirection);
	}
#endif

	bHurtEntry = false;
}

#if IG_TRIBES3 // Alex:
simulated final function processHurtRadiusVictim(Actor victim, float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Actor directHitActor, optional Vector directHitDirection)
{
	local vector position;
	local vector direction;
	local float Distance;
	local float falloff;

	if (victim!=directHitActor)
	{
		// indirect hit: radial splash damage and knockback

		//log("indirect hit");

		// if in a hurt radius family use position of parent for damage calculations
		if (victim.getHurtRadiusParent() == None)
			position = victim.unifiedGetPosition();         // glenn: works for havok objects (somewhat)
		else
			position = victim.getHurtRadiusParent().unifiedGetPosition();  

		direction = position - HitLocation;
		Distance = FMax(1,VSize(direction));
		direction = direction / Distance; 

		// note: simple radial falloff to object center
		// long thin objects may need some special attention here!

		// what you really want is to find the nearest feature on the object
		// and use that distance for the falloff - not the distance to the object center!

		falloff = 1.0 - FClamp((Distance - victim.getReceiveDamageRadius()) / DamageRadius, 0.0, 1.0);

		Victim.TakeDamage
			(
			falloff * DamageAmount,
			Instigator, 
			HitLocation,                            // glenn: note changed here because upright cylinder approximation makes *very* little sense for non-characters
			(falloff * Momentum * direction),
			DamageType
			);
	} 
	else
	{
		// direct hit: full damage and knockback in specified direction

		//log("direct hit: "$directHitActor.name$" -> "$directHitDirection);

		Victim.TakeDamage
			(
			DamageAmount,
			Instigator, 
			HitLocation,
			directHitDirection * Momentum,
			DamageType
			);
	} 
}

// Return parent of hurt radius family. None implies this Actor is not a part of a hurt radius family.
simulated function Actor getHurtRadiusParent()
{
	return None;
}

simulated function float getReceiveDamageRadius()
{
	return CollisionRadius;
}

#endif

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

// Returns the string representation of the name of an object without the package
// prefixes.
//
#if IG_TRIBES3 // Alex:
simulated function String GetItemName( string FullName )
#else
function String GetItemName( string FullName )
#endif
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// Returns the human readable string representation of an object.
//
simulated function String GetHumanReadableName()
{
	return GetItemName(string(class));
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

#if IG_TRIBES3 // Paul: added accessor to get RadarInfo from a sensed actor
simulated function class GetRadarInfoClass()
{
	return class(DynamicLoadObject("Gameplay.RadarInfo", class'Class'));
}
#endif

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
}

// Get localized message string associated with this actor
#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos
static function string GetLocalString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2
	)
#else
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
#endif
{
	return "";
}

function MatchStarting(); // called when gameplay actually starts
function SetGRI(GameReplicationInfo GRI);

#if IG_TRIBES3 // Alex:
simulated function String GetDebugName()
#else
function String GetDebugName()
#endif
{
	return GetItemName(string(self));
}

/* DisplayDebug()
list important actor variable on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
the ShowDebug exec is used
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;
	local int i;
	local Actor A;
	local name anim;
	local float frame,rate;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);
	T = GetDebugName();
	if ( bDeleteMe )
		T = T$" DELETED (bDeleteMe == true)";

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,255);

	if ( Level.NetMode != NM_Standalone )
	{
		// networking attributes
		T = "ROLE ";
		Switch(Role)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		T = T$" REMOTE ROLE ";
		Switch(RemoteRole)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		if ( bTearOff )
			T = T$" Tear Off";
		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	T = "Physics ";

	Switch(Physics)
	{
		case PHYS_None: T=T$"None"; break;
		case PHYS_Walking: T=T$"Walking"; break;
		case PHYS_Falling: T=T$"Falling"; break;
		case PHYS_Swimming: T=T$"Swimming"; break;
		case PHYS_Flying: T=T$"Flying"; break;
		case PHYS_Rotating: T=T$"Rotating"; break;
		case PHYS_Projectile: T=T$"Projectile"; break;
		case PHYS_Interpolating: T=T$"Interpolating"; break;
		case PHYS_MovingBrush: T=T$"MovingBrush"; break;
		case PHYS_Spider: T=T$"Spider"; break;
		case PHYS_Trailer: T=T$"Trailer"; break;
		case PHYS_Ladder: T=T$"Ladder"; break;
#if IG_TRIBES3_MOVEMENT
		case PHYS_Movement: T=T$"Movement"; break;
#endif
#if IG_SHARED // Alex:
		case PHYS_Havok: T=T$"Havok"; break;
#endif
	}
	T = T$" in physicsvolume "$GetItemName(string(PhysicsVolume))$" on base "$GetItemName(string(Base));
#if IG_TRIBES3 // Alex:
	if (bHardAttach)
		T = T$" (Hard Attach) ";
#endif
	if ( bBounce )
		T = T$" - will bounce";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

#if IG_TRIBES3 // Alex:
	if (bHardAttach)
	{
		Canvas.DrawText("Relative Location: "$RelativeLocation$" Relative Rotation: "$RelativeRotation, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
#endif

	Canvas.DrawText("Location: "$Location$" Rotation "$Rotation, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Velocity: "$Velocity$" Speed "$VSize(Velocity), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Acceleration: "$Acceleration, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 0;
	Canvas.DrawText("Collision Radius "$CollisionRadius$" Height "$CollisionHeight);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Collides with Actors "$bCollideActors$", world "$bCollideWorld$", proj. target "$bProjTarget);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Blocks Actors "$bBlockActors$", players "$bBlockPlayers);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Touching ";
	ForEach TouchingActors(class'Actor', A)
		T = T$GetItemName(string(A))$" ";
	if ( T == "Touching ")
		T = "Touching nothing";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.R = 0;
	T = "Rendered: ";
	Switch(Style)
	{
		case STY_None: T=T; break;
		case STY_Normal: T=T$"Normal"; break;
		case STY_Masked: T=T$"Masked"; break;
		case STY_Translucent: T=T$"Translucent"; break;
		case STY_Modulated: T=T$"Modulated"; break;
		case STY_Alpha: T=T$"Alpha"; break;
	}		

	Switch(DrawType)
	{
		case DT_None: T=T$" None"; break;
		case DT_Sprite: T=T$" Sprite "; break;
		case DT_Mesh: T=T$" Mesh "; break;
		case DT_Brush: T=T$" Brush "; break;
		case DT_RopeSprite: T=T$" RopeSprite "; break;
		case DT_VerticalSprite: T=T$" VerticalSprite "; break;
		case DT_Terraform: T=T$" Terraform "; break;
		case DT_SpriteAnimOnce: T=T$" SpriteAnimOnce "; break;
		case DT_StaticMesh: T=T$" StaticMesh "; break;
	}

	if ( DrawType == DT_Mesh )
	{
		T = T$GetItemName(string(Mesh));
		if ( Skins.Length > 0 )
		{
			T = T$" skins: ";
			for ( i=0; i<Skins.Length; i++ )
			{
				if ( Skins[i] == None )
					break;
				else
					T =T$GetItemName(string(Skins[i]))$", ";
			}
		}

		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		
		// mesh animation
		GetAnimParams(0,anim,frame,rate);
		T = "AnimSequence "$anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
	}
	else if ( (DrawType == DT_Sprite) || (DrawType == DT_SpriteAnimOnce) )
		T = T$Texture;
	else if ( DrawType == DT_Brush )
		T = T$Brush;
		
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 255;	
#if IG_TRIBES3 // david: removed old event system
	Canvas.DrawText("Label: "$Label$" TriggeredBy: "$TriggeredBy$" STATE: "$GetStateName(), false);
#else
	Canvas.DrawText("Tag: "$Tag$" Event: "$Event$" STATE: "$GetStateName(), false);
#endif
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Instigator "$GetItemName(string(Instigator))$" Owner "$GetItemName(string(Owner)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
	Canvas.DrawText("Timer: "$TimerCounter$" LifeSpan "$LifeSpan$" AmbientSound "$AmbientSound);
#else
	Canvas.DrawText("Timer: "$TimerCounter$" LifeSpan "$LifeSpan);
#endif
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// NearSpot() returns true is spot is within collision cylinder
simulated final function bool NearSpot(vector Spot)
{
	local vector Dir;

	Dir = Location - Spot;
	
	if ( Abs(Dir.Z) > CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius );
}

simulated final function bool TouchingActor(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;
	
	if ( Abs(Dir.Z) > CollisionHeight + A.CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius + A.CollisionRadius );
}

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/	
simulated function StartInterpolation()
{
	GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset();

/* 
Trigger an event
*/
event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( EventName == '' )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
    {
#if IG_EFFECTS
        A.PreTrigger(Other, EventInstigator);
#endif
		A.Trigger(Other, EventInstigator);
	}
}

/*
UnTrigger an event
*/
function UnTriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( EventName == '' )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.UnTrigger(Other, EventInstigator);
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;
	
	ForEach TouchingActors(class'Volume',V)
		if ( V == aVolume )
			return true;
	return false;
}
	 
function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamagePerSec > 0) )
			return true;
	return false;
}

function PlayTeleportEffect(bool bOut, bool bSound);

function bool CanSplash()
{
	return false;
}

function vector GetCollisionExtent()
{
	local vector Extent;

	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	return Extent;
}

simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated )
{
	local PlayerController P;
	local bool bResult;
	
	if ( Level.NetMode == NM_DedicatedServer )
		bResult = bForceDedicated;
	else if ( Level.NetMode == NM_Client )
		bResult = true;
	else if ( (Instigator != None) && Instigator.IsHumanControlled() )
		bResult =  true;
	else if ( SpawnLocation == Location )
		bResult = ( Level.TimeSeconds - LastRenderTime < 3 );
	else if ( (Instigator != None) && (Level.TimeSeconds - Instigator.LastRenderTime < 3) )
		bResult = true;
	else
	{	
		P = Level.GetLocalPlayerController();
		if ( P == None )
			bResult = false;
		else 
			bResult = ( (Vector(P.Rotation) Dot (SpawnLocation - P.ViewTarget.Location)) > 0.0 );
	}
	return bResult;
}

#if IG_EFFECTS
// Register for notification that gameplay has started
simulated final function RegisterNotifyGameStarted() { Level.InternalRegisterNotifyGameStarted(self); }
// Callback when gameplay has started
simulated function OnGameStarted();

// Add a context to be considered for the _next_ TriggerEffectEvent().
//
// WARNING: Caller should _always_ TriggerEffectEvent() after adding
//          contexts.  Failure to do so may adversely affect the next
//          call to TriggerEffectEvent().
simulated function AddContextForNextEffectEvent(name Context)
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

    Level.EffectsSystem.AddContextForNextEffectEvent(Context);
}

//returns True iff any effect event responses match the effect event that occurred.
simulated event bool TriggerEffectEvent(
    name EffectEvent,                   // The name of the effect event to trigger.  Should be a verb in past tense, eg. 'Landed'.
    // -- Optional Parameters --        // -- Optional Parameters --
    optional Actor Other,               // The "other" Actor involved in the effect event, if any.
    optional Material TargetMaterial,   // The Material involved in the effect event, eg. the matterial that a 'BulletHit'.
    optional vector HitLocation,        // The location in world-space (if any) at which the effect event occurred.
    optional rotator HitNormal,         // The normal to the involved surface (if any) at the HitLocation.
    optional bool PlayOnOther,          // If true, then any effects played will be associated with Other rather than Self.
    optional bool QueryOnly,            // If true, then don't actually play any effects.
                                        //   _True_ is still returned iff any responses matched the effect event.
                                        //   This can be used to determine if there are any effects associated with a particular effect event,
                                        //   without actually responding to the effect event.
    optional IEffectObserver Observer,  // Optional Observer that gets callbacks when effects are started and stopped.
                                        // Useful when you want to edit an effect dynamically
    optional name ReferenceTag)         // If ReferenceTag is not passed (or is ''), then Other.Tag is used instead 
										//   when matching event triggers to responses.
{
    if( Level.NetMode == NM_DedicatedServer )
        return false;

    if (Level.HasGameStarted() || bTriggerEffectEventsBeforeGameStarts)
    {
		return Level.EffectsSystem.EffectEventTriggered(
                self, 
                EffectEvent, 
                Other, 
                TargetMaterial, 
                HitLocation, 
                HitNormal, 
                false, 
                PlayOnOther, 
                QueryOnly, 
                Observer, 
                ReferenceTag);
    }
    else
    {
        return false;   //we don't want to trigger effect events before the game starts
    }
}


simulated event UnTriggerEffectEvent(name EffectEvent,optional name ReferenceTag)
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

    Level.EffectsSystem.EffectEventTriggered(
            self, EffectEvent,,,,,true,,,,ReferenceTag);  //untriggered
}

//gets called before Trigger()
simulated final function PreTrigger( Actor Other, Pawn EventInstigator )
{
    TriggerEffectEvent('Triggered');
}
#endif // IG_EFFECTS

#if IG_SHARED  //tcohen (by ckline): get a material on a mesh
// Retrieves a reference to the 'active' material at the specified index. First
// the actor is checked for an instance-specific material at the given
// index in the Skins array; if this is not null then it is returned. Next the
// default materials are checked. If there is not valid
// instance-specific or default material at the given Index, then
// None is returned.
// This method handles objects that are DrawType DT_Mesh and DT_StaticMesh, 
// but not other drawtypes.
native final event Material GetCurrentMaterial(optional int Index); //defaults to 0
#endif

#if IG_SCRIPTING // david:
// onMessage
event function onMessage(Message msg);

// registerMessage
// Convenience function
// triggeredByFilter is a comma-separated list of actor labels
function registerMessage(class<Message> messageClass, coerce string triggeredByFilter)
{
    // registerReceiver will not register the receiver if triggeredByFilter is equivalent of NAME_None
    AssertWithDescription(triggeredByFilter != "None" && triggeredByFilter != "", "triggeredByFilter with value of '"$triggeredByFilter$"' was passed by "$Name$" to RegisterMessage("$messageClass$")");
	Level.messageDispatcher.registerReceiver(self, messageClass, triggeredByFilter);
}

// registerClientMessage
// The message could potentially be receieved on both a server and a net client
// (Most messages should have no need to be client-side)
// triggeredByFilter is a comma-separated list of actor labels
simulated function registerClientMessage(class<Message> messageClass, coerce string triggeredByFilter)
{
    // registerReceiver will not register the receiver if triggeredByFilter is equivalent of NAME_None
    AssertWithDescription(triggeredByFilter != "None" && triggeredByFilter != "", "triggeredByFilter with value of '"$triggeredByFilter$"' was passed by "$Name$" to RegisterClientMessage("$messageClass$")");
	Level.messageDispatcher.registerReceiver(self, messageClass, triggeredByFilter);
}

// dispatchMessage
// Convenience function
function dispatchMessage(Message msg)
{
	Level.messageDispatcher.dispatch(self, msg);
}

// clientDispatchMessage
// The message could potentially be dispatched on both a server and a net client
simulated function clientDispatchMessage(Message msg)
{
	Level.messageDispatcher.dispatch(self, msg);
}
#endif // IG_SCRIPTING

#if IG_SHARED // ckline: Used by effects system, but could also be of general use

// OptimizeOut: makes this actor as lightweight and optimal as possible by making sure it's not rendered, or ticked
final function OptimizeOut()
{
	// Hide the actor
    bHidden = true;

    // Make the actor not get ticked
    SetPhysics(PHYS_None);
    bStasis = true;
    
    OnOptimizedOut();
}

// OptimizedIn: returns from an OptimizedOut state, which resets the values back to defaults (Note: maybe they should be backed up from the last optimized out call)
final function OptimizeIn()
{
	// Show the actor.
    bHidden = Default.bHidden;

    // Make the actor receive ticks again
    SetPhysics(Default.Physics);
    bStasis = Default.bStasis;

	// Allow subclasses to hook into this.
    OnOptimizedIn();
}
function OnOptimizedOut();      // Notification we've been optimized out
function OnOptimizedIn();       // Notification we've been optimized in

// Make an actor hidden, and stop it from ticking.
// Note: it is not an error to hide something that is already hidden
final function Hide()
{
	// Hide the actor
    bHidden = true;
}
// Allow subclasses to implement additional functionality when an actor gets a Hide() call
function OnHidden();

// Un-hide an actor that was previously hidden via Hide()
// Note: it is not an error to show something that is not hidden.
final function Show()
{
	// Show the actor.
    bHidden = false;
    OnShown();
}

// Allow subclasses to implement additional functionality when an actor gets a Show() call
function OnShown();

#endif // IG_SHARED

#if IG_TRIBES3_PHYSICS  // physics: ragdoll support code
native final function AnimStopLooping(optional int Channel);
native final function Name GetClosestBone( Vector loc, Vector ray, out float boneDist, optional Name BiasBone, optional float BiasDistance );
#endif

#if IG_TRIBES3_STATICMESH_SOCKETS	// glenn: support for staticmesh sockets
native final event bool getSocket(String name, out Vector position, out Rotator rotation, out Vector scale, optional SocketCoordinates coordinates);
native final event bool checkSocket(String name);
#endif

#if IG_TRIBES3	// rowan: localisation helpers
function string LocalizeMapText(string SectionName, string KeyName)
{
	return static.Localize(SectionName, KeyName, "Localisation\\Maps\\text files\\"$Level.LocalisationFile);
}
#endif

#if IG_TRIBES3_PHYSICS  // Paul: Unified Physics Interface

// Some Actors use an unnatural center of mass in order to achieve a particular physical behavior. This function returns the center of
// mass that would normally be expected of the object and unifiedGetCOMPosition returns the actual center of mass.
simulated event Vector unifiedGetNaturalCOMPosition()
{
	return unifiedGetCOMPosition();
}

// Get Center of Mass
simulated event Vector unifiedGetCOMPosition()
{
    return HavokGetCenterOfMass();      // note: this function correctly falls back to Location for non-havok
}

// Get/Set Position
simulated function Vector unifiedGetPosition()
{
	return Location;
}

simulated function unifiedSetPosition(Vector newPosition)
{
	if(Physics == PHYS_Havok || Physics == PHYS_HavokSkeletal)
	{
		HavokSetPosition(newPosition);
	}
	else if (Physics == PHYS_Falling || Physics == PHYS_None)
	{
		setLocation(newPosition);
	}
}

simulated function unifiedSetRotation(Rotator newRotation)
{
	if(Physics == PHYS_Havok || Physics == PHYS_HavokSkeletal)
	{
		HavokSetRotation(quatFromRotator(newRotation));
	}
	else if (Physics == PHYS_Falling || Physics == PHYS_None)
	{
		setRotation(newRotation);
	}
}

// Be careful with this function. Only used for 0, 0, 0 when originally written.
simulated function unifiedSetAngularVelocity(Rotator newAngularVelocity)
{
	local vector vectorAngularVelocity;

	if(Physics == PHYS_Havok || Physics == PHYS_HavokSkeletal)
	{
		vectorAngularVelocity.X = newAngularVelocity.Roll;
		vectorAngularVelocity.Y = newAngularVelocity.Pitch;
		vectorAngularVelocity.Z = newAngularVelocity.Yaw;
		HavokSetAngularVelocity(vectorAngularVelocity);
	}
	else
	{
		RotationRate = newAngularVelocity;
	}
}

// Get/Set Velocity
simulated function Vector unifiedGetVelocity()
{
	return Velocity;
}

simulated function unifiedSetVelocity(Vector newVelocity)
{
	if(Physics == PHYS_Havok)
	{
		HavokSetLinearVelocity(newVelocity);
	}
	else if(Physics == PHYS_HavokSkeletal)
	{
		HavokSetLinearVelocityAll(newVelocity);
	}
	else if (Physics == PHYS_Falling/* || Physics == PHYS_None*/)
	{
		SetPhysics(PHYS_Falling);
		Velocity = newVelocity;
	}
}

// Get/Set Acceleration
simulated function Vector unifiedGetAcceleration()
{
	return Acceleration;
}

simulated function unifiedSetAcceleration(Vector newAcceleration)
{
	if (Physics == PHYS_Falling/* || Physics == PHYS_None*/)
	{
		SetPhysics(PHYS_Falling);
		Acceleration = newAcceleration;
	}
}

// Get/Set Mass
simulated function float unifiedGetMass()
{
	return Mass;
}

simulated function unifiedSetMass(float newMass)
{
	Mass = newMass;
}

// Add velocity
simulated function unifiedAddVelocity(Vector deltaVelocity)
{
	if(bMovable && !bStatic && (Physics == PHYS_Falling/* || Physics == PHYS_None*/))
	{
		SetPhysics(PHYS_Falling);
		Velocity += deltaVelocity;
	}
}

// Add Impulse
simulated function unifiedAddImpulse(Vector impulse)
{
	// Apply the impulse at the center of mass
	if(Physics == PHYS_Havok || Physics == PHYS_HavokSkeletal)
	{
		HavokImpartCOMImpulse(impulse);
	}
	else if(bMovable && !bStatic && (Physics == PHYS_Falling/* || Physics == PHYS_None*/))
	{
		SetPhysics(PHYS_Falling);
		velocity += impulse / Mass;
	}
}

simulated function unifiedAddImpulseAtPosition(Vector impulse, Vector position)
{
	// apply the impulse at the requested position.
	if(Physics == PHYS_Havok || Physics == PHYS_HavokSkeletal)
	{
		HavokImpartImpulse(impulse, position);
	}
	else if(bMovable && !bStatic && (Physics == PHYS_Falling/* || Physics == PHYS_None*/))
	{
		// Position is ignored
		SetPhysics(PHYS_Falling);
		velocity += impulse / Mass;
	}
}

// Add Force
simulated function unifiedAddForce(Vector force)
{
	if(bMovable && !bStatic && (Physics == PHYS_Falling/* || Physics == PHYS_None*/))
	{
		SetPhysics(PHYS_Falling);
		velocity += force / Mass;
	}
}

simulated function unifiedAddForceAtPosition(Vector force, Vector position)
{
	if(bMovable && !bStatic && (Physics == PHYS_Falling/* || Physics == PHYS_None*/))
	{
		// Position is ignored
		SetPhysics(PHYS_Falling);
		velocity += force / Mass;
	}
}

// Add Torque
simulated function unifiedAddTorque(Vector torque)
{

}

simulated function float unifiedGetGravity()
{
    if (PhysicsVolume!=None)
        return -PhysicsVolume.Gravity.Z * GravityScale;
    else
        return 14.5*80 * GravityScale;
}

#endif // END Unified Physics Interface


#if IG_TRIBES3_ADMIN   // glenn: admin support

native final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native final function string GetUrlOption(string Option);

#endif

#if IG_TRIBES3 // dbeswick: this function is called to determine whether a projectile can hit this actor
simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	return bProjTarget && !bSkipEncroachment;
}
#endif

#if IG_TRIBES3 // dbeswick: needed for turret to block splash
simulated event bool ShouldActorsBlockSplash()
{
	return false;
}
#endif

#if IG_TRIBES3 // speech manager precache
simulated event PrecacheSpeech(SpeechManager Manager);
#endif

defaultproperties
{
     BumpmapLODScale=1.000000
     MaxTraceDistance=5000.000000
     DrawType=DT_Sprite
     bLightingVisibility=True
     bUseDynamicLights=True
     bAcceptsShadowProjectors=True
     bReplicateMovement=True
     bNavigationRelevant=True
     RemoteRole=ROLE_DumbProxy
     Role=ROLE_Authority
     NetUpdateFrequency=100.000000
     NetPriority=1.000000
     maxDifficulty=2
     LODBias=1.000000
     Texture=Texture'Engine_res.S_Actor'
     DrawScale=1.000000
     DrawScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     MaxLights=4
     ScaleGlow=1.000000
     Style=STY_Normal
     bMovable=True
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     bJustTeleported=True
     Mass=100.000000
     GravityScale=1.000000
     MessageClass=Class'LocalMessage'
}
