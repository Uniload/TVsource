/*===========================================================================
	  C++ class	definitions	exported from UnrealScript.
	  This is automatically	generated by the tools.
	  DO NOT modify	this manually! Edit	the	corresponding .uc files	instead!
===========================================================================*/
#if SUPPORTS_PRAGMA_PACK
#pragma pack (push,4)
#endif

#ifndef AICOMMON_API
#define AICOMMON_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern AICOMMON_API	FName AICOMMON_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(OnViewerLostPawn)
AUTOGENERATE_NAME(OnViewerSawPawn)

#ifndef NAMES_ONLY

// Constant MAX_TICKS_TO_PROCESS_PAIN is declared in "..\AICommon\Classes\Squads\SquadInfo.uc"
#define UCONST_MAX_TICKS_TO_PROCESS_PAIN 5



// "event"	function whose parameters correspond to	"struct IIVisionNotification_eventOnViewerLostPawn_Parms"	is declared	in "..\AICommon\Classes\Sensing\IVisionNotification.uc"
struct IIVisionNotification_OnViewerLostPawn_Parms
{
	  class APawn* Viewer;
	  class APawn* Seen;
};
// "event"	function whose parameters correspond to	"struct IIVisionNotification_eventOnViewerSawPawn_Parms"	is declared	in "..\AICommon\Classes\Sensing\IVisionNotification.uc"
struct IIVisionNotification_OnViewerSawPawn_Parms
{
	  class APawn* Viewer;
	  class APawn* Seen;
};

// Class	ASquadInfo is declared in "..\AICommon\Classes\Squads\SquadInfo.uc"
class AICOMMON_API	ASquadInfo	: public AActor
{
public:
    TArrayNoInit<class UClass*> goals;
    TArrayNoInit<class UClass*> abilities;
    class UTyrion_ResourceBase* SquadAI;
    TArrayNoInit<class APawn*> pawns;
    BYTE AI_LOD_Level;
    FLOAT tickTime;
    FLOAT tickTimeOrg;
    FRange tickTimeUpdateRange;
    BITFIELD logTyrion:1;
	   DECLARE_CLASS(ASquadInfo,AActor,0,AICommon)
	   NO_DEFAULT_CONSTRUCTOR(ASquadInfo)
};

// Class	UShotNotifier is declared in "..\AICommon\Classes\Sensing\ShotNotifier.uc"
class AICOMMON_API	UShotNotifier	: public UDeleteableObject
{
public:
    TArrayNoInit<class IIShotNotification*> NotificationList;
    class APawn* Shooter;
	   DECLARE_CLASS(UShotNotifier,UDeleteableObject,0,AICommon)
	   NO_DEFAULT_CONSTRUCTOR(UShotNotifier)
};

// Class	IIVisionNotification is declared in "..\AICommon\Classes\Sensing\IVisionNotification.uc"
class AICOMMON_API	IIVisionNotification	: public UObject
{
public:
	  void OnViewerLostPawn(class APawn* Viewer, class APawn* Seen)
	  {
        IIVisionNotification_OnViewerLostPawn_Parms Parms;
		   Parms.Viewer=Viewer;
		   Parms.Seen=Seen;
        ProcessFunction(FindFunctionChecked(AICOMMON_OnViewerLostPawn),&Parms);
	  }
	  void OnViewerSawPawn(class APawn* Viewer, class APawn* Seen)
	  {
        IIVisionNotification_OnViewerSawPawn_Parms Parms;
		   Parms.Viewer=Viewer;
		   Parms.Seen=Seen;
        ProcessFunction(FindFunctionChecked(AICOMMON_OnViewerSawPawn),&Parms);
	  }
	   DECLARE_CLASS(IIVisionNotification,UObject,0|CLASS_Interface,AICommon)
	   NO_DEFAULT_CONSTRUCTOR(IIVisionNotification)
};

// Class	UHearingNotifier is declared in "..\AICommon\Classes\Sensing\HearingNotifier.uc"
class AICOMMON_API	UHearingNotifier	: public URefCount
{
public:
    TArrayNoInit<class IIHearingNotification*> NotificationList;
    class APawn* listener;
	   DECLARE_CLASS(UHearingNotifier,URefCount,0,AICommon)
	   NO_DEFAULT_CONSTRUCTOR(UHearingNotifier)
};

#endif


#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if SUPPORTS_PRAGMA_PACK
#pragma pack	(pop)
#endif

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_SIZE_NODIE(UHearingNotifier)
VERIFY_CLASS_SIZE_NODIE(IIVisionNotification)
VERIFY_CLASS_SIZE_NODIE(UShotNotifier)
VERIFY_CLASS_SIZE_NODIE(ASquadInfo)
#endif // VERIFY_CLASS_SIZES
