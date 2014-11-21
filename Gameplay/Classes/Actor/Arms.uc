class Arms extends Engine.Actor;

var class<SkinInfo> userSkinClass; // for reference only, change in attached tribesReplicationInfo

simulated function Material GetOverlayMaterial(int Index)
{
	assert(Owner != None);
	return Owner.GetOverlayMaterial(Index);
}

defaultProperties
{
	RemoteRole = ROLE_None
	DrawType=DT_Mesh
	bAcceptsProjectors = false
}