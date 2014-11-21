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
     bExactProjectileCollision=True
     DrawType=DT_StaticMesh
     bStatic=True
     bWorldGeometry=True
     bAcceptsProjectors=True
     bShadowCast=True
     bStaticLighting=True
     bMovable=False
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
     bBlockHavok=True
     bEdShouldSnap=True
}
