class FailProjectileSpinfusor extends EquipmentClasses.ProjectileSpinfusor;

var() float damageEnergyDrainFactor;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

function bool ShouldDeflect(Actor Other, Vector TouchLocation, out Vector deflectionNormal)
{
	local Character c;
	local Buckler b;
	local Vector bucklerHeight;
	local BucklerProjectile bp;

	c = Character(Other);

	if (bDeflectable && c != None)
	{
		b = Buckler(c.weapon);

		if (b != None && b.hasAmmo())
		{
			deflectionNormal = Normal(Vector(c.motor.GetViewRotation()));
			bucklerHeight = c.Location + Vect(0.0, 0.0, 50.0);
			if (Normal(bucklerHeight - TouchLocation) Dot deflectionNormal < -b.cosDeflectionAngle)
			{
				b.TriggerEffectEvent('BucklerDeflect');
				b.bDeflected = !b.bDeflected;

				radiusDamageAmt = 0;
			}
		}
	}

	return false;
}

defaultproperties
{
     damageEnergyDrainFactor=1.000000
     radiusDamageSize=560.000000
     radiusDamageMomentum=270000.000000
     MaxVelocity=10000.000000
}
