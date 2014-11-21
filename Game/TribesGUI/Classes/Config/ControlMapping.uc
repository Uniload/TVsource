class ControlMapping extends Core.Object
	PerObjectConfig
	Config(ControlMapping);

struct CommandMapping
{
	var				bool	bIsSectionLabel;
	var localized	string	Action;
	var				string	Command;
};

var localized config string			Labels[50];		// fixed-length array for localization
var localized config CommandMapping	Mappings[50];	// mappings of keyMappings
var config int NumMappings;							// number of mappings

//
// Bug in ucc means that we have to have an accessor function
// for fixed size arrays. Meh.
//
function CommandMapping GetMapping(int i)
{
	log("labels["$i$"]: "$Labels[i]);
	log("mappings["$i$"]: "$Mappings[i].Action@Mappings[i].Command);
	return Mappings[i];
}