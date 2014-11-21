//=============================================================================
// PathNode.
//=============================================================================
class PathNode extends NavigationPoint
	placeable
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
	virtual UBOOL ReviewPath(APawn* Scout);
	virtual void CheckSymmetry(ANavigationPoint* Other);
	virtual INT AddMyMarker(AActor *S);

}


defaultproperties
{
     Texture=Texture'Engine_res.S_Pickup'
}
