class Arms extends Engine.Actor;

var class<SkinInfo> userSkinClass; // for reference only, change in attached tribesReplicationInfo

simulated function Material GetOverlayMaterial(int Index)
{
	assert(Owner != None);
	return Owner.GetOverlayMaterial(Index);
}

defaultproperties
{
     DrawType=DT_Mesh
     RemoteRole=ROLE_None
}
