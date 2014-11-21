class PlayerCharacterController extends Engine.PlayerController
	native
	dependsOn(Rook)
	dependsOn(InventoryStationAccess)
	dependsOn(Character)
	dependsOn(ClientSideCharacter);

import enum EDirectionType from ClientSideCharacter;
import enum EClientPainType from Character;

// Inputs
var input byte
	bObjectives, bZoom, bQuickChat, bDropWeapon, bLoadoutSelection;

var Rook Rook;
var Character Character;

enum EDigitalAxisInput
{
	DAI_Zero,
	DAI_Positive,
	DAI_Negative
};

// Client movement prediction
var Array<SavedMove>	TribesSavedMoves;
var Array<SavedMove>	TribesFreeMoves;
var SavedMove			TribesPendingMove;
var Vector				replayFromStartLocation;
var Vector				replayFromEndLocation;
var float				replayFromAccumulator;
var Vector				replayFromVelocity;
var float				replayFromEnergy;
var Character.MovementState	replayFromMovement;
var int					replicateMoveCalls;
var int					combinedMoves;
var int					correctedMoves;
var int					dualMoves;
var float				ExactPing;
var globalconfig float	TimeMarginSlack;
var float				lastReplicationCallTime;
var bool				bDebugSpeedhack;
var float				SpeedhackLastAppTime;
var float				SpeedhackLastComparison;
var float				SpeedhackComparison;

var string currentHUDClass; // Store the HUD class so that the HUD can be restored when loading a saved game

var int debugLogLevel; // use debugMovementReplication console command

// ClientAdjustPosition replication (event called at end of frame)
struct native ClientAdjustment
{
	var float TimeStamp;
	var float accumulator;
	var float energy;
	var name newState;
	var Character.MovementState movement;
	var Vector StartLoc;
	var Vector EndLoc;
	var Vector NewVel;
};
var ClientAdjustment PendingAdjustment;

// HUD related stuff
var transient TribesHUDManager HUDManager;
var() string spectatorHUDClass;
var() string countdownHUDClass;
var() string gameEndHUDClass;
var() string respawnHUDClass;
var() string vehicleHUDClass;
var() string turretHUDClass;
var() string waitRoundEndHUDClass;
var() string waitGameStartHUDClass;
var() string commandHUDClass;
// Muted players
var Array<String> MutedPlayerList;

// GUI
var() string GUIPackage;
var() string SPEscapeMenuClass;
var() string MPEscapeMenuClass;
var() string MPStatsClass;
var() string MPWeaponStatsClass;
var() string MPGameStatsClass;
var() string MPAdminClass;
var() string HelpScreenClass;
var transient MojoCore.CinematicOverlay CinematicOverlay;

// Sensor system
var SensorListNode detectedFriendlyList;
var SensorListNode detectedEnemyList;
var bool commandHUDVisible;
var float radarZoomScale;

// Client-side scripting info
var transient ClientSideCharacter clientSideChar;
var Array<Actor> RenderedRooks;

var bool	bForcedRespawn;		// whether the player is doing a forced respawn

var() string inventoryStationMenuClass;

// debug hud data

var int animationDebugCounter;
var int movementDebugCounter;

enum AlertnessModeType
{
    AlertnessMode_Default,          // default alertness (combat on fire weapon, degrades over time to alert then neutral)
    AlertnessMode_Combat,           // force combat
    AlertnessMode_Alert,            // force alert
    AlertnessMode_Neutral,          // force neutral
};

var editconst AlertnessModeType alertnessMode;
var float alertnessDecayTime;       // time in seconds to decay from combat to alert, and from alert to neutral

enum GroundMovementModeType
{
    GroundMovementMode_Any,         // walk, run and sprint are allowed (35kph+)
    GroundMovementMode_Sprint,      // natural sprint (25kph)
    GroundMovementMode_Run,         // natural run (15kph)
    GroundMovementMode_Walk,        // natural walk (5kph)
    GroundMovementMode_Stand,       // only stand is allowed (not allowed to move)
};

var GroundMovementModeType groundMovementMode;

// Loadout
var private Loadout			currentLoadout;		// used by GameInfo::RestartPlayer to equip the player

// Radar zooming
var config Array<float> radarZoomScales;
var config int radarZoomIndex;

// Zooming
var config Array<float> zoomedFOVs;
var config Array<float> zoomedMouseScale;
var config Array<float> zoomMagnificationLevels;
var config float zoomSpeed;
var config int zoomLevel;
var float	maxSpectatorZoom;
var float	minSpectatorZoom;

// Chat window sizes
var config Array<int>	ChatWindowSizes;
var config int			ChatWindowSizeIndex;
var config Array<int>	SPChatWindowSizes;
var config int			SPChatWindowSizeIndex;

// invenotry station external camera offset
var config Vector		InvExtCamOffset;

// whether to color hud markers with team colors (alternative is relative)
var config bool			bTeamMarkerColors;

// Hide weapons for fps gain
var config bool bHideFirstPersonWeapon;

// Identification (under crosshair)
var Actor			lastIdentified;
var float			lastIdentifiedDuration;		// how long (in seconds) has crosshair been held over "lastIdentified" 
var Vector			lastIdentifiedHitLocation;	// where the crosshair taytrace hit "lastIdentified"
var private float	m_identifyTime;
var private float	m_identifyFrequency;
var private float	m_identifyRange;
var private float	IdentifyRadius;		// radius from center of screen where identify can occur
// Store the screen res, we do this to make the Idetify work better
var String			ResolutionString;	// current resolution string
var int				ResolutionX;		// current resolution x
var int				ResolutionY;		// current resolution y

// Combat
var Actor lastHurt; // the last actor that we hurt
var class<Weapon> lastWeaponClass; // the last weapon class we had equipped (used for stat tracking)

// Inventory Station
var InventoryStationInteraction inventoryStationInterface;
var InventoryStationAccess inventoryStation;

// Resupply Station
var ResupplyStation currentResupply;

// see comment in clientInventoryStationAccess
var bool inventoryStationWaitingForCharacter;
var InventoryStationAccess inventoryStationWaitingForCharacterInput;

// User input
var bool	bWasUsingDeployable;

// Damage flash
var(PlayerCharacterController) Vector		damageFlashColor		"X=Red, Y=Green, Z=Blue, Values should be quite high (> 900)";
var(PlayerCharacterController) float		damageFlashScale		"Lower values = greater effect";
var(PlayerCharacterController) float		maxFlashThreshold		"The percentage of damage where the maximum flash occurs";
var(PlayerCharacterController) float		minFlashThreshold		"The percentage of damage where the minimum flash occurs";
var(PlayerCharacterController) float		damageFlashMultiplier	"The multiplier is applied to the amount of damage and then added to the flash color";

// Used when the players view is being controlled by a camera (see state CameraControlled)
var PlayerControllerCamera controllingCamera;

// Rounds and spawning
var RoundInfo roundInfo;
var BaseInfo	spawnBase;				// the base at which the player has elected to spawn
var float		respawnDelay;			// current number of seconds before a player is allowed to respawn (started after dying)
var int			livesLeft;				// number of lives the player has (or -1 for infinite lives)
var bool		bWaitingForRoundEnd;	// if the player must wait for the round to end

var bool bUseEnabled;

// Player-specific objectives
var float objectivesUpdateRate;
var ObjectivesList objectives;

// Variables for the prompt window & Useable objects
var UseableObject			CurrentUseableObject;			// (only on server) Object the player will use when triggered
var UseableObject			PromptingUseableObject;			// (only on server) Object the player will see a prompt for (usually the currentUseableObject)
var class<UseableObject>	PromptingObjectClass;			// (replicated to client) Currently focused useable object class
var class<Actor>			PromptingDataClass;				// (replicated to client)
var Vector					PromptingObjectLocation;		// (replicated to client) Location of the currently focused useable object
var byte					PromptingObjectPromptIndex;		// (replicated to client) Index of the prompt to use for this character on the promping object
var bool					PromptingObjectCanBeUsed;		// (replicated to client) Whether the prompting object can be used
var InventoryStationAccess	CurrentUseableInventoryAccess;	// (replicated to client) Inventory station access the user is using
var string					lowPriorityPromptText;			// General prompts that don't rely on useable objects (use localised message class)
var float					lowPriorityPromptTimeout;		// 

var private TalkingHeadCamera	currentTalkingHeadCam;
var private Script				talkingHeadScript;			// The script that showed the current talking head

var bool	bCountDown;
var float	countDown;

var int		ChatCount;
var float	LastValidChatTime;
var float	ChatSpamMutedTime;
var config int MaxMessageTextLength;		// max length of any chat message text
var config bool ChatSpamGuardEnabled;		// whether the chat spam guard is enabled
var config int ChatSpamMaxMessages;			// max messages in threshold time
var config float ChatSpamThresholdTime;		// threshold time
var config float ChatSpamMutePeriod;		// mute period after exceeding limits

// cahced key bindings - updateCachedKeyBindings
var string vehiclePositionSwitchOneKey;
var string vehiclePositionSwitchTwoKey;
var string vehiclePositionSwitchThreeKey;
var string gameStatsKey;
var string myStatsKey;
var string adminKey;
var string respawnKey;

struct native DynamicTurretRotationProcessingOutput
{
	var rotator worldSpaceNoRollRotation;
	var rotator vehicleSpaceRotation;
};

// Skins
// Skin preferences
// On the client, this serves as a record of which skin the player likes to use for a given team and role and is stored in the config.
// On the server, this info is requested from the client and stored on a per-client basis.
var private Array<CustomPlayerLoadout.SkinPreferenceMapping> skinPreferences;

// PlayerCamera
var bool bJustRespawned;		// whether the player had respawed this frame
var class<Armor> armorClassBeforeInventoryAccess;
var PlayerCamera camera;
var Name introCameraOldState;
var Script introCameraScript;			// The script that showed the current talking head

var bool bOldBehindView;

// Points of interest to be displayed on the command map
var Array<PointOfInterest> PointsOfInterest;

replication
{
	// Client to server
	unreliable if( Role<ROLE_Authority )
		TribesServerMove, TribesStateServerMove, TribesShortServerMove, TribesDualServerMove, QuickChat, TeamQuickChat, serverTurretMove, tribesServerDrive,
		serverVehicleTurretMove;

	reliable if( Role<ROLE_Authority )
		serverNextWeapon, serverPrevWeapon, serverSelectWeapon, setIsFemale, switchTeam, spectate, serverFinishInventoryStationAccess, serverToggleReady,
		serverActivatePack, serverEquipDeployable, serverEquipCarryable, serverEquipFallbackWeapon, serverSpectate,
		debugSwitchSpawnBase,
		serverFinishEquippingPreRestart,
		serverCommandHUDShown, serverCommandHUDHidden,
		serverSetRadarZoomScale,
		serverSetSkin,
		ServerRestartPlayerInVehicle, ServerRestartPlayerAtBase, ServerKillPlayer, ServerPlayerSelectRespawn, ServerCancelRespawn,
		serverSwitchVehiclePosition,
		serverFinishQuickInventoryStationAccess,
		serverInventoryStationSwitchVehiclePosition,
		serverDebugMovementReplication,
		serverSetForcedRespawn,
		ServerViewNextMPObject, ServerViewNextSpectatorStart;

	// Server to client
	unreliable if( Role == ROLE_Authority )
		TribesLongClientAdjustPosition, TribesAdjustState, TribesShortClientAdjustPositionEx, TribesClientAdjustPositionEx,
		clientAdjustTurretPosition, respawnDelay; 

	reliable if (Role == ROLE_Authority)
		clientSetCheats, clientTribesSetHUD,
		clientInventoryStationAccess, clientInventoryStationWait,
		clientTerminateInventoryStationAccess,
		clientGetSkinPreference,
		clientSetSkinPreference,
		clientWeaponUseEnergy,
		clientLoadSkinClasses,
		roundInfo,
		ClientDamagedFrom,
		PromptingObjectClass, PromptingObjectLocation, PromptingObjectPromptIndex, PromptingObjectCanBeUsed, CurrentUseableInventoryAccess, PromptingDataClass,
		PlayPainSound;

	reliable if (Role == ROLE_Authority && bNetOwner)
		objectives, detectedFriendlyList, detectedEnemyList;
}

// Speedhack checking
native final function bool CheckSpeedHack(float DeltaTime);

function GameSaved()
{
	TeamMessage(None, Localize("Prompts", "MSG_Prompt_gamesaved", "Localisation\\GUI\\Prompts"), 'Announcer');
}

simulated function updateCachedKeyBindings()
{
	// dedicated server has no interaction master
	if(Level.NetMode == NM_DedicatedServer)
		return;

	vehiclePositionSwitchOneKey = player.interactionMaster.getKeyFromBinding("switchVehiclePosition 1", true);
	vehiclePositionSwitchTwoKey = player.interactionMaster.getKeyFromBinding("switchVehiclePosition 2", true);
	vehiclePositionSwitchThreeKey = player.interactionMaster.getKeyFromBinding("switchVehiclePosition 3", true);

	gameStatsKey = player.interactionMaster.getKeyFromBinding("ShowGameStats", true);
	myStatsKey = player.interactionMaster.getKeyFromBinding("ShowMyStats", true);
	adminKey = player.interactionMaster.getKeyFromBinding("ShowAdmin", true);
	respawnKey = player.interactionMaster.getKeyFromBinding("Respawn true", true);
	//Log("UpdatedCachedKeyBindings, "$gameStatsKey@myStatsKey@adminKey);
}

simulated function Destroyed()
{
	local int i;

	DestroySensorLists();
	
	if(HUDManager != None)
		HUDManager.Cleanup();

	PointsOfInterest.Length = 0;

	for (i = 0; i < TribesFreeMoves.Length; i++)
	{
		TribesFreeMoves[i].Delete();
	}
	for (i = 0; i < TribesSavedMoves.Length; i++)
	{
		TribesSavedMoves[i].Delete();
	}
    
	super.Destroyed();
}

// Paul: Overriding ClientGotoState to not call it if we are already in the requested state
function ClientGotoState(name NewState, optional name NewLabel)
{
	// only goto the state if we are not already in it or the new label is specified
	if(! IsInState(NewState) || NewLabel != '')
		GotoState(NewState,NewLabel);
}

function serverSetForcedRespawn(bool bForced)
{
	bForcedRespawn = bForced;
}

simulated function SetForcedRespawn(bool bForced)
{
	//Log("SetForcedRespawn called with "$bForced);
	bForcedRespawn = bForced;
	serverSetForcedRespawn(bForced);
}

// Sensor system functions /////////////////////////////////////////////////////////////////////////

function DestroySensorLists()
{
	DestroySensorList(detectedFriendlyList);
	DestroySensorList(detectedEnemyList);

	detectedFriendlyList = None;
	detectedEnemyList = None;
}

function DestroySensorList(SensorListNode head)
{
	local SensorListNode sln;
	local SensorListNode dsln;

	sln = head;

	while (sln != None)
	{
		dsln = sln;
		sln = dsln.next;
		dsln.Destroy();
	}
}

function int calculateHeight(float rookZ)
{
	local Vector pos;
	local float height;
	local float heightDiff;

	if (Pawn != None)
	{
		pos = Pawn.Location;
		height = Pawn.CollisionHeight * 2;
	}
	else
	{
		pos = Location;
		height = 140;
	}

	heightDiff = rookZ - pos.Z;

	if (heightDiff > height)
		return 1;
	else if (heightDiff < -height)
		return -1;

	return 0;
}

function bool isRookRelevant(Rook sensedRook)
{
	local Vector pos;
	local float radarRadius;
	local float distanceSquared2D;

	if (commandHUDVisible)
		return true;

	if (Pawn != None)
		pos = Pawn.Location;
	else
		pos = Location;

	radarRadius = (radarZoomScale * Level.GetMapTextureExtent()) / 2.0;

	distanceSquared2D = VSizeSquared2D(pos - sensedRook.Location);

	return distanceSquared2D <= (radarRadius * radarRadius);
}

function addDetectedFriendly(Rook detectedFriendly)
{
	local SensorListNode sln;

	if (Pawn != detectedFriendly && isRookRelevant(detectedFriendly))
	{
		sln = new class'SensorListNode'(self, detectedFriendly);

		sln.next = detectedFriendlyList;
		sln.prev = None;

		if (detectedFriendlyList != None)
			detectedFriendlyList.prev = sln;

		detectedFriendlyList = sln;
	}
}

function removeDetectedFriendly(SensorListNode sln)
{
	if (detectedFriendlyList == sln)
		detectedFriendlyList = sln.next;

	sln.detachNode();
	sln.Destroy();
}

function addDetectedEnemy(Rook detectedEnemy)
{
	local SensorListNode sln;

	if (isRookRelevant(detectedEnemy))
	{
		sln = new class'SensorListNode'(self, detectedEnemy);

		sln.next = detectedEnemyList;
		sln.prev = None;

		if (detectedEnemyList != None)
			detectedEnemyList.prev = sln;

		detectedEnemyList = sln;
	}
}

function removeDetectedEnemy(SensorListNode sln)
{
	if (detectedEnemyList == sln)
		detectedEnemyList = sln.next;

	sln.detachNode();
	sln.Destroy();
}

// End sensor system functions /////////////////////////////////////////////////////////////////////

// Skin functions //////////////////////////////////////////////////////////////////////////////////

//
// Loads the skin classes on the client
//
function clientLoadSkinClasses()
{
	class'SkinInfo'.static.loadAllSkins(Level);
}

// Asks the client for its skin preference
// NOTE: this should not be used until the main menu "default mesh" gui is implemented.
// Please set userSkinName in TribesReplicationInfo
function clientGetSkinPreference(Mesh mesh)
{
	serverSetSkin(getSkinPreference(mesh), mesh);
}

// Tells the client to set a skin preference
function clientSetSkinPreference(Mesh mesh, String skinPath)
{
	saveSkinPreference(mesh, skinPath);
}

// Sends a player's skin preference to the server
// NOTE: this should not be used until the main menu "default mesh" gui is implemented.
// Please set userSkinName in TribesReplicationInfo
function serverSetSkin(string skinPath, Mesh mesh)
{
	if (GameInfo(Level.Game).allowSkinChanges())
	{
		saveSkinPreference(mesh, skinPath);
		updateCharacterUserSkin();
	}
	else
		LOG("Skin changes are not allowed by the game type");
}

// Updates the PRI with the correct user skin choice for a character
// private, call clientGetSkinPreference
private function updateCharacterUserSkin()
{
	local TribesReplicationInfo tri;

	if (character == None)
		return;

	tri = TribesReplicationInfo(PlayerReplicationInfo);
	if (tri != None)
	{
		tri.userSkinName = getSkinPreference(character.Mesh);
	}
}

// get the player's skin preference for a given team and combat role. Returns the skin path.
function string getSkinPreference(Mesh mesh)
{
	local int idx;
	idx = getSkinPreferenceRecord(mesh);
	if (idx != -1)
	{
		return skinPreferences[idx].skin;
	}

	return "";
}

// save a skin preference for a given team and combat role in the user setting
function saveSkinPreference(Mesh mesh, string skinPath)
{
	local int idx;
	idx = getSkinPreferenceRecord(mesh);
	if (idx == -1)
	{
		addSkinPreferenceRecord(mesh, skinPath);
	}
	else
	{
		skinPreferences[idx].mesh = mesh;
		skinPreferences[idx].skin = skinPath;
	}

	SaveConfig();
}

private function int getSkinPreferenceRecord(Mesh mesh)
{
	local int i;
	for (i = 0; i < skinPreferences.Length; i++)
	{
		if (skinPreferences[i].mesh == mesh)
			return i;
	}

	return -1;
}

private function int addSkinPreferenceRecord(Mesh mesh, string skinPath)
{
	skinPreferences.Length = skinPreferences.Length + 1;
	skinPreferences[skinPreferences.Length - 1].mesh = mesh;
	skinPreferences[skinPreferences.Length - 1].skin = skinPath;

	return skinPreferences.Length - 1;
}

///////////////////////////////////////////////////////////////////////////////
//
// check other TRI for absolute friendliness. Please don't change this
// to use IsFriendly - it must return false if the other team is different
// in any way to this controllers team - even if it is None.
//
function bool IsFriendlyPRI(PlayerReplicationInfo OtherPRI)
{
	// Check for None PRI, or the case where the PRI is not of type TRI. This should not happen,
	// but adding this check avoids the spamming which may occur.
	if(TribesReplicationInfo(OtherPRI) == None || TribesReplicationInfo(PlayerReplicationInfo) == None)
		return false;

	return TribesReplicationInfo(OtherPRI).Team == TribesReplicationInfo(PlayerReplicationInfo).Team;
}

///////////////////////////////////////////////////////////////////////////////
//
// check other actor for friendliness
simulated function bool IsFriendly(Actor Other)
{
	local TribesReplicationInfo TRI;
	local TeamInfo OtherTeam;

	if(Other == None)
		return true;

	if(Other.IsA('TeamInfo'))
		OtherTeam = TeamInfo(Other);
	else if(Other.IsA('Rook'))
		OtherTeam = Rook(Other).team();
	else if(Other.IsA('TribesReplicationInfo'))
		OtherTeam = TribesReplicationInfo(Other).team;
	else if(Other.IsA('PlayerController'))
		OtherTeam = TribesReplicationInfo(PlayerController(Other).PlayerReplicationInfo).team;

	TRI = TribesReplicationInfo(PlayerReplicationInfo);

	if(OtherTeam == None || TRI == None || OtherTeam.IsFriendly(TRI.team))
		return true;

	return false;
}

simulated function TeamInfo GetControllerTeam()
{
	if(TribesReplicationInfo(PlayerReplicationInfo) != None)
		return TribesReplicationInfo(PlayerReplicationInfo).team;

	return None;
}


