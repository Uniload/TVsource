/*
	Projectile
	
	A object fired from a weapon for the purpose of hurting things. Could be propelled (bullet) or hit instantly (beam).
*/
class Projectile extends Engine.Actor
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var int SpawnTick;

var Vector InitialVelocity;
var bool bReceivedInitialVelocity;
var bool bReplicateInitialVelocity;

var() float AccelerationMagtitude;
var() float MaxVelocity;

// Damage and messages
var Name deathMessage;
var() float damageAmt;

// Internals
var Name victim;
var Rook rookAttacker;

var int bounceCount;

var() class<DamageType> damageTypeClass;

var() bool bScaleProjectile;
var() float initialXDrawScale;
var() float xDrawScalePerSecond;

var() bool bDeflectable;

var (Knockback) float knockback;                    // knockback impulse to apply to object when hits (unreal units * kilograms)
var (Knockback) float knockbackAliveScale;          // use this to reduce knockback applied while the character is alive without reducing the effects of the knockback on ragdolls and dynamic objects [0,1]. designed so the chaingun doesnt push people back so much while they are alive. it looks dumb.

replication
{
	reliable if (Role == ROLE_Authority && bReplicateInitialVelocity)
		InitialVelocity;
}

// construct
overloaded function construct(Rook attacker, optional actor Owner, optional name Tag, 
				  optional vector Location, optional rotator Rotation)
{
	rookAttacker = attacker;
	super.construct(Owner, Tag, Location, Rotation);
}

static simulated function PrecacheProjectileRenderData(LevelInfo Level, class<Projectile> ProjectileClass)
{
	// projectile stuff
	if (ProjectileClass.default.DrawType == DT_StaticMesh)
		Level.AddPrecacheStaticMesh(ProjectileClass.default.StaticMesh);

	if (ProjectileClass.default.DrawType == DT_Mesh)
		Level.AddPrecacheMesh(ProjectileClass.default.Mesh);

	// mp sturf
	if (Level.NetMode != NM_Standalone)
	{
		if (ProjectileClass.default.damageTypeClass != None && ProjectileClass.default.damageTypeClass.default.deathMessageIconMaterial != None)
			Level.AddPrecacheMaterial(ProjectileClass.default.damageTypeClass.default.deathMessageIconMaterial);
	}
}


simulated function PostNetBeginPlay()
{
	local Vector initDrawScale3D;

	super.PostNetBeginPlay();

	if (bScaleProjectile)
	{
		initDrawScale3D = Vect(0.0, 1.0, 1.0);
		initDrawScale3D.X = initialXDrawScale;
		SetDrawScale3D(initDrawScale3D);
	}
}

simulated function Tick(float Delta)
{
	local Vector newDrawScale;

	if (bScaleProjectile && DrawScale3D.X < 1.0)
	{
		newDrawScale = Vect(0.0, 1.0, 1.0);

		newDrawScale.X = DrawScale3D.X + xDrawScalePerSecond * Delta;
		newDrawScale.Y = 1.0;
		newDrawScale.Z = 1.0;

		SetDrawScale3D(newDrawScale);
	}
}

simulated function PostNetReceive()
{
	if (rookAttacker == None)
		rookAttacker = Rook(Instigator);

	if (!bReceivedInitialVelocity && InitialVelocity != Vect(0.0, 0.0, 0.0))
	{
		Velocity = InitialVelocity;
		Acceleration = Normal(Velocity) * AccelerationMagtitude;
		SetRotation(Rotator(Velocity));

		bReceivedInitialVelocity = true;
	}
}

simulated function triggerHitEffect(Actor HitActor, vector TouchLocation, vector TouchNormal, optional Name HitEffect)
{
	local Material HitMaterial;
	local Vector HitLocation;
    local Rotator HitRotator;
    local Rotator DecalRotator;

	if (HitEffect == '')
		HitEffect = 'Hit';

  	if (HitActor != None && resolveImpactEffect(HitActor, TouchLocation, TouchNormal, HitMaterial, HitLocation, HitRotator, DecalRotator))
	{
		TriggerEffectEvent(HitEffect, None, HitMaterial, HitLocation, HitRotator);
		TriggerEffectEvent('Decal', None, HitMaterial, HitLocation, DecalRotator);
	}
	else
		TriggerEffectEvent(HitEffect, None, None, TouchLocation);
}

