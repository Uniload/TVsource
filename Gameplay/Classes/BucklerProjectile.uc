class BucklerProjectile extends Projectile;

var Character firer;
var Buckler buckler;

var Vector xAxis, yAxis, zAxis; // The player's view axes

var float velocitySize;

var bool bReturning;

var() float returnTime		"The number of seconds before the buckler will try to return to it's owner";

var() bool bPlayingClosed;
var() float closeRadius		"The radius at which the buckler will close up when returning to it's owner";

var float xAxisLength;

var Vector target;
var Vector previousTarget;

var Array<Actor> hitActors;

replication
{
	reliable if (Role == ROLE_Authority)
		target, velocitySize;
}

simulated function Destroyed()
{
	if (buckler != None)
		buckler.proj = None;

	super.Destroyed();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	LoopAnim('Spin', 2.0);
	firer = Character(Instigator);
}

simulated function bool hasHit(Actor a)
{
	local int i;

	for (i = 0; i < hitActors.Length; ++i)
		if (hitActors[i] == a)
			return true;

	return false;
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (!hasHit(Other))
	{
		hitActors[hitActors.Length] = Other;
		super.ProjectileHit(Other, TouchLocation, TouchNormal);
	}
}

simulated function Projectile bounce(Vector HitNormal, vector HitLocation, Vector TargetVelocity)
{
	assert(false);
	return None;
}

simulated function lost()
{
	if (buckler != None)
	{
		buckler.lost();
	}

	TriggerEffectEvent('Lost');
	Destroy();
}

simulated function endLife(Actor HitActor, vector TouchLocation, vector TouchNormal)
{
	local Material HitMaterial;
	local Vector HitLocation;
    local Rotator HitRotator;
	local Rotator DecalRotator;

    if (HitActor != None && resolveImpactEffect(HitActor, TouchLocation, TouchNormal, HitMaterial, HitLocation, HitRotator, DecalRotator))
		TriggerEffectEvent( 'Hit', None, HitMaterial, HitLocation, HitRotator);
	else
		TriggerEffectEvent('Hit', None, None, TouchLocation);
}

function returnBuckler()
{
	local Buckler buckler;

	if (firer != None)
		buckler = Buckler(firer.nextEquipment(None, class'Buckler'));

	if (buckler != None)
		buckler.returned();

	Destroy();
}

simulated function controlProjectile(float Delta)
{
	local bool bControllable;

	if (firer == None)
		firer = Character(Instigator);

	bControllable = (firer != None && Buckler(firer.weapon) != None);

	if (Level.NetMode != NM_Client)
	{
		if (bReturning)
			xAxisLength -= velocitySize * Delta;
		else
			xAxisLength += velocitySize * Delta;

		if (xAxisLength < 0.0)
			xAxisLength = 0.0;
	}

	if (!bControllable)
	{
		if (bReturning && firer != None)
			Velocity = Normal(firer.Location - Location) * velocitySize;
		else
			return;
	}

	if (bControllable && Level.NetMode != NM_Client)
	{
		GetAxes(firer.motor.getViewRotation(), xAxis, yAxis, zAxis);

		target = ((xAxis * xAxisLength) + firer.Location) - Location;
	}

	if (bControllable && target != previousTarget)
	{
		Velocity = Normal(target) * velocitySize;
		previousTarget = target;
	}

	DesiredRotation = Rotator(Velocity);
	DesiredRotation.Yaw = Rotation.Yaw;
	DesiredRotation.Roll = Rotation.Roll;
}

simulated function adjustXAxisLengthForBounce()
{
	xAxisLength = VSize(Instigator.Location - Location) - velocitySize;

	if (xAxisLength < 0.0)
		xAxisLength = 0.0;
}

auto state Launched
{
	simulated function BeginState()
	{
		SetTimer(returnTime, false);
	}

	simulated function EndState()
	{
		hitActors.Length = 0;
	}

	simulated function Timer()
	{
		GotoState('Returning');
	}

	simulated function Tick(float Delta)
	{
		controlProjectile(Delta);
	}

	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (Instigator == None)
		{
			lost();
			return;
		}

		adjustXAxisLengthForBounce();

		GotoState('Returning');

		TriggerEffectEvent('Bounce');
	}
}

state Returning
{
	simulated function BeginState()
	{
		bReturning = true;

		if (Instigator != None)
			SetRotation(Rotator(Instigator.Location - Location));
	}

	simulated function Tick(float Delta)
	{
		if (Instigator == None)
		{
			lost();
			return;
		}

		if (VSize(Location - Instigator.Location) <= Instigator.CollisionHeight)
		{
			returnBuckler();
			return;
		}

		controlProjectile(Delta);

		if (VSize(Location - Instigator.Location) <= closeRadius)
		{
			if (!bPlayingClosed)
			{
				PlayAnim('Spin_ToClose');
				bPlayingClosed = true;
			}
		}
		else if (bPlayingClosed)
		{
			LoopAnim('Spin', 2.0);
			bPlayingClosed = false;
		}
	}

	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (Instigator == None)
		{
			lost();
			return;
		}

		if (((Instigator.Location - Location) Dot Velocity) < 0)
		{
			adjustXAxisLengthForBounce();
		}
		else
		{
			lost();
		}
	}

	simulated function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
	{
		if (Other == Instigator)
			returnBuckler();
		else
			Global.ProjectileTouch(Other, TouchLocation, TouchNormal);
	}
}

defaultproperties
{
     returnTime=2.000000
     closeRadius=200.000000
     damageAmt=50.000000
     bDeflectable=False
     Knockback=0.000000
     DrawType=DT_Mesh
     bNetTemporary=False
     Mesh=SkeletalMesh'weapons.BucklerProjectile'
     bRotateToDesired=True
     RotationRate=(Pitch=25000)
}
