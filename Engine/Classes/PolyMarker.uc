//=============================================================================
// PolyMarker.
//
// These are markers for the polygon drawing mode.
//
// These should NOT be manually added to the level.  The editor adds and
// deletes them on it's own.
//
//=============================================================================
class PolyMarker extends Keypoint
	placeable
	native;

defaultproperties
{
     Texture=Texture'Engine_res.S_PolyMarker'
     bEdShouldSnap=True
}
