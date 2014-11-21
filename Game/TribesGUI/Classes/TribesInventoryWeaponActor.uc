class TribesInventoryWeaponActor extends Engine.Actor;

function SetWeaponClass(class<Weapon> weaponClass)
{
	if(weaponClass != None)
		LinkMesh(weaponClass.default.thirdPersonMesh);
}

defaultproperties
{
	DrawType = DT_Mesh;
	RemoteRole = None;
	Physics = PHYS_None;
}