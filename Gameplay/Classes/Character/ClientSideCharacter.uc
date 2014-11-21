class ClientSideCharacter extends Core.RefCount
	dependsOn(ObjectiveInfo)
	dependsOn(Deployable)
	dependsOn(RadarInfo)
	native;

import enum EObjectiveStatus from ObjectiveInfo;
import enum EObjectiveType from ObjectiveInfo;
import enum EAllyType from ObjectiveInfo;
import enum EStateType from ObjectiveInfo;
import enum EInputKey from Interactions;
import enum EColorType from RadarInfo;

enum ETeamAlignment
{
	TA_Neutral,
	TA_Friendly,
	TA_Enemy
};

// Mouse pointer position
var int						MouseX;
var int						MouseY;

// user pref values
var EColorType				UserPrefColorType;

// Level time
var float					levelTimeSeconds;

var bool					bNeedCountDownTimer;
var bool					bRoundCountingDown;
var float					countDown;
var float					respawnTime;

// character location
var Vector					charLocation;
var Rotator					charRotation;

// movement stats
var float					Velocity;

// prompt window text & useable object marker
var string					promptText;
var Vector					useableObjectLocation;
var bool					bUseableObjectSwitch;
var bool					bCanBeUsed;		// true when the player can actually use the object (ie: in the zone)
var bool					bEnabledForUse;	// true if the object is enabled for use
var bool					bUseableObjectPowered;

// health and energy
var float					health;
var float					healthMaximum;
var float					energy;
var float					energyMaximum;
var bool					bShowEnergyBar;

var float					energyWeaponDepleted;
var float					healthInjectionAmount;

var bool					bHotkeysUpdated;

var float					throwForceMax;
var float					throwForce;

var bool					bZoomed;
var float					zoomMagnificationLevel;

// equipment
struct native HUDWeaponInfo
{
	var class<Weapon>		type;
	var int					ammo;
	var string				hotkey;
	var bool				bCanFire;
	var float				refireTime;
	var float				timeSinceLastFire;
	var float				Spread;
};

// index of the currently equipped weapon
var int						activeWeaponIdx;
// WeaponInfo of the current USED weapon: this is set for vehicles & turrets
var HUDWeaponInfo			activeWeapon;

var HUDWeaponInfo			fallbackWeapon;
var HUDWeaponInfo			weapons[3];
var HUDWeaponInfo			grenades;
var class<MPCarryable>		carryable;
var int						numCarryables;
var class<Deployable>		deployable;
var class<Equipment>		questItem;
var class<Pack>				pack;
var class<HealthKit>		healthKit;
var int						healthKitQuantity;

var string					deployableHotkey;
var string					healthKitHotkey;
var string					packHotkey;
var string					carryableHotkey;

// deployable state data
var Deployable.eDeployableInfo deployableState;
var bool bDeployableActive;
var float deployableUseTime;

// pack state data
var enum ePackState
{
	PS_Recharging,
	PS_Active,
	PS_Ready
} packState;
var float					packProgressRatio;

// team/base data
struct native SpawnPointData
{
	var bool bValid;
	var String SpawnPointName;
	var Vector SpawnPointLocation;

};
const MAX_SPAWN_AREAS = 20;
var SpawnPointData	spawnAreas[MAX_SPAWN_AREAS];	// length is max respawn bases + max respawn vehicles
var bool			bShowRespawnMap;				// set when the respawn screen should show a map (after timeout)
var bool			bInstantRespawnMode;			// whether the respawn screen should show in instant respawn mode

// game data
var class<GameInfo>			gameClass;
var bool					bAwaitingTournamentStart;
var int						ownTeamScore;
var int						otherTeamScore;
var string					ownTeam;
var string					otherTeam;
var Material				ownTeamIcon;
var Material				otherTeamIcon;
var Color					ownTeamColor;
var Color					ownTeamHighlightColor;
var Color					otherTeamColor;
var Color					otherTeamHighlightColor;
var bool					bNoMoreCarryables;

var Color					relativeFriendlyTeamColor;
var Color					relativeFriendlyHighlightColor;
var Color					relativeEnemyTeamColor;
var Color					relativeEnemyHighlightColor;

