/*=============================================================================
// AutoLadder - automatically placed at top and bottom of LadderVolume
============================================================================= */

class AutoLadder extends Ladder
	notplaceable
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
	virtual UBOOL IsIdentifiedAs(FName ActorName);

}


defaultproperties
{
     bCollideWhenPlacing=False
}