///////////////////////////////////////////////////////////////////////////////

simulated function clientWeaponUseEnergy(float quantity)
{
	if (Character != None)
		Character.clientWeaponUseEnergy(quantity);
}

// Calculates the rotations required for turret processing. Rotations are stored directly on turret
// (worldSpaceNoRollRotation, worldSpaceRotation, vehicleSpaceRotation).
static native function DynamicTurretRotationProcessingOutput dynamicTurretRotationProcessing(rotator moveRotation,
		rotator mountRotation, float minimumPitch, float maximumPitch, bool yawConstrained,
		optional bool yawPositiveDirection, optional float yawStart, optional float yawRange);

function serverCommandHUDShown()
{
	commandHUDVisible = true;
}

function serverCommandHUDHidden()
{
	commandHUDVisible = false;
}

function serverSetRadarZoomScale(float newRadarZoomScale)
{
	radarZoomScale = newRadarZoomScale;
}

//******************************************
// Useable object & prompt methods


///////////////////////////////////////////////////////////////////////////////
//
// Udpates the current useable object by cycling over all the touching UseableObjects
// and checking for the highest priority one. Called every tick to ensure that the 
// current Object does not get lost.
//
// The CurrentUseableObject is the object that the user will actually use when they
// press their use key. The PromptingUseableObject is the object which is presenting
// a prompt to the user. This will usually be the same as the CurrentUseableObject, but
// in situations where the user is getting a prompt from an object which they CANNOT use, 
// we do not want the 
//
function UpdateUseableObject()
{
	local UseableObject TestUseableObject;

	// don't do this on clients
	if(Role < ROLE_Authority)
		return;

	// Always set these to none before we process. It's important that we 
	// don't have one of these on the client if the user is not standing in one
	CurrentUseableInventoryAccess = None;
	CurrentUseableObject = None;
	PromptingUseableObject = None;
	PromptingObjectClass = None;
	PromptingObjectCanBeUsed = false;
	PromptingDataClass = None;

	if(Character(Pawn) != None)
	{
		// check for a Useable object first, and get the highest priority one
		ForEach Pawn.TouchingActors(class'UseableObject', TestUseableObject)
		{
			if(TestUseableObject.CanBeUsedBy(Pawn) && TestUseableObject.getCorrespondingInventoryStation() != None)
				CurrentUseableInventoryAccess = TestUseableObject.getCorrespondingInventoryStation();

			// Handle use always objects
			if(TestUseableObject.bAlwaysUse)
			{
				if(TestUseableObject.CanBeUsedBy(Pawn))
				{
					CurrentUseableObject = TestUseableObject;
					PromptingUseableObject = TestUseableObject;
					break;
				}
				else
				{
					if (!TestUseableObject.bDoNotPromptWhenNotUseable)
						PromptingUseableObject = TestUseableObject;
				}
			}

			if(TestUseableObject.CanBeUsedBy(Pawn) && (CurrentUseableObject == None || CurrentUseableObject.priority < TestUseableObject.priority))
				CurrentUseableObject = TestUseableObject;
			if((PromptingUseableObject == None || PromptingUseableObject.priority < TestUseableObject.priority) && !TestUseableObject.bDoNotPromptWhenNotUseable)
				PromptingUseableObject = TestUseableObject;
		}
	}

	// Set the current prompting object data. These values will be replicated to the client.
	if(PromptingUseableObject != None)
	{
		PromptingObjectClass = PromptingUseableObject.class;
		PromptingObjectLocation = PromptingUseableObject.GetUseablePoint();
		PromptingObjectPromptIndex = PromptingUseableObject.GetPromptIndex(Character(Pawn));
		PromptingObjectCanBeUsed = (PromptingUseableObject == CurrentUseableObject);
		PromptingDataClass = PromptingUseableObject.GetPromptDataClass();
	}
}

///////////////////////////////////////////////////////////////////////////////
//
// Returns whether the PlayerController can currently use a quick inventory
// loadout menu. This is called when the user presses the key bound to quick 
// loadouts, in order to establish whether they can actually use one before 
// showing the menu.
//
simulated function bool CanUseQuickInventoryLoadoutMenu()
{
	if( ! IsSinglePlayer() &&
		bLoadoutSelection == 1 && 
		CurrentUseableInventoryAccess != None)
			return true;
	
	return false;
}

// End useable Object methods
//
//******************************************


//
// analogueToDigital
//
simulated static function EDigitalAxisInput analogueToDigital(float analogueInput, float maxValue)
{
	if (analogueInput > maxValue * 0.5)
		return DAI_Positive;
	if (analogueInput < -maxValue * 0.5)
		return DAI_Negative;
	return DAI_Zero;
}

//
// digitalToAnalogue
//
simulated static function float digitalToAnalogue(EDigitalAxisInput digitalInput, float maxValue)
{
	if (digitalInput == DAI_Positive)
		return maxValue;
	if (digitalInput == DAI_Negative)
		return -maxValue;
	return 0;
}

//
// Resets the input values for the controller. Should be called whenever the player is doing 
// something which may result in input sticking (eg: opening an inventory station interface
// while firing or skiing results in that input being stuck on when the player exits)
//
simulated function ResetInputState()
{
	// this list may not be complete, add any values
	// which might need to be reset if they are missing
	bSki = 0;
	bJetpack = 0;
	bJump = 0;
	bFire = 0;
	bAltFire = 0;
	bQuickChat = 0;
	bLoadoutSelection = 0;
	if(character != None && character.motor != None)
	{
		character.motor.releaseFire();
		character.motor.releaseAltFire();
	}
}

function showTalkingHead(TalkingHeadCamera thc, Script requestingScript)
{
	if (currentTalkingHeadCam != None)
		currentTalkingHeadCam.stop();

	currentTalkingHeadCam = thc;
	talkingHeadScript = requestingScript;

	currentTalkingHeadCam.play();
	clientSideChar.aHeadIsTalking = true;
}

function hideTalkingHead(Script requestingScript)
{
	if (talkingHeadScript != None && talkingHeadScript != requestingScript)
		return;

	if (currentTalkingHeadCam != None)
		currentTalkingHeadCam.stop();

	currentTalkingHeadCam = None;

	clientSideChar.aHeadIsTalking = false;
}

// updateCasts
// Do your derived-class casts here, or they will not update properly on network clients
simulated function updateCasts()
{
	Rook = Rook(Pawn);

	if (Rook != None)
		Character = Rook.getControllingCharacter();
}

function playerDisconnected()
{
	if (character != None)
		character.Died(None, class'DamageType', Vect(0,0,0));
}

// glenn: test

/*
exec function stop()
{
    character.unifiedSetVelocity(vect(0,0,0));
}
*/

exec function Fire(optional float F)
{
	// code is here instead of TribesPlayerWalking to support flying state
	if (character != None && character.motor != None)
	{
		character.motor.bFirePressed = true;
		character.motor.fire();
	}
}

// called when fire is released
exec function releaseFire(optional float F)
{
	// code is here instead of TribesPlayerWalking to support flying state
	if (character != None && character.motor != None)
	{
		character.motor.bFirePressed = false;
		character.motor.releaseFire();
	}
}

exec function AltFire(optional float F)
{
	// code is here instead of TribesPlayerWalking to support flying state
	if (character != None && character.motor != None)
	{
		character.motor.altFire();
	}
}

exec function releaseAltFire(optional float F)
{
	// code is here instead of TribesPlayerWalking to support flying state
	if (character != None && character.motor != None)
	{
		character.motor.releaseAltFire();
	}
}

// called when jetpack is pressed
exec function Jetpack( optional float F )
{
}

function SelectTeleport( )
{
	clientGotoState('PlayerTeleport');
	GotoState('PlayerTeleport');
}

exec function Respawn( optional bool bAllowExit )
{
	local bool bAllowManualRespawn;

	if (IsSinglePlayer())
		bAllowManualRespawn = GameInfo(Level.Game).allowManualRespawn();
	else
		bAllowManualRespawn = true;

	if (bAllowManualRespawn)
	{
		updateCachedKeyBindings();
		SetForcedRespawn(bAllowExit);
		bForcedRespawn = true;
		ServerPlayerSelectRespawn();
	}
}

simulated function initHUDObjects()
{
	if(HUDManager == None)
	{
		HUDManager = new class'TribesHUDManager';
		HUDManager.Initialise(self);
	}

	if(clientSideChar == None)
		clientSideChar = new class'ClientSideCharacter';
}

// PostBeginPlay
simulated function PostBeginPlay()
{
	camera = new class'PlayerCamera';
	camera.pcc = self;

	if( Level.GetLocalPlayerController() == self )
		initHUDObjects();

	// cache localplayercontroller (as it's often used in native code)
	Level.GetLocalPlayerController();

	Super.PostBeginPlay();

	// Spawn objective list on server
	if (Level.NetMode != NM_CLIENT)
		objectives = spawn(class'ObjectivesList');

	updateCasts();
	
	alertnessMode = AlertnessMode_Default;

    EnterCombat();
}

function PostLoadGame()
{
	super.PostLoadGame();
	initHUDObjects();
}

// PostNetReceive
simulated function PostNetReceive()
{
	super.PostNetReceive();

	updateCasts();

	// see comment in clientInventoryStationAccess
	if (inventoryStationWaitingForCharacter && Character(Pawn) != None)
	{
		inventoryStationWaitingForCharacter = false;
		clientInventoryStationAccess(inventoryStationWaitingForCharacterInput);
	}
}

function bool HasCurrentLoadout()
{
	return (currentLoadout != None);
}

// newLoadout
function newLoadout(Loadout l)
{
	if(currentLoadout == l)
		return;

	if (currentLoadout != None)
		currentLoadout = None;

	currentLoadout = l;
}

// equipCharacter
function equipCharacter()
{
	if (currentLoadout != None && Character(Pawn) != None)
		currentLoadout.equip(Character(Pawn));
}

function ClientRestart(Pawn aPawn, Name currentState)
{
	bJustRespawned = true;

	//Log("Parent ClientRestart() called for "$self$" and pawn "$aPawn);
	super.ClientRestart(aPawn, currentState);

	updateCasts();
}

// Possess
function Possess(Pawn aPawn)
{
	if ( PlayerReplicationInfo.bOnlySpectator )
		return;

	Pawn = aPawn;

	updateCasts();

	if (rook != None)
	{
		// need this to prevent incorrect stasis on player rooks
		rook.AI_LOD_Level = AILOD_ALWAYS_ON;

		if (!rook.isAlive())
			GotoState('Dead');
		else if (rook.playerControllerState != '')
			GotoState(rook.playerControllerState);
	}
	
	// REMOVE
	//Level.Game.SetGameSpeed(0.01);

	ResetSpeedhack();

	Super.Possess(aPawn);

	serverSetRadarZoomScale(radarZoomScales[radarZoomIndex]);
}

// UnPossess
function UnPossess()
{
	Super.UnPossess();

	updateCasts();
}

// PawnDied
function PawnDied(Pawn P)
{
	Super.PawnDied(P);

	updateCasts();
}

simulated function Vector calculateScreenPosition(class objectClass, Vector objectPos)
{
	local Vector screenPos;

	screenPos = objectPos;
	if(ClassIsChildOf(objectClass, class'RadarInfo'))
		screenPos += class<RadarInfo>(objectClass).default.markerOffset;

	if(! WorldToScreen(screenPos))
	{
		// The vector is behind us
		screenPos.x = -1;
		screenPos.y = -1;
	}

	return screenPos;
}

//
// Converts a vector from world space to screen space, but ensures
// that the world position of the vector is actually in front of 
// the player first, and returns false if it wasnt.
//
simulated function bool WorldToScreen(out Vector inputVector)
{
	local Vector xAxis, yAxis, zAxis;
	local Interaction interaction;

	if(Player.LocalInteractions.Length <= 0)
		return false;

	interaction = Player.LocalInteractions[Player.LocalInteractions.Length - 1];
	if(interaction != None && Rook != None)
	{
		// dont add anything behind us
		GetAxes(Normalize(Rotation), xAxis, yAxis, zAxis);
		if(((Rook.location - inputVector) Dot xAxis) < 0)
		{
			// its in front of us, now we can determine its height
			// and convert it to screen space
			inputVector = interaction.WorldToScreen(inputVector);
			return true;
		}
	}

	inputVector.X = -1;
	inputVector.Y = -1;
	return false;
}

// ClientSetHUD
// Stores the HUD class so that the HUD can be restored when loading a saved game
function ClientSetHUD(class<HUD> newHUDType, optional class<Scoreboard> newScoringType)
{
	LOG("ClientSetHUD deprecated: use clientTribesSetHUD");
}

function clientTribesSetHUD(string newHUDType)
{
	// just call the SetHUD() in the hudmanager and it handles the rest
	if(HUDManager != None)
		HUDManager.SetHUD(newHUDType);

}

// checkAutoWeaponSwitch
// Check if a weapon needs to be automatically equipped or switched for any reason
function checkAutoWeaponSwitch()
{
	if (character == None || character.motor == None)
		return;

	// check if the deployable we were using has been depleted
	if (bWasUsingDeployable && (character.deployable == None || character.deployable.bDeployed))
	{
		serverSelectWeapon(character.motor.lastUsedWeapon);
	}
	else if (character.motor.switchToWeapon == None && character.weapon == None && character.deployable == None && character.motor.switchToDeployable == None)
	{
		// player should always be holding something
		NextWeapon();

		// If the player still has no weapon go to the fallback weapon
		if (character.motor.switchToWeapon == None && character.weapon == None)
			serverEquipFallbackWeapon();
	}

	bWasUsingDeployable = character.deployable != None && !character.deployable.bDeployed;
}

function serverEquipFallbackWeapon()
{
	character.equipFallbackWeapon();
}

// DisplayDebug
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local int i;

	//Super.DisplayDebug(Canvas, YL, YPos);

	YPos += YL;
	YPos += YL;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Playercontroller state: "$GetStateName());
	YPos += YL;

	for (i = max(0, TribesSavedMoves.Length - 10); i < TribesSavedMoves.Length; i++)
	{
		Canvas.DrawText(""$TribesSavedMoves[i].Timestamp$":  "$TribesSavedMoves[i].SavedLocation);
	}
}

// voting console commands

exec function kickvote(string name)
{
    if (voteReplicationInfo!=None)
    {
        log("sending kick vote: "$name);
        voteReplicationInfo.SubmitKickVote(name);
    }
    else
        log("none voteReplicationInfo!");
}

exec function mapvote(string map, string gametype)
{
    if (voteReplicationInfo!=None)
    {
        log("sending map vote: "$map$" ["$gametype$"]");
        voteReplicationInfo.SubmitMapVote(map, gametype);
    }
    else
        log("none voteReplicationInfo!");
}

exec function adminvote(string name)
{
    if (voteReplicationInfo!=None)
    {
        log("sending admin vote: "$name);
        voteReplicationInfo.SubmitAdminVote(name);
    }
    else
        log("none voteReplicationInfo!");
}

exec function teamdamagevote(bool vote)
{
    if (voteReplicationInfo!=None)
    {
        log("sending team damage vote: "$vote);
        voteReplicationInfo.SubmitTeamDamageVote(vote);
    }
    else
        log("none voteReplicationInfo!");
}

exec function tournamentvote(bool vote)
{
    if (voteReplicationInfo!=None)
    {
        log("sending tournament vote: "$vote);
        voteReplicationInfo.SubmitTournamentVote(vote);
    }
    else
        log("none voteReplicationInfo!");
}

// force movement configuration (global)

exec function Movement(String name)
{
	character.prefixMovement(name);
	updatePhysicsConfiguration();
}

// force movement configuration (global)

exec function Force(String name)
{
	character.forceMovement(name);
	updatePhysicsConfiguration();
}

// debug hud functionality

exec function toggleDebugHUD()
{
	HUDManager.showDebugHUD(!inDebugHud());
}

function setDebugHud(bool visible)
{
    HUDManager.showDebugHUD(visible);
}

function bool inDebugHud()
{
    return HUDManager.IsInState('ShowingDebugHUD');
}

exec function debugAnimation()
{
    animationDebug();
}

exec function animationDebug()
{
	animationDebugCounter ++;
	
	if (animationDebugCounter>2)
	    animationDebugCounter = 0;
	    
	if (animationDebugCounter>0 && movementDebugCounter>0)
	{
	    character.debugMovement(false);
	    movementDebugCounter = 0;
	}

	ClientSetBehindView(animationDebugCounter>0);
	
    setDebugHud(animationDebugCounter>0 || movementDebugCounter>0);
}

exec function debugMovement()
{
    movementDebugCounter ++;        
    
    if (movementDebugCounter>2)
        movementDebugCounter = 0;

    character.debugMovement(movementDebugCounter>0);

    if (movementDebugCounter>0)
    {
        animationDebugCounter = 0;
    	ClientSetBehindView(false);
    }
	
    setDebugHud(animationDebugCounter>0 || movementDebugCounter>0);
}

exec function movementDebug()
{
    debugMovement();
}


// animation testing functions

exec function playAnimation(string animation)
{
    character.playAnimation(animation);
}

exec function loopAnimation(string animation)
{
    character.loopAnimation(animation);
}

exec function stopAnimation()
{
    character.stopAnimation();
}

exec function isPlayingAnimation()
{
    log(character.isPlayingAnimation());
}

exec function isLoopingAnimation()
{
    log(character.isLoopingAnimation());
}

exec function playFireAnimation(optional string weapon)
{
    character.playFireAnimation(weapon);
}

exec function playUpperBodyAnimation(string animation)
{
    character.playUpperBodyAnimation(animation);
}

exec function loopUpperBodyAnimation(string animation)
{
    character.loopUpperBodyAnimation(animation);
}

exec function stopUpperBodyAnimation()
{
    character.stopUpperBodyAnimation();
}

exec function isPlayingUpperBodyAnimation()
{
    log(character.isPlayingUpperBodyAnimation());
}

exec function isLoopingUpperBodyAnimation()
{
    log(character.isLoopingUpperBodyAnimation());
}

exec function loopArmAnimation(string animation)
{
    character.loopArmAnimation(animation);
}

exec function stopArmAnimation()
{
    character.stopArmAnimation();
}

exec function isLoopingArmAnimation()
{
    log(character.isLoopingArmAnimation());
}

exec function playFlinchAnimation()
{
    character.playFlinchAnimation();
}

exec function setAlertness(string mode)
{
	if (mode=="default")
		alertnessMode = AlertnessMode_Default;
	else if (mode=="combat")
	{
		alertnessMode = AlertnessMode_Combat;
		character.alertness = Alertness_Combat;
	}
	else if (mode=="alert")
	{
		alertnessMode = AlertnessMode_Alert;
		character.alertness = Alertness_Alert;
	}
	else if (mode=="neutral")
	{
		alertnessMode = AlertnessMode_Neutral;
		character.alertness = Alertness_Neutral;
	}
}

exec function setGroundMovement(string mode)
{
	if (mode~="stand")
		groundMovementMode = GroundMovementMode_Stand;
	else if (mode~="walk")
		groundMovementMode = GroundMovementMode_Walk;
	else if (mode~="run")
		groundMovementMode = GroundMovementMode_Run;
	else if (mode~="sprint")
		groundMovementMode = GroundMovementMode_Sprint;
	else
		groundMovementMode = GroundMovementMode_Any;
}

exec function updatePhysicsConfiguration()
{
	level.UpdateMovementConfiguration();
}

// effect logging
exec function effectLog()
{
	character.effectLogging = !character.effectLogging;
}

// whack off
exec function whack()
{
    character.addImpulse(Vect(250000, 0, 0) >> Rotation);
}

// UI
function bool isSinglePlayer()
{
	return Level.Game != None && SinglePlayerGameInfo(Level.Game) != None;
}

exec function bool SkipOpeningCutscene()
{
	return false;
}

exec function showEscapeMenu()
{
	// try to escape any playing cutscenes
	
	if (!Level.EscapeCutscene() && !SkipOpeningCutscene())
	{
		// force updateing of hotkeys, just incase they 
		// change their controls in the escape menu
		if (isSinglePlayer())
			Player.GUIController.OpenMenu(GUIPackage $ "." $ SPEscapeMenuClass, SPEscapeMenuClass);
		else
		// It's an MP game.
			Player.GUIController.OpenMenu(GUIPackage $ "." $ MPEscapeMenuClass, MPEscapeMenuClass);
	}
}

function toggleEscapePanel(string menuClass)
{
	local GUIController gc;

	gc = GUIController(Player.GUIController);

	if (!isSinglePlayer())
	{
		updateCachedKeyBindings();
		//Log("Comparing "$gc.ActivePage.Class.Name$" to "$Name(MPEscapeMenuClass));
		if (gc.ActivePage != None)
			Player.GUIController.CloseMenu();
		else
			Player.GUIController.OpenMenu(GUIPackage $ "." $ MPEscapeMenuClass, MPEscapeMenuClass, menuClass);
	}
}

exec function showMyStats()
{
	toggleEscapePanel(MPStatsClass);
}

exec function showWeaponStats()
{
	toggleEscapePanel(MPWeaponStatsClass);
}

exec function showGameStats()
{
	toggleEscapePanel(MPGameStatsClass);
}

exec function showAdmin()
{
	toggleEscapePanel(MPAdminClass);
}

// Character Movement state.
// This is the state that an active moving player is in while in PHYS_Movement.

