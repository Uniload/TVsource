class RepairPack extends Pack implements IRepairClient;

var (RepairPack) float activePeriod						"How frequently the active repair effect is applied in seconds";
var (RepairPack) float passivePeriod					"How frequently the passive repair effect is applied in seconds";
var (RepairPack) float radius							"The radius within which repair effects will be applied to friendly players and objects";
var (RepairPack) float activeHealthPerPeriod			"The health per activePeriod to restore to friendly players and objects when active";
var (RepairPack) float activeExtraSelfHealthPerPeriod	"The extra health per activePeriod to restore to user when active";
var (RepairPack) float passiveHealthPerPeriod			"The health per passivePeriod to restore to user when the pack is worn";
var (RepairPack) float accumulationScale				"How much this pack's active effect stacks with the active effect of other packs";
var (RepairPack) string socketFrontUp;
var (RepairPack) string socketFrontDown;
var (RepairPack) string socketBackUp;
var (RepairPack) string socketBackDown;

var float radiusSquared;

var RepairRadius rr;
var Character repairer;

// local port positions
var Vector frontPortUp;
var Vector frontPortDown;
var Vector backPortUp;
var Vector backPortDown;

var bool bGotPorts;

replication
{
	reliable if (Role == ROLE_Authority)
		repairer;
}


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	radiusSquared = radius * radius;
}

simulated function Destroyed()
{
	super.Destroyed();

	finishActiveEffect();
}

simulated function applyPassiveEffect(Character characterOwner)
{
	characterOwner.regenerationActive = true;
	characterOwner.regenerationRateHealthPerSecond = passiveHealthPerPeriod;
}

simulated function removePassiveEffect(Character characterOwner)
{
	characterOwner.regenerationActive = false;
	characterOwner.regenerationRateHealthPerSecond = 0;
}

simulated function startActiveEffect(Character characterOwner)
{
	repairer = characterOwner;

	bGotPorts = false;

	if (repairer != None)
	{
		rr = new class'RepairRadius'(self, , repairer.Location);

		repairer.regenerationRateHealthPerSecond +=activeExtraSelfHealthPerPeriod;
	}
}

simulated function finishActiveEffect()
{
	if (rr != None)
		rr.Destroy();

	rr = None;

	if (repairer != None)
		repairer.regenerationRateHealthPerSecond -=activeExtraSelfHealthPerPeriod;
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

	return r != repairer && r.canBeRepairedBy(repairer) && r.health < r.healthMaximum;
}

simulated function float getRepairRadius()
{
	return radius;
}

simulated function beginRepair(Rook r)
{
	if (!r.IsHumanControlled())
		level.speechManager.PlayDynamicSpeech( r, 'UseHealth' );

	if (Role == ROLE_Authority)
		r.addRepairFromPack(activeHealthPerPeriod / activePeriod, accumulationScale, repairer);
}

simulated function endRepair(Rook r)
{
	if (Role == ROLE_Authority)
		r.removeRepairFromPack(accumulationScale, repairer);
}

simulated function Pawn getFXOriginActor()
{
	return repairer;
}

simulated function onTendrilCreate(RepairTendril t) {}

