class FailVehicleSpawnFighter extends BaseObjectClasses.BaseObjectVehicleSpawnFighter;

var bool bFirstSpawn;

simulated function preBeginPlay()
{
	super.preBeginPlay();
	bFirstSpawn = true;
}

/*
simulated latent function latentExecuteInitialization()
{
	if(isDisabled())
	{
		GotoState('Destructed');
	}
	else if(!isPowered() && !bWasDeployed)
	{
		GotoState('UnPowered');
	}
	else if(isDamaged())
	{
		GotoState('Damaged');
	}
	else
	{
		if(bFirstSpawn)
			GotoState('Active');
		else {
			bFirstSpawn = false;
			GotoState('Active','NewSpawn');
		}
	}
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
     VehicleClass=Class'FailVehiclePod'
     bWorldGeometry=False
     bCollideWorld=False
}
