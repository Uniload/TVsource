class FailVehicleSpawnAssaultShip extends BaseObjectClasses.BaseObjectVehicleSpawnAssaultShip;

/*
simulated function postSpawnVehicle()
{
	// getting crash in detachFromBone
	if (spawnedVehicle != None)
	{
		spawnedVehicle.spawning = false;

		spawnedVehicle.finishedSpawnFromVehicleSpawnPoint();
	}
	Destroy();
}
*/

// State Unpowered
simulated state Unpowered
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if(Health <= 0)
		{
			GotoState('Destructed');
			return;
		}

		if(isDisabled())
			GotoState('Destructed');

		if (isPowered())
		{
			if(isDamaged())
				GotoState('Damaged');
			else if(Health >= healthMaximum)
				if(spawnedVehicle == None)
					GotoState('Active','NewSpawn');
				else
					GotoState('Active','WaitForNewSpawnEvent');
		}
	}

	simulated function BeginState()
	{
		if (!bInitialization)
		    TriggerEffectEvent('UnpoweredStart');
	    TriggerEffectEvent('UnpoweredLoop');

		if(Mesh != None)
		{
			if (!bInitialization)
			{
				if(HasAnim('PowerLost'))
					PlayBDAnim('PowerLost');
				else
					StopAnimating();
			}
			else
			{
				PlayBDAnim('PowerLost');
				SetAnimFrame(1000.0);
			}
		}
		
		deactivatepersonalShield();

		dispatchMessage(new class'MessageBaseDevicePowerOff'(Label));

		bInitialization = false;
	}
	
	simulated function EndState()
	{
	    UnTriggerEffectEvent('UnpoweredLoop');
	    TriggerEffectEvent('UnpoweredStop');

		dispatchMessage(new class'MessageBaseDevicePowerOn'(Label));
	}
}

defaultproperties
{
     VehicleClass=Class'FailVehicleAssaultShip'
     localizedName="Mile High Club Pad"
     bWorldGeometry=False
     bCollideWorld=False
}