var Color					neutralColor;
var Color					neutralHighlightColor;

// whether the player hit an object last tick
var bool					bHitObject;
var float					lastHitObjectTime;

// whether the player was hit by an enemy, and from what direction
enum EDirectionType
{
	DAMAGE_Front,
	DAMAGE_Rear,
	DAMAGE_Left,
	DAMAGE_Right,
	DAMAGE_Top,
	DAMAGE_Bottom,
	MAX_DAMAGE_DIRECTIONS
};
var int	DamageAmounts[7];

// Target data
var class					targetType;
var	String					targetLabel;
var float					targetHealth;
var float					targetHealthMax;
var float					targetShield;
var float					targetShieldMax;
var float					targetDistance;
var float					targetFunctionalHealthThreshold;
var ETeamAlignment			targetTeamAlignment;
var class<TeamInfo>			targetTeam;
var bool					targetCanBeDamaged;

// Vehicle specific information
struct native HUDPositionData
{
	var int posX;
	var int posY;
	var bool bOccupiedByPlayer;
	var bool bOccupied;
	var bool bNotLabelled;
	var String SwitchHotKey;
};
var Array<HUDPositionData>	vehiclePositionData;
var Material				vehicleManifestSchematic;
var float					vehicleHealth;
var float					vehicleHealthMaximum;

// Turret health
var float					turretHealth;
var float					turretHealthMaximum;

// player UI flags
var bool					bCanExitRespawnHUD;		// whether the player should be able to exit the respawn HUD
var String					ExitRespawnKeyText;
var int						ExitRespawnKeyBinding;
var String					ShowCommandMapKeyText;

// Game and round data
var int						livesLeft;
var bool					bWaitingForRoundEnd;
var int						matchScoreLimit;
var String					watchedPlayerName;
var int						ping;

// Player Score data
var int						OffenseScore;
var int						DefenseScore;
var int						StyleScore;

// Level description
var String					levelDescription;

////////////////////////////////////////////////////////////
// Radar/Sensor data
var Vector		mapOrigin;
var float		mapExtent;
var Material	radarUnderlayMaterial;
var float		zoomFactor;
var bool		bSensorGridFunctional;

// Points of interest
struct native POIInfo
{
	var class<RadarInfo>	RadarInfoClass;
	var Vector				Location;
	var String				LabelText;
};
var Array<POIInfo>			POIData;

// Detected allies data
var Array<class>			detectedAlliesClass;
var Array<float>			detectedAlliesXPosition;
var Array<float>			detectedAlliesYPosition;
var Array<int>				detectedAlliesHeight;
var Array<byte>				detectedAlliesState;

// Detected enemies data
var Array<class<TeamInfo> >	detectedEnemiesTeam;
var Array<class>			detectedEnemiesClass;
var Array<float>			detectedEnemiesXPosition;
var Array<float>			detectedEnemiesYPosition;
var Array<int>				detectedEnemiesHeight;
var Array<int>				detectedEnemiesScreenX;
var Array<int>				detectedEnemiesScreenY;
var Array<byte>				detectedEnemiesState;

struct native ClientObjectiveInfo
{
	var class				radarInfoClass;
	var string				description;
	var EObjectiveStatus	status;
	var EObjectiveType		type;
	var bool				bFlashing;
	var byte				state;
	var bool				isFriendly;
	var class<TeamInfo>		TeamInfoClass;
};

struct native ClientObjectiveActorInfo
{
	var byte			objectiveDataIndex;
	var bool			IsFriendly;
	var class<TeamInfo>	TeamInfoClass;
	var float			XPosition;
	var float			YPosition;
	var float			Distance;
	var int				Height;
	var int				ScreenX;
	var int				ScreenY;
	var bool			bFlashing;
};

// Objectives
var Array<ClientObjectiveInfo>		ObjectiveData;
var Array<ClientObjectiveActorInfo>	ObjectiveActorData;

// Local sensed data
struct native MarkerData
{
	var class<RadarInfo>	Type;
	var int					ScreenX;
	var int					ScreenY;
	var byte				State;
	var bool				Friendly;
	var class<TeamInfo>		Team;
};
var Array<MarkerData>	markers;

