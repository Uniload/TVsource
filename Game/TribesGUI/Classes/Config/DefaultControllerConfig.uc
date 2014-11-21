///
/// Extended for the sole purpose of overriding the config file.
///
class DefaultControllerConfig extends ControllerConfig
	Config(DefaultControllerConfig);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	ReadCurrent();
	Store();
}

