class EmergencySpawnPoint extends ObjectSpawnPoint;


// State Unpowered
simulated state Unpowered
{
Begin:
	bPowered = true;
	GotoState('Active');
}


defaultproperties
{
	bCanSpawnMultiples	= true
	bCanBeDamaged		= false
}