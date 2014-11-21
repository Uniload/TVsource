//
//
class ConfigManager extends Engine.Actor
	Config(CustomControllerConfigs);

var config String			activeConfigName;
var config Array<String>	configNames;

var private Array<ControllerConfig>	configs;
var private ControllerConfig		activeConfig;
var private DefaultControllerConfig	defaultConfig;

//
// Initialises the ConfigManager. This involves creating
// the configs from the strings loaded from the config file
//
simulated function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	for(i = 0; i < configNames.Length; ++i)
	{
		configs[i] = new(None, configNames[i]) class'ControllerConfig';
		if(configNames[i] == activeConfigName)
			activeConfig = configs[i];
	}

	defaultConfig = new class'DefaultControllerConfig';
	if(activeConfig == None)
		activeConfig = defaultConfig;
}

//
// Gets the active profile
//
simulated function ControllerConfig GetActiveConfig()
{
	return activeConfig;
}

//
// Sets the active profile. If the profile cannot be
// found in the list of configs it is added automatically
//
simulated function SetActiveConfig(ControllerConfig newActiveConfig)
{
	local int i;
	local bool bFound;

	for(i = 0; i < configs.Length; ++i)
	{
		if(configs[i] == newActiveConfig)
			bfound = true;
	}

	if(! bFound)
		configs[configs.Length] = newActiveConfig;

	activeConfig = newActiveConfig;
	activeConfigName = string(activeConfig.name);
}

//
// Creates a new profile, adds it to the list and returns it.
//
simulated function ControllerConfig NewConfig(String newName)
{
	local ControllerConfig config;

	config = new(None, newName) class'ControllerConfig';

	configs[configs.Length] = config;
	configNames[configs.Length] = string(config.name);

	return config;
}

//
// Deletes an existing profile
//
simulated function DeleteConfig(ControllerConfig config)
{
	local int i;

	for(i = configs.Length - 1; i >= 0; --i)
	{
		if(configs[i] == config)
		{
			configs.Remove(i, 1);
			configNames.Remove(i, 1);
			config.Destroy();
		}
	}
}

defaultproperties
{
	bHidden = true
}