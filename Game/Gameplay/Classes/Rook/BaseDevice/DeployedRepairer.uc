class DeployedRepairer extends BaseDevice implements IRepairClient;

var RepairRadius rr;
var() float radius;
var() float repairRate;
var() float accumulationScale;
var() float selfRepairRate;
var() string socketFrontLeft;
var() string socketFrontRight;
var() string socketBackLeft;
var() string socketBackRight;

// local port positions
var Vector frontPortLeft;
var Vector frontPortRight;
var Vector backPortLeft;
var Vector backPortRight;

simulated function PostBeginPlay()
{
	local Rotator rot;
	local Vector s;

	super.PostBeginPlay();

	initRepairRadius();
	getSocket(socketFrontLeft, frontPortLeft, rot, s, SOCKET_Local);
	getSocket(socketFrontRight, frontPortRight, rot, s, SOCKET_Local);
	getSocket(socketBackLeft, backPortLeft, rot, s, SOCKET_Local);
	getSocket(socketBackRight, backPortRight, rot, s, SOCKET_Local);
}

simulated function Tick(float Delta)
{
	super.Tick(Delta);
	IncreaseHealth(selfRepairRate * Delta);
}

simulated function initRepairRadius()
{
	rr = new class'RepairRadius'(self, , Location);
}

simulated function Destroyed()
{
	super.Destroyed();

	if (rr != None)
		rr.Destroy();
}

// IRepairClient
simulated function bool canRepair(Rook r)
{
	local BaseDevice b;

	if (Character(r) != None && !r.isAlive())
		return false;

	b = BaseDevice(r);
	if (b != None && b.bWasDeployed && b.isDisabled())
		return false;

	return r != self && r.canBeRepairedBy(self) && r.health < r.healthMaximum;
}

simulated function float getRepairRadius()
{
	return radius;
}

simulated function beginRepair(Rook r)
{
	if (!r.IsHumanControlled())
		level.speechManager.PlayDynamicSpeech( r, 'UseHealth' );

	r.addRepairFromDeployable(repairRate, accumulationScale);
}

simulated function endRepair(Rook r)
{
	r.removeRepairFromDeployable(accumulationScale);
}

simulated function Pawn getFXOriginActor()
{
	return self;
}

simulated function Vector getFXTendrilOrigin(Vector targetPos)
{
	local Vector forwardVec;
	local Vector leftVec;
	local Vector originatorToTarget;
	local bool bForward;
	local bool bLeft;

	originatorToTarget = targetPos - Location;
	originatorToTarget.z = 0;
	originatorToTarget = Normal(originatorToTarget);

	forwardVec = Vector(Rotation);
	forwardVec.z = 0;
	forwardVec = Normal(forwardVec);

	leftVec.x = forwardVec.y;
	leftVec.y = -forwardVec.x;

	bForward = originatorToTarget dot forwardVec > 0;
	bLeft = originatorToTarget dot leftVec > 0;

	if (bLeft)
	{
		if (bForward)
			return Location + (frontPortLeft >> Rotation);
		else
			return Location + (backPortLeft >> Rotation);
	}
	else
	{
		if (bForward)
			return Location + (frontPortRight >> Rotation);
		else
			return Location + (backPortRight >> Rotation);
	}

	return Location;
}

simulated function Vector getFXTendrilTarget(Actor target)
{
	return target.unifiedGetPosition();
}

simulated function onTendrilCreate(RepairTendril t) {}

// End IRepairClient

defaultproperties
{
	bWasDeployed = true
	bIgnoreEncroachers = true

	radius = 400
	repairRate = 10
	accumulationScale = 1.0
	selfRepairRate = 5

	socketFrontLeft = "CHILD00"
	socketFrontRight = "CHILD01"
	socketBackLeft = "CHILD02"
	socketBackRight = "CHILD03"

	Mesh = SkeletalMesh'Deployables.DepRepairStation'
}