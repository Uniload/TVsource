//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
#if IG_SHARED
	hidecategories(Events, Force, LightColor, Lighting, Object, Sound)
#endif
	native
	placeable;

var() bool bExactProjectileCollision;		// nonzero extent projectiles should shrink to zero when hitting this actor

// IGA >>> identifies whether or not to include this static mesh in the automated aspect of the pathfinding system
var() bool bIncludeInGroundNavigation;

defaultproperties
{
	DrawType=DT_StaticMesh
	bEdShouldSnap=True
	bStatic=True
	bStaticLighting=True
	bShadowCast=True
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	bBlockKarma=True
#if IG_TRIBES3	// rowan: setup in havok static world by default
	bMovable=False
	bBlockHavok=True
#endif
	bWorldGeometry=True
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bAcceptsProjectors=True
	bExactProjectileCollision=true
	
	bIncludeInGroundNavigation=false
}