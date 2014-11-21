class EnergyPack extends Pack;

var (EnergyPack) float boostImpulsePerSecond			"The amount of impulse to apply to the wearer per second when activated";

var (EnergyPack) float rechargeScale					"The wearer's energy recharge rate will be passively multiplied by this amount";

var float originalEnergyRechargeScale;

simulated function applyPassiveEffect(Character characterOwner)
{
	originalEnergyRechargeScale = characterOwner.energyRechargeScale;
	characterOwner.energyRechargeScale = rechargeScale;
}

simulated function removePassiveEffect(Character characterOwner)
{
	characterOwner.energyRechargeScale = originalEnergyRechargeScale;
}

simulated state Activating
{
	simulated function tick(float deltaSeconds)
	{
		local vector facing;
		local float AppliedImpulsePerSecond;

		Super.tick(deltaSeconds);

		// calculate facing
		if (heldBy != None && heldBy.movementObject != None)
		{
			facing = vect(1,0,0);
			facing = facing >> heldBy.motor.getViewRotation();

			// tune the boost to act on a mass of 100 regardless
			AppliedImpulsePerSecond = (boostImpulsePerSecond * heldBy.unifiedGetMass()) / 100;

			// apply boost
			heldBy.movementObject.addImpulse(facing * AppliedImpulsePerSecond * deltaSeconds);
		}
	}
}

simulated state Active
{
	simulated function tick(float deltaSeconds)
	{
		local vector facing;
		local float AppliedImpulsePerSecond;

		Super.tick(deltaSeconds);

		if (heldBy != None && heldBy.movementObject != None)
		{
			// calculate facing
			facing = vect(1,0,0);
			facing = facing >> heldBy.motor.getViewRotation();

			// tune the boost to act on a mass of 100 regardless
			AppliedImpulsePerSecond = (boostImpulsePerSecond * heldBy.unifiedGetMass()) / 100;

			// apply boost
			heldBy.movementObject.addImpulse(facing * AppliedImpulsePerSecond * deltaSeconds);
		}
	}
}

defaultProperties
{
	boostImpulsePerSecond = 170000

	rechargeScale = 2

	rechargeTimeSeconds = 2

	rampUpTimeSeconds = 0.75

	durationSeconds = 0.75

	thirdPersonMesh = StaticMesh'Packs.EnergyPack'
	StaticMesh = StaticMesh'Packs.EnergyPackdropped'
}