simulated state CharacterMovement
{
	ignores SeePlayer, HearNoise, Bump;

	exec function Fire( optional float F )
	{
		// freeze player during cutscenes
		if (isInCutscene())
			return;
		Global.Fire(F);
	}

	exec function AltFire(optional float F)
	{
		// freeze player during cutscenes
		if (isInCutscene())
			return;
		Global.AltFire(F);
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		return false;
	}

	exec function DropWeapon()
	{
		if (character != None)
		{
			character.dropWeapon();
		}
	}

	///
	/// ServerUse()
	///
	/// Called when the user presses the use button. Overriden here because we
	/// want to ensure that we only use the objects of type 'UseableObject' when 
	/// it has the higher priority.
	/// 
	function ServerUse()
	{
		if ( Level.Pauser == PlayerReplicationInfo )
		{
			SetPause(false);
			return;
		}

		if (Pawn==None)
			return;

		// if we have a useable object, then Use it & return
		if(currentUseableObject != None)
		{
			currentUseableObject.UsedBy(Pawn);
			return;
		}
		else if(character.potentialEquipment != None && !character.potentialEquipment.bDeleteMe)
		{
			character.switchEquipment();
			return;
		}	
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Log("WARNING: PlayerCharacterController.CharacterMovement.ProcessMove has been deprecated");
	}

	function TribesProcessMove(float forward, float strafe, float jump, float ski, float thrust)
	{
		if (Character.motor != None)
			Character.motor.moveCharacter(forward, strafe, jump, ski, thrust, GroundMovementLevels(groundMovementMode));
	}

	function PlayerMove(float DeltaTime)
	{
		local vector x,y,z;
		local Rotator ViewRotation;
		local float incYaw, incPitch;
		local float jump, ski, thrust;

		// Had problem where client would not change to PlayerUsingInventoryStation when using Buggy. They would occasionally be in the
		// Buggy (PHYS_None) yet still be in this state. By adding the following code the server shall send down state updates meaning
		// that the client is guaranteed to eventually go to PlayerUsingInventoryStation.
		if (character.Physics == PHYS_None && Role < ROLE_Authority)
			TribesStateServerMove(Level.TimeSeconds);

		if (character == None || character.Physics != PHYS_Movement)
			return;

		// freeze player during cutscenes
		if (isInCutscene())
		{
			releaseFire();
			TribesProcessMove(0, 0, 0, 0, 0);
			return;
		}

		GetAxes(Rotation,x,y,z);

		Pawn.CheckBob(DeltaTime, y);

		ViewRotation = character.motor.getViewRotation();
		incYaw = 32.0 * DeltaTime * aTurn;
		incPitch = 32.0 * DeltaTime * aLookUp;
		if (character.isZoomed())
		{
			incYaw *= zoomedMouseScale[zoomLevel];
			incPitch *= zoomedMouseScale[zoomLevel];
		}

		ViewRotation.Yaw += incYaw;
		ViewRotation.Pitch += incPitch;

		character.motor.setMoveRotation(ViewRotation);
		character.motor.setViewRotation(ViewRotation);

		// zoom
		if (character.motor != None)
			character.motor.setZoomed(bZoom != 0);

		if (Role < ROLE_Authority)
		{
			TribesReplicateMove(aForward / 24000, aStrafe / 24000, bSki == 1 && character != None && !character.bDisableSkiing,
					bJetpack == 1 && character != None && !character.bDisableJetting, bJump == 1);
		}
		else
		{
			if (bJump>0)
    			jump = 1.0;
	   		else
			    jump = 0.0;
	
			if (bSki>0 && character != None && !character.bDisableSkiing)
				ski = 1.0;
			else
				ski = 0.0;

			if (bJetpack>0 && character != None && !character.bDisableJetting)
				thrust = 1.0;
			else
				thrust = 0.0;

			TribesProcessMove(aForward / 24000, aStrafe / 24000, jump, ski, thrust);
		}
	}

	function BeginState()
	{
		CleanOutSavedMoves();

		PlayerReplicationInfo.bWaitingPlayer = false;
		
		ResetSpeedhack();

		//if(Role == ROLE_Authority)
		//	log("Server: Player put in CharacterMovement with pawn "$Pawn);
		//else
		//	log("Client: Player put in CharacterMovement with pawn "$Pawn);
	}

	function EndState()
	{
		GroundPitch = 0;

		if (Character != None && Character.motor != None)
			Character.motor.moveCharacter();

		FOVAngle = DefaultFOV;
	}

	// client + listen-server
	function PlayerTick(float Delta)
	{
		if (bJustRespawned && character.bZoomOutOnSpawn)
		{
			camera.firstToThirdTransition(0.1, 0.5, 0.5);
		}
		
		if (armorClassBeforeInventoryAccess != character.armorClass && !bBehindView)
		{
			armorClassBeforeInventoryAccess = character.armorClass;
			
			if (!bJustRespawned && !camera.isTransitioning())
				camera.firstToThirdTransition(0.1, 0.5, 0.5);
		}

		Global.PlayerTick(Delta);

        if (bZoom!=0)
            EnterCombat();
	    
		ProcessZoom(Delta, character);

		// MJ:  This shouldn't be necessary...it was causing players to unpredictably go to PlayerRespawn state
		//      Leaving it here in case it turns out it was necessary.
		// go to spectator mode when pawn is destroyed
		// if pawn is destroyed before bTearOff is checked, nothing takes the player controller to the dying state
		//if (Level.NetMode != NM_Client && bIsPlayer && Pawn == None)
		//{
		//	GotoState(GameInfo(Level.Game).playerPawnDestroyedState());
		//	ClientGotoState(GameInfo(Level.Game).playerPawnDestroyedState());
		//}
	}

	// server-side only (clients use PlayerTick)
	function Tick(float Delta)
	{
		Global.Tick(Delta);
		checkAutoWeaponSwitch();

		UpdateUseableObject();

		// had a problem with characters being invisible and invulnerable - added this code to address the problem after it occurred
		if (Pawn != None && Pawn.Physics == PHYS_Movement && (Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer))
		{
			if (Pawn.DrawType == DT_None)
			{
				warn(Pawn @ "controlled by" @ self @ "had draw type none despite being in the normal movement state");
				Pawn.setDrawType(DT_Mesh);
			}
			if (Pawn.bHidden)
			{
				warn(Pawn @ "controlled by" @ self @ "was bHidden despite being in the normal movement state");
				Pawn.bHidden = false;
			}
			if (character != None && character.bHiddenVehicleOccupant)
			{
				warn(character @ "controlled by" @ self @ "was bHiddenVehicleOccupant despite being in the normal movement state");
				character.bHiddenVehicleOccupant = false;
			}
		}
	}

	function ServerMove
		(
		float TimeStamp, 
		vector InAccel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus, 
		bool NewbDoubleJump,
		EDoubleClickDir DoubleClickMove, 
		byte ClientRoll, 
		int View,
		bool NewbJetpack,
		optional byte OldTimeDelta,
		optional int OldAccel
		)
	{
		// do nothing, occurs when character spawns on server and client continues to send spectator moves
	}

Begin:
	// this fixes a network crash
	// because of packetloss, it's possible for the state to be changed to CharacterMovement before the controller's 
	// 'Pawn' variable is received, potentially placing non-character objects in PHYS_Movement... fusion doesn't like that
    while (Character(Pawn) == None)
		Sleep(0);
	Pawn.SetPhysics(PHYS_Movement);

	updateCasts();

	clientTribesSetHUD(character.hudType);
	
	character.wake();
	
	character.resetMovementAnimations();
}

// PlayerTick
event PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);

	if (lowPriorityPromptTimeout > 0)
		lowPriorityPromptTimeout -= DeltaTime;
	
	// duplicated in Tick for a reason
	camera.update(DeltaTime);

	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);

	Rook = Rook(Pawn);
	Character = Character(Pawn);

	doIdentify(DeltaTime);

	if (Pawn != None && Pawn.controller != None)
		level.AI_Setup.doPlayerRelatedAIProcessing(DeltaTime, Pawn);

	if(HUDManager != None && Level.GetLocalPlayerController() == self )
		HUDManager.Update();

	if (bCountDown)
	{
		if (countDown > 0.0)
		{
			countDown -= DeltaTime;

			if (countDown <= 0.0)
			{
				Level.Game.dispatchMessage(new class'MessageCountDownExpired');
				countDown = 0.0;
			}
		}
	}

	if(HUDManager != None)
		HUDManager.UpdateHUDData();

	// clear this array now, because we should be done with it.
	RenderedRooks.remove(0, RenderedRooks.Length);

	bJustRespawned = false;
}


//
// GetIdentify
// Return the actor data used for identifying a given actor, if any
//
simulated function Actor GetIdentify()
{
	if( (Character(lastIdentified) != None && Character(lastIdentified).isAlive()) ||
		(lastIdentified != None && lastIdentified.IsA('SkelRookSatelliteDish') ) ||	// Super hack: the sat dishes for sp showed no health
		(BaseDevice(lastIdentified) != None) ||
		(Vehicle(lastIdentified) != None) ||
		(AccessTerminal(lastIdentified) != None) ||
		(MPActor(lastIdentified) != None))
			return lastIdentified;
	
	return None;
}

function UpdateScreenRes()
{
	local String CurrentRes;
	local int i;

	CurrentRes = ConsoleCommand("GETCURRENTRES");
	if(CurrentRes != ResolutionString)
	{
		ResolutionString = CurrentRes;
		i = InStr( ResolutionString, "x" );
		if( i > 0 )
		{
			ResolutionX = int( Left ( ResolutionString, i )  );
			ResolutionY = int( Mid( ResolutionString, i+1 ) );
		}
	}
}

// doIdentify
simulated function doIdentify(float delta)
{
	local Vector startTrace, hitNormal, endTrace, ScreenPos, ScreenCenter;
	local Actor hitTest, hit;
	local float traceRange, ActorRadiusDistance, ShortestHitDistance, CurrentHitDistance;
	local int i;

	if(Pawn == None)
		return;

	m_identifyTime += delta;

	if (m_identifyTime > m_identifyFrequency)
	{
		// Closest one yet: check it can be hit with a line check
		// extend trace range while zoomed
		traceRange = m_identifyRange;
		if (bZoom != 0)
			traceRange *= zoomLevel + 2;

		startTrace = Pawn.Location + Pawn.EyePosition();
		endTrace = startTrace + Vector(rotation) * traceRange;
		hit = Pawn.Trace(lastIdentifiedHitLocation, hitNormal, endTrace, startTrace, true); 

		// init shortest hit to some massive value
		ShortestHitDistance = 9999999999.0;
		if(hit != None)
			ShortestHitDistance = VSize(hit.Location - Location);

		// this ensures the resolution is set
		UpdateScreenRes();
		// make a vector to represent the center of the screen
		ScreenCenter.X = ResolutionX * 0.5;
		ScreenCenter.Y = ResolutionY * 0.5;
		ScreenCenter.Z = 0;

		for(i = 0; i < RenderedRooks.Length; ++i)
		{
			ScreenPos = RenderedRooks[i].Location;
			if(WorldToScreen(ScreenPos))
			{
				// The Actor is in front of the player, check if they are in the zone
				ScreenPos.Z = 0;
				ActorRadiusDistance = VSize2D(ScreenCenter - ScreenPos);

				if(ActorRadiusDistance < IdentifyRadius)
				{
					CurrentHitDistance = VSize(RenderedRooks[i].Location - Pawn.Location);
					// in the zone, see if its close than the last one
					if(CurrentHitDistance < ShortestHitDistance)
					{
						// Closest one yet: check it can be hit with a line check
						hitTest = Pawn.Trace(lastIdentifiedHitLocation, hitNormal, RenderedRooks[i].Location, Pawn.Location + Pawn.EyePosition(), true); 
						if(hitTest == RenderedRooks[i])
						{
							if(hitTest.IsA('InventoryStationPlatform'))
								hit = hitTest.Base;
							else
								hit = hitTest;
							ShortestHitDistance = CurrentHitDistance;
						}
					}
				}
			}
		}

		UpdateCasts();

		// dont register our own stuff
		if(hit == Pawn || hit == self || hit == character)
			hit = None;

		// update the duration this was displayed unchanged
		if ( hit == lastIdentified )
		{
			lastIdentifiedDuration += m_identifyTime;
		}
		else
		{
			lastIdentified = hit;
			lastIdentifiedDuration = 0;
		}

		m_identifyTime = 0;
	}
}

// checkForFireButton
function checkForFireButton()
{
}

// AddCheats
// spawn the cheat manager
function AddCheats()
{
	if (CheatManager==None && Level.Game!=None)
		CheatManager = new(self)GameInfo(Level.Game).CheatClass;
}

function clientSetCheats(class<CheatManager> c)
{
	if ( CheatManager == None )
		CheatManager = new(self)c;
}

// Networking functions /////////////////////////////////////////////////////////////////////////////////////////////////////
// TribesGetFreeMove
// Returns a free move from the free move store, or allocates a new move
function SavedMove TribesGetFreeMove()
{
	local SavedMove s;

	if ( TribesFreeMoves.Length == 0 )
	{
        // don't allow more than 100 saved moves
        if ( TribesSavedMoves.Length > 100 )
		{
			TribesFreeMoves = TribesSavedMoves;
			
			while (TribesSavedMoves.Length > 0)
			{
				TribesSavedMoves[0].Clear();
				PopSavedMove();
			}
		}
		else
		{
			return new class'SavedMove';
		}
	}

	s = TribesFreeMoves[0];
	PopFreeMove();
	return s;
}


// PopFreeMove
function PopFreeMove()
{
	TribesFreeMoves.Remove(0, 1);
}

// AppendFreeMove
function AppendFreeMove(SavedMove m)
{
	TribesFreeMoves[TribesFreeMoves.Length] = m;
}

// PopSavedMove
function PopSavedMove()
{
	TribesSavedMoves.Remove(0, 1);
}

// AppendSavedMove
function AppendSavedMove(SavedMove m)
{
	TribesSavedMoves[TribesSavedMoves.Length] = m;
}

// CleanOutSavedMoves
function CleanOutSavedMoves()
{
	super.CleanOutSavedMoves();

	// clean out saved moves
	while ( TribesSavedMoves.Length > 0 )
	{
		TribesSavedMoves[0].Delete();
		PopSavedMove();
	}
	if ( TribesPendingMove != None )
	{
		TribesPendingMove.Delete();
		TribesPendingMove = None;
	}
}

// TribesReplicateMove
function TribesReplicateMove(float forward, float strafe, bool ski, bool thrust, bool jump)
{
	local int i;
	local SavedMove NewMove, ImportantMove;
	local float NetMoveDelta;
	local byte ImportantTimeDelta;
	local int ImportantData;
	local vector MoveLoc;
	local float DeltaTime;

	if (bDemoOwner)
		return;

	// if first move, server will have no previous timestamp to form delta, so send Level.TimeSeconds to use as delta and don't move
	if ( lastReplicationCallTime == 0 )
	{
		if (debugLogLevel > 0)
			LOG("CLIENT FIRST MOVE!");
		lastReplicationCallTime = Level.TimeSeconds;
		TribesShortServerMove(Level.TimeSeconds, Vect(0,0,0), 0);
		return;
	}

	DeltaTime = FMin(MaxResponseTime, Level.TimeSeconds - lastReplicationCallTime);
	lastReplicationCallTime = Level.TimeSeconds;

	// find the most recent important move
	if ( TribesSavedMoves.Length > 0 )
	{
		for (i = TribesSavedMoves.Length - 1; i >= 0; i--)
		{
			// find most recent important move to send redundantly
			if ( TribesSavedMoves[i].isImportant(Rotation, thrust, jump, ski, forward, strafe) )
			{
				ImportantMove = TribesSavedMoves[i];
				break;
			}
		}
	}

    // Get a SavedMove actor to store the movement in.
	NewMove = TribesGetFreeMove();
	if ( NewMove == None )
		return;

	if (bDebugSpeedhack)
		NewMove.SetMoveFor(Level.TimeSeconds * 2, self, DeltaTime, forward, strafe);
	else
		NewMove.SetMoveFor(Level.TimeSeconds, self, DeltaTime, forward, strafe);

	// Simulate the movement locally.
    TribesMoveAutonomous(NewMove.Delta, Rotation, forward, strafe, ski, thrust, jump);
    NewMove.PostUpdate(self);

	// if the last move was held, see if that move and the current move could be combined
	if ( TribesPendingMove != None )
	{
		if (NewMove.canCombine(Pawn, TribesPendingMove))
		{
			combinedMoves++;	
			NewMove.combine(TribesPendingMove);

			TribesPendingMove.Clear();
			AppendFreeMove(TribesPendingMove);
			TribesPendingMove = None;
		}
	}

	// stats
	replicateMoveCalls++;

    // Decide whether to hold off on move
	if (TribesPendingMove == None)
	{
		if ( (Player.CurrentNetSpeed > 10000) && (GameReplicationInfo != None) && (GameReplicationInfo.PRIArray.Length <= 10) )
			NetMoveDelta = 0;	// full rate
		else
			NetMoveDelta = FMax(0.0222,2 * Level.MoveRepSize/Player.CurrentNetSpeed);

		if ( Level.TimeSeconds - ClientUpdateTime < NetMoveDelta )
		{
			TribesPendingMove = NewMove;
			return;
		}
	}

	ClientUpdateTime = Level.TimeSeconds;

	// check if there's an important move that we should compress and send redundantly
    if ( ImportantMove != None )
    {
        ImportantMove.encodeImportantData(Level.TimeSeconds, ImportantData, ImportantTimeDelta);
		//ImportantMove.debugEncoding(ImportantData, ImportantTimeDelta);
    }

	// get the physics object's current position
	if (character!=None && character.movementObject!=None)
		MoveLoc = character.movementObject.getEndPosition();
	else if (Pawn!=None)
		MoveLoc = pawn.Location;
	else
		MoveLoc = Location;

	if (debugLogLevel > 1)
		log(character.movementObject.getEndPosition());

	// Send the movement to the server
	CallServerMove(MoveLoc, NewMove, ImportantTimeDelta, ImportantData);
	/*(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))*/
}

function CallServerMove
(
	Vector ClientLoc,
	SavedMove NewMove,
    optional byte CompressedImportantTimeDelta,
	optional int ImportantMoveData
)
{
	local bool bCombine;
	local EDigitalAxisInput digitalForward, digitalStrafe, pendingForward, pendingStrafe;
	local byte buttonInput;

	digitalForward = analogueToDigital(NewMove.forward, 1);
	digitalStrafe = analogueToDigital(NewMove.strafe, 1);

	// TribesPendingMove will be a move held from the frame before NewMove.
	// if TribesPendingMove is not none, it means that it and NewMove could not be combined.
	// if the moves were combined, the result is in NewMove only.

	// if a move was held and not combined...
	if ( TribesPendingMove != None  )
	{
		// TribesPendingMove will always be utilised at this point, so save it
		AppendSavedMove(TribesPendingMove);

		// send two moves simultaneously
		// send short server move if velocity did not change
		if ( !NewMove.changesAcceleration()
			&& TribesPendingMove.StartVelocity == vect(0,0,0)
			&& !TribesPendingMove.changesAcceleration() )
		{
			if ( Pawn == None )
				bCombine = (Velocity == vect(0,0,0));
			else
				bCombine = (Pawn.Velocity == vect(0,0,0));

			if ( bCombine )
			{
				TribesShortServerMove
				(
					NewMove.TimeStamp,
					ClientLoc,
					NewMove.compressedView()
				);

				AppendSavedMove(NewMove);
				// no longer need pending move
				TribesPendingMove = None;
				return;
			}
		}

		// un-combinable moves share a final ClientLoc to save bandwidth
		dualMoves++;

		pendingForward = analogueToDigital(TribesPendingMove.forward, 1);
		pendingStrafe = analogueToDigital(TribesPendingMove.strafe, 1);

		if (TribesPendingMove.bSki)
			buttonInput = 1;
		if (TribesPendingMove.bThrust)
			buttonInput += 2;
		if (TribesPendingMove.bJump)
			buttonInput += 4;
		if (NewMove.bSki)
			buttonInput += 8;
		if (NewMove.bThrust)
			buttonInput += 16;
		if (NewMove.bJump)
			buttonInput += 32;

		if ( CompressedImportantTimeDelta == 0 )
		{
			TribesDualServerMove
			(
				TribesPendingMove.TimeStamp,
				buttonInput,
				pendingForward,
				pendingStrafe,
				TribesPendingMove.compressedView(),
				NewMove.TimeStamp,
				digitalForward,
				digitalStrafe,
				NewMove.compressedView(),
				ClientLoc
			);
		}
		else
		{
			TribesDualServerMove
			(
				TribesPendingMove.TimeStamp,
				buttonInput,
				pendingForward,
				pendingStrafe,
				TribesPendingMove.compressedView(),
				NewMove.TimeStamp,
				digitalForward,
				digitalStrafe,
				NewMove.compressedView(),
				ClientLoc,
				CompressedImportantTimeDelta,
				ImportantMoveData
			);
		}
	}
    else if ( !NewMove.changesAcceleration() )
	{
        TribesShortServerMove
        (
            NewMove.TimeStamp,
            ClientLoc,
			NewMove.compressedView()
        );
	}
    else if ( CompressedImportantTimeDelta == 0 )
	{
        TribesServerMove
        (
            NewMove.TimeStamp,
            ClientLoc,
            NewMove.compressedView(),
            digitalForward,
            digitalStrafe,
			NewMove.bSki,
			NewMove.bThrust,
			NewMove.bJump
        );
	}
    else
	{
        TribesServerMove
        (
            NewMove.TimeStamp,
            ClientLoc,
            NewMove.compressedView(),
            digitalForward,
            digitalStrafe,
			NewMove.bSki,
			NewMove.bThrust,
			NewMove.bJump,
            CompressedImportantTimeDelta,
            ImportantMoveData
        );
	}

	AppendSavedMove(NewMove);

	// no longer need pending move
	TribesPendingMove = None;
}