////////////////////////////////////////////////////////////
// Chat & general messaging data

var bool	bDisplayChatWindow;

// Chat window sizes
var int		CurrentChatWindowSize;
var int		ChatScrollDelta;

enum EMessageType
{
	MessageType_Global,
	MessageType_Ally,
	MessageType_Enemy,
	MessageType_Subtitle,
	MessageType_System,
	MessageType_StatHigh,
	MessageType_StatMedium,
	MessageType_StatLow,
	MessageType_StatPenalty,
	MAX_MESSAGE_TYPES
};

struct native HUDMessage
{
	var String Text;
	var EMessageType Type;
};

// messages
var Array<HUDMessage>	Messages;

// announcer messages
var Array<String>		Announcements;

// personal messages
var Array<HUDMessage>	PersonalMessages;

// event messages
struct native EventMessage
{
	var String StringOne;
	var EMessageType StringOneType;
	var String StringTwo;
	var EMessageType StringTwoType;
	var Material IconMaterial;
};
var Array<EventMessage>		EventMessages;

var bool bTalk;				// set by the controller when the player wants to talk (global)
var bool bTeamTalk;			// set by the controller when the player wants to talk (team only)
var bool bQuickChat;		// set by the controller when the player wants to use quick chat
var bool aHeadIsTalking;

var Array<String>	loadoutNames;
var Array<byte>		loadoutEnabled;
var bool			bLoadoutSelection;	// set to true when the user is in the loadout selection menu

event ETeamAlignment GetTeamAlignment(PlayerCharacterController localController, PlayerReplicationInfo PRI)
{
	if(TribesReplicationInfo(PRI).team == None)
		return TA_Neutral;
	else if(localController.IsFriendly(PRI))
		return TA_Friendly;
	else
		return TA_Enemy;
}

event Color GetTeamColor(ETeamAlignment alignment, optional bool bHighlight, optional class<TeamInfo> ObjectTeam)
{
	// neutral colours are the same regardless of preference
	if(alignment == TA_Neutral)
	{
		if(bHighlight)
			return neutralHighlightColor;
		else
			return neutralColor;
	}
	else if(UserPrefColorType == COLOR_Relative)
	{
		if(alignment == TA_Friendly)
		{
			if(bHighlight)
				return relativeFriendlyHighlightColor;
			else
				return relativeFriendlyTeamColor;
		}
		else if(alignment == TA_Enemy)
		{
			if(bHighlight)
				return relativeEnemyHighlightColor;
			else
				return relativeEnemyTeamColor;
		}
	}
	else if(UserPrefColorType == COLOR_Team)
	{
		if(ObjectTeam != None)
		{
			if(bHighlight)
				return ObjectTeam.default.TeamHighlightColor;
			else
				return ObjectTeam.default.TeamColor;
		}
		else if(alignment == TA_Friendly)
		{
			if(bHighlight)
				return ownTeamHighlightColor;
			else
				return ownTeamColor;
		}
		else if(alignment == TA_Enemy)
		{
			if(bHighlight)
				return otherTeamHighlightColor;
			else
				return otherTeamColor;
		}
	}
}

// have to have this accessor function because UCC chokes
// if you try to externally access an array bigger than 19 
function SpawnPointData GetSpawnArea(int index)
{
	return spawnAreas[index];
}

// have to have this accessor function because UCC chokes
// if you try to externally access an array bigger than 19 
function SetSpawnArea(int index, SpawnPointData data)
{
	spawnAreas[index] = data;
}

defaultproperties
{
	relativeFriendlyTeamColor=(R=20,G=220,B=20,A=255)
	relativeFriendlyHighlightColor=(R=0,B=0,G=255,A=255)
	relativeEnemyTeamColor=(R=220,G=20,B=20,A=255)
	relativeEnemyHighlightColor=(R=255,G=0,B=0,A=255)
	
	neutralColor=(R=128,G=128,B=128,A=255)
	neutralHighlightColor=(R=196,G=196,B=196,A=255)
}