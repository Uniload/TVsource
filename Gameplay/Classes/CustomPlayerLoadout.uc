//
// class: CustomPlayerLoadout
//
// 
//
class CustomPlayerLoadout extends Loadout
	native
	transient;

var config class<CombatRole>	combatRoleClass;
var config string				userSkinPath;
var config string				loadoutName;

struct native SkinPreferenceMapping
{
	var config Mesh		mesh;
	var config string	skin;
};

var config Array<SkinPreferenceMapping>	skinPreferences;

// isValid
// returns false if the given loadout is invalid for a character
//
// this version always returns true if the armorClass is valid 
// because the armor is held in the loadout and thus should be ok
//
function bool isValid(Character c, Armor a)
{
	if(combatRoleClass.default.armorClass != None)
		return true;
	else
		return super.isValid(c, a);
}

// equip
// gives the equipment in the loadout to the player
function bool equip(Character c)
{
	local bool equipped;
	local Mesh mesh;
	local Jetpack jetpack;
	local Mesh armsMesh;

	if(combatRoleClass != None)
	{
		c.combatRole = combatRoleClass;
		if(combatRoleClass.default.armorClass != None)
		{
			c.armorClass = combatRoleClass.default.armorClass;

			combatRoleClass.default.armorClass.static.equip(c);

			// set mesh from TeamInfo
			mesh = c.team().getMeshForRole(c.combatRole, c.bIsFemale);
			if(mesh != None)
				c.LinkMesh(mesh);
			else
				log("MultiplayerGameInfo: No mesh defined for combat role "$c.combatRole$", team "$c.team()$", bIsFemale "$c.bIsFemale);

			// set jetpack mesh for TeamInfo
			jetpack = c.team().getJetpackForRole(c, c.combatRole, c.bIsFemale);
			if (jetpack != None)
				c.setJetpack(jetpack);

			armsMesh = c.team().getArmsMeshForRole(c.combatRole);
			if (armsMesh != None)
				c.setArmsMesh(armsMesh);
		}
	}

	equipped = super.equip(c);
	if (equipped)
	{
		c.tribesReplicationInfo.userSkinName = userSkinPath;
	}

	return equipped;
}

// skin helper functions

static function SetSkinPreference(out Array<SkinPreferenceMapping> skinPreferences, Mesh mesh, String skinPath)
{
	local int i;

	for(i = 0; i < skinPreferences.Length; ++i)
	{
		if(mesh == skinPreferences[i].mesh)
		{
			skinPreferences[i].skin = skinPath;
			return;
		}
	}

	skinPreferences.Length = skinPreferences.Length + 1;
	skinPreferences[skinPreferences.Length - 1].mesh = mesh;
	skinPreferences[skinPreferences.Length - 1].skin = skinPath;
}

static function String GetSkinPreference(Array<SkinPreferenceMapping> skinPreferences, Mesh mesh)
{
	local int i;

	for(i = 0; i < skinPreferences.Length; ++i)
	{
		if(mesh == skinPreferences[i].mesh)
			return skinPreferences[i].skin;
	}

	return "";
}

defaultproperties
{
}