/* TribesShortServerMove() 
- As with ServerMove but view and client loc only, to save bandwidth. Used when Pawn is stationary.
*/
function TribesShortServerMove
(
	float TimeStamp,
	Vector ClientLoc,
	int View
)
{
	TribesServerMove(TimeStamp, ClientLoc, View, DAI_Zero, DAI_Zero, false, false, false);
}

/* TribesDualServerMove()
- replicated function sent by client to server - contains client movement info for two moves
*/
function TribesDualServerMove
(
	float TimeStamp0,
	byte ButtonInput,
	EDigitalAxisInput forward0,
	EDigitalAxisInput strafe0,
	int View0,
    float TimeStamp,
	EDigitalAxisInput forward,
	EDigitalAxisInput strafe,
    int View,
    vector ClientLoc,
    optional byte CompressedImportantTimeDelta,
    optional int ImportantMoveData
)
{
	local bool bSki0, bThrust0, bJump0, bSki, bThrust, bJump;

	bSki0 = (ButtonInput & 1) != 0;
	bThrust0 = (ButtonInput & 2) != 0;
	bJump0 = (ButtonInput & 4) != 0;
	bSki = (ButtonInput & 8) != 0;
	bThrust = (ButtonInput & 16) != 0;
	bJump = (ButtonInput & 32) != 0;

	TribesServerMove(TimeStamp0,vect(0,0,0),View0,forward0,strafe0,bSki0,bThrust0,bJump0);

	if ( ClientLoc == vect(0,0,0) )
		ClientLoc = vect(0.1,0,0);

	TribesServerMove(TimeStamp,ClientLoc,View,forward,strafe,bSki,bThrust,bJump,CompressedImportantTimeDelta,ImportantMoveData);
}

// TribesStateServerMove
// Call this on the client when you just want to replicate state
function TribesStateServerMove(float Timestamp)
{
	local float DeltaTime;

    DeltaTime = FMin(MaxResponseTime, TimeStamp - CurrentTimeStamp);

	if (Timestamp - CurrentTimestamp > 0.3)
	{
		TribesAdjustState(Timestamp, GetStateName());
		CurrentTimeStamp = TimeStamp;
	}
}

/* TribesServerMove() 
- replicated function sent by client to server - contains client movement info
Passes acceleration in components so it doesn't get rounded.
*/
function TribesServerMove
(
	float TimeStamp, 
	Vector ClientLoc,
	int View,
	EDigitalAxisInput digitalForward,
	EDigitalAxisInput digitalStrafe,
	bool ski,
	bool thrust,
	bool jump,
    optional byte CompressedImportantTimeDelta,
	optional int ImportantMoveData
)
{
	local float DeltaTime, clientErr, ImportantTimeStamp;
	local rotator Rot, ViewRot;
	local vector LocDiff;
	local int ViewPitch, ViewYaw;
	local float analogueForward;
	local float analogueStrafe;
	local float importantStrafe, importantForward, importantDelta;
	local int importantJump, importantSki, importantThrust;
	local int importantPitch, importantYaw;

	analogueForward = digitalToAnalogue(digitalForward, 1);
	analogueStrafe = digitalToAnalogue(digitalStrafe, 1);

	// first move will have no previous timestamp to form delta, so set CurrentTimeStamp to use as delta and that's all
	if ( CurrentTimeStamp == 0 )
	{
		if (debugLogLevel > 0)
			LOG("SERVER FIRST MOVE!");
		CurrentTimeStamp = TimeStamp;
		return;
	}

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
	{
		if (debugLogLevel > 0) LOG("Discarded");
		return;
	}

    // check if an important move was lost
    if ( CompressedImportantTimeDelta != 0 )
    {
		class'SavedMove'.static.decodeImportantData(
			ImportantMoveData, 
			CompressedImportantTimeDelta,
			importantThrust, 
			importantSki, 
			importantJump, 
			importantForward, 
			importantStrafe, 
			importantPitch, 
			importantYaw, 
			importantDelta
			);

		// CurrentTimeStamp is time of last processed packet from client.
		// Timestamp is time of incoming client packet and CurrentTimeStamp + [client delta] should equal Timestamp.
		// If Timestamp - ImportantDelta is greater than CurrentTimeStamp, then a packet must have been lost
		// before the current packet was received. Perform the important movement before the current movement for greater prediction accuracy
		// on lossy connections.
        ImportantTimeStamp = TimeStamp - importantDelta - 0.001;
        if ( CurrentTimeStamp < ImportantTimeStamp - 0.001 )
        {
			ViewRot.Roll = 0;
			ViewRot.Pitch = importantPitch;
			ViewRot.Yaw = importantYaw;

            ImportantTimeStamp = FMin(ImportantTimeStamp, CurrentTimeStamp + MaxResponseTime);
            TribesMoveAutonomous(ImportantTimeStamp - CurrentTimeStamp, ViewRot, importantForward, importantStrafe, importantSki != 0, importantThrust != 0, importantJump != 0);
			CurrentTimeStamp = ImportantTimeStamp;
		}
	}

	// View components
	ViewPitch = class'SavedMove'.static.decodeViewPitch(View);
	ViewYaw = class'SavedMove'.static.decodeViewYaw(View);

	// Save move parameters.
    DeltaTime = FMin(MaxResponseTime, TimeStamp - CurrentTimeStamp);

	if ( Pawn == None )
		TimeMargin = 0;
	else if ( !CheckSpeedHack(DeltaTime) )
	{
		DeltaTime = 0;
		Pawn.unifiedSetVelocity(vect(0,0,0));
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	SetRotation(ViewRot);

	if ( Pawn != None )
	{
		Rot.Yaw = ViewYaw;
		Pawn.SetRotation(Rot);
	}

    // Perform actual movement
	if ( (Level.Pauser == None) && (DeltaTime > 0) )
	{
        TribesMoveAutonomous(DeltaTime, ViewRot, analogueForward, analogueStrafe, ski, thrust, jump);
	}

	if (debugLogLevel > 1)
		log(character.movementObject.getEndPosition());

	// Accumulate movement error.
    if ( ClientLoc == vect(0,0,0) )
		return;		// first part of double servermove
	else if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
	    if (character!=None && character.movementObject!=None)
		    LocDiff = character.movementObject.getEndPosition() - ClientLoc;
		else if (Pawn!=None)
			LocDiff = Pawn.Location - ClientLoc;
		else
			LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		PendingAdjustment.Timestamp = Timestamp;
		PendingAdjustment.newState = GetStateName();

        if (character!=None && Pawn != None)
        {
			PendingAdjustment.energy = character.energy;
			PendingAdjustment.NewVel = character.Velocity;
			PendingAdjustment.movement = character.movement;
			
			if (character.movementObject!=None)
			{
				PendingAdjustment.StartLoc = character.movementObject.getStartPosition();
				PendingAdjustment.EndLoc = character.movementObject.getEndPosition();
				PendingAdjustment.accumulator = character.movementObject.getAccumulator();
			}
		    else
			{
				PendingAdjustment.StartLoc = Location;
				PendingAdjustment.EndLoc = Location;
			}
        }
		else if (Pawn!=None)
		{
			PendingAdjustment.StartLoc = Pawn.Location;
			PendingAdjustment.EndLoc = Pawn.Location;
			PendingAdjustment.NewVel = Pawn.Velocity;
		}
		else
		{
			PendingAdjustment.StartLoc = Location;
			PendingAdjustment.EndLoc = Location;
			PendingAdjustment.NewVel = Velocity;
		}

		if (debugLogLevel > 0 && ClientErr != 10000)
			log("Client Error at "$TimeStamp$" is "$ClientErr$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
	}

	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}	

/* Called on server at end of tick when PendingAdjustment has been set.
Done this way to avoid ever sending more than one ClientAdjustment per server tick.
*/
event SendClientAdjustment()
{
	if ( PendingAdjustment.NewVel == vect(0,0,0) )
	{
		TribesShortClientAdjustPositionEx
		(
			PendingAdjustment.TimeStamp, 
			PendingAdjustment.accumulator, 
			PendingAdjustment.energy, 
			PendingAdjustment.newState,
			PendingAdjustment.movement, 
			PendingAdjustment.StartLoc.X,
			PendingAdjustment.StartLoc.Y,
			PendingAdjustment.StartLoc.Z, 
			PendingAdjustment.EndLoc.X,
			PendingAdjustment.EndLoc.Y,
			PendingAdjustment.EndLoc.Z
		);
	}
	else
	{
		TribesClientAdjustPositionEx
		(
			PendingAdjustment.TimeStamp, 
			PendingAdjustment.accumulator, 
			PendingAdjustment.energy, 
			PendingAdjustment.newState,
			PendingAdjustment.movement, 
			PendingAdjustment.StartLoc.X,
			PendingAdjustment.StartLoc.Y,
			PendingAdjustment.StartLoc.Z, 
			PendingAdjustment.EndLoc.X,
			PendingAdjustment.EndLoc.Y,
			PendingAdjustment.EndLoc.Z,
			PendingAdjustment.NewVel.X,
			PendingAdjustment.NewVel.Y,
			PendingAdjustment.NewVel.Z 
		);
	}

	LastUpdateTime = Level.TimeSeconds;
	PendingAdjustment.TimeStamp = 0;
}

// TribesProcessMove
// Implemented in state
function TribesProcessMove(float forward, float strafe, float jump, float ski, float thrust)
{
}

/* TribesShortClientAdjustPositionEx
bandwidth saving version, when velocity is zeroed, includes state
*/
function TribesShortClientAdjustPositionEx
(
	float TimeStamp, 
	float accumulator,
	float energy,
	name newState, 
	Character.MovementState movement,
	float StartLocX, 
	float StartLocY, 
	float StartLocZ, 
	float EndLocX, 
	float EndLocY, 
	float EndLocZ 
)
{
	TribesLongClientAdjustPosition(TimeStamp,accumulator,energy,newState,movement,StartLocX,StartLocY,StartLocZ,EndLocX,EndLocY,EndLocZ,0,0,0);
}

/* TribesClientAdjustPositionEx
- pass newloc and newvel in components so they don't get rounded, includes state
*/
function TribesClientAdjustPositionEx
(
	float TimeStamp, 
	float accumulator,
	float energy,
	name newState, 
	Character.MovementState movement,
	float StartLocX, 
	float StartLocY, 
	float StartLocZ, 
	float EndLocX, 
	float EndLocY, 
	float EndLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ
)
{
	TribesLongClientAdjustPosition(TimeStamp,accumulator,energy,newState,movement,StartLocX,StartLocY,StartLocZ,EndLocX,EndLocY,EndLocZ,NewVelX,NewVelY,NewVelZ);
}

// CommonClientAdjustPosition
// Code to be shared by all 'adjust position' functions
function bool CommonClientAdjustPosition(float TimeStamp, Name NewState)
{
    local float NewPing;

	// update ping
	if ( (PlayerReplicationInfo != None) && !bDemoOwner )
	{
		NewPing = FMin(1.5, Level.TimeSeconds - TimeStamp);

		if ( ExactPing < 0.004 )
			ExactPing = FMin(0.3,NewPing);
		else
		{
			if ( NewPing > 2 * ExactPing )
				NewPing = FMin(NewPing, 3*ExactPing);
			ExactPing = FMin(0.99, 0.99 * ExactPing + 0.008 * NewPing); // placebo effect
		}
		PlayerReplicationInfo.Ping = 1000.0 * ExactPing;
		PlayerReplicationInfo.bReceivedPing = true;
		if ( Level.TimeSeconds - LastPingUpdate > 4 )
		{
			if ( bDynamicNetSpeed && (OldPing > DynamicPingThreshold * 0.001) && (ExactPing > DynamicPingThreshold * 0.001) )
			{
				if ( Level.MoveRepSize < 64 )
					Level.MoveRepSize += 8;
				else if ( Player.CurrentNetSpeed >= 6000 )
					SetNetSpeed(Player.CurrentNetSpeed - 1000);
				OldPing = 0;
			}
			else
				OldPing = ExactPing;
			LastPingUpdate = Level.TimeSeconds;
			ServerUpdatePing(1000 * ExactPing);
		}
	}
	if ( Pawn != None )
	{
		if ( Pawn.bTearOff )
		{
			Pawn = None;
			if ( !IsInState('GameEnded') && !IsInState('Dead') )
			    GotoState('Dead');
            return false;
		}

		if ( IsInState('PlayerWaitingInventoryStation') && NewState != 'PlayerWaitingInventoryStation' )
			GotoState(NewState);
		if ( IsInState('PlayerTurreting') && NewState != 'PlayerTurreting' )
			GotoState(NewState);
	}
	else 
    {
 	   	if( GetStateName() != newstate )
		{
		    if ( NewState == 'GameEnded' )
			    GotoState(NewState);
			else if ( IsInState('Dead') )
			{
		    	if ( (NewState != 'CharacterMovement') )
		        {
				    GotoState(NewState);
		        }
		        return false;
			}
			else if ( NewState == 'Dead' )
				GotoState(NewState);
			else if ( NewState == 'TribesSpectating' )
				GotoState(NewState);
		}
	}
	if ( CurrentTimeStamp > TimeStamp )
		return false;
	CurrentTimeStamp = TimeStamp;

	return true;
}

// TribesAdjustState
function TribesAdjustState(float Timestamp, Name newState)
{
	if (!CommonClientAdjustPosition(timeStamp, newState))
		return;

	if (GetStateName() != newState)
		GotoState(newState);
}

/* TribesLongClientAdjustPosition 
long version, when care about pawn's floor normal
*/
function TribesLongClientAdjustPosition
(
	float TimeStamp, 
	float accumulator,
	float energy,
	name newState, 
	Character.MovementState movement,
	float StartLocX, 
	float StartLocY, 
	float StartLocZ, 
	float EndLocX, 
	float EndLocY, 
	float EndLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ
)
{
    local vector NewStartLocation, NewEndLocation, NewVelocity;
	local Actor MoveActor;
    local SavedMove CurrentMove;

	if (!CommonClientAdjustPosition(TimeStamp, NewState))
		return;

	if ( Pawn != None )
	{
		MoveActor = Pawn;
        if ( (ViewTarget != Pawn)
			&& ((ViewTarget == self) || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Health <= 0))) )
		{
			SetViewTarget(Pawn);
		}
	}
	else 
    {
		MoveActor = self;
	}

	if ( !bDemoOwner )
	{
		NewStartLocation.X = StartLocX;
		NewStartLocation.Y = StartLocY;
		NewStartLocation.Z = StartLocZ;
		NewEndLocation.X = EndLocX;
		NewEndLocation.Y = EndLocY;
		NewEndLocation.Z = EndLocZ;
		NewVelocity.X = NewVelX;
		NewVelocity.Y = NewVelY;
		NewVelocity.Z = NewVelZ;

		// skip update if no error (key to client movement prediction)
		while (TribesSavedMoves.Length > 0)
		{
			CurrentMove = TribesSavedMoves[0];
			if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
			{
				PopSavedMove();
				AppendFreeMove(CurrentMove);
				if ( CurrentMove.TimeStamp == CurrentTimeStamp )
				{ 
					// glenn: this if statement looks very strange, i think it can be simplified quite a bit
				
					CurrentMove.Clear();	// SavedLocation is not cleared
					if ( (VSize(CurrentMove.SavedLocation - NewEndLocation) < 3)
						&& (GetStateName() == NewState)/* && (accumulator == CurrentMove.accumulator)*/ )
					{
						return;
					}
					break;
				}
				else
				{
					CurrentMove.Clear();
				}
			}
			else
				break;
		}

		correctedMoves++;

		// update fusion movement state from server
		if (debugLogLevel > 0) log("Client "$Role$" adjust stamp "$TimeStamp$" - "$CurrentMove.SavedLocation$" to "$NewEndLocation$" ("$NewEndLocation - CurrentMove.SavedLocation$"), client accum "$CurrentMove.accumulator$" / "$accumulator);

		CurrentMove = None;	// no need to access this from here on
	}

	if( GetStateName() != newstate )
		GotoState(newstate);

	if (!bDemoOwner)
	{
		replayFromStartLocation = NewStartLocation;
		replayFromEndLocation = NewEndLocation;
		replayFromAccumulator = accumulator;
		replayFromVelocity = NewVelocity;
		replayFromEnergy = energy;
		replayFromMovement = movement;
		bUpdatePosition = true;
	}
}

function LongClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase,
	float NewFloorX,
	float NewFloorY,
	float NewFloorZ
)
{
	if (IsInState('BaseSpectating'))
		Super.LongClientAdjustPosition(TimeStamp, newState, newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);
}

// ClientUpdatePosition
// Replay moves from a received server position when player gets out of sync
function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int i;
	local int restored;
	local Rotator oldRotation;

	bUpdatePosition = false;

	if (character != None)
	{
		character.energy = replayFromEnergy;
		character.unifiedSetVelocity(replayFromVelocity);
		character.forceMovementState(replayFromMovement);

		if (character.movementObject!=None)
		{
			character.movementObject.setStartPosition(replayFromStartLocation);
			character.movementObject.setEndPosition(replayFromEndLocation);
			character.movementObject.setAccumulator(replayFromAccumulator);
		}
	}
	else if (Pawn == None)
	{
		super.ClientUpdatePosition();
	}

	oldRotation = Rotation;

	bUpdating = true;
	i = 0;
	while ( i < TribesSavedMoves.Length )
	{
		CurrentMove = TribesSavedMoves[i];
		// Discard moves older than the correction time stamp
		// Also discard the move corresponding to the last received server move (as it's our starting point)
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			CurrentMove.Clear();
			AppendFreeMove(CurrentMove);
			PopSavedMove();
		}
		else
		{
			i++;
			restored++;

			TribesMoveAutonomous(CurrentMove.Delta, CurrentMove.rotation, CurrentMove.forward, CurrentMove.strafe, CurrentMove.bSki, CurrentMove.bThrust, CurrentMove.bJump);
			CurrentMove.PostUpdate(self);
		}
	}
    if ( TribesPendingMove != None )
    {
		restored++;
		TribesMoveAutonomous(TribesPendingMove.Delta, TribesPendingMove.rotation, TribesPendingMove.forward, TribesPendingMove.strafe, TribesPendingMove.bSki, TribesPendingMove.bThrust, TribesPendingMove.bJump);
		TribesPendingMove.PostUpdate(self);
    }
    
	SetRotation(oldRotation);

	if (restored > 0 && debugLogLevel > 0)
		log("Client update position restored "$restored$" moves");

	bUpdating = false;
}

// TribesMoveAutonomous
function TribesMoveAutonomous
(	
	float DeltaTime, 	
	rotator moveRotation,
	float forward,
	float strafe,
	bool ski,
	bool thrust,
	bool jump
)
{
//	log(deltatime);
	if (Pawn != None)
	{
		SetRotation(moveRotation);
		
		TribesProcessMove(forward, strafe, float(jump), float(ski), float(thrust));
		Pawn.AutonomousPhysics(DeltaTime);
	}
	else
	{
		AutonomousPhysics(DeltaTime);
	}
	
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

function ServerRestartPlayerInVehicle(int vehicleRespawnIndex, bool bKeepPawn)
{
	// Check to ensure that the vehicle is still available to spawn at
	// if it isnt, we do nothing because the HUD will still be open on
	// the client, and the can simply select from another spawn point.

	// MJ:  Prevented this function from being called repeatedly by adding
	//      check to TribesRespawnHUD's Tick() instead
	// potentially already left PlayerRespawn state so ignore in that case
	//if (!isInState('PlayerRespawn'))
	//	return;

	if(TribesReplicationInfo(PlayerReplicationInfo).team.validVehicleRespawnIndex(vehicleRespawnIndex))
	{
		// Alex: added this becuase I found an enemies spawn base would be set in the case a player had switched teams and wanted to
		// immediately spawn at the Rover.
		spawnBase = None;

		if (!bKeepPawn)
			GameInfo(Level.Game).tryRespawn(self);
		else
			GameInfo(Level.Game).respawnKeepPawn(self);

		// snap player into respawn vehicle if necessary
		if (pawn != None)
				TribesReplicationInfo(PlayerReplicationInfo).team.respawnVehicles[vehicleRespawnIndex].spawnCharacter(Character(pawn));
	}
}

// ServerRestartPlayer
function ServerRestartPlayer()
{
	GameInfo(Level.Game).tryRespawn(self);
}

function ServerRestartPlayerKeepPawn()
{
	GameInfo(Level.Game).respawnKeepPawn(self);
}

function ServerRestartPlayerAtBase(BaseInfo Base, optional bool bKeepPawn)
{
	if(Base != None)
		SpawnBase = Base;

	if (bKeepPawn)
		ServerRestartPlayerKeepPawn();
	else
		ServerRestartPlayer();
}

function ServerKillPlayer()
{
	local Vehicle vehicle;
	local VehicleMountedTurret vehicleTurret;
	local Turret turret;

	//Log("ServerKillPlayer() called");

	vehicle = Vehicle(Pawn);
	vehicleTurret = VehicleMountedTurret(Pawn);
	turret = Turret(Pawn);
	if (vehicle != None)
	{
		// vehicle case
		vehicle.positions[vehicle.driverIndex].occupant.KilledBy(Pawn);

		// ... kick out dead body immediately
		vehicle.driverLeave(true, vehicle.driverIndex);
	}
	else if (vehicleTurret != None)
	{
		// vehicle mounted turret case
		vehicleTurret.ownerVehicle.positions[vehicleTurret.positionIndex].occupant.KilledBy(Pawn);

		// ... kick out dead body immediately
		vehicleTurret.ownerVehicle.driverLeave(true, vehicleTurret.positionIndex);
	}
	else if (turret != None)
	{
		// turret case
		turret.driver.KilledBy(Pawn);

		// ... kick out dead body immediately
		turret.driverLeave(true);
	}
	else
		Pawn.KilledBy(Pawn);

	// MJ:  Don't send the client to dead since the server will determine which state
	// the client goes to next
	GotoState('Dead', 'Forced');
}

function ServerPlayerSelectRespawn()
{
	GotoState('PlayerRespawn', 'Forced');
	ClientGotoState('PlayerRespawn', 'Forced');
}

function ServerCancelRespawn()
{
	if (bForcedRespawn)
	{
		GotoState(Rook(Pawn).playerControllerState);
		ClientGotoState(Rook(Pawn).playerControllerState);
	}
}

// serverSpectate
function serverSpectate(optional string playerName)
{
	spectate(playerName);
}

//
// State Respawn
//
// The player is viewing the respawn HUD, selecting a respawn point
// Needs to be extended from Dead so that the player can rotate his viewpoint around the dead pawn.
//
simulated state PlayerRespawn extends Dead
{
	exec function Fire( optional float F )
	{
	}

	exec function AltFire(optional float F)
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
	}

	exec function Respawn( optional bool bAllowExit )
	{
	}

	// The behaivour in the parent Engine.Controller 'Dead' state
	// is not what we desire.
	function ServerRestartPlayer()
	{
		Global.ServerRestartPlayer();
	}

	function BeginState()
	{
		// allows rotation around character
		bFrozen = false;
		DestroySensorLists();
		ResetSpeedhack();
	}

	simulated function EndState()
	{
		//Log(self $ " exited PlayerRespawn state");
		bBehindView = false;
		bForcedRespawn = false;
		releaseFire();

		if (Level.NetMode != NM_DedicatedServer)
		{
			HUDManager.SetHUD("");
		}
	}

	function PlayerTick(float Delta)
	{
		Global.PlayerTick(Delta);

		// The view should be frozen when the hud map is shown
		bFrozen = clientSideChar.bShowRespawnMap;
	}

	function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (respawnDelay > 0)
			respawnDelay -= Delta;
	}

	exec function showEscapeMenu()
	{
		if (isSinglePlayer() || !bForcedRespawn)
			Global.showEscapeMenu();
	}

	// Lock the player when looking at the respawn map
	function playerMove(float deltaTime)
	{
		if (!clientSideChar.bShowRespawnMap)
		{
			Super.playerMove(deltaTime);
			return;
		}

		if (pawn == none)
			return;

		// need to do this to handle case user is blown off
		if (ROLE < ROLE_Authority)
		{
			tribesReplicateMove(0, 1, false, false, false);
		}
		else
		{
			tribesProcessMove(0, 0, 0, 0, 0);
		}
	}

