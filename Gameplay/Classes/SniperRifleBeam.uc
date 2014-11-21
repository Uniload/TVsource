class SniperRifleBeam extends Engine.Actor;

const STATIC_MESH_LENGTH = 100;

var SniperRifleProjectile proj;
var() float fadeRate;

var float scaleX;
var float scaleZ;
var Vector direction;

replication
{
	reliable if (Role == ROLE_Authority)
		scaleX, scaleZ, direction;
}

overloaded function construct(SniperRifleProjectile p)
{
	// Must set direction *before* super.construct() because super.construct() calls PostNetBeginPlay()
	direction = p.Velocity;

	super.construct();

	GotoState('Scaling');

	p.beam = self;
	proj = p;

	SetLocation(p.Location);

	setBeamScale(0.0, p.energyModifier);
}

simulated function PostNetBeginPlay()
{
	SetRotation(Rotator(direction));
}

simulated function PostNetReceive()
{
	super.PostNetReceive();
	setBeamScale(scaleX, scaleZ);
}

simulated function float setBeamScale(float x, float z)
{
	local Vector scale;

	scaleX = x; // For replication
	scaleZ = z; // For replication

	scale.X = x;
	scale.Y = 1.0;
	scale.Z = z;

	SetDrawScale3D(scale);

	return scale.Z;
}

function onProjectileDeath()
{
	if (proj != None)
		scaleBeam();

	GotoState('Fading');
}

function scaleBeam()
{
	setBeamScale(VSize(Location - proj.Location) / STATIC_MESH_LENGTH, proj.energyModifier);
}

state Scaling
{
	function Tick(float Delta)
	{
		if (proj != None)
			scaleBeam();
		else
			GotoState('Fading');
	}
}

state Fading
{
	function Tick(float Delta)
	{
		if (setBeamScale(DrawScale3D.X, DrawScale3D.Z - (Delta / fadeRate)) <= 0.0)
			Destroy();
	}
}

defaultproperties
{
     fadeRate=1.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'weapons.SniperRifleTracer'
     bUpdateSimulatedPosition=True
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=True
}
