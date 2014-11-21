class FailProjectileSniperRifle extends EquipmentClasses.ProjectileSniperRifle;

//var() float damageEnergyDrainFactor;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		damageAmt = 0;
	}

	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

/* function bool ShouldDeflect(Actor Other, Vector TouchLocation, out Vector deflectionNormal)
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
} */
/*
singular simulated function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	local Projectile p;
	local Vector HitNormal;

	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		damageAmt = 0;
	}

	if (!projectileTouchProcessing(Other, TouchLocation, TouchNormal))
		return;

	if (ShouldHit(Other, TouchLocation))
	{
		if (!ShouldDeflect(Other, TouchLocation, HitNormal))
		{
			ProjectileHit(Other, TouchLocation, TouchNormal);
		}
		else
		{
			p = bounce(HitNormal, TouchLocation, Other.Velocity);
			p.bounceCount = 0; // Deflection doesn't count as a bounce
		}
	}

}
*/

defaultproperties
{
     //damageEnergyDrainFactor=0.750000
}