Forced:
	bForcedRespawn = true;
	respawnDelay = -1;

Begin:
	bBehindView = true;

	//Log(self $ " entered PlayerRespawn state with bForced set to "$bForcedRespawn);

	if (Level.NetMode != NM_DedicatedServer)
		HUDManager.SetHUD(respawnHUDClass);
}

//
// State PlayerTeleport
//
simulated state PlayerTeleport
{
	exec function Fire( optional float F )
	{
	}

	exec function AltFire(optional float F)
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
	}

	exec function activatePack()
	{
	}

	exec function Respawn( optional bool bAllowExit )
	{
	}

	exec function SwitchWeapon(byte F)
	{
	}

	exec function equipCarryable()
	{
	}

	exec function equipDeployable()
	{
	}

	function BeginState()
	{
		// allows rotation around character
		bFrozen = true;
	}

	simulated function PlayerTick(float Delta)
	{
		Global.PlayerTick(Delta);

		// The view should be frozen when the hud map is shown
		bFrozen = clientSideChar.bShowRespawnMap;
	}

	function EndState()
	{
		//Log(self $ " exited PlayerTeleport state");
		bBehindView = false;
		clientTribesSetHUD("");
		bForcedRespawn = false;
	}

	function ServerRestartPlayer()
	{
	}

Begin:
	//Log(self $ " entered PlayerTeleport state");
	bBehindView = true;
	respawnDelay = -1;
	bForcedRespawn = true;

	if (Level.NetMode != NM_DedicatedServer)
		HUDManager.SetHUD(respawnHUDClass);
}

// State Dead
//
// The player is dead
//
simulated state Dead
{
	exec function Fire( optional float F )
	{
		// respawn on fire
		Global.ServerRestartPlayer();
	}

	exec function AltFire(optional float F)
	{
		// respawn on fire
		Global.ServerRestartPlayer();
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
		// go to spectator mode when jetpack is pressed
		serverSpectate();
	}

	// michaelj:  Multiplayer effectively bypasses the Dead state and goes to one of two possible states
	//            1) PlayerRespawn, which lets the player choose a location, spawn, then play
	//            2) AwaitingNextRound if the player doesn't have any lives left
	function BeginState()
	{
		super.BeginState();

		// enable rotation around the dead player.
		bFrozen = false;
		
		if(IsSinglePlayer())
			ClientTribesSetHUD("");

		//clientTribesSetHUD("");
		if (character != None)
			TriggerEffectEvent('Died');

		// Notify the GameInfo of this player's death (decrements livesLeft if applicable)
		if (Level.NetMode != NM_Client)
			GameInfo(Level.Game).onDeath(self);

		// If livesLeft is -1 (disabled) or greater than 0 (you have lives left), go to a regular
		// destroyed state
		if (livesLeft != 0)
		{
			if (Level.NetMode != NM_Client)
			{
				//Log("Sending "$self$" to "$GameInfo(Level.Game).playerPawnDestroyedState()$" from Dead with livesLeft = "$livesLeft);
				GotoState(GameInfo(Level.Game).playerPawnDestroyedState());
				ClientGotoState(GameInfo(Level.Game).playerPawnDestroyedState());
			}
		}
		// Otherwise you can't respawn.  Game over in SP, wait for the next round in MP
		else
		{
			if (Level.NetMode != NM_Client)
			{
				//Log("Sending "$self$" to "$GameInfo(Level.Game).playerPawnNoRespawnState()$" from Dead with livesLeft "$livesLeft);
				GotoState(GameInfo(Level.Game).playerPawnNoRespawnState());
				ClientGotoState(GameInfo(Level.Game).playerPawnNoRespawnState());
			}
		}
	}

Forced:
	bForcedRespawn = true;

Begin:
//	clientTribesSetHUD(respawnHUDClass);
//	clientTribesSetHUD("");
}

state BaseSpectating
{
	function BeginState()
	{
		super.BeginState();
		DestroySensorLists();
	}
}

// State TribesSpectating
//
// The player is spectating
//
simulated state TribesSpectating extends BaseSpectating
{
	function BeginState()
	{
		Super.BeginState();

		bFrozen = false;
		bCollideWorld = false;
		PlayerReplicationInfo.bIsSpectator = true;
		spawnBase = None;
		//Log("Setting team of "$self$" to None in TribesSpectating BeginState()");
		tribesReplicationInfo(playerReplicationInfo).setTeam(None);
	}

	exec function Fire( optional float F )
	{
		SetSpectateSpeed( 2000.0 );
	}

	exec function AltFire(optional float F)
	{
		// respawn on altfire
		//Global.ServerRestartPlayer();
	}

	exec function releaseFire(optional float F)
	{
		SetSpectateSpeed( 1200.0 );
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
		// select spectate target on jetpack key
		ServerViewNextPlayer();
	}

	exec function NextWeapon()
	{
		camera.thirdPersonCameraDist = FMin(maxSpectatorZoom, camera.thirdPersonCameraDist + 1);
		if (camera.thirdPersonCameraDist == minSpectatorZoom + 1)
		{
			// Switch to third-person
			//bBehindView = true;
			//bFreeCamera = true;
		}
	}

	exec function PrevWeapon()
	{
		camera.thirdPersonCameraDist = FMax(minSpectatorZoom, camera.thirdPersonCameraDist - 1);
		if (camera.thirdPersonCameraDist == minSpectatorZoom)
		{
			// Switch to first-person
			//bBehindView = false;
			//bFreeCamera = false;
		}
	}

	exec function SwitchWeapon(byte F)
	{
		switch(F)
		{
		case 1: ServerViewNextMPObject(); break;
		case 2: ServerViewNextSpectatorStart(); break;
		}
	}

	function CalcFirstPersonView(Vector cameraLocation, Rotator cameraRotation)
	{
	}

	function EndState()
	{
		Super.EndState();
		bBehindView = false;
		PlayerReplicationInfo.bIsSpectator = false;
		camera.thirdPersonCameraDist = camera.default.thirdPersonCameraDist;
		if (Level.NetMode != NM_DedicatedServer)
			HUDManager.SetHUD("");
	}

	function ServerReStartPlayer()
	{
	}

	exec function Respawn( optional bool bAllowExit )
	{
	}

Begin:
	CleanOutSavedMoves();
	if (Level.NetMode != NM_DedicatedServer)
		HUDManager.SetHUD(spectatorHUDClass);
}

// State TribesCountdown
//
// The player is in the countdown phase
//
simulated state TribesCountdown extends BaseSpectating
{
	exec function Suicide()
	{
	}

	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
	}

	function TurnAround()
	{
		// stop player turning
	}

	function ServerRestartPlayer()
	{
		//Global.ServerRestartPlayer();
	}

	exec function Fire( optional float F )
	{
		serverToggleReady();
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire( optional float F )
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
	}
	
	function BeginState()
	{
		local Rotator r;

		super.BeginState();

		r = character.Rotation;
		r.Pitch = 0;
		character.setRotation(r);

		character.enterManualAnimationState();
		character.bReplicateAnimations = true;
		character.LoopAnim('start_round', 1.0);
		bBehindView = true;
		bFreeCamera = true;

		camera.clearTransitions();
	}

	function EndState()
	{
		character.exitManualAnimationState();
		character.bReplicateAnimations = false;
		bFreeCamera = false;
		clientTribesSetHUD("");
		camera.doZoomIn(0.15);
	}

	// server-side only (clients use PlayerTick)
	function Tick(float Delta)
	{
		Global.Tick(Delta);

		checkAutoWeaponSwitch();
	}

	function ToggleBehindView()
	{
		// do nothing
	}

	exec function Respawn( optional bool bAllowExit )
	{
		// do nothing
	}

Begin:
	//Log(self$" entered state TribesCountdown");
	CleanOutSavedMoves();
	clientTribesSetHUD(CountdownHUDClass);
}

//
// State SPIntroduction
//
// The camera pans around the player and enters his head
//
state SPIntroduction
{
	function TurnAround()
	{
		// stop player turning
	}

	exec simulated function bool SkipOpeningCutscene()
	{
		if (introCameraScript != None)
		{
			introCameraScript.exit();
			GotoState(introCameraOldState);
			return true;
		}

		return false;
	}

	function serverSelectWeapon(Weapon w)
	{
		// do nothing
	}

	exec function Fire( optional float F )
	{
		serverToggleReady();
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire( optional float F )
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
	}
	
	function BeginState()
	{
		// this logic is for when triggered via test exec command (script calls camera.transition)
		if (!camera.isTransitioning())
			camera.transition('LevelStartPan', 4.5);

		clientTribesSetHUD("");

		SetCinematicMode(true);
		class'ActionCinematicEnter'.static.cinematicEnter(Level);
	}

	function Tick(float delta)
	{
		if (!camera.isTransitioning())
			GotoState(introCameraOldState);
	}

	function EndState()
	{
		camera.clearTransitions();
		camera.GotoState('');
		introCameraScript = None;
		bBehindView = false;

		SetCinematicMode(false);
		class'ActionCinematicExit'.static.cinematicExit(Level);
	}
}

function serverToggleReady()
{
	local TribesReplicationInfo TRI;

	if (Role != ROLE_Authority)
		return;

	TRI = TribesReplicationInfo(PlayerReplicationInfo);

	// Allow clicking to ready/unready if in tournament mode and the countdown hasn't started yet
	if (GameReplicationInfo.bTournamentMode 
			&& TribesGameReplicationInfo(GameReplicationInfo).bAwaitingTournamentStart
			&& TRI.numReadies < 10)
	{
		// Broadcast ready message
		TRI.bReady = !TRI.bReady;
		TRI.numReadies++;
		if (TRI.bReady)
			Level.Game.BroadcastLocalized(self, Level.Game.GameMessageClass, 20, PlayerReplicationInfo);
		else
			Level.Game.BroadcastLocalized(self, Level.Game.GameMessageClass, 21, PlayerReplicationInfo);
	}
}

