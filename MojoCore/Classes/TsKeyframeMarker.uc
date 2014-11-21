class TsKeyframeMarker extends Engine.Actor;

defaultproperties
{
//	Mesh=Mesh'COGStandardSoldiers.COGGruntMesh'
//	DrawType=DT_Mesh
//	StaticMesh=StaticMesh'mojotoolmeshes.markerSm'      // glenn: commented out because this asset no longer exists (ucc warning)
	DrawType=DT_StaticMesh
	bStatic=false
	bShadowCast=false
	bUnlit=true
	bCollideActors=true
	bCollideWorld=false
	bWorldGeometry=false
	CollisionHeight=+000005.000000
	CollisionRadius=+000005.000000
}

