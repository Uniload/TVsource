class PowerGenerator extends BaseDevice;

// State Unpowered
simulated state Unpowered
{
Begin:
	bPowered = true;
	GotoState('Active', 'Regenerating');
}

defaultproperties
{
	baseDeviceMessageClass			= class'MPBaseDeviceMessages'
}