// State AwaitingNextRound
//
// The player waiting for the next round to begin
//
simulated state AwaitingNextRound extends TribesSpectating
{
	function BeginState()
	{
		bWaitingForRoundEnd = true;
		bCollideWorld = true;
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	function EndState()
	{
		Super.EndState();
		//Log(self $" leaving state AwaitingNextRound");
		if (Level.NetMode != NM_DedicatedServer)
			HUDManager.SetHUD(respawnHUDClass);
		bWaitingForRoundEnd = false;
	}

Begin:
	bBehindView = true;
	//Log(self $" entered state AwaitingNextRound");
	//CleanOutSavedMoves();
	if (Level.NetMode != NM_DedicatedServer)
		HUDManager.SetHUD(waitRoundEndHUDClass);
}

// State AwaitingGameStart
//
// The player waiting for the game to start
simulated state AwaitingGameStart extends TribesSpectating
{
	function BeginState()
	{
		bFrozen = true;
		bCollideWorld = true;
		PlayerReplicationInfo.bIsSpectator = true;
	}

	function ServerReStartPlayer()
	{
		//Log(self$" tried to restart in state AwaitingGameStart");
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	function EndState()
	{
		if (Level.NetMode != NM_DedicatedServer)
			HUDManager.SetHUD("");

		PlayerReplicationInfo.bIsSpectator = false;
	}

Begin:
	if (Level.NetMode != NM_DedicatedServer)
		HUDManager.SetHUD(waitGameStartHUDClass);

}

// State GameEnded (overrides GameEnded in Controller)
//
// The game has ended
//
state GameEnded
{
	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire( optional float F )
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack( optional float F )
	{
	}
	
	function BeginState()
	{
		CleanOutSavedMoves();
		clientTribesSetHUD(gameEndHUDClass);
		bBehindView = true;
	}

	function EndState()
	{
		clientTribesSetHUD("");
		bBehindView = false;
	}
}

// clientFinishInventoryStationAccess
//
// Does client side processing associated with a character ceasing usage of an inventory station.
function clientFinishInventoryStationAccess()
{
	inventoryStation = None;

    character.StopMovementEffects();

	// replicated from server but do here as well to guarantee it is done by now
	GotoState('CharacterMovement');
}

// clientInventoryStationWait
//
// Does Client side processing for waiting for an inventory station.
function clientInventoryStationWait()
{
	// replicated from server but do here as well to guarantee it is done by now
	GotoState('PlayerWaitingInventoryStation');
}

// clientInventoryStationAccess
//
// Does client side processing for using an inventory station.
function clientInventoryStationAccess(InventoryStationAccess inputInventoryStation)
{
	// If the player is entering an inventory station immediately after spawning it is possible that the player pawn has not been
	// replicated yet. This situation is caught here and handled by simply delaying this call until the player pawn has been replicated.
	// The function is re-called in PostNetReceive.

	if (Level.NetMode == NM_Client && Character(Pawn) == None)
	{
		inventoryStationWaitingForCharacter = true;
		inventoryStationWaitingForCharacterInput = inputInventoryStation;
		return;
	}

	inventoryStation = inputInventoryStation;
	inventoryStation.clientSetupInventoryStation(Character(Pawn));

	Character(Pawn).unifiedSetVelocity(Vect(0,0,0));

	// replicated from server but do here as well to guarantee it is done by now
//	GotoState('PlayerUsingInventoryStation');
}

// serverTerminateInventoryStationAccess
//
// Abruptly stops inventory station usage.
function serverTerminateInventoryStationAccess()
{
	inventoryStation.serverTerminateCharacterAccess();

	clientTerminateInventoryStationAccess();
}

// clientTerminateInventoryStationAccess
//
// Does processing on client side associated with terminating a users access/
function clientTerminateInventoryStationAccess()
{
	clientFinishInventoryStationAccess();
}

// serverFinishInventoryStationAccess
//
// Called from client when player finishes doing a quick loadout select
// 
function serverFinishQuickInventoryStationAccess(
	InventoryStationAccess inputInventoryStation,
	class<CombatRole> selectedRole, 
	String userSkin, 
	int activeWeaponSlot, 
	optional class<Pack> selectedPack, 
	optional class<HandGrenade> grenades,
	optional class<Weapon> weaponSlot1, 
	optional class<Weapon> weaponSlot2, 
	optional class<Weapon> weaponSlot3, 
	optional class<Weapon> weaponSlot4, 
	optional class<Weapon> weaponSlot5, 
	optional class<Weapon> weaponSlot6, 
	optional class<Weapon> weaponSlot7, 
	optional class<Weapon> weaponSlot8, 
	optional class<Weapon> weaponSlot9, 
	optional class<Weapon> weaponSlot10)
{
	local InventoryStationAccess.InventoryStationLoadout selectedLoadout;

	if (character != None)
		character.detachGrapple();

	// rebuild loadout struct
	selectedLoadout.role.combatRoleClass = selectedRole;
	selectedLoadOut.userSkin = userSkin;
	selectedLoadOut.activeWeaponSlot = activeWeaponSlot;
	selectedLoadOut.pack.packClass = selectedPack;
	selectedLoadout.grenades.grenadeClass = grenades;
	selectedLoadout.weapons[0].weaponClass = weaponSlot1;
	selectedLoadout.weapons[1].weaponClass = weaponSlot2;
	selectedLoadout.weapons[2].weaponClass = weaponSlot3;
	selectedLoadout.weapons[3].weaponClass = weaponSlot4;
	selectedLoadout.weapons[4].weaponClass = weaponSlot5;
	selectedLoadout.weapons[5].weaponClass = weaponSlot6;
	selectedLoadout.weapons[6].weaponClass = weaponSlot7;
	selectedLoadout.weapons[7].weaponClass = weaponSlot8;
	selectedLoadout.weapons[8].weaponClass = weaponSlot9;
	selectedLoadout.weapons[9].weaponClass = weaponSlot10;

	inputInventoryStation.serverFinishCharacterAccess(selectedLoadout, true, character);
}

// serverFinishInventoryStationAccess
//
// Called from client when player finishes using an inventory station. The each component of the selected
// load out is passed separately because Unreal does not like serialising structs.
function serverFinishInventoryStationAccess(
			InventoryStationAccess inputInventoryStation,
			class<CombatRole> selectedRole, 
			String userSkin, 
			int activeWeaponSlot, 
			optional class<Pack> selectedPack, 
			optional class<HandGrenade> grenades,
			optional class<Weapon> weaponSlot1, 
			optional class<Weapon> weaponSlot2, 
			optional class<Weapon> weaponSlot3, 
			optional class<Weapon> weaponSlot4, 
			optional class<Weapon> weaponSlot5, 
			optional class<Weapon> weaponSlot6, 
			optional class<Weapon> weaponSlot7, 
			optional class<Weapon> weaponSlot8, 
			optional class<Weapon> weaponSlot9, 
			optional class<Weapon> weaponSlot10)
{
	local InventoryStationAccess.InventoryStationLoadout selectedLoadout;

	// rebuild loadout struct
	selectedLoadout.role.combatRoleClass = selectedRole;
	selectedLoadOut.userSkin = userSkin;
	selectedLoadOut.activeWeaponSlot = activeWeaponSlot;
	selectedLoadOut.pack.packClass = selectedPack;
	selectedLoadout.grenades.grenadeClass = grenades;
	selectedLoadout.weapons[0].weaponClass = weaponSlot1;
	selectedLoadout.weapons[1].weaponClass = weaponSlot2;
	selectedLoadout.weapons[2].weaponClass = weaponSlot3;
	selectedLoadout.weapons[3].weaponClass = weaponSlot4;
	selectedLoadout.weapons[4].weaponClass = weaponSlot5;
	selectedLoadout.weapons[5].weaponClass = weaponSlot6;
	selectedLoadout.weapons[6].weaponClass = weaponSlot7;
	selectedLoadout.weapons[7].weaponClass = weaponSlot8;
	selectedLoadout.weapons[8].weaponClass = weaponSlot9;
	selectedLoadout.weapons[9].weaponClass = weaponSlot10;

	// confirm that inventory station was actually being used
	if (inputInventoryStation != inventoryStation)
	{
		log("WARNING: attempted to finish using an inventory station that was not being used");
	}

	inventoryStation.serverFinishCharacterAccess(selectedLoadout, true);
}

//
// Updates current loadout and restarts the character
//
function serverFinishEquippingPreRestart(
		class<CombatRole> selectedRole, 
		String userSkin, 
		int activeWeaponSlot, 
		optional class<Pack> selectedPack, 
		optional class<HandGrenade> grenades,
		optional class<Weapon> weaponSlot1, 
		optional class<Weapon> weaponSlot2, 
		optional class<Weapon> weaponSlot3, 
		optional class<Weapon> weaponSlot4, 
		optional class<Weapon> weaponSlot5, 
		optional class<Weapon> weaponSlot6, 
		optional class<Weapon> weaponSlot7, 
		optional class<Weapon> weaponSlot8, 
		optional class<Weapon> weaponSlot9, 
		optional class<Weapon> weaponSlot10)
{
	local CustomPlayerLoadout selectedLoadout;
	local CustomPlayerLoadout.WeaponInfo weaponInfo;
	local CustomPlayerLoadout.GrenadeInfo grenadeInfo;

	selectedLoadout = new class'CustomPlayerLoadout';

	selectedLoadout.combatRoleClass = selectedRole;
	selectedLoadout.packClass = selectedPack;

	// add grenades
	grenadeInfo.grenadeClass = grenades;
	grenadeInfo.ammo = 0;
	selectedLoadout.grenades = grenadeInfo;

	// add weapon 1
	weaponInfo.weaponClass = weaponSlot1;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[0] = weaponInfo;
	// add weapon 2
	weaponInfo.weaponClass = weaponSlot2;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[1] = weaponInfo;
	// add weapon 3
	weaponInfo.weaponClass = weaponSlot3;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[2] = weaponInfo;
	// add weapon 4
	weaponInfo.weaponClass = weaponSlot4;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[3] = weaponInfo;
	// add weapon 5
	weaponInfo.weaponClass = weaponSlot5;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[4] = weaponInfo;
	// add weapon 6
	weaponInfo.weaponClass = weaponSlot6;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[5] = weaponInfo;
	// add weapon 7
	weaponInfo.weaponClass = weaponSlot7;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[6] = weaponInfo;
	// add weapon 8
	weaponInfo.weaponClass = weaponSlot8;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[7] = weaponInfo;
	// add weapon 9
	weaponInfo.weaponClass = weaponSlot9;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[8] = weaponInfo;
	// add weapon 10
	weaponInfo.weaponClass = weaponSlot10;
	weaponInfo.ammo = 0;
	selectedLoadout.weaponList[9] = weaponInfo;

	currentLoadout = selectedLoadout;

	GameInfo(Level.Game).RestartPlayer(self);
}

//
// State the player is in when they are equpping at an inventory
// screen before they spawn.
//
simulated state PlayerEquippingPreRestart
{

	function EndState()
	{
		ClientCloseMenu();
	}

	exec function Fire(optional float F)
	{
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack(optional float F)
	{
	}

	//
	// Overriden to avoid access None on Pawn while in this state. 
	// I tried to do a Pawn != None check before it was called, but
	// it didn't seem to work.
	// 
	function CalcFirstPersonView(Vector cameraLocation, Rotator cameraRotation)
	{
	}

	function LoadInventoryInterface()
	{
		local class<GameInfo> GameInfoClass;

		GameInfoClass = class<GameInfo>(DynamicLoadObject(GameReplicationInfo.GameClass, class'Class'));
		inventoryStation = new GameInfoClass.default.InventoryStationAccessClass; //class'InventoryStationStandaloneAccess';

		// PROBLEM:  inventoryStation needs a currentUser, which is currently of type Character.  But before you spawn, you don't have
		//           a Pawn.  Maybe change InventoryStationAccess to store the Controller instead?  And then pass the Controller in this
		//           call to SetupAccessData().
		InventoryStationStandaloneAccess(inventoryStation).SetupAccessData(TribesReplicationInfo(PlayerReplicationInfo).team);

		OpenMenu(inventoryStationMenuClass);
	}

begin:
	// hackity hack: waiting for the team to be set before we use it
	while(TribesReplicationInfo(PlayerReplicationInfo).team == None)
		sleep(0);

	LoadInventoryInterface();
}

// State PlayerWaitingInventoryStation
//
// Player is currently accessing an Inventory Station using a specialised HUD.
//
simulated state PlayerWaitingInventoryStation
{
	exec function Fire(optional float F)
	{
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack(optional float F)
	{
	}

	// keep sending moves to the server so we get state updates
	function PlayerMove( float DeltaTime )
	{
		if (Role < ROLE_Authority)
			TribesReplicateMove(0, 0, false, false, false);
	}

	simulated function PlayerTick(float deltaSeconds)
	{
		Global.PlayerTick(deltaSeconds);

		// check for user death
		if (pawn == None || pawn.bTearOff)
		{
			Pawn = None;
			if (!IsInState('GameEnded') && !IsInState('Dead'))
			{
				GotoState('Dead');
			}
			return;
		}
	}

	function BeginState()
	{
		ResetSpeedhack();
	}
}

// State PlayerUsingInventoryStation
//
// Player is currently accessing an Inventory Station using a specialised HUD.
//
state PlayerUsingInventoryStation
{
	function BeginState()
	{
		if(inventoryStation == None)
		{
			GotoState('CharacterMovement');
			return;
		}

		if (character != None)
		{
			armorClassBeforeInventoryAccess = character.armorClass;

			character.unifiedSetVelocity(Vect(0,0,0));
			character.detachGrapple();
			character.StopMovementEffects();
		}

		// probably a more appropriate place to put this - ideally at start up and after bindings change
		updateCachedKeyBindings();

		ResetInputState();
		ResetSpeedhack();

		myHud.bHideHud = true;
		OpenMenu(inventoryStationMenuClass);
	}

	function EndState()
	{
		local Character user;

		if (Player.GUIController.IsPageActive(inventoryStationMenuClass))
			Player.GUIController.CloseMenu();
		myHud.bHideHud = false;

		// make sure excess health is not being applied to character
		user = Character(pawn);
		if (user != None)
			user.clampHealthInjection();

		ResetSpeedhack();

		inventoryStation = None;
	}

	function Tick(float Delta)
	{
		// check for station death
		if (inventoryStation == None || inventoryStation.bDeleteMe)
		{
			GotoState('CharacterMovement');
		}
	}

	exec function Fire(optional float F)
	{
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack(optional float F)
	{
	}

	exec function inventoryStationSwitchVehiclePosition(byte position, InventoryStationAccess.InventoryStationLoadout selectedLoadout)
	{
		serverInventoryStationSwitchVehiclePosition(position, selectedLoadout);
	}

	function serverInventoryStationSwitchVehiclePosition(byte position, InventoryStationAccess.InventoryStationLoadout selectedLoadout)
	{
		local Vehicle vehicle;
		local int positionIndex;

		// get vehicle, if any, this inventory station is based on
		vehicle = inventoryStation.getVehicleBase();

		if (vehicle == None)
			return;

		// do nothing if cannot enter new position
		if (!vehicle.canArmourBeDriver(selectedLoadout.role.combatRoleClass.default.armorClass))
			return;

		positionIndex = vehicle.getOccupantPositionIndex(Character(Pawn));
		
		if (positionIndex < 0)
		{
			warn("inventory station user is not occupant of corresponding vehicle");
			return;
		}

		if (!vehicle.canSwitchPosition(positionIndex, position))
			return;

		// do processing associated with finishing inventory station use
		inventoryStation.serverFinishCharacterAccess(selectedLoadout, false);

		vehicle.switchPosition(positionIndex, position);
	}

	function playerMove(float deltaTime)
	{
		// need to do this to handle case user is blown off
		if (Role < ROLE_Authority)
		{
			TribesReplicateMove(0, 1, false, false, false);
		}
		else
		{
			TribesProcessMove(0, 0, 0, 0, 0);
		}
	}

	exec function Suicide()
	{
		if (Level.NetMode == NM_Client)
			return;

		serverTerminateInventoryStationAccess();

		super.Suicide();
	}
}

// State PlayerUsingResupplyStation
//
// Player is currently accessing a Resupply Station.
//
simulated state PlayerUsingResupplyStation
{
	exec function Fire(optional float F)
	{
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
	}

	exec function releaseAltFire(optional float F)
	{
	}

	exec function Jetpack(optional float F)
	{
	}

	simulated function PlayerTick(float deltaSeconds)
	{
		Global.PlayerTick(deltaSeconds);

		// check for user death
		if (pawn == None || pawn.bTearOff)
		{
			Pawn = None;
			if (!IsInState('GameEnded') && !IsInState('Dead'))
			{
				GotoState('Dead');
			}
			return;
		}
	}

	function ServerUse()
	{
		currentResupply.access.UsedBy(Pawn);
	}

	function EndState()
	{
		currentResupply = None;
	}
}

exec function inventoryStationSwitchVehiclePosition(byte position, InventoryStationAccess.InventoryStationLoadout selectedLoadout)
{
	// nothing
}

function serverInventoryStationSwitchVehiclePosition(byte position, InventoryStationAccess.InventoryStationLoadout selectedLoadout)
{
	// nothing
}

function processTurretMove(float DeltaTime, float aTurn, float aLookUp)
{
}

function serverTurretMove(float timeStamp, float turn, float lookup, int clientPitch, int clientYaw, optional float importantDelta, optional float importantTurn, optional float importantLookup)
{
}

function clientAdjustTurretPosition(float timeStamp, int serverPitch, int serverYaw, int serverTargetPitch, int serverTargetYaw, name newState)
{
	if (newState != GetStateName())
		GotoState(newState);
}

function replicateTurretMove(float DeltaTime, float aTurn, float aLookup)
{
}

// State PlayerTurreting
//
// Player controlling a Turret.
//
state PlayerTurreting
{
ignores SeePlayer, HearNoise, Bump;

	function TribesServerMove
	(
		float TimeStamp, 
		Vector ClientLoc,
		int View,
		EDigitalAxisInput forward,
		EDigitalAxisInput strafe,
		bool ski,
		bool thrust,
		bool jump,
	    optional byte CompressedImportantTimeDelta,
		optional int ImportantMoveData
	)
	{
		TribesShortClientAdjustPositionEx
		(
			TimeStamp, 0, 0, GetStateName(), MovementState_Stand, Location.X, Location.Y, Location.Z, Location.X, Location.Y, Location.Z
		);
	}

	function PlayerTick(float Delta)
	{
		local Turret turret;

		Global.PlayerTick(Delta);

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		// prevent weapons from firing after we leave
		if (Turret.driver != None && Turret.driver.motor != None)
			Turret.driver.motor.bFirePressed = false;

		ProcessZoom(Delta, turret.driver);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
	}

	function PlayerMove( float DeltaTime )
	{
		local Turret turret;
		local float turn, lookup;

		turret = Turret(Pawn);
		if (turret == None)
			return;

		// zoom
		if (turret.motor != None)
			turret.motor.setZoomed(bZoom != 0);

		turn = 32.0 * aTurn;
		lookup = 32.0 * aLookup;
		if (turret.driver != None && turret.driver.isZoomed())
		{
			turn *= zoomedMouseScale[zoomLevel];
			lookup *= zoomedMouseScale[zoomLevel];
		}

		// if a client, replicate the move to the server, else just do the move
		if (Role < ROLE_Authority)
			replicateTurretMove(DeltaTime, turn, lookup);
		else
			processTurretMove(DeltaTime, turn, lookup);
	}

	// Sets the view rotation for the turret based on the input provided.
	// Used to update the authoritative turret position on the server, as well
	// as the predicted location on the client.
	function processTurretMove(float DeltaTime, float turn, float lookup)
	{
		local Turret Turret;
		local Rotator newRot;

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		newRot = turret.motor.getViewRotation();

		newRot.Yaw += turn * DeltaTime;
		newRot.Pitch += lookUp * DeltaTime;

		turret.motor.setViewTarget(newRot);

		turret.updateAim(DeltaTime);
	}

	// Performs the actual turret movement locally, stores the result, then sends
	// the movement to the server
	function replicateTurretMove(float DeltaTime, float turn, float lookup)
	{
		local Turret Turret;
		local SavedMove newMove;
		local SavedMove importantMove;
		local int i;
		//local float NetMoveDelta;

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		// find the most recent important move
		if ( TribesSavedMoves.Length > 0 )
		{
			for (i = TribesSavedMoves.Length - 1; i >= 0; i--)
			{
				// find most recent important move to send redundantly
				if ( TribesSavedMoves[i].strafe != 0 || TribesSavedMoves[i].forward != 0)
				{
					importantMove = TribesSavedMoves[i];
					break;
				}
			}
		}

		// do the turret move
		processTurretMove(DeltaTime, turn, lookup);
 
		// store the new turret state
		newMove = TribesGetFreeMove();
		newMove.Delta = DeltaTime;
		newMove.strafe = turn;
		newMove.forward = lookup;
		newMove.Rotation = turret.motor.getViewRotation();
		newMove.TimeStamp = Level.TimeSeconds;

		AppendSavedMove(newMove);

		// if the last move was held, combined it with this move
		if ( TribesPendingMove != None )
		{
			combinedMoves++;
				
			NewMove.combineTurret(TribesPendingMove);
			TribesPendingMove = None;
		}

		// stats
		replicateMoveCalls++;

		// Decide whether to hold off on move
		if (TribesPendingMove == None)
		{
			// temporarily disabled
			/*if ( (Player.CurrentNetSpeed > 10000) && (GameReplicationInfo != None) && (GameReplicationInfo.PRIArray.Length <= 10) )
				NetMoveDelta = 0;	// full rate
			else
				NetMoveDelta = FMax(0.0222,2 * Level.MoveRepSize/Player.CurrentNetSpeed);

			if ( Level.TimeSeconds - ClientUpdateTime < NetMoveDelta )
			{
				TribesPendingMove = NewMove;
				return;
			}*/
		}

		ClientUpdateTime = Level.TimeSeconds;

		//log("SENT "@newmove.Timestamp@newmove.strafe@newmove.forward@newmove.rotation.pitch@newmove.rotation.yaw);
		if (importantMove != None)
		{
			serverTurretMove(newMove.TimeStamp, newMove.strafe, newMove.forward, newMove.Rotation.Pitch, newMove.Rotation.Yaw, importantMove.TimeStamp, importantMove.strafe, importantMove.forward);
		}
		else
			serverTurretMove(newMove.TimeStamp, newMove.strafe, newMove.forward, newMove.Rotation.Pitch, newMove.Rotation.Yaw);
	}

	// Sends a turret move to the server.
	// Once the move is received it is carried out in the authoritative gameworld.
	// The result of the server's processing is sent back to the client to give it an
	// opportunity to correct itself if needed.
	function serverTurretMove(float timeStamp, float turn, float lookup, int clientPitch, int clientYaw, optional float importantTimestamp, optional float importantTurn, optional float importantLookup)
	{
		local Turret turret;
		local Rotator viewTarget;
		local Rotator viewRotation;

		turret = Turret(Pawn);
		if (turret == None || turret.motor == None)
			return;

		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
		{
			return;
		}

		//log("RECEIVED "@Timestamp@turn@lookup@clientPitch@clientYaw);
		// check if an important move was lost
		if ( importantTimestamp != 0 )
		{
			//log(Timestamp@importantTimestamp@CurrentTimeStamp);
			if ( CurrentTimeStamp < ImportantTimeStamp )
			{
				importantTimestamp = FMin(importantTimestamp, CurrentTimeStamp + MaxResponseTime);
				processTurretMove(ImportantTimeStamp - CurrentTimeStamp, importantTurn, importantLookup);
				CurrentTimeStamp = ImportantTimeStamp;
			}
		}

		processTurretMove(FMin(MaxResponseTime, TimeStamp - CurrentTimeStamp), turn, lookup);

		viewTarget = turret.motor.getViewTarget();
		viewRotation = turret.motor.getViewRotation();

		CurrentTimeStamp = timeStamp;

		// If client has accumulated a noticeable error, correct him.
		if (Abs(clientPitch - viewRotation.Pitch) > 16 || Abs(clientYaw - viewRotation.Yaw) > 16 || (Level.TimeSeconds - LastUpdateTime > 0.3))
		{
			clientAdjustTurretPosition(timeStamp, viewRotation.Pitch, viewRotation.Yaw, viewTarget.Pitch, viewTarget.Yaw, GetStateName());
			LastUpdateTime = Level.TimeSeconds;
		}
	}

	// Sent from the server to the client to ensure that the client is kept in sync
	function clientAdjustTurretPosition(float timeStamp, int serverPitch, int serverYaw, int serverTargetPitch, int serverTargetYaw, name newState)
	{
		local Turret Turret;
		local SavedMove	CurrentMove;
		
		if (!CommonClientAdjustPosition(timeStamp, newState))
			return;

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		if ( CurrentTimeStamp > TimeStamp )
			return;		// ignore disordered adjust position message
		CurrentTimeStamp = timeStamp;
		
		while (TribesSavedMoves.Length > 0)
		{
			// Discard moves of an earlier timestamp than that sent by the server, and
			// find the move corresponding to the server timestamp
			CurrentMove = TribesSavedMoves[0];
			if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
			{
				PopSavedMove();
				AppendFreeMove(CurrentMove);

				if ( CurrentMove.TimeStamp == CurrentTimeStamp )
				{ 
					// found the given server move
					if ( Abs(CurrentMove.rotation.Pitch - serverPitch) <= 16 && 
						 Abs(CurrentMove.rotation.Yaw - serverYaw) <= 16)
					{ 
						CurrentMove.Clear();
						return;
					}

					CurrentMove.Clear();
					break;
				}
				else
				{
					CurrentMove.Clear();
				}
			}
			else
				break;
		}

		replayFromStartLocation.X = serverYaw;
		replayFromStartLocation.Y = serverPitch;
		replayFromEndLocation.X = serverTargetYaw;
		replayFromEndLocation.Y = serverTargetPitch;

		bUpdatePosition = true;
	}

	// Replay moves from a received server position when player gets out of sync
	function ClientUpdatePosition()
	{
		local SavedMove CurrentMove;
		local int i;
		local int restored;
		local Turret Turret;
		local Rotator newRot;

		bUpdatePosition = false;

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		newRot.Yaw = replayFromStartLocation.X;
		newRot.Pitch = replayFromStartLocation.Y;
		turret.overrideCurrentRotation(newRot);
		newRot.Yaw = replayFromEndLocation.X;
		newRot.Pitch = replayFromEndLocation.Y;
		turret.motor.setViewTarget(newRot);

		bUpdating = true;
		i = 0;
		while ( i < TribesSavedMoves.Length )
		{
			CurrentMove = TribesSavedMoves[i];
			// Discard moves older than the correction time stamp
			if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
			{
				CurrentMove.Clear();
				AppendFreeMove(CurrentMove);
				PopSavedMove();
			}
			else
			{
				i++;
				restored++;

				processTurretMove(CurrentMove.Delta, CurrentMove.strafe, CurrentMove.forward);
				CurrentMove.Rotation = turret.motor.getViewRotation();
			}
		}
		if ( TribesPendingMove != None )
		{
			restored++;

			processTurretMove(CurrentMove.Delta, CurrentMove.strafe, CurrentMove.forward);
			CurrentMove.Rotation = turret.motor.getViewRotation();
		}

		if (restored > 0 && debugLogLevel > 0)
			log("Client turret update position restored "$restored$" moves");

		bUpdating = false;
	}

	exec function Fire(optional float F)
	{
		local Turret turret;

		turret = Turret(Pawn);
		if (turret != None)
		{
			turret.motor.fire();
		}
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
		local Turret turret;

		turret = Turret(Pawn);
		if (turret != None)
		{
			turret.motor.releaseFire();
		}
	}

	exec function releaseAltFire(optional float F)
	{
	}

	// When you hit use inside the Turret, you get out.
	function ServerUse()
	{
		local Turret Turret;

		Turret = Turret(Pawn);
		if (Turret != None)
		{
			Turret.bGetOut = true;
		}
	}
	
	// player cannot use third person view while manning turrets
	function ToggleBehindView()
	{
		// do nothing
	}

	function serverSelectWeapon(Weapon w)
	{
		// do nothing
	}

  	function BeginState()
	{
		CleanOutSavedMoves();
		clientTribesSetHUD(turretHUDClass);
	}
	
	function EndState()
	{
		CleanOutSavedMoves();
		releaseFire();
	}

}

function serverVehicleTurretMove(int packedMoveRotation, int packedVehicleSpaceRotation)
{
	local VehicleMountedTurret turret;

	local rotator moveRotation;
	local rotator vehicleSpaceRotation;

	moveRotation = class'Vehicle'.static.unpackPitchAndYaw(packedMoveRotation);

	vehicleSpaceRotation = class'Vehicle'.static.unpackPitchAndYaw(packedVehicleSpaceRotation);

	turret = VehicleMountedTurret(Pawn);
	if (turret == None)
		return;

	// client handled counter rotation so simply set it to 0
	turret.processMove(moveRotation, vehicleSpaceRotation);

	setRotation(moveRotation);
}

// State PlayerVehicleTurreting
//
// Player controlling a Turret.
//
state PlayerVehicleTurreting
{
	ignores SeePlayer, HearNoise, Bump;

	function TribesServerMove
	(
		float TimeStamp, 
		Vector ClientLoc,
		int View,
		EDigitalAxisInput forward,
		EDigitalAxisInput strafe,
		bool ski,
		bool thrust,
		bool jump,
		optional byte CompressedImportantTimeDelta,
		optional int ImportantMoveData
	)
	{
		TribesShortClientAdjustPositionEx
		(
			TimeStamp, 0, 0, GetStateName(), MovementState_Stand, Location.X, Location.Y, Location.Z, Location.X, Location.Y, Location.Z
		);
	}

	function TribesLongClientAdjustPosition
	(
		float TimeStamp, 
		float accumulator,
		float energy,
		name newState, 
		Character.MovementState movement,
		float StartLocX, 
		float StartLocY, 
		float StartLocZ, 
		float EndLocX, 
		float EndLocY, 
		float EndLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ
	)
	{
		// do nothing
	}

	exec function SwitchWeapon(byte F)
	{

	}

	exec function Suicide()
	{
		// suicide character instead of vehicle
		local VehicleMountedTurret turret;
		local Character occupant;
		if (Level.NetMode == NM_Client)
			return;
		turret = VehicleMountedTurret(Pawn);
		occupant = turret.ownerVehicle.positions[turret.positionIndex].occupant;
		if ((occupant != None) && (Level.TimeSeconds - occupant.LastStartTime > 1))
			occupant.TakeDamage(occupant.health + 1, None, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'DamageType');
	}

	exec function switchVehiclePosition(byte position)
	{
		local VehicleMountedTurret turret;
		local Character occupant;

		// handle case we are heavy and trying to switch to a pilot position
		turret = VehicleMountedTurret(Pawn);
		occupant = turret.ownerVehicle.positions[turret.positionIndex].occupant;
		if (turret.ownerVehicle.getTargetPositionIndex(position) == turret.ownerVehicle.driverIndex &&
				!turret.ownerVehicle.canArmorOccupy(VP_DRIVER, occupant))
		{
			lowPriorityPromptText = class'Vehicle'.default.heavyAttemptedToPilot;
			lowPriorityPromptTimeout = class'Vehicle'.default.heavyAttemptedToPilotSwitchPromptDuration;
			return;
		}

		serverSwitchVehiclePosition(position);
	}

	function stateServerSwitchVehiclePosition(byte position)
	{
		local VehicleMountedTurret turret;
		turret = VehicleMountedTurret(Pawn);
		turret.ownerVehicle.switchPosition(turret.positionIndex, position);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{

	}

	function PlayerMove(float deltaTime)
	{
		local rotator moveRotation;
		local VehicleMountedTurret turret;
		local DynamicTurretRotationProcessingOutput output;
		local float zoomScale;

		turret = VehicleMountedTurret(Pawn);
		if (turret == None)
			return;

		// use turret rotation as base rotation
		moveRotation = turret.worldSpaceNoRollRotation;

		// zoom
		if (turret.getDriver() != None)
			turret.getDriver().setZoomed(bZoom != 0);
		
		zoomScale = 1;
		if (bZoom != 0)
			zoomScale = zoomedMouseScale[zoomLevel];

		// apply user input (copy pasted from PlayerController.UpdateRotation)
		moveRotation.Yaw += 32.0 * deltaTime * aTurn * zoomScale;
		moveRotation.Pitch += 32.0 * deltaTime * aLookUp * zoomScale;

		output = dynamicTurretRotationProcessing(moveRotation, turret.ownerVehicle.Rotation, turret.minimumPitch, turret.maximumPitch,
				turret.yawConstrained, turret.yawPositiveDirection, turret.yawStart, turret.yawRange);
		turret.worldSpaceNoRollRotation = output.worldSpaceNoRollRotation;
		turret.vehicleSpaceRotation = output.vehicleSpaceRotation;

		setRotation(turret.worldSpaceNoRollRotation);

		// forward to result server
		if (Role < ROLE_Authority)
		{
			serverVehicleTurretMove(class'Vehicle'.static.packPitchAndYaw(turret.worldSpaceNoRollRotation),
					class'Vehicle'.static.packPitchAndYaw(turret.vehicleSpaceRotation));
		}
	}

	function ViewShake(float deltaTime)
	{
		// ignored
	}

	exec function fire(optional float F)
	{
		local VehicleMountedTurret turret;

		turret = VehicleMountedTurret(Pawn);
		if (turret == None)
			return;

		turret.turretFire();
	}

	exec function AltFire( optional float F )
	{
	}

	exec function releaseFire(optional float F)
	{
		local VehicleMountedTurret turret;

		turret = VehicleMountedTurret(Pawn);
		if (turret == None)
			return;

		turret.turretCeaseFire();
	}

	exec function releaseAltFire(optional float F)
	{
	}

	// When you hit use inside the Turret, you get out.
	function ServerUse()
	{
		local VehicleMountedTurret turret;

		if (Role != ROLE_Authority)
			return;

		turret = VehicleMountedTurret(Pawn);
		if (turret != None)
		{
			turret.getOut();
		}
	}

	function BeginState()
	{
		local VehicleMountedTurret turret;

		bOldBehindView = bBehindView;

		CleanOutSavedMoves();
		clientTribesSetHUD(vehicleHUDClass);

		// set initial worldSpaceNoRollRotation as it is not updated when there is no occupant
		turret = VehicleMountedTurret(Pawn);
		if (turret != None)
			turret.worldSpaceNoRollRotation = turret.getDefaultOccupantRotation();
	}

	function EndState()
	{
		CleanOutSavedMoves();
		releaseFire();

		bBehindView = bOldBehindView;
	}

	// player cannot use third person view while manning vehicle turrets
	function ToggleBehindView()
	{
		// do nothing
	}

	event playerTick(float deltaTime)
	{
		local VehicleMountedTurret turret;

		Global.playerTick(deltaTime);

		turret = VehicleMountedTurret(Pawn);
		if (turret != None)
			ProcessZoom(deltaTime, turret.getDriver());
	}

	exec function NextWeapon()
	{
		// nothing
	}

	exec function PrevWeapon()
	{
		// nothing
	}

	exec function equipCarryable()
	{
	}

	exec function equipDeployable()
	{
	}
}

exec function switchVehiclePosition(byte position)
{
	// nothing
}

function serverSwitchVehiclePosition(byte position)
{
	stateServerSwitchVehiclePosition(position);
}

// I originally simply implemented serverSwitchVehiclePosition in the appropriate states however I found that it would not correctly
// replicate to one of the states. To work around this I replicate a global function, serverSwitchVehiclePosition, and then forward the
// call to the states server side using stateServerSwitchVehiclePosition.
function stateServerSwitchVehiclePosition(byte position)
{

}

function tribesProcessDrive(float inForward, float inStrafe, rotator directionRotation, bool inThrust, bool inDive)
{
}

function tribesServerDrive(EDigitalAxisInput inForward, EDigitalAxisInput inStrafe, int packedRotation, bool inThrust, bool inDive)
{
	local rotator directionRotation;
	directionRotation = class'Vehicle'.static.unpackPitchAndYaw(packedRotation);
	tribesProcessDrive(digitalToAnalogue(inForward, 24000), digitalToAnalogue(inStrafe, 24000), directionRotation, inThrust, inDive);
}

// State TribesPlayerDriving
//
// Player driving a vehicle.
//
state TribesPlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

	function TribesServerMove
	(
		float TimeStamp, 
		Vector ClientLoc,
		int View,
		EDigitalAxisInput forward,
		EDigitalAxisInput strafe,
		bool ski,
		bool thrust,
		bool jump,
		optional byte CompressedImportantTimeDelta,
		optional int ImportantMoveData
	)
	{
		TribesShortClientAdjustPositionEx
		(
			TimeStamp, 0, 0, GetStateName(), MovementState_Stand, Location.X, Location.Y, Location.Z, Location.X, Location.Y, Location.Z
		);
	}

	function TribesLongClientAdjustPosition
	(
			float TimeStamp, 
			float accumulator,
			float energy,
			name newState, 
			Character.MovementState movement,
			float StartLocX, 
			float StartLocY, 
			float StartLocZ, 
			float EndLocX, 
			float EndLocY, 
			float EndLocZ, 
			float NewVelX, 
			float NewVelY, 
			float NewVelZ
	)
	{
		if (!CommonClientAdjustPosition(timeStamp, newState))
			return;
	}

	exec function SwitchWeapon(byte F)
	{

	}

	exec function Suicide()
	{
		// suicide character instead of vehicle
		local Vehicle vehicle;
		local Character occupant;
		if (Level.NetMode == NM_Client)
			return;
		vehicle = Vehicle(Pawn);
		occupant = vehicle.positions[vehicle.driverIndex].occupant;
		if ((occupant != None) && (Level.TimeSeconds - occupant.LastStartTime > 1))
			occupant.TakeDamage(occupant.health + 1, None, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'DamageType');
	}

	exec function switchVehiclePosition(byte position)
	{
		serverSwitchVehiclePosition(position);
	}

	function stateServerSwitchVehiclePosition(byte position)
	{
		local Vehicle vehicle;
		vehicle = Vehicle(Pawn);
		vehicle.switchPosition(vehicle.driverIndex, position);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{

	}

    exec function fire(optional float F)
    {
		local Vehicle drivenVehicle;

		drivenVehicle = Vehicle(Pawn);
		if (drivenVehicle != None)
		{
			drivenVehicle.vehicleFire();
		}
    }

	exec function releaseFire(optional float F)
	{
		local Vehicle drivenVehicle;

		drivenVehicle = Vehicle(Pawn);
		if (drivenVehicle != None)
		{
			drivenVehicle.vehicleCeaseFire();
		}
	}

    exec function altFire(optional float F)
    {

    }

	exec function releaseAltFire(optional float F)
	{

	}

	// When you hit use inside the SVehicle, you get out.
	function ServerUse()
	{
		local Vehicle drivenVehicle;

		if (Role != ROLE_Authority)
			return;

		drivenVehicle = Vehicle(Pawn);
		if (drivenVehicle != None)
		{
			drivenVehicle.getOut(VP_DRIVER);
		}
	}

	// Set the throttle, steering etc. for the vehicle based on the input provided
	function tribesProcessDrive(float inForward, float inStrafe, rotator directionRotation, bool inThrust, bool inDive)
	{
		local Vehicle DrivenVehicle;

		DrivenVehicle = Vehicle(Pawn);

		drivenVehicle.motor.driveVehicle(inForward, inStrafe, directionRotation, inThrust, inDive);
	}

    function PlayerMove( float DeltaTime )
	{
		local Vehicle drivenVehicle;
		local float zoomScale;
		local rotator newRotation;

		drivenVehicle = Vehicle(Pawn);

		if (drivenVehicle == None)
			return;

		// zoom
		if (drivenVehicle.getDriver() != None)
			drivenVehicle.getDriver().setZoomed(bZoom != 0);

		zoomScale = 1;
		if (bZoom != 0)
			zoomScale = zoomedMouseScale[zoomLevel];

		newRotation = Rotation;

		// apply user input (copy pasted from PlayerController.UpdateRotation)
		newRotation.Yaw += 32.0 * deltaTime * aTurn * zoomScale;
		newRotation.Pitch += 32.0 * deltaTime * aLookUp * zoomScale;

		newRotation = normalize(newRotation);
		newRotation.Pitch = clamp(newRotation.Pitch, drivenVehicle.driverMinimumPitch, drivenVehicle.driverMaximumPitch);

		setRotation(newRotation);

		// give vehicle a chance to do any necessary processing
		drivenVehicle.playerMoveProcessing(DeltaTime);

		// only servers can actually do the driving logic
		if (Role < ROLE_Authority)
			tribesServerDrive(analogueToDigital(aForward, 24000), analogueToDigital(aStrafe, 24000), class'Vehicle'.static.packPitchAndYaw(Rotation), bJetpack == 1, bSki == 1);
		else
			tribesProcessDrive(aForward, aStrafe, Rotation, bJetpack == 1, bSki == 1);
	}

	event playerTick(float deltaTime)
	{
		local Vehicle drivenVehicle;

		Global.playerTick(deltaTime);

		drivenVehicle = Vehicle(Pawn);
		if (drivenVehicle != None)
			ProcessZoom(deltaTime, drivenVehicle.getDriver());
	}

	function ToggleBehindView()
	{
		// do nothing
	}

	function BeginState()
	{
		bOldBehindView = bBehindView;

		CleanOutSavedMoves();
		clientTribesSetHUD(vehicleHUDClass);
	}
	
	function EndState()
	{
		local Vehicle DrivenVehicle;

		CleanOutSavedMoves();

		bBehindView = bOldBehindView;

		// turn vehicle off
		DrivenVehicle = Vehicle(Pawn);
		if (DrivenVehicle != None)
			drivenVehicle.motor.driveVehicle(0, 0, Rotation, false, false);
	}

	function Pawn GetTravelPawn()
	{
		local Vehicle drivenVehicle;

		drivenVehicle = Vehicle(Pawn);
		if (drivenVehicle != None)
			return drivenVehicle.getDriver();
		else
			return global.GetTravelPawn();
	}

	exec function NextWeapon()
	{
		// nothing
	}

	exec function PrevWeapon()
	{
		// nothing
	}

	exec function equipCarryable()
	{
	}

	exec function equipDeployable()
	{
	}
}

// enter combat alertness.
// alertness degrades over time, first to alert, then back down to neutral.

function enterCombat()
{
    character.setAlertnessLevel(ALERTNESS_Combat);
    SetTimer(alertnessDecayTime, false);

    if (character==None)
        return;

    if (alertnessMode!=AlertnessMode_Default)
        return;
}

function Timer()
{
	if (character==None)
		return;

    if (alertnessMode!=AlertnessMode_Default)
        return;

    if (character.getAlertnessLevel()==ALERTNESS_Combat)
    {
        character.setAlertnessLevel(ALERTNESS_Alert);
        SetTimer(alertnessDecayTime, false);
    }
    else
        character.setAlertnessLevel(ALERTNESS_Neutral);
}

// serverSelectWeapon
function serverSelectWeapon(Weapon w)
{
	if (character != None && character.motor != None)
	{
		character.motor.setWeapon(w);
	}
}

// serverEquipDeployable
function serverEquipDeployable()
{
	local Deployable d;

	if (character == None)
		return;

	d = Deployable(character.nextEquipment(d, class'Deployable'));

	if (character.deployable == d)
		return;

	if (d == None)
	{
//		ClientMessage("You do not have a deployable");
		return;
	}
	else
	{
		if (character != None && character.motor != None)
			character.motor.setDeployable(d);
	}
}

// serverEquipCarryable
function serverEquipCarryable()
{
	if (character == None)
		return;

	if (character != None && character.motor != None && character.carryableReference != None && character.carryableReference.bIsWeaponType &&
		character.weapon != character.pseudoWeapon && character.numCarryables > character.numPermanentCarryables)
		character.motor.setWeapon(character.pseudoWeapon);
}

// PrevWeapon
exec simulated function PrevWeapon()
{
	serverPrevWeapon();
}

function serverPrevWeapon()
{
	local int i;
	local Weapon w;

	if (character == None)
		return;

	if (character.motor.switchToWeapon != None)
		w = character.motor.switchToWeapon;
	else
		w = character.weapon;

	if (w != None && w != character.fallbackWeapon && w != character.pseudoWeapon && character.deployable == None)
	{
		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
			if (character.weaponSlots[i] == w)
				break;

		if (i < class'Character'.const.NUM_WEAPON_SLOTS)
		{
			--i;

			if (i < 0)
				i = class'Character'.const.NUM_WEAPON_SLOTS - 1;

			while (character.weaponSlots[i] == None)
			{
				--i;

				if (i < 0)
					i = class'Character'.const.NUM_WEAPON_SLOTS - 1;
			}

			if (character.weaponSlots[i] != w)
				serverSelectWeapon(character.weaponSlots[i]);
		}
	}
	else // No current weapon so just find the last non-None weapon
	{
		for (i = class'Character'.const.NUM_WEAPON_SLOTS - 1; i >= 0 ; --i)
		{
			if (character.weaponSlots[i] != None)
			{
				serverSelectWeapon(character.weaponSlots[i]);
				return;
			}
		}
	}
}

// NextWeapon
exec simulated function NextWeapon()
{
	serverNextWeapon();
}

function serverNextWeapon()
{
	local int i;
	local Weapon w;

	if (character == None)
		return;

	if (character.motor.switchToWeapon != None)
		w = character.motor.switchToWeapon;
	else
		w = character.weapon;

	if (w != None && w != character.fallbackWeapon && w != character.pseudoWeapon && character.deployable == None)
	{
		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
			if (character.weaponSlots[i] == w)
				break;

		if (i < class'Character'.const.NUM_WEAPON_SLOTS)
		{
			i = (i + 1) % class'Character'.const.NUM_WEAPON_SLOTS;

			while (character.weaponSlots[i] == None)
				i = (i + 1) % class'Character'.const.NUM_WEAPON_SLOTS;

			if (character.weaponSlots[i] != w)
				serverSelectWeapon(character.weaponSlots[i]);
		}
	}
	else // No current weapon so just find the first non-None weapon
	{
		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
		{
			if (character.weaponSlots[i] != None)
			{
				serverSelectWeapon(character.weaponSlots[i]);
				return;
			}
		}
	}
}

simulated function ShiftWeapon(int offset)
{
	local int i;
	local Weapon w;

	if (character == None)
		return;

	if (character.motor.switchToWeapon != None)
		w = character.motor.switchToWeapon;
	else
		w = character.weapon;

	if (w != None)
	{
		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
			if (character.weaponSlots[i] == w)
				break;

		if (i < class'Character'.const.NUM_WEAPON_SLOTS)
		{
			i += offset;

			if (i < 0)
				i = class'Character'.const.NUM_WEAPON_SLOTS - 1;
			else if (i >= class'Character'.const.NUM_WEAPON_SLOTS)
				i = 0;

			serverSelectWeapon(character.weaponSlots[i]);
		}
	}
	else // There is no current weapon so the concept of next prev don't apply. Find the first non-None weapon
	{
		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
			if (character.weaponSlots[i] != None)
				break;

		if (i < class'Character'.const.NUM_WEAPON_SLOTS)
			serverSelectWeapon(character.weaponSlots[i]);
	}
}

// SwitchWeapon
exec function SwitchWeapon(byte F)
{
	//local int i;
	local Weapon w;

	if (character == None)
		return;

	w = character.weaponSlots[F - 1];

	if (w != None)
	{
		if (bDropWeapon != 0)
			w.drop();
		else
			serverSelectWeapon(w);
	}
}

// Equips a particular weapon class
exec function SetWeapon(class<Weapon> WeaponClass)
{
	local Weapon w;

	w = Weapon(character.nextEquipment(w, WeaponClass));

	if (w == None)
		return;

	if (bDropWeapon != 0)
		w.drop();
	else
		serverSelectWeapon(w);
}

exec function SwitchToFallbackWeapon()
{
	if (character == None && character.motor != None)
		return;

	serverEquipFallbackWeapon();
}

// Allow zoom level changes when not zoomed
exec simulated function forceCycleZoomLevel(optional bool bReverse)
{
	if (character == None)
		return;

	if (!bReverse)
	{
		zoomLevel = zoomLevel + 1;
		if (zoomLevel == zoomedFOVs.Length)
			zoomLevel = 0;
	}
	else
	{
		zoomLevel = zoomLevel - 1;
		if (zoomLevel < 0)
			zoomLevel = zoomedFOVs.Length - 1;
	}
}

exec simulated function setZoomLevel(int index)
{
	if (character == None)
		return;

	zoomLevel = index;
	if (zoomLevel >= zoomedFOVs.Length)
		zoomLevel = zoomedFOVs.Length - 1;
	else if (zoomLevel < 0)
		zoomLevel = 0;
}


// cycleZoomLevel
exec simulated function cycleZoomLevel(optional bool bReverse)
{
	if (character == None)
		return;

	if (character.isZoomed())
	{
		if (!bReverse)
		{
			zoomLevel = zoomLevel + 1;
			if (zoomLevel == zoomedFOVs.Length)
				zoomLevel = 0;
		}
		else
		{
			zoomLevel = zoomLevel - 1;
			if (zoomLevel < 0)
				zoomLevel = zoomedFOVs.Length - 1;
		}
	}
}

// CycleRadarZoomScale
exec simulated function CycleRadarZoomScale()
{
	if(character == None)
		return;

	radarZoomIndex = (radarZoomIndex + 1) % radarZoomScales.Length;

	serverSetRadarZoomScale(radarZoomScales[radarZoomIndex]);
}

// cycles the index into the size of the chat 
// window (ie: number of lines to display
exec simulated function CycleChatWindowSize()
{
	if(IsSinglePlayer())
		SPChatWindowSizeIndex = (SPChatWindowSizeIndex + 1) % SPChatWindowSizes.Length;
	else
		chatWindowSizeIndex = (chatWindowSizeIndex + 1) % chatWindowSizes.Length;
}

// Scrolls the chat window text by a specified numer of lines
//
exec simulated function ScrollChatWindow(int NumLines)
{
	clientSideChar.ChatScrollDelta += NumLines;
}

// equipDeployable
exec simulated function equipDeployable()
{
	serverEquipDeployable();
}

// equipCarryable
exec simulated function equipCarryable()
{
	serverEquipCarryable();
}

// called to talk
exec function TribesTalk()
{
	// dont let SP players talk
	if(! IsSinglePLayer())
		clientSideChar.bTalk = true;
	else
		clientSideChar.bTeamTalk = false;
}

// called to teamtalk
exec function TribesTeamTalk()
{
	// dont let SP players talk
	if(! IsSinglePLayer())
		clientSideChar.bTeamTalk = true;
	else
		clientSideChar.bTeamTalk = false;
}

function bool IsChatSpam()
{
	if(! ChatSpamGuardEnabled)
		return false;

	// still muted, return true instantly
	if(Level.TimeSeconds < (ChatSpamMutedTime + ChatSpamMutePeriod))
		return true;

	if(Level.TimeSeconds > (LastValidChatTime + ChatSpamThresholdTime))
	{
		LastValidChatTime = Level.TimeSeconds;
		ChatCount = 0;
	}
	else
	{
		ChatCount++;
		if(ChatCount >= ChatSpamMaxMessages)
		{
			ChatCount = 0;
			ChatSpamMutedTime = Level.TimeSeconds;
		}
	}

	return false;
}

function ApplyMessageRestrictions(out String Msg)
{
	Msg = TribesReplicationInfo(PlayerReplicationInfo).stripCodes(Msg);
	Msg = Repl(Msg, "¼", "", false);
	if(Len(Msg) > MaxMessageTextLength)
		Msg = Left(Msg, MaxMessageTextLength);
}

exec function Say(String Msg)
{
	if(IsChatSpam())
		return;

	ApplyMessageRestrictions(Msg);
	super.Say(Msg);
}

exec function TeamSay(String Msg)
{
	if(IsChatSpam())
		return;

	ApplyMessageRestrictions(Msg);
	super.TeamSay(Msg);
}

exec function QuickChat(String message, String ChatTag, optional bool bLocal, optional String animName)
{
	if(IsChatSpam())
		return;

	ApplyMessageRestrictions(message);

	if(! bLocal)
	{
		Level.Game.Broadcast(self, ChatTag $"?" $message, 'QuickChat');
		if(Character(Pawn) != None && animName != "")
			Character(Pawn).PlayQCAnimation(animName);
	}
	else if(Character(Pawn) != None)
	{
		Character(Pawn).PlayQCSpeech(ChatTag);
		if(animName != "")
			Character(Pawn).PlayQCAnimation(animName);
	}
}

exec function TeamQuickChat(String message, String ChatTag, optional bool bLocal, optional String animName)
{
	if(IsChatSpam())
		return;

	ApplyMessageRestrictions(message);
	
	if(! bLocal)
	{
		Level.Game.BroadcastTeam(self, ChatTag $"?" $message, 'TeamQuickChat');
		if(Character(Pawn) != None && animName != "")
			Character(Pawn).PlayQCAnimation(animName);
	}
	else if(Character(Pawn) != None)
	{
		Character(Pawn).PlayQCSpeech(ChatTag);
		if(animName != "")
			Character(Pawn).PlayQCAnimation(animName);
	}
}

exec function ShowHelpScreen()
{
	// uncomment when the menu is finished (needs Art)
	MyHUD.bHideHud = true;
	ClientOpenMenu(HelpScreenClass);
}

// ProcessZoom
simulated function ProcessZoom(float Delta, Character c)
{
	if (c == None)
		return;

	if (c.bCanZoom)
	{
		if (c.isZoomed())
		{
			if (FOVAngle > zoomedFOVs[zoomLevel])
				FOVAngle -= (FOVAngle - zoomedFOVs[zoomLevel]) * zoomSpeed;
			else
				FOVAngle = zoomedFOVs[zoomLevel];
		}
		else
		{
			if (FOVAngle < DefaultFOV)
				FOVAngle += (DefaultFOV - FOVAngle) * zoomSpeed;
			else
				FOVAngle = DefaultFOV;
		}
	}
	else
	{
		FOVAngle = DefaultFOV;
	}
}

// setIsFemale
function setIsFemale(bool b)
{
	PlayerReplicationInfo.bIsFemale = b;
	MultiplayerGameInfo(Level.Game).SetPlayerMesh(self);
}

// changeTeam (replicated)
function changeTeam(int i, optional bool bAdminOverride)
{
	local TeamInfo t;
	local TribesReplicationInfo TRI;

	// See if this switchteam is allowed, unless an admin has overridden it
	if (!bAdminOverride)
	{
		if (!Level.Game.ChangeTeam(self, i, true))
			return;
	}

	t = getTeamInfo(i);
	TRI = TribesReplicationInfo(PlayerReplicationInfo);

	if (t == None || TRI.team == t)
		return;

	if (character != None)
	{
		character.Died( None, class'DamageType', character.Location );
	}

	TRI.setTeam(t);
	TRI.bTeamChanged = true;

	GotoState('PlayerRespawn');
	ClientGotoState('PlayerRespawn');
}

function TeamInfo getTeamInfo(int index)
{
	local TeamInfo t;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (t.TeamIndex == index)
            return t;
	}

	return None;
}

// switchTeam (replicated)
function switchTeam(optional bool bAdminOverride)
{
	local TeamInfo t;
	local bool bFoundTeam;
	local TribesReplicationInfo TRI;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (bFoundTeam)
			break;

		if (TribesReplicationInfo(PlayerReplicationInfo).team == t)
            bFoundTeam = true;
	}

	if (t == None)
		ForEach DynamicActors(class'TeamInfo', t)
			break;

	if (t == None)
		return;

	// See if this switchteam is allowed, unless an admin has overridden it
	if (!bAdminOverride)
	{
		if (!Level.Game.ChangeTeam(self, t.TeamIndex, true))
			return;
	}

	if (Pawn != None)
	{
		serverKillPlayer();
	}

	TRI = TribesReplicationInfo(PlayerReplicationInfo);
	TRI.setTeam(t);
	TRI.bTeamChanged = true;

	GotoState('PlayerRespawn');
	ClientGotoState('PlayerRespawn');
}

// spectate (replicated)
function spectate(optional string playerName)
{
	if (PlayerReplicationInfo.bIsSpectator && playerName != "")
	{
		SpectatePlayer(playerName);
		return;
	}

	if (PlayerReplicationInfo.bIsSpectator && playerName != "")
	{
		GameInfo(Level.Game).onUnspectate(self);
	}
	else
		GameInfo(Level.Game).onSpectate(self);
}

function SpectatePlayer(string playerName)
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;

	// view player
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
        if ( C.playerReplicationInfo != None && C.playerReplicationInfo.PlayerName == playerName && Level.Game.CanSpectate(self,true,C) )
		{
			if ( Pick == None )
                Pick = C;
			if ( bFound )
			{
                Pick = C;

				// Don't allow spectating of spectators
				if (Pick.playerReplicationInfo.bIsSpectator)
					return;

				break;
			}	
			else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
		}
	}

	if (Pick == None)
		return;

	SetViewTarget(Pick);
    ClientSetViewTarget(Pick);
	bBehindView = true; //bChaseCam;
    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

exec function activatePack()
{
	serverActivatePack();

	// forward to character
	if (Level.NetMode != NM_Client && character != None)
		character.activatePack();
}

function serverActivatePack()
{
	// forward to character
	if (character != None)
		character.activatePack();
}

///////////////////////////////////////////////////////////////////////////////
//
// Adds a damage direction to the flags in the hud data
//
simulated function ClientDamagedFrom(EDirectionType direction, int DamageAmount)
{
	if(clientSideChar.DamageAmounts[direction] < DamageAmount)
		clientSideChar.DamageAmounts[direction] = DamageAmount;
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local vector color;
	local float damagePercentage, scale;

	local vector direction, xAxis, yAxis, zAxis;
	local float longDot, latDot;
	local Rotator rotation;

	color = damageFlashColor;

	if (damageFlashColor.X != 0)
		damageFlashColor.X += Damage * damageFlashMultiplier;
	if (damageFlashColor.Y != 0)
		damageFlashColor.Y += Damage * damageFlashMultiplier;
	if (damageFlashColor.Z != 0)
		damageFlashColor.Z += Damage * damageFlashMultiplier;

	// scale should be maximum at maxFlashThreshold
	// remember that with the scale, less is more
	damagePercentage = fClamp((Damage / character.healthMaximum) / maxFlashThreshold, 0.0, 1.0);
	scale = fClamp(1.0 - damagePercentage, 0.0, 1.0 - minFlashThreshold);

	// Flash the screen
//  if (myHUD.PlayerOwner.ViewTarget==Pawn)
//		ClientFlash(scale, damageFlashColor);

	if(Rook != None)
	{
		rotation = Normalize(Rook.Rotation);
		if(InstigatedBy != None)
			direction = Normal(Rook.Location - InstigatedBy.Location);
		GetAxes(rotation, xAxis, yAxis, zAxis);
		longDot = (direction Dot xAxis);

		rotation.yaw += 16384;
		GetAxes(rotation, xAxis, yAxis, zAxis);
		latDot = (direction Dot xAxis);

		// check if we are hurting ourselves (dumbass!)
		if(longDot == 0 && latDot == 0)
		{
			ClientDamagedFrom(EDirectionType.DAMAGE_Front, Damage);
			ClientDamagedFrom(EDirectionType.DAMAGE_Rear, Damage);
			ClientDamagedFrom(EDirectionType.DAMAGE_Left, Damage);
			ClientDamagedFrom(EDirectionType.DAMAGE_Right, Damage);
		}

		if(longDot > 0 && Abs(latDot) < 0.75)
			ClientDamagedFrom(EDirectionType.DAMAGE_Rear, Damage);
		if(Abs(longDot) < 0.75 && latDot < 0)
			ClientDamagedFrom(EDirectionType.DAMAGE_Right, Damage);
		if(Abs(longDot) < 0.75 && latDot > 0)
			ClientDamagedFrom(EDirectionType.DAMAGE_Left, Damage);
		if(longDot < 0 && Abs(latDot) < 0.75)
			ClientDamagedFrom(EDirectionType.DAMAGE_Front, Damage);
	}
}

// debug function for choosing a spawn base, multiplayer only
exec function debugSwitchSpawnBase()
{
	local BaseInfo b;
	local BaseInfo chosen;
	local bool bFound;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		if (bFound && b.team == character.team())
		{
			chosen = b;
			break;
		}

		if (b == spawnBase)
		{
			bFound = true;
		}
	}

	if (chosen == None) // wrap around
		ForEach DynamicActors(class'BaseInfo', b)
			if (b.team == character.team())
			{
				chosen = b;
				break;
			}

	spawnBase = chosen;

	ClientMessage("New spawn base is "$b.label);
}

state CameraControlled
{
	exec function Fire( optional float F ) {}
	exec function releaseFire( optional float F ) {}
	exec function AltFire(optional float F) {}
	exec function releaseAltFire(optional float F) {}
	exec function Jetpack( optional float F ) {}

	exec simulated function bool SkipOpeningCutscene()
	{
		if(CutsceneManager(Level.cutsceneManager).CancelOpeningCutscence())
		{
			// return control to the player camera:
			controllingCamera.actionControlledReturn();
			if (CinematicOverlay != None)
				CinematicOverlay.ClearSubtitle();
			return true;
		}

		return false;
	}

	exec function use()
	{
		// freeze player during cutscenes
		if (isInCutscene())
			return;

		controllingCamera.playerControlledReturn();
	}

	function playerTick(float deltaSeconds)
	{
		// Not sure if we need these yet
		//ViewShake(DeltaTime);
		//ViewFlash(DeltaTime);
	}
}

function TeamInfo getOwnTeam()
{
	// Figures out what team this controller is on, if applicable
	return TribesReplicationInfo(PlayerReplicationInfo).team;
}

function TeamInfo getOtherTeam()
{
	local TeamInfo t;

	// Returns the first team that isn't the same as this controller's
	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (t != getOwnTeam())
			return t;
	}

	return None;
}

function class<Weapon> GetLastWeapon()
{
	if ( (Character == None) || (Character.Weapon == None) )
		return lastWeaponClass;
	return Character.Weapon.Class;
}

function Tick(Float Delta)
{
	Super.Tick(Delta);

	// duplicated in PlayerTick
	// Listen servers don't run this for the player's own controller, but run this for joined players.
	camera.update(Delta);

	// Update objectives every tick
	if(PlayerReplicationInfo.IsA('TribesReplicationInfo'))
		objectives.updateObjectives(objectivesUpdateRate, TribesReplicationInfo(PlayerReplicationInfo).team);
	else
		objectives.updateObjectives(objectivesUpdateRate, None);
}

exec function Use()
{
	if (bUseEnabled)
		Super.Use();
}

// Player muting
function bool IsMuted(String PlayerName)
{
	local int i;

	for(i = 0; i < MutedPlayerList.Length; ++i)
		if(MutedPlayerList[i] ~= PlayerName)
			return true;

	return false;
}

// toggles player muting
exec function Mute(String PlayerName)
{
	local int i;
	local bool found;

	found = false;
	for(i = 0; i < MutedPlayerList.Length; ++i)
	{
		if(MutedPlayerList[i] ~= PlayerName)
		{
			MutedPlayerList.Remove(i--, 1);
			found = true;
		}
	}

	if(! found)
		MutedPlayerList[MutedPlayerList.Length] = PlayerName;
}

// will only switch it off
exec function UnMute(String PlayerName)
{
	// if the player is muted, call Mute to toggle the mote to off.
	if(IsMuted(PlayerName))
		Mute(PlayerName);
}

exec function ToggleQuickChat()
{
	if(bQuickChat == 1)
		bQuickChat = 0;
	else
		bQuickChat = 1;
}		

function serverDebugMovementReplication(int level)
{
	if (class'GameEngine'.default.EnableDevTools)
		debugLogLevel = level;
}

exec function debugMovementReplication(int level)
{
	if (class'GameEngine'.default.EnableDevTools)
	{
		debugLogLevel = level;
		ClientMessage("Movement replication debug: "$debugLogLevel);
		serverDebugMovementReplication(level);
	}
}

exec function movementReport()
{
    local float correctedPerc, combinedPerc, dualPerc;

	correctedPerc = (float(correctedMoves) / float(replicateMoveCalls))*100.0;
	combinedPerc = (float(combinedMoves) / float(replicateMoveCalls))*100.0;
	dualPerc = (float(dualMoves) / float(replicateMoveCalls))*100.0;

	// report stats
	LOG("-- PlayerCharacterController Stats --");
	LOG("ReplicateMove Calls : "$replicateMoveCalls);
	LOG("Combined Moves      : "$combinedMoves$" ("$combinedPerc$"%)");
	LOG("Corrections		 : "$correctedMoves$" ("$correctedPerc$"% if 0 loss)");
	LOG("Dual Moves			 : "$dualMoves$" ("$dualPerc$"% if 0 loss)");
}

// use PlayerCamera class
simulated event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	// If desired, call the pawn's own special callview
	if( Pawn != None && Pawn.bSpecialCalcView )
	{
		// try the 'special' calcview. This may return false if its not applicable, and we do the usual.
		if( Pawn.SpecialCalcView(ViewActor, CameraLocation, CameraRotation) )
			return;
	}

	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
		if ( (Pawn != None) && !Pawn.bDeleteMe )
			SetViewTarget(Pawn);
        else if ( RealViewTarget != None )
            SetViewTarget(RealViewTarget);
		else
			SetViewTarget(self);
	}

	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;

	if ( ViewTarget == self )
	{
		if ( bCameraPositionLocked )
			CameraRotation = CheatManager.LockedRotation;
		else
			CameraRotation = Rotation;
// IGA >>> Cinematic camera shake
		CameraLocation = CameraLocation + CinematicShakeOffset;
		CameraRotation = CameraRotation + CinematicShakeRotate;
// IGA
		return;
	}
	else
		camera.calcView(CameraLocation, CameraRotation);
}

