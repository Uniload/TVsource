class RocketPodProjectile extends ExplosiveProjectile;

var		Vector	xAxis, yAxis, zAxis;	// The player's view axes

struct InitVec
{
	var float X, Y, Z;
};

var		InitVec	initialZAxis;

var		Vector	rotationVec;			// The vector towards which the projectile velocity needs to be rotated
var		Vector	prevRotationVec;

var		float	offset;					// The offset from the players view vector
var		float	offsetVecAngle;			// The angle of the offset vector (the offset vector is the z axis of the players view
var()	float	spiralRate				"The rate, in degrees, at which the projectiles rotate around each other"; // Converted to radians at run time

var		bool	armed;					// Set to true after the armingPeriod has expired
var()	float	armingPeriod			"The period after which the projectile will become armed";

var()	float	spreadRadius			"The radius to which the projectile will spread out to after launch";
var()	float	spreadPeriod			"The amount of time it will take the projectile the reach the spreadRadius";

var()	float	convergeRadius			"The radius to which the projectile will converge in to after spreadRadius is reached";
var()	float	convergePeriod			"The amount of time it will take the projectile the reach the convergeRadius";

var()	float	postSpreadVelocity		"The velocity the projectile will accelerate to after reaching the spreadRadius";
var()	float	postSpreadAcceleration	"The rate at which the projectile will accelerate to postSpreadVelocity";

var()	float	maxAnglePerSecond		"Rate of turn in degrees"; // Converted to radians at run time
var()	float	rotationModifier		"Modifier applied to the angle before rotation";

var		float	timeCounter;

replication
{
	reliable if (Role == ROLE_Authority)
		rotationVec, initialZAxis;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(armingPeriod, false);
}

simulated function Timer()
{
	armed = true;
}

simulated function endLife(Actor HitActor, vector TouchLocation, vector TouchNormal)
{
	if (armed)
	{
		Super.endLife(HitActor, TouchLocation, TouchNormal);
	}
	else
	{
		if (!bEndedLife)
			TriggerEffectEvent('Dud', None, None, TouchLocation, Rotator(TouchNormal));

		bEndedLife = true;

		Destroy();
	}
}

simulated function Destroyed()
{
	UntriggerEffectEvent('Jet');
	super.Destroyed();
}

auto state Spread
{
	simulated function BeginState()
	{
		maxAnglePerSecond = (maxAnglePerSecond / 180.0) * Pi; // convert angle from degress to radians
		spiralRate = (spiralRate / 180.0) * Pi; // convert angle from degress to radians
		timeCounter = 0.0;
	}

	simulated function spreadAlongAxis(float Delta)
	{
		zAxis.X = initialZAxis.X;
		zAxis.Y = initialZAxis.Y;
		zAxis.Z = initialZAxis.Z;

		Move(zAxis * (Delta / spreadPeriod) * spreadRadius);
	}

	simulated function Tick(float Delta)
	{
		if (timeCounter < spreadPeriod)
		{
			spreadAlongAxis(Delta);
			timeCounter += Delta;
		}
		else
		{
			offset = spreadRadius;
			GotoState('Converge');
		}
	}
}

state Converge
{
	simulated function BeginState()
	{
		TriggerEffectEvent('Jet');
		timeCounter = 0.0;
	}

	simulated function Tick(float Delta)
	{
		accelerateProjectile(Delta);
		controlProjectile(Delta);

		if (Level.NetMode != NM_Client)
			offset -= (Delta / convergePeriod) * convergeRadius;

		timeCounter += Delta;

		if (timeCounter > convergePeriod)
		{
			// If we haven't hit terminal velocity yet continue accelerating
			if (VSize(Velocity) < postSpreadVelocity)
				GotoState('Accelerate');
			else
				GotoState('Control');
		}
	}
}

simulated function accelerateProjectile(float Delta)
{
	Velocity += Normal(Velocity) * (postSpreadAcceleration * Delta);
}

state Accelerate
{
	simulated function Tick(float Delta)
	{
		accelerateProjectile(Delta);
		controlProjectile(Delta);

		if (VSize(Velocity) > postSpreadVelocity)
			GotoState('Control');
	}
}

simulated function controlProjectile(float Delta)
{
	local Character firer;
	local Vector projectileVec;		// Vector from the players location to the projectiles location
	local float angle;

	if (Level.NetMode != NM_Client)
	{
		if (Instigator == None)
			return;

		firer = Character(Instigator);

		if (RocketPod(firer.weapon) == None)
			return;

		GetAxes(firer.motor.getViewRotation(), xAxis, yAxis, zAxis);

		projectileVec = Location - firer.weapon.rookMotor.getFirstPersonEquippableLocation(firer.weapon);

		offsetVecAngle += spiralRate * Delta;
		
		if (offsetVecAngle > 2 * Pi)
			offsetVecAngle -= 2 * Pi;

		// The projectileVec is projected onto the xAxis and extended by the magnitude of the projectile velocity.
		// Then we add the offset vector (which is calculated with those quat operations and scaled by the offset value).
		// Then we subtract the projectileVec from the value to get a vector from the projectiles location to its ideal location.
		rotationVec = ((((projectileVec Dot xAxis) + VSize(Velocity)) * xAxis) +
			QuatRotateVector(QuatFromAxisAndAngle(xAxis, offsetVecAngle), zAxis) * offset) - projectileVec;
	}

	angle = ACos(FClamp(Normal(Velocity) Dot Normal(rotationVec), -1.0, 1.0));

	if (angle > maxAnglePerSecond)
		angle = maxAnglePerSecond;

	Velocity = QuatRotateVector(QuatFromAxisAndAngle(Velocity Cross rotationVec, angle * Delta * rotationModifier), Velocity);

	prevRotationVec = rotationVec;

	SetRotation(Rotator(Velocity));
}

state Control
{
	simulated function Tick(float Delta)
	{
		controlProjectile(Delta);
	}
}

defaultproperties
{
     spiralRate=120.000000
     armingPeriod=0.500000
     spreadRadius=75.000000
     spreadPeriod=0.500000
     convergeRadius=25.000000
     convergePeriod=1.500000
     postSpreadVelocity=2000.000000
     postSpreadAcceleration=500.000000
     maxAnglePerSecond=90.000000
     rotationModifier=1.000000
     radiusDamageAmt=15.000000
     radiusDamageSize=50.000000
     radiusDamageMomentum=10000.000000
     bDeflectable=False
     StaticMesh=StaticMesh'weapons.Rocket'
     bNetTemporary=False
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
}
