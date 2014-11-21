/*===========================================================================
	  C++ class	definitions	exported from UnrealScript.
	  This is automatically	generated by the tools.
	  DO NOT modify	this manually! Edit	the	corresponding .uc files	instead!
===========================================================================*/
#if SUPPORTS_PRAGMA_PACK
#pragma pack (push,4)
#endif

#ifndef TYRION_API
#define TYRION_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern TYRION_API	FName TYRION_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(OnHearSound)
AUTOGENERATE_NAME(Pawn)
AUTOGENERATE_NAME(chooseAction)
AUTOGENERATE_NAME(copyTerrainProfileDebug)
AUTOGENERATE_NAME(deleteRemovedActions)
AUTOGENERATE_NAME(hasActiveMembers)
AUTOGENERATE_NAME(initAction)
AUTOGENERATE_NAME(instantFail)
AUTOGENERATE_NAME(instantSucceed)
AUTOGENERATE_NAME(priorityFn)
AUTOGENERATE_NAME(resourceCheck)
AUTOGENERATE_NAME(runAction)

#ifndef NAMES_ONLY

// Enum DLM_MovementMode is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
enum DLM_MovementMode
{
	 DLMMM_WALKING           =0,
	 DLMMM_JETPACKING        =1,
	 DLMMM_SKIING            =2,
	 DLMMM_MAX               =3,
};
// Enum LOA_AvoidDirections is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
enum LOA_AvoidDirections
{
	 LOA_DONTCARE            =0,
	 LOA_LEFT                =1,
	 LOA_RIGHT               =2,
	 LOA_UP                  =3,
	 LOA_MAX                 =4,
};
// Enum VDLM_ReturnCodes is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
enum VDLM_ReturnCodes
{
	 VDLM_SUCCESS            =0,
	 VDLM_TIMED_OUT          =1,
	 VDLM_MAX                =2,
};
// Enum DZGLM_ReturnCodes is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
enum DZGLM_ReturnCodes
{
	 DZGLM_SUCCESS           =0,
	 DZGLM_MAX               =1,
};
// Enum DLM_ReturnCodes is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
enum DLM_ReturnCodes
{
	 DLM_SUCCESS             =0,
	 DLM_CANT_FIND_PATH      =1,
	 DLM_IRREVERSIBLY_OFF_COURSE=2,
	 DLM_TIME_LIMIT_EXCEEDED =3,
	 DLM_INSUFFICIENT_ENERGY =4,
	 DLM_DESTINATION_ENCROACHED=5,
	 DLM_ALL_RESOURCES_DIED  =6,
	 DLM_MAX                 =7,
};
// Struct FTerrainSample	is declared	in "..\Tyrion\Classes\Engine\AI_Controller.uc"
struct TYRION_API FTerrainSample
{
    FVector Location;
    FVector Normal;
    FVector Velocity;
    BITFIELD bTerrain:1;
    BITFIELD bDownSlope:1;
    BITFIELD bBeforeSkiRouteStart:1;
};

// Constant MAX_TICKS_TO_PROCESS_PAIN is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_MAX_TICKS_TO_PROCESS_PAIN 5
// Constant ALERTNESS_COMBAT_TIME is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_ALERTNESS_COMBAT_TIME 10.0f
// Constant ALERTNESS_ALERT_TIME is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_ALERTNESS_ALERT_TIME 20.0f
// Constant DONT_CARE is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_DONT_CARE -99999.0
// Constant DEBUGAI_Y is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_DEBUGAI_Y 100
// Constant DEBUGAI_X is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_DEBUGAI_X 20
// Constant DO_LOCAL_MOVE_NUMBER is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
#define UCONST_DO_LOCAL_MOVE_NUMBER 2200

// "event"	function whose parameters correspond to	"struct AAI_Controller_eventOnHearSound_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Controller.uc"
struct AAI_Controller_eventOnHearSound_Parms
{
	  class AActor* SoundMaker;
	  FVector SoundOrigin;
	  FName SoundCategory;
};
// "event"	function whose parameters correspond to	"struct AAI_Controller_eventcopyTerrainProfileDebug_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Controller.uc"
struct AAI_Controller_eventcopyTerrainProfileDebug_Parms
{
};
// "event"	function whose parameters correspond to	"struct AAI_Controller_eventdeleteRemovedActions_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Controller.uc"
struct AAI_Controller_eventdeleteRemovedActions_Parms
{
};

