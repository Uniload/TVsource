class PlayerCharacter extends Character
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//=====================================================================
// Functions

function PostBeginPlay()
{
	CreateVisionNotifier();

	super.PostBeginPlay();
}

//=====================================================================

cpptext
{
	UBOOL CanSee(APawn* Other);
	void LookForPawns();

}


defaultproperties
{
     SightRadius=18000.000000
}
