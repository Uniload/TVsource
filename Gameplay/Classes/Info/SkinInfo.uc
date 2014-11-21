// This class defines data used to build the selection of skins available to a user at an inventory station
// Skin authors should inherit from the class and store the new classes in the skin's package file
class SkinInfo extends Engine.Info
	native;

var() Array<Material>	meshSkins;
var() Array<Material>	jetpackSkins;
var() Array<Material>	armsSkins;
var() Mesh				applicableMesh;

// applies the skin to a character.
// the default SkinInfo class should set the character's skin to defaults.
static function applyToCharacter(Actor c)
{
	local int i;

	// clear existing skin settings
	for (i = 0; i < c.skins.Length; i++)
		c.skins[i] = None;
	
	// set new skin
	for (i = 0; i < default.meshSkins.Length; i++)
		c.Skins[i] = default.meshSkins[i];
}

static function applyToJetpack(Actor j)
{
	local int i;

	// clear existing skin settings
	for (i = 0; i < j.skins.Length; i++)
		j.skins[i] = None;
	
	// set new skin
	for (i = 0; i < default.jetpackSkins.Length; i++)
		j.Skins[i] = default.jetpackSkins[i];
}

static function applyToArms(Actor a)
{
	local int i;

	// clear existing skin settings
	for (i = 0; i < a.skins.Length; i++)
		a.skins[i] = None;
	
	// set new skin
	for (i = 0; i < default.armsSkins.Length; i++)
		a.Skins[i] = default.armsSkins[i];
}

// returns true if the skin class can be used with the given team and role
static function bool isApplicable(Mesh mesh)
{
	return mesh == default.applicableMesh;
}

// loads all skin info objects from the skins directory
native static function loadAllSkins(LevelInfo l);