// Constant TIMETOHIT_FUDGE_TERM is declared in "..\Tyrion\Classes\Engine\Setup.uc"
#define UCONST_TIMETOHIT_FUDGE_TERM 1.0f
// Constant MAX_TARGET_CHECK_RANGE is declared in "..\Tyrion\Classes\Engine\Setup.uc"
#define UCONST_MAX_TARGET_CHECK_RANGE 10000.0f
// Constant TARGET_DURATION is declared in "..\Tyrion\Classes\Engine\Setup.uc"
#define UCONST_TARGET_DURATION 0.5f

// Constant ONLY_NON_NONE_VALUE is declared in "..\Tyrion\Classes\Engine\AI_Sensor.uc"
#define UCONST_ONLY_NON_NONE_VALUE 2
// Constant ONLY_NONE_VALUE is declared in "..\Tyrion\Classes\Engine\AI_Sensor.uc"
#define UCONST_ONLY_NONE_VALUE 1

// Enum SensorDataType is declared in "..\Tyrion\Classes\Engine\AI_SensorData.uc"
enum SensorDataType
{
	 SDT_FLOAT               =0,
	 SDT_INTEGER             =1,
	 SDT_CATEGORICAL         =2,
	 SDT_OBJECT              =3,
	 SDT_MAX                 =4,
};


// Enum ACT_ErrorCodes is declared in "..\Tyrion\Classes\Engine\ActionBase.uc"
enum ACT_ErrorCodes
{
	 ACT_SUCCESS             =0,
	 ACT_GENERAL_FAILURE     =1,
	 ACT_RESOURCE_INACTIVE   =2,
	 ACT_INTERRUPTED         =3,
	 ACT_CANT_FIND_PATH      =4,
	 ACT_IRREVERSIBLY_OFF_COURSE=5,
	 ACT_TIME_LIMIT_EXCEEDED =6,
	 ACT_INVALID_PARAMETERS  =7,
	 ACT_CANT_REACH_DESTINATION=8,
	 ACT_ALL_RESOURCES_DIED  =9,
	 ACT_REQUIRED_RESOURCE_STOLEN=10,
	 ACT_INSUFFICIENT_RESOURCES_AVAILABLE=11,
	 ACT_INSUFFICIENT_ENERGY =12,
	 ACT_DESTINATION_ENCROACHED=13,
	 ACT_LOST_TARGET         =14,
	 ACT_COULDNT_ENTER_VEHICLE=15,
	 ACT_COULDNT_EXIT_VEHICLE=16,
	 ACT_PARTIAL_SUCCESS     =17,
	 ACT_MAX                 =18,
};
// Constant DONT_CARE is declared in "..\Tyrion\Classes\Engine\ActionBase.uc"
#define UCONST_DONT_CARE -99999.0

// "event"	function whose parameters correspond to	"struct UActionBase_eventinstantFail_Parms"	is declared	in "..\Tyrion\Classes\Engine\ActionBase.uc"
struct UActionBase_eventinstantFail_Parms
{
	  BYTE errorCode;
	  BITFIELD bRemoveGoal;
};
// "event"	function whose parameters correspond to	"struct UActionBase_eventrunAction_Parms"	is declared	in "..\Tyrion\Classes\Engine\ActionBase.uc"
struct UActionBase_eventrunAction_Parms
{
};


// "event"	function whose parameters correspond to	"struct UAI_Action_eventinitAction_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Action.uc"
struct UAI_Action_eventinitAction_Parms
{
	  class UAI_Resource* R;
	  class UAI_Goal* goal;
};
// "event"	function whose parameters correspond to	"struct UAI_Action_eventinstantSucceed_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Action.uc"
struct UAI_Action_eventinstantSucceed_Parms
{
};







