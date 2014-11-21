class Jetpack extends Engine.Actor;

var class<SkinInfo> userSkinClass; // for reference only, change in attached tribesReplicationInfo

simulated function Material GetOverlayMaterial(int Index)
{
	assert(Owner != None);
	return Owner.GetOverlayMaterial(Index);
}

defaultProperties
{
	RemoteRole = ROLE_None
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'lightArmour.jetpackPL'

	bHardAttach=true
	bCollideActors=false
	bStatic=false
	bOwnerNoSee=true
	bAcceptsProjectors=false
} 