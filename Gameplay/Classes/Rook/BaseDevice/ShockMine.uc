class ShockMine extends BaseDevice;

var() float				armingDelay			"Number of seconds until the mine is armed after being dropped";

var Controller deployerController;	// controller of the player who placed the mine
var	bool bIsArmed;
var bool bExploded;
var Actor explosion;

var ShockMineProximity	proximity;

var() float				proximityHeight;
var() float				proximityRadius;
	
replication
{
	reliable if(Role==ROLE_Authority)
		bIsArmed, bExploded;
}

// PostNetBeginPlay
function PostBeginPlay()
{
	super.PostBeginPlay();

	SetTimer(armingDelay, false);

	if (deployer != None)
		deployerController = deployer.Controller;
}

simulated function Destroyed()
{
	if (proximity != None)
		proximity.Destroy();

	super.Destroyed();
}

function Timer()
{
	proximity = spawn(class'ShockMineProximity', self,, Location);
	proximity.SetCollisionSize(proximityRadius, proximityHeight);
	proximity.SetCollision(true, false, false);

	bIsArmed = true;
}

// Touch
simulated function WithinProximity(Actor Other)
{
	if(bIsArmed)
	{
		if (Rook(Other) != None)
		{
			// don't explode our own teammates
			if (isFriendly(Rook(Other)))
				return;

			// Only kill characters or vehicles
			if (Character(Other) == None && Vehicle(Other) == None)
				return;
		}
		else if (Other.Physics != PHYS_Havok)
		{
			return;
		}
	
		if (bCanBeDamaged)
			Health = 0;
	}
}

// used by death message systems
function Controller GetKillerController()
{
	return deployerController;
}

auto simulated state Active
{
	simulated function CheckChangeState()
	{
		if (Health <= 0 || bExploded)
			GotoState('Explode');
	}
}

simulated state Explode
{
Begin:
	TriggerEffectEvent('Explode');

	bHidden = true;

	if(destroyedExplosionClass != None && Role == ROLE_Authority)
	{
		explosion = spawn(destroyedExplosionClass, , , Location, Rotation);
		explosion.Trigger(self, self);
	}

	SetCollision(false, false, false);
	bExploded = true;
	// prevent repair beams
	health = healthMaximum;

	if (Role == ROLE_Authority)
	{
		Sleep(1);
		Destroy();
	}
}

defaultproperties
{
	proximityHeight = 35
	proximityRadius = 300

	armingDelay = 3
	bNoDelete = false
	bIgnoreEncroachers = true

	bWorldGeometry = false
}