simulated function Vector getFXTendrilOrigin(Vector targetPos)
{
	local Vector forwardVec;
	local Vector leftVec;
	local Vector originatorToTarget;
	local Vector leftLocation;
	local Vector rightLocation;
	local Vector frontUp;
	local Vector backUp;
	local Vector frontDown;
	local Vector backDown;
	local Rotator leftRotation;
	local Rotator rightRotation;
	local bool bForward;
	local bool bLeft;
	local bool bAbove;
	local bool bBehindView;

	if (!bGotPorts || repairer == None)
		return targetPos;

	bBehindView = PlayerController(repairer.Controller) != None && PlayerController(repairer.Controller).bBehindView;

	if (bBehindView)
	{
		if (repairer.leftPack != None)
		{
			leftLocation = repairer.leftPack.Location;
			leftRotation = repairer.leftPack.Rotation;
		}
		else
		{
			leftLocation = repairer.Location;
		}

		if (repairer.rightPack != None)
		{
			rightLocation = repairer.rightPack.Location;
			rightRotation = repairer.rightPack.Rotation;
		}
		else
		{
			rightLocation = repairer.Location;
		}

		frontUp = frontPortUp;
		backUp = backPortUp;
		frontDown = frontPortDown;
		backDown = backPortDown;
	}
	else
	{
		leftLocation.Y = -repairer.CollisionRadius;
		leftLocation = (leftLocation >> repairer.Rotation) + repairer.Location;
		rightLocation.Y = repairer.CollisionRadius;
		rightLocation = (rightLocation >> repairer.Rotation) + repairer.Location;
	}

	bAbove = targetPos.z >= repairer.Location.z;

	originatorToTarget = targetPos - repairer.Location;
	originatorToTarget.z = 0;
	originatorToTarget = Normal(originatorToTarget);

	forwardVec = Vector(repairer.Rotation);
	forwardVec.z = 0;
	forwardVec = Normal(forwardVec);

	leftVec.x = forwardVec.y;
	leftVec.y = -forwardVec.x;

	bForward = originatorToTarget dot forwardVec > 0;
	bLeft = originatorToTarget dot leftVec > 0;

	if (bLeft)
	{
		if (bForward)
		{
			if (bAbove)
				return leftLocation + (frontUp >> leftRotation);
			else
				return leftLocation + (frontDown >> leftRotation);
		}
		else
		{
			if (bAbove)
				return leftLocation + (backUp >> leftRotation);
			else
				return leftLocation + (backDown >> leftRotation);
		}
	}
	else
	{
		// because of rotations, forward and back are deliberately switched
		if (bForward)
		{
			if (bAbove)
				return rightLocation + (backUp >> rightRotation);
			else
				return rightLocation + (backDown >> rightRotation);
		}
		else
		{
			if (bAbove)
				return rightLocation + (frontUp >> rightRotation);
			else
				return rightLocation + (frontDown >> rightRotation);
		}
	}

	return repairer.Location;
}


simulated function Vector getFXTendrilTarget(Actor target)
{
	return target.unifiedGetPosition();
}

simulated function bool canStartFXTendril()
{
	return bGotPorts;
}
// End IRepairClient

simulated state Active
{
	simulated function tick(float deltaSeconds)
	{
		local Rotator rot;
		local Vector s;

		if (repairer != None)
		{
			// for clients
			if (rr == None)
			{
				rr = new class'RepairRadius'(self, , repairer.Location);

				repairer.regenerationRateHealthPerSecond +=activeExtraSelfHealthPerPeriod;
			}

			// to take account of delayed replication of leftPack variable
			if (!bGotPorts && rr != None && repairer.leftPack != None && repairer.leftPack.StaticMesh != None)
			{
				// get energy exit ports
				repairer.leftPack.getSocket(socketFrontUp, frontPortUp, rot, s, SOCKET_Local);
				repairer.leftPack.getSocket(socketFrontDown, frontPortDown, rot, s, SOCKET_Local);
				repairer.leftPack.getSocket(socketBackUp, backPortUp, rot, s, SOCKET_Local);
				repairer.leftPack.getSocket(socketBackDown, backPortDown, rot, s, SOCKET_Local);
				bGotPorts = true;
			}

			rr.Move(repairer.Location - rr.Location);
		}

		super.tick(deltaSeconds);
	}
}

defaultproperties
{
     activePeriod=0.500000
     passivePeriod=0.500000
     Radius=2000.000000
     activeHealthPerPeriod=6.000000
     activeExtraSelfHealthPerPeriod=2.000000
     passiveHealthPerPeriod=2.000000
     accumulationScale=1.000000
     socketFrontUp="CHILD02"
     socketFrontDown="CHILD03"
     socketBackUp="CHILD00"
     socketBackDown="CHILD01"
     rechargeTimeSeconds=7.000000
     rampUpTimeSeconds=0.200000
     durationSeconds=4.000000
     thirdPersonMesh=StaticMesh'packs.RepairPack'
     StaticMesh=StaticMesh'packs.RepairPackdropped'
}
