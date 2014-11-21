///
/// @file:		ControllerConfig.uc
/// @author:	Paul Dennison
///
/// The ControllerConfig class is responsible for managing a single control
/// configuration which can be saved to a file.
///

class ControllerConfig extends Engine.Actor
	PerObjectConfig
	Config(CustomControllerConfigs);

var private	Array<BindingSet>	BindingSets;
var Array<String>				BindingSetNames;

//
// Initialise the array of binding sets.
//
simulated function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	BindingSets.Length = BindingSetNames.Length;
	for(i = 0; i < BindingSetNames.Length; ++i)
	{
		BindingSets[i] = new(None, name$"_"$BindingSetNames[i]) class'BindingSet';
		BindingSets[i].SetName = BindingSetNames[i];
	}
}

simulated function ReadCurrent()
{
	local int i;

	for(i = 0; i < BindingSets.Length; ++i)
		BindingSets[i].ReadCurrent();
}

//
// Stores the config to file
//
simulated function Store()
{
	local int i;

	for(i = 0; i < BindingSets.Length; ++i)
		BindingSets[i].Store();

	SaveConfig();
}

//
// Applies the current key bindings to the settings to be used
// by the player.
//
simulated function Apply()
{
	local int i;

	for(i = 0; i < BindingSets.Length; ++i)
		BindingSets[i].Apply();
}

defaultproperties
{
	BindingSetNames(0)=General
}