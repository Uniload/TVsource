class TimeChargeUpWeapon extends ChargeUpWeapon
	abstract;

var() float initialChargeRate		"Initial rate of charge";
var() float chargeRateAccel			"Acceleration of charge rate";
var() float peakChargeMaxHoldTime	"The maximum time the player can hold the charge once it is at maximum";
var() float releaseDelay			"Delay in seconds from the button being released to the weapon being fired";
var() name chargeAnimation;
var() name releaseAnimation;

var float tickDelta;
var float chargeRate;
var float timeSinceMaxChargeHit;

simulated state FirePressed
{
	simulated function BeginState()
	{
		super.BeginState();
		animClass.static.playEquippableAnim(self, chargeAnimation);
	}

	simulated function Tick(float Delta)
	{
		tickDelta = Delta;
		Super.Tick(Delta);
	}

	simulated function attemptFire()
	{
		if(charge < maxCharge)
		{
			chargeRate += tickDelta * chargeRateAccel;
			charge += tickDelta * chargeRate;
		}
		else
		{
			timeSinceMaxChargeHit += tickDelta;

			if(timeSinceMaxChargeHit >= peakChargeMaxHoldTime && peakChargeMaxHoldTime > 0)
			{
				timeSinceMaxChargeHit = 0;
				chargeRate = initialChargeRate;
				charge = 0;

				if (rookMotor != None)
					rookMotor.setFirePressed(self, false);

				GotoState('Idle');
			}
		}
	}
}

simulated state FireReleased
{
	simulated function BeginState()
	{
		timeSinceMaxChargeHit = 0;
		chargeRate = initialChargeRate;
		animClass.static.playEquippableAnim(self, releaseAnimation);
	}

Begin:
	if (releaseDelay > 0)
		Sleep(releaseDelay);

	fireWeapon();
	charge = 0;

	while (!fireRatePassed())
		Sleep(0.0);

	GotoState('Idle');
}

defaultproperties
{
	initialChargeRate		= 1
	chargeRate				= 1
	chargeRateAccel			= 0
	peakChargeMaxHoldTime	= 3
	chargeAnimation			= "charge"
	releaseAnimation		= "fire"
}