simulated function InventoryCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Rotator StationRotation;

	if(Buggy(character.Base) != None)
	{
		// we are in a Rover Inv station...
		Buggy(character.Base).InventoryCalcView(ViewActor, CameraLocation, CameraRotation);
	}
	else
	{
		// always third person
		ViewActor = Pawn;

		// calculate camera location
		StationRotation.Yaw = inventoryStation.Rotation.Yaw + 16384;
		CameraLocation = Pawn.Location + Pawn.EyePosition() + (InvExtCamOffset >> StationRotation);

		// point the camera at the inventoryStationAccess
		CameraRotation = Rotator(Normal(Pawn.Location + Pawn.EyePosition() - cameraLocation));
	}
}

function ServerToggleBehindView()
{
	ClientSetBehindView(!bBehindView, true);

	if (!bBehindView)
		camera.doZoomOut(0.15);
	else
		camera.doZoomIn(0.15);
}

function ClientSetBehindView(bool B, optional bool bInteractive)
{
	if (bInteractive)
	{
		if (B)
			camera.doZoomOut(0.15);
		else
			camera.doZoomIn(0.15);
	}
	else
		bBehindView = B;
}

event ShowSubtitle(String Subtitle, float lifetime)
{
	if(CinematicOverlay != None 
		&& SingleplayerGameInfo(Level.Game) != None
		&& SingleplayerGameInfo(Level.Game).default.bShowSubtitles)
		CinematicOverlay.AddSubtitle(Subtitle, lifetime);
}

