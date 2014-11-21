class FailProjectileChaingunSentry extends EquipmentClasses.ProjectileChaingunSentry;

var() float damageEnergyDrainFactor;

function bool ShouldDeflect(Actor Other, Vector TouchLocation, out Vector deflectionNormal)
{
	local Character c;
	local Buckler b;
	local Vector bucklerHeight;

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
				if(c.energy < damageAmt * damageEnergyDrainFactor)
				{
					damageAmt -= (c.energy * damageEnergyDrainFactor);
					c.energy = 0;
					return false;
				}
				else
				 {
					Instigator = c;
					c.weaponUseEnergy(damageAmt * damageEnergyDrainFactor);
					//c.clientWeaponUseEnergy(damageAmt * damageEnergyDrainFactor);
				}

				return true;
			}
		}
	}

	return false;
}

defaultproperties
{
     damageEnergyDrainFactor=0.500000
}
