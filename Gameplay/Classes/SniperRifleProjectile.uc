class SniperRifleProjectile extends Projectile;

var SniperRifleBeam beam;
var float energyModifier;

// construct
overloaded function construct(Rook attacker, optional actor Owner, optional name Tag, 
				  optional vector Location, optional rotator Rotation)
{
	energyModifier = Character(attacker).energy / Character(attacker).energyMaximum;

	damageAmt = default.damageAmt * energyModifier;

	super.construct(attacker, Owner, Tag, Location, Rotation);
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
    // scale knockback my energy multiplier

    local Vector momentum;
    
    momentum = normal(velocity) * knockback;

	victim = Other.Name;

	Other.TakeDamage(damageAmt, Instigator, TouchLocation, momentum, damageTypeClass, 1.0-knockbackAliveScale);

	endLife(Other, TouchLocation, TouchNormal);
}

function PostBounce(Projectile newProjectile)
{
	local SniperRifleProjectile srProj;

	srProj = SniperRifleProjectile(newProjectile);

	srProj.energyModifier = energyModifier;
	srProj.damageAmt = damageAmt;

	new class'SniperRifleBeam'(srProj);

	super.PostBounce(srProj);
}

simulated function Destroyed()
{
	if (beam != None)
		beam.onProjectileDeath();

	super.Destroyed();
}

defaultproperties
{
     damageAmt=60.000000
     Knockback=60000.000000
     StaticMesh=StaticMesh'weapons.Grenade'
     DrawScale3D=(X=0.100000,Y=0.100000,Z=0.100000)
}