function SetCinematicMode(bool bCinematic)
{
	if(bCinematic)
	{
		if(Player.GUIController.OpenMenu("MojoCore.CinematicOverlay"))
			CinematicOverlay = CinematicOverlay(GUIController(Player.GUIController).ActivePage);
		else
			Warn("Could not open cinematic overlay");
	}
	else
	{
		Player.GUIController.CloseMenu();
		CinematicOverlay = None;
	}
}

function GivePawn(Pawn NewPawn)
{
	//Log("GivePawn called in PCC with "$NewPawn$" for "$self$" in state "$GetStateName()$" and moveobj = "$character.movementObject);
	if ( NewPawn == None )
		return;

	Pawn = NewPawn;
	NewPawn.Controller = self;

	ClientRestart(NewPawn, GetStateName());
}	

function ServerViewNextMPObject()
{
    local MPActor A, Pick;
    local bool bFound;
	
	// view next mp object
	ForEach Level.AllActors(class'MPActor', A)
	{
        if ( Level.Game.CanSpectate(self,true,A) )
		{
			if ( Pick == None && A.bAllowSpectators )
                Pick = A;
			if ( bFound )
			{
                Pick = A;
				break;
			}	
			else
                bFound = ( (RealViewTarget == A) || (ViewTarget == A) && A.bAllowSpectators );
		}
	}
	SetViewTarget(Pick.getViewTarget());
    ClientSetViewTarget(Pick.getViewTarget());
    ClientSetBehindView(true);
}

function ServerViewNextSpectatorStart()
{
	// Not sure how to do this yet
	// Need to cycle through all PlayerStarts that have bObserverStart set to true; unfortunately they're
	// not pawns so you can't set them as viewtargets
}

function PlayPainSound(Character.EClientPainType type)
{
	if (character == None)
		return;

	switch (type)
	{
	case CLIENTPAIN_Hurt:
		character.PlayMovementSpeech( 'Hurt' );
		break;
	case CLIENTPAIN_BigHurt:
		character.PlayMovementSpeech( 'HurtLarge' );
		break;
	case CLIENTPAIN_Death:
		character.PlayMovementSpeech( 'Death' );
		break;
	case CLIENTPAIN_Cratered:
		character.PlayMovementSpeech( 'DeathCratered' );
		break;
	case CLIENTPAIN_Burnt:
		character.PlayMovementSpeech( 'DeathScream' );
		break;
	}
}

function bool isInCutscene()
{
	return CutsceneManager(Level.cutsceneManager) != None
			&& CutsceneManager(Level.cutsceneManager).playingCutscene != None
			&& CutsceneManager(Level.cutsceneManager).playingCutscene.scriptType == TYPE_OpeningCutscene;
}

native function ResetSpeedhack();

exec function dumpVehicleData()
{
	local Vehicle vehicle;

	log("********** VEHICLE DUMP" @ Level.TimeSeconds @ "**********");
	forEach DynamicActors(class'Vehicle', Vehicle)
	{
		log("==========" @ Vehicle @ "==========");
		log("Physics:" @ Vehicle.Physics);
		log("Havok Active:" @ Vehicle.HavokIsActive());
		log("Havok Completely Initialised:" @ Vehicle.isHavokCompletelyInitialised());
		log("Tick:" @ Vehicle.LastTick);
		log("Last State Received Time:" @ Vehicle.lastStateReceiveTime);
		log("Spawning:" @ Vehicle.spawning);
		log("Role:" @ Vehicle.Role);
		log("Tear Off:" @ Vehicle.bTearOff);
		log("Team:" @ Vehicle.team());
	}
}

defaultproperties
{
	// Important for net movement prediction -- MaxResponseTime should equal Fusion's delta clamp value
    MaxResponseTime=1.0
    MaxTimeMargin=1.0
	TimeMarginSlack=0.001

	// for PostNetReceive
	bNetNotify					= true

	CheatClass					= class'TribesCheatManager'
	DefaultFOV					= 95

	spectatorHUDClass			= "TribesGUI.TribesSpectatorHUD"
	countdownHUDClass			= "TribesGUI.TribesCountdownHUD"
	gameEndHUDClass				= ""
	respawnHUDClass				= "TribesGUI.TribesRespawnHUD"
	vehicleHUDClass				= "TribesGUI.TribesVehicleHUD"
	turretHUDClass				= "TribesGUI.TribesTurretHUD"
	inventoryStationMenuClass	= "TribesGUI.TribesInventorySelectionMenu"
	waitRoundEndHUDClass		= "TribesGUI.TribesAwaitRoundEndHUD"
	waitGameStartHUDClass		= "TribesGUI.TribesAwaitGameStartHUD"
	commandHUDClass				= "TribesGUI.TribesCommandHUD"
	HelpScreenClass				= "TribesGUI.TribesHelpScreen"
	GUIPackage					= "TribesGUI"
	SPEscapeMenuClass			= "TribesSPEscapeMenu"
	MPEscapeMenuClass			= "TribesMPEscapeMenu"
	MPStatsClass				= "TribesMPStatsPanel"
	MPWeaponStatsClass			= "TribesMPWeaponStatsPanel"
	MPGameStatsClass			= "TribesMPPlayersPanel"
	MPAdminClass				= "TribesMPAdminPanel"

	MovementObjectClass			= "Gameplay.CharacterPhysicsObject"

	PlayerReplicationInfoClass	= class'Gameplay.TribesReplicationInfo'

	m_identifyFrequency			= 0.1
	m_identifyRange				= 5000

    alertnessMode               = AlertnessMode_Default;
    alertnessDecayTime          = 10

    groundMovementMode          = GroundMovementMode_Any;

	damageFlashColor			= (X=900,Y=0,Z=0)
	damageFlashScale			= 0.3
	maxFlashThreshold			= 0.5
	minFlashThreshold			= 0.1
	damageFlashMultiplier		= 1

	livesLeft				    = -1

	IdentifyRadius				= 32

	InvExtCamOffset				= (X=-200,Y=0,Z=210)

	bUseEnabled					= true
	debugLogLevel				= 0
    SpectateSpeed=+1200.0
	maxSpectatorZoom			= 30
	minSpectatorZoom			= 6

	ChatSpamGuardEnabled		= true
	ChatSpamMaxMessages			= 4
	ChatSpamThresholdTime		= 4
	ChatSpamMutePeriod			= 8
	MaxMessageTextLength		= 196
}