// "event"	function whose parameters correspond to	"struct UAI_Goal_eventpriorityFn_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Goal.uc"
struct UAI_Goal_eventpriorityFn_Parms
{
	  INT ReturnValue;
};
// Constant RU_MOUNT is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
#define UCONST_RU_MOUNT 8
// Constant RU_LEGS is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
#define UCONST_RU_LEGS 4
// Constant RU_ARMS is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
#define UCONST_RU_ARMS 2
// Constant RU_HEAD is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
#define UCONST_RU_HEAD 1
// Constant OPTIONAL_RESOURCE_PRIORITY is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
#define UCONST_OPTIONAL_RESOURCE_PRIORITY 20

// "event"	function whose parameters correspond to	"struct UAI_Resource_eventPawn_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Resource.uc"
struct UAI_Resource_eventPawn_Parms
{
	  class APawn* ReturnValue;
};
// "event"	function whose parameters correspond to	"struct UAI_Resource_eventresourceCheck_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Resource.uc"
struct UAI_Resource_eventresourceCheck_Parms
{
	  class UAI_Goal* goal;
	  class UAI_Action* bestAction;
};
// "event"	function whose parameters correspond to	"struct UAI_Resource_eventchooseAction_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_Resource.uc"
struct UAI_Resource_eventchooseAction_Parms
{
	  class UAI_Goal* goal;
	  class UAI_Action* ReturnValue;
};

