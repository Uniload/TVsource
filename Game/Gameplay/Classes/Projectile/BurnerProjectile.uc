class BurnerProjectile extends Projectile;

var() float ignitionDelay;
var() float postIgnitionColRadius;
var() float postIgnitionColHeight;
var() float postIgnitionVelocity;
var bool weHaveIgnition;

var() class<BurningArea> burningAreaClass;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetTimer(ignitionDelay, false);
}

simulated event Destroyed()
{
    UntriggerEffectEvent('Ignition');
	super.Destroyed();
}

simulated function Timer()
{
	UnTriggerEffectEvent('Alive');
	TriggerEffectEvent('Ignition');
	SetCollisionSize(postIgnitionColRadius, postIgnitionColHeight);
	Velocity = Normal(Velocity) * postIgnitionVelocity;
	weHaveIgnition = true;
}

simulated function HitWall(Vector HitNormal, Actor HitWall)
{
	SpawnBurningArea();
	super.HitWall(HitNormal, HitWall);
}

function SpawnBurningArea()
{
	if (!PhysicsVolume.bWaterVolume)
		Spawn(burningAreaClass,,, Location);
}

simulated function bool ShouldHit(Actor Other, vector TouchLocation)
{
	if (weHaveIgnition)
		return super.ShouldHit(Other, TouchLocation);
	else
		return !ClientDetectDeflection(Other, TouchLocation) && super.ShouldHit(Other, TouchLocation);
}

function bool ShouldDeflect(Actor Other, Vector TouchLocation, out Vector deflectionNormal)
{
	return !weHaveIgnition && super.ShouldDeflect(Other, TouchLocation, deflectionNormal);
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	BurnTarget(Rook(Other));
	SpawnBurningArea();
	super.ProjectileHit(Other, TouchLocation, TouchNormal);
}

simulated function BurnTarget(Rook target)
{
	if (target != None)
	{
		target.flameSource = Instigator;
		target.flameDamageType = damageTypeClass;
		target.flameDamagePerSecond = burningAreaClass.default.burnDamageRate;
		target.flameDamageReductionPerSecond = burningAreaClass.default.burnDamageRateReduction;
	}
}

defaultproperties
{
	damageAmt = 10
	burningAreaClass = class'BurningArea'

	bNetTemporary = false

	ignitionDelay = 0.4
	postIgnitionColRadius = 200
	postIgnitionColHeight = 200
	postIgnitionVelocity = 3000

	StaticMesh = StaticMesh'Weapons.Disc'
	DrawScale3D = (X=0.75,Y=0.75,Z=0.75)

	deathMessage = '%s copped it off %s\'s Spinfusor'
	
	knockback = 0			// burner projectile does not cause knockback
}