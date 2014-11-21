class compSpawnRover extends BaseObjectClasses.BaseObjectVehicleSpawnBuggy;


// State Unpowered
simulated state Unpowered
{
	simulated function Tick(float Delta)
	{
		Log("adding to spawnStartTime " $ Delta);
		spawnStartTime += Delta; //this is the time the game thinks the vehicle started to spawn
		
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
				GotoState('Active');
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
     VehicleClass=Class'compRover'
     localizedName="compmod Rover Pad"
}
