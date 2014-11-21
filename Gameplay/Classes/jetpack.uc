class Jetpack extends Engine.Actor;

var class<SkinInfo> userSkinClass; // for reference only, change in attached tribesReplicationInfo

simulated function Material GetOverlayMaterial(int Index)
{
	assert(Owner != None);
	return Owner.GetOverlayMaterial(Index);
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'LightArmour.JetPackPL'
     RemoteRole=ROLE_None
     bHardAttach=True
     bOwnerNoSee=True
}
