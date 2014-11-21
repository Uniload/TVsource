class PlayerCharacter extends Character
	native;

cpptext
{
	UBOOL CanSee(APawn* Other);
	void LookForPawns();
}

//=====================================================================
// Functions

function PostBeginPlay()
{
	CreateVisionNotifier();

	super.PostBeginPlay();
}

//=====================================================================

defaultproperties
{
    peripheralVision                = 0.5           // 60 degrees either side for a total of 120 degrees
	SightRadius						= 18000.0
	VisionUpdateRange			    = (Min=0.6,Max=0.8)
}