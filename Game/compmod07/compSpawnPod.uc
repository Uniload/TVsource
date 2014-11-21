class compSpawnPod extends BaseObjectClasses.BaseObjectVehicleSpawnFighter;

// State Unpowered
simulated state Unpowered
{
	simulated function Tick(float Delta)
	{
		Log("adding to spawnStartTime " $ Delta);
		spawnStartTime += Delta; //this is the time the game thinks the vehicle started to spawn
		super.Tick(Delta);
	}
}

defaultproperties
{
     VehicleClass=Class'compPod'
}
