
class TribesInventoryCharacter extends Engine.Actor;

var InventoryStationAccess.InventoryStationLoadout currentLoadout;

var name						jetpackBone;
var Jetpack						jetpack;

var name						packLeftBone;
var name						packRightBone;
var StaticMeshAttachment		leftPack;
var StaticMeshAttachment		rightPack;

var name						weaponBone;
var StaticMeshAttachment		weapon;

simulated function Destroyed()
{
	super.Destroyed();

	if(jetpack != None)
	{
		jetpack.Destroy();
		jetPack = None;
	}

	if(leftPack != None)
	{
		leftPack.Destroy();
		leftPack = None;
	}
	if(rightPack != None)
	{
		rightPack.Destroy();
		rightPack = None;
	}

	if(weapon != None)
	{
		weapon.Destroy();
		weapon = None;
	}
}

function UpdateSkin(class<SkinInfo> newSkin)
{
	if(newSkin == None)
		return;

	newSkin.static.applyToCharacter(self);
	if(jetPack != None)
		newSkin.static.applyToJetpack(jetPack);
}

simulated function UpdateLoadout(InventoryStationAccess.InventoryStationLoadout newLoadout, TeamInfo team, bool bIsFemale)
{
	local Jetpack	newJetpack;
	local Mesh		newMesh;
	local bool		bNeedsWeaponSwitch;

	// change to selected armour if armour is different
	if(newLoadout.role.combatRoleClass != currentLoadout.role.combatRoleClass)
	{
		// change mesh
		newMesh = team.getMeshForRole(newLoadout.role.combatRoleClass, bIsFemale);
		if(newMesh != None)
			LinkMesh(newMesh);

		// change jetpack mesh
		newJetpack = team.getJetpackForRole(self, newLoadout.role.combatRoleClass, bIsFemale);
		if(jetpack != None)
		{
			jetpack.destroy();
			jetpack = None;
		}

		if(newJetpack != None)
		{
			jetpack = newJetpack;
			attachToBone(jetpack, jetpackBone);
		}

		bNeedsWeaponSwitch = true;
	}

	bNeedsWeaponSwitch = bNeedsWeaponSwitch || 
						(currentLoadout.weapons[currentLoadout.activeWeaponSlot].weaponClass != 
						newLoadout.weapons[newLoadout.activeWeaponSlot].weaponClass);

	// change to selected pack
	if(currentLoadout.pack.packClass != newLoadout.pack.packClass)
	{
		// destroy the packs first
		if(leftPack != None)
		{
			leftPack.destroy();
			leftPack = None;
		}
		if(rightPack != None)
		{
			rightPack.destroy();
			rightPack = None;
		}

		if(newLoadout.pack.packClass != None && newLoadout.pack.packClass.default.thirdPersonMesh != None)
		{
			// add the left pack
			leftPack = new class'StaticMeshAttachment';
			leftPack.SetStaticMesh(newLoadout.pack.packClass.default.thirdPersonMesh);
			attachToBone(leftPack, packLeftBone);

			// add the right pack
			rightPack = new class'StaticMeshAttachment';
			rightPack.SetStaticMesh(newLoadout.pack.packClass.default.thirdPersonMesh);
			attachToBone(rightPack, packRightBone);
		}
	}

	// set the current loadout
	currentLoadout = newLoadout;

	// attach the selected weapon 
	if(bNeedsWeaponSwitch && weapon == None)
		SetHeldWeapon(newLoadout.weapons[newLoadout.activeWeaponSlot].weaponClass);
}

function SetHeldWeapon(class<Weapon> weaponClass)
{
	if(currentLoadout.role.combatRoleClass == None || 
	   currentLoadout.role.combatRoleClass.default.armorClass == None)
			return;

	if(weapon != None)
	{
		weapon.Destroy();
		weapon = None;
	}

	weapon = new class'StaticMeshAttachment';
	if(weaponClass == None)
		weapon.SetStaticMesh(None);
	else if(currentLoadout.role.combatRoleClass.default.armorClass.static.useAlternateWeaponMesh())
		weapon.SetStaticMesh(weaponClass.default.thirdPersonAltStaticMesh);
	else
		weapon.SetStaticMesh(weaponClass.default.thirdPersonStaticMesh);
	attachToBone(weapon, weaponBone);
	weapon.SetRelativeLocation(weaponClass.default.thirdPersonAttachmentOffset);
}

defaultproperties
{
	DrawType		= DT_Mesh
	RemoteRole		= None

	packLeftBone	= packLeft
	packRightBone	= packRight
	jetpackBone		= jetpack
	weaponBone		= weapon

}