// "event"	function whose parameters correspond to	"struct UAI_SquadResource_eventhasActiveMembers_Parms"	is declared	in "..\Tyrion\Classes\Engine\AI_SquadResource.uc"
struct UAI_SquadResource_eventhasActiveMembers_Parms
{
	  BITFIELD ReturnValue;
};
// Class	AAI_Controller is declared in "..\Tyrion\Classes\Engine\AI_Controller.uc"
class TYRION_API	AAI_Controller	: public AController
{
public:
    class UNS_DoLocalMove* dlm;
    FVector localMoveOrigin;
    FVector localMoveDirection;
    FLOAT localMoveTimeLimitSeconds;
    FLOAT localMoveStartTimeSeconds;
    FLOAT localMoveDistance;
    FLOAT localMoveNextDistance;
    FVector localMoveNextDirection;
    FVector localMoveNextDirectionXY;
    FLOAT localMoveNextDistanceXY;
    FVector localSmoothMoveDestination;
    BITFIELD localSmoothMoveDestinationValid:1;
    FLOAT previousSmoothingFactor;
    BYTE dlmReturnValue;
    BYTE dlmMovementMode;
    BYTE vehicleDoLocalMoveResult;
    class AActor* actorHit;
    class AActor* followedActor;
    FLOAT avoidDistance;
    FVector avoidDirection;
    class AActor* lastActorHit;
    FVector lastActorLocation;
    BYTE dirSwitch;
    INT ticksElapsedWithNoProgress;
    BITFIELD bAvoiding:1;
    BITFIELD bNoLOA:1;
    BITFIELD disableSmoothing:1;
    BITFIELD smoothingStarted:1;
    BITFIELD bAiming:1;
    FLOAT dodgeExpirationTime;
    FLOAT dodgeStartTime;
    FVector dodgeDisplacement;
    FVector LastLocation;
    class UCarDoLocalMove* carLocalMoveAction;
    class UAircraftDoLocalMove* aircraftLocalMoveAction;
    BITFIELD aircraftAttacking:1;
    FLOAT moveStartTime;
    FLOAT maximumDuration;
    INT vehicleNavigationFunctionIndex;
    FLOAT currentSpeed;
    class UNS_DoZeroGravityLocalMove* zeroGravityMoveAction;
    FVector elevatorCentreXY;
    BYTE zeroGravityMoveResult;
    BITFIELD bPatrolling:1;
    BITFIELD bJetSkiManager:1;
    BITFIELD bSkiTo:1;
    BITFIELD bJetpacking:1;
    BITFIELD bTerminate:1;
    BITFIELD bShouldJetpack:1;
    TArrayNoInit<FTerrainSample> terrainSamples;
    TArrayNoInit<FTerrainSample> terrainSamplesDebug;
    TArrayNoInit<class UNS_Action*> idleActions;
    TArrayNoInit<class UNS_Action*> runningActions;
    TArrayNoInit<class UNS_Action*> removedActions;
    BYTE lastErrorCode;
    FRange tickTimeUpdateRange;
	   DECLARE_FUNCTION(execgetNodesWithinSphere);
	   DECLARE_FUNCTION(execstopMove);
	   DECLARE_FUNCTION(execgetTerrainHeight);
	   DECLARE_FUNCTION(execspeedInDirection);
	   DECLARE_FUNCTION(execgetRandomLocation);
	   DECLARE_FUNCTION(execisPointEncroachedForMovement);
	   DECLARE_FUNCTION(execoffersCover);
	   DECLARE_FUNCTION(execcanJetToPoint);
	   DECLARE_FUNCTION(execcanPointBeReachedUsingJetpack);
	   DECLARE_FUNCTION(execcanPointBeReachedUsingAircraft);
	   DECLARE_FUNCTION(execcanPointBeReached);
	   DECLARE_FUNCTION(execcopyTerrainProfileDebug);
	   DECLARE_FUNCTION(execlogSkiRoute);
	   DECLARE_FUNCTION(execgenerateReverseSkiRoute);
	   DECLARE_FUNCTION(execbSuitableTerrainForSkiing);
	   DECLARE_FUNCTION(execfindLandingSpot);
	   DECLARE_FUNCTION(execjetLookAhead);
	   DECLARE_FUNCTION(execAircraftDoLocalMove);
	   DECLARE_FUNCTION(execCarDoLocalMove);
	   DECLARE_FUNCTION(execdoZeroGravityLocalMove);
	   DECLARE_FUNCTION(execdoLocalMove);
	  void	eventOnHearSound(class AActor* SoundMaker, FVector SoundOrigin, FName SoundCategory)
	  {
        AAI_Controller_eventOnHearSound_Parms Parms;
		   Parms.SoundMaker=SoundMaker;
		   Parms.SoundOrigin=SoundOrigin;
		   Parms.SoundCategory=SoundCategory;
        ProcessEvent(FindFunctionChecked(TYRION_OnHearSound),&Parms);
	  }
	  void	eventcopyTerrainProfileDebug()
	  {
		   ProcessEvent(FindFunctionChecked(TYRION_copyTerrainProfileDebug),NULL);
	  }
	  void	eventdeleteRemovedActions()
	  {
		   ProcessEvent(FindFunctionChecked(TYRION_deleteRemovedActions),NULL);
	  }
	   DECLARE_CLASS(AAI_Controller,AController,0|CLASS_Config,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(AAI_Controller)
};

// Class	ANearMissCollisionVolume is declared in "..\Tyrion\Classes\Engine\NearMissCollisionVolume.uc"
class TYRION_API	ANearMissCollisionVolume	: public AActor
{
public:
    class APawn* Pawn;
    class UAI_NearMissSensor* nearMissSensor;
	   DECLARE_CLASS(ANearMissCollisionVolume,AActor,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(ANearMissCollisionVolume)
};

// Class	ASetup is declared in "..\Tyrion\Classes\Engine\Setup.uc"
class TYRION_API	ASetup	: public ATyrion_Setup
{
public:
    class UTyrion_ResourceBase* sensorResource;
	   DECLARE_FUNCTION(execSetStaticSensorResource);
	   DECLARE_FUNCTION(execGetStaticSensorResource);
	   DECLARE_CLASS(ASetup,ATyrion_Setup,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(ASetup)
};

// Class	UAI_Sensor is declared in "..\Tyrion\Classes\Engine\AI_Sensor.uc"
class TYRION_API	UAI_Sensor	: public UDeleteableObject
{
public:
    class UAI_SensorAction* sensorAction;
    TArrayNoInit<class UAI_SensorRecipient*> recipients;
    class UAI_SensorData* Value;
    BITFIELD bNotifyOnValueChange:1;
    BITFIELD bNotifyIfResourceInactive:1;
	   DECLARE_CLASS(UAI_Sensor,UDeleteableObject,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_Sensor)
};

// Class	UAI_SensorData is declared in "..\Tyrion\Classes\Engine\AI_SensorData.uc"
class TYRION_API	UAI_SensorData	: public UDeleteableObject
{
public:
    BYTE dataType;
    FLOAT floatData;
    INT integerData;
    class UObject* objectData;
	   DECLARE_CLASS(UAI_SensorData,UDeleteableObject,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_SensorData)
};

// Class	UAI_SensorWithBounds is declared in "..\Tyrion\Classes\Engine\AI_SensorWithBounds.uc"
class TYRION_API	UAI_SensorWithBounds	: public UDeleteableObject
{
public:
    class UAI_Sensor* sensor;
    FLOAT lowerBound;
    FLOAT upperBound;
	   DECLARE_CLASS(UAI_SensorWithBounds,UDeleteableObject,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_SensorWithBounds)
};

// Class	UActionBase is declared in "..\Tyrion\Classes\Engine\ActionBase.uc"
class TYRION_API	UActionBase	: public UTyrion_ActionBase
{
public:
    BITFIELD bIdle:1;
    BITFIELD bCompleted:1;
    BITFIELD bWasTicked:1;
    BITFIELD bDeleted:1;
    BITFIELD bSensorAction:1;
	  void	eventinstantFail(BYTE errorCode, BITFIELD bRemoveGoal)
	  {
        UActionBase_eventinstantFail_Parms Parms;
		   Parms.errorCode=errorCode;
		   Parms.bRemoveGoal=bRemoveGoal;
        ProcessEvent(FindFunctionChecked(TYRION_instantFail),&Parms);
	  }
	  void	eventrunAction()
	  {
		   ProcessEvent(FindFunctionChecked(TYRION_runAction),NULL);
	  }
	   DECLARE_CLASS(UActionBase,UTyrion_ActionBase,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UActionBase)
};

// Class	UAI_RunnableAction is declared in "..\Tyrion\Classes\Engine\AI_RunnableAction.uc"
class TYRION_API	UAI_RunnableAction	: public UActionBase
{
public:
    class UAI_Resource* resource;
	   DECLARE_CLASS(UAI_RunnableAction,UActionBase,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_RunnableAction)
};

// Class	UAI_Action is declared in "..\Tyrion\Classes\Engine\AI_Action.uc"
class TYRION_API	UAI_Action	: public UAI_RunnableAction
{
public:
    class UClass* satisfiesGoal;
    class UAI_Goal* achievingGoal;
    TArrayNoInit<class UAI_Goal*> childGoals;
    class UNS_Action* nsChild;
    FLOAT heuristicValue;
    INT resourceUsage;
    INT waitingForGoalsN;
	  void	eventinitAction(class UAI_Resource* R, class UAI_Goal* goal)
	  {
        UAI_Action_eventinitAction_Parms Parms;
		   Parms.R=R;
		   Parms.goal=goal;
        ProcessEvent(FindFunctionChecked(TYRION_initAction),&Parms);
	  }
	  void	eventinstantSucceed()
	  {
		   ProcessEvent(FindFunctionChecked(TYRION_instantSucceed),NULL);
	  }
	   DECLARE_CLASS(UAI_Action,UAI_RunnableAction,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_Action)
};

// Class	UAI_SensorAction is declared in "..\Tyrion\Classes\Engine\AI_SensorAction.uc"
class TYRION_API	UAI_SensorAction	: public UAI_RunnableAction
{
public:
    INT usageCount;
    BITFIELD bCallBegin:1;
	   DECLARE_CLASS(UAI_SensorAction,UAI_RunnableAction,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_SensorAction)
};

// Class	UNS_Action is declared in "..\Tyrion\Classes\Navigation\NS_Action.uc"
class TYRION_API	UNS_Action	: public UActionBase
{
public:
    class AAI_Controller* Controller;
    class UNS_Action* childAction;
    class UActionBase* parentAction;
    BYTE errorCode;
    BITFIELD bWakeUpParent:1;
    FLOAT tickTime;
    FLOAT tickTimeOrg;
	   DECLARE_CLASS(UNS_Action,UActionBase,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UNS_Action)
};

// Class	UAircraftDoLocalMove is declared in "..\Tyrion\Classes\Navigation\AircraftDoLocalMove.uc"
class TYRION_API	UAircraftDoLocalMove	: public UNS_Action
{
public:
    FVector Destination;
    FLOAT terminalDistance;
    FLOAT speed;
    BITFIELD nextDestinationValid:1;
    FVector nextDestination;
    class ARook* Target;
	   DECLARE_CLASS(UAircraftDoLocalMove,UNS_Action,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAircraftDoLocalMove)
};

// Class	UCarDoLocalMove is declared in "..\Tyrion\Classes\Navigation\CarDoLocalMove.uc"
class TYRION_API	UCarDoLocalMove	: public UNS_Action
{
public:
    FVector Destination;
    FLOAT terminalDistance;
    FLOAT speed;
    BITFIELD nextDestinationValid:1;
    FVector nextDestination;
	   DECLARE_CLASS(UCarDoLocalMove,UNS_Action,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UCarDoLocalMove)
};

// Class	UNS_DoLocalMove is declared in "..\Tyrion\Classes\Navigation\NS_DoLocalMove.uc"
class TYRION_API	UNS_DoLocalMove	: public UNS_Action
{
public:
    FVector Destination;
    BYTE skiCompetency;
    BYTE jetCompetency;
    BYTE groundMovement;
    BITFIELD nextDestinationValid:1;
    FVector nextDestination;
    FLOAT terminalDistanceXY;
    FLOAT terminalDistanceZ;
    FLOAT energyUsage;
    FLOAT TerminalVelocity;
    FLOAT terminalHeight;
    BITFIELD bMustJetpack:1;
    BITFIELD bMustSki:1;
	   DECLARE_CLASS(UNS_DoLocalMove,UNS_Action,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UNS_DoLocalMove)
};

// Class	UNS_DoZeroGravityLocalMove is declared in "..\Tyrion\Classes\Navigation\NS_DoZeroGravityLocalMove.uc"
class TYRION_API	UNS_DoZeroGravityLocalMove	: public UNS_Action
{
public:
    FVector Destination;
    class AElevatorVolume* Elevator;
    FLOAT terminalDistanceXY;
    FLOAT terminalDistanceZ;
	   DECLARE_CLASS(UNS_DoZeroGravityLocalMove,UNS_Action,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UNS_DoZeroGravityLocalMove)
};

// Class	UAI_Goal is declared in "..\Tyrion\Classes\Engine\AI_Goal.uc"
class TYRION_API	UAI_Goal	: public UTyrion_GoalBase
{
public:
    BITFIELD bRemoveGoalOfSameType:1;
    BITFIELD bTryOnlyOnce:1;
    INT Priority;
    FStringNoInit goalName;
    class UAI_SensorWithBounds* activationSentinel;
    class UAI_SensorWithBounds* deactivationSentinel;
    class UAI_Action* achievingAction;
    class UAI_Action* parentAction;
    BITFIELD bInactive:1;
    BITFIELD bPermanent:1;
    BITFIELD bDeleted:1;
    BITFIELD bGoalConsidered:1;
    BITFIELD bWakeUpPoster:1;
    BITFIELD bTerminateIfStolen:1;
    BITFIELD bGoalFailed:1;
    BITFIELD bGoalAchieved:1;
    INT ignoreCounter;
    INT matchedN;
    class UAI_Resource* resource;
    TArrayNoInit<class IIGoalNotification*> notificationRecipients;
	  INT	eventpriorityFn()
	  {
        UAI_Goal_eventpriorityFn_Parms Parms;
		   Parms.ReturnValue=0;
        ProcessEvent(FindFunctionChecked(TYRION_priorityFn),&Parms);
		   return Parms.ReturnValue;
	  }
	   DECLARE_CLASS(UAI_Goal,UTyrion_GoalBase,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_Goal)
};

// Class	UAI_Resource is declared in "..\Tyrion\Classes\Engine\AI_Resource.uc"
class TYRION_API	UAI_Resource	: public UTyrion_ResourceBase
{
public:
    TArrayNoInit<class UAI_RunnableAction*> idleActions;
    TArrayNoInit<class UAI_RunnableAction*> runningActions;
    TArrayNoInit<class UAI_RunnableAction*> removedActions;
    class UAI_Action* usedByAction;
    TArrayNoInit<class UAI_Sensor*> sensors;
    TArrayNoInit<class UAI_SensorAction*> sensorActions;
	   DECLARE_FUNCTION(execsetActionParametersInternal);
	  class APawn*	eventPawn()
	  {
        UAI_Resource_eventPawn_Parms Parms;
		   Parms.ReturnValue=0;
        ProcessEvent(FindFunctionChecked(TYRION_Pawn),&Parms);
		   return Parms.ReturnValue;
	  }
	  void	eventresourceCheck(class UAI_Goal* goal, class UAI_Action* bestAction)
	  {
        UAI_Resource_eventresourceCheck_Parms Parms;
		   Parms.goal=goal;
		   Parms.bestAction=bestAction;
        ProcessEvent(FindFunctionChecked(TYRION_resourceCheck),&Parms);
	  }
	  class UAI_Action*	eventchooseAction(class UAI_Goal* goal)
	  {
        UAI_Resource_eventchooseAction_Parms Parms;
		   Parms.ReturnValue=0;
		   Parms.goal=goal;
        ProcessEvent(FindFunctionChecked(TYRION_chooseAction),&Parms);
		   return Parms.ReturnValue;
	  }
	   DECLARE_CLASS(UAI_Resource,UTyrion_ResourceBase,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_Resource)
};

// Class	UAI_SquadResource is declared in "..\Tyrion\Classes\Engine\AI_SquadResource.uc"
class TYRION_API	UAI_SquadResource	: public UAI_Resource
{
public:
    class ASquadInfo* squad;
	  BITFIELD	eventhasActiveMembers()
	  {
        UAI_SquadResource_eventhasActiveMembers_Parms Parms;
		   Parms.ReturnValue=0;
        ProcessEvent(FindFunctionChecked(TYRION_hasActiveMembers),&Parms);
		   return Parms.ReturnValue;
	  }
	   DECLARE_CLASS(UAI_SquadResource,UAI_Resource,0,Tyrion)
	   NO_DEFAULT_CONSTRUCTOR(UAI_SquadResource)
};

#endif

AUTOGENERATE_FUNCTION(AAI_Controller,-1,execgetNodesWithinSphere);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execstopMove);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execgetTerrainHeight);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execspeedInDirection);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execgetRandomLocation);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execisPointEncroachedForMovement);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execoffersCover);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execcanJetToPoint);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execcanPointBeReachedUsingJetpack);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execcanPointBeReachedUsingAircraft);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execcanPointBeReached);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execcopyTerrainProfileDebug);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execlogSkiRoute);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execgenerateReverseSkiRoute);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execbSuitableTerrainForSkiing);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execfindLandingSpot);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execjetLookAhead);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execAircraftDoLocalMove);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execCarDoLocalMove);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execdoZeroGravityLocalMove);
AUTOGENERATE_FUNCTION(AAI_Controller,-1,execdoLocalMove);
AUTOGENERATE_FUNCTION(UAI_Resource,-1,execsetActionParametersInternal);
AUTOGENERATE_FUNCTION(ASetup,-1,execSetStaticSensorResource);
AUTOGENERATE_FUNCTION(ASetup,-1,execGetStaticSensorResource);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if SUPPORTS_PRAGMA_PACK
#pragma pack	(pop)
#endif

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_SIZE_NODIE(UAI_Action)
VERIFY_CLASS_SIZE_NODIE(AAI_Controller)
VERIFY_CLASS_SIZE_NODIE(UAI_Goal)
VERIFY_CLASS_SIZE_NODIE(UAI_Resource)
VERIFY_CLASS_SIZE_NODIE(UAI_RunnableAction)
VERIFY_CLASS_SIZE_NODIE(UAI_Sensor)
VERIFY_CLASS_SIZE_NODIE(UAI_SensorAction)
VERIFY_CLASS_SIZE_NODIE(UAI_SensorData)
VERIFY_CLASS_SIZE_NODIE(UAI_SensorWithBounds)
VERIFY_CLASS_SIZE_NODIE(UAI_SquadResource)
VERIFY_CLASS_SIZE_NODIE(UActionBase)
VERIFY_CLASS_SIZE_NODIE(UAircraftDoLocalMove)
VERIFY_CLASS_SIZE_NODIE(UCarDoLocalMove)
VERIFY_CLASS_SIZE_NODIE(UNS_Action)
VERIFY_CLASS_SIZE_NODIE(UNS_DoLocalMove)
VERIFY_CLASS_SIZE_NODIE(UNS_DoZeroGravityLocalMove)
VERIFY_CLASS_SIZE_NODIE(ANearMissCollisionVolume)
VERIFY_CLASS_SIZE_NODIE(ASetup)
#endif // VERIFY_CLASS_SIZES