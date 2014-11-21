// CombatRole
// Characters on a given team choose from a list of combat roles that are common across all teams.
// CombatRole defines the common aspects of a role for all teams. 
// CombatRole also defines defaults for the combat role which can be overidden per player.
// Combat roles might include a Light Solider, Medium Solider, Heavy Solider.
// Team-specific aspects of the role, such as the mesh used for the character, are defined in
// that team's TeamInfo object.
class CombatRole extends Core.Object
	hidecategories(Object);

var() class<Armor>		armorClass;
var() class<Loadout>	defaultLoadout;
var() Material			inventoryIcon	"Icon used to represent the armor on the inventory screen";

defaultproperties
{
     inventoryIcon=Texture'GUITribes.InvArmourBeagleLight'
}