// endLife
simulated function endLife(Actor HitActor, vector TouchLocation, vector TouchNormal)
{
	triggerHitEffect(HitActor, TouchLocation, TouchNormal);
	Destroy();
}

native final function bool resolveImpactEffect(Actor HitActor, vector TouchLocation, vector TouchNormal, out material hitMaterial, 
											   out vector hitLocation, out rotator hitRotator, out rotator decalRotator);

function Projectile bounce(Vector HitNormal, vector HitLocation, Vector TargetVelocity)
{
	local Projectile p;
	local class<Projectile> projClass;
	local vector newVelDir;
	local float preBounceVelSize;
	local Vector newVelocity;

	++bounceCount;

	newVelDir = MirrorVectorByNormal(Normal(Velocity), HitNormal);

	projClass = class;
	p = new projClass(Rook(Instigator), , , (HitLocation + newVelDir * (VSize(TargetVelocity) / 10)), Rotator(newVelDir));

	preBounceVelSize = VSize(Velocity);

	p.bounceCount = bounceCount;
	newVelocity = preBounceVelSize * newVelDir + TargetVelocity;

	// Bouncing never reduces the size of the velocity
	if (VSize(newVelocity) < preBounceVelSize)
		newVelocity = preBounceVelSize * newVelDir;

	p.InitialVelocity = newVelocity;
	p.Velocity = newVelocity;

	Acceleration = Normal(Velocity) * AccelerationMagtitude;

	PostBounce(p);

	return p;
}

function PostBounce(Projectile newProjectile)
{
	Destroy();
}

// HitWall
simulated function HitWall(Vector HitNormal, Actor HitWall)
{
	endLife(HitWall, Location, HitNormal);
}

simulated function bool ShouldHit(Actor Other, vector TouchLocation)
{
	if (Equipment(Other) != None)
		return false;

	return Other.ShouldProjectileHit(Instigator) && (Other != Instigator || bounceCount > 0);
}

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
				Instigator = c;
				return true;
			}
		}
	}

	return false;
}


simulated function bool ClientDetectDeflection(Actor Other, vector TouchLocation)
{
	local Character c;
	local Buckler b;
	local Rotator r;

	if (Level.NetMode == NM_Client)
	{
		c = Character(Other);

		if (c != None)
		{
			b = Buckler(c.weapon);

			if (b != None && b.hasAmmo())
			{
				r.Pitch = 257 * c.movementSimProxyPitch - 32768;
				r.Yaw = c.Rotation.Yaw;

				if (Normal(c.Location - TouchLocation) Dot Normal(Vector(r)) < -b.cosDeflectionAngle)
					return true;
			}
		}
	}

	return false;
}

// Touch
singular simulated function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	local Projectile p;
	local Vector HitNormal;

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

// Give sub-classes a chance to do processing. If false is returned do not continue touch processing.
simulated function bool projectileTouchProcessing(Actor Other, vector TouchLocation, vector TouchNormal)
{
	return true;
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
    local Vector momentum;
    
    momentum = normal(velocity) * knockback;

	victim = Other.Name;

	Other.TakeDamage(damageAmt, Instigator, TouchLocation, momentum, damageTypeClass, 1.0-knockbackAliveScale);

	endLife(Other, TouchLocation, TouchNormal);
}

// makeHarmless
// Call this to make the projectile deal no damage
function makeHarmless()
{
	damageAmt = 0;
}

cpptext
{
	virtual UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);
	virtual void performPhysics(FLOAT DeltaSeconds);
	virtual void BoundProjectileVelocity();

}


defaultproperties
{
     bReplicateInitialVelocity=True
     DeathMessage="'"
     damageTypeClass=Class'ProjectileDamageType'
     bDeflectable=True
     Knockback=10000.000000
     Physics=PHYS_Projectile
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'weapons.Disc'
     bNetTemporary=True
     bReplicateInstigator=True
     bReplicateMovement=False
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=2.500000
     CullDistance=5000.000000
     bUnlit=True
     bCollideActors=True
     bCollideWorld=True
     bProjectile=True
     bUseCylinderCollision=True
     bNetNotify=True
     bNeedLifetimeEffectEvents=True
}
