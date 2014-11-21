class Buckler extends Weapon;

var BucklerProjectile proj;

var() float checkingDamage				"The amount of damage applied when you bodycheck someone while holding this";
var() float checkingDmgVelMultiplier	"The amount to scale damage by according to the relative velocities of the holder and target";
var() float checkingMultiplier			"The amount of momentum to impart";

var() float minCheckRate				"The minimum amount of time that must pass between successive bodychecks";
var() float minCheckVelocity			"Holder or target must be going at least this fast in order to bodycheck";
var float lastCheckTime;

var() float deflectionAngle				"Angle of a cone in front of you which determines how effectively projectiles will be deflected";
var float cosDeflectionAngle;

var Vector failedReturnLocation;
var Vector failedReturnVelocity;

var() float projSpawnDelay;
var() float lostReturnDelay				"The number of seconds to wait before returning after it has become lost";

var Vector fireLoc;

var int localAmmoCount;

var bool bLost;
var bool bLocalLost;

var bool bDeflected;
var bool bLocalDeflected;

replication
{
	reliable if (Role == ROLE_Authority)
		bDeflected;

	reliable if (Role == ROLE_Authority && bNetOwner)
		bLost;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	cosDeflectionAngle = Cos((deflectionAngle / 180.0) * Pi);
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	if (bLost && !bLocalLost)
		lost();

	bLocalLost = bLost;

	if (ammoCount == 1 && localAmmoCount == 0)
		returned();

	localAmmoCount = ammoCount;

	if (bDeflected != bLocalDeflected)
	{
		TriggerEffectEvent('BucklerDeflect');
		bLocalDeflected = bDeflected;
	}
}

simulated function extractFirstPersonMeshData()
{
	super.extractFirstPersonMeshData();
	//projSpawnDelay = GetAnimLength(Name(animPrefix $ "_" $ fireAnimation));
}

simulated function Destroyed()
{
	if (proj != None)
		proj.Destroy();

	super.Destroyed();
}

simulated function bool shouldHide(bool bIsFirstPerson)
{
	if (!hasAmmo())
		return true;
	else
		return super.shouldHide(bIsFirstPerson);
}

simulated function bool keepArms()
{
	return !hasAmmo();
}

simulated function lost()
{
	SetTimer(lostReturnDelay, false);
	bLost = true;
}

function Timer()
{
	returned();
}

simulated function returned()
{
	local Character c;

	c = Character(rookOwner);

	ammoCount = 1;
	bLost = false;

	if (c != None && c.weapon == self)
		playIdleAnim();
}

function setDropLocation()
{
	if (proj == None)
		super.setDropLocation();
	else
		SetLocation(proj.Location);
}

function setDropVelocity()
{
	if (proj == None)
		super.setDropVelocity();
	else
		Velocity = Normal(proj.Velocity) * dropVelocity;
}

function pickup(Character newOwner)
{
	if (Weapon(newOwner.nextEquipment(None, class)) == None)
		super.pickup(newOwner);
}

function initialiseVelocity(Projectile p, Vector InitialVelocity)
{
	if (VSize(InitialVelocity) < projectileVelocity)
		super.initialiseVelocity(p, Normal(InitialVelocity) * projectileVelocity);
	else
		super.initialiseVelocity(p, InitialVelocity);
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	proj = BucklerProjectile(super.makeProjectile(fireRot, fireLoc));

	if (proj.bDeleteMe)
	{
		returned();
		return None;
	}

	proj.buckler = self;

	proj.velocitySize = VSize(proj.Velocity);
	proj.xAxisLength = proj.velocitySize;

	return proj;
}

simulated function moveWeapon()
{
	if (hasAmmo())
		super.moveWeapon();
	else
		animClass.static.setLocRot(self, rookMotor.getFirstPersonEquippableLocation(self), rookMotor.getFirstPersonEquippableRotation(self));
}

simulated protected function FireWeapon()
{
	lastFireTime = Level.TimeSeconds;

	TriggerEffectEvent('Fired');

	bLost = false;
	bFiredWeapon = true;
}

simulated protected function playPostFireAnim()
{
	bFiredWeapon = false;
	playIdleAnim();
}

simulated function playIdleAnim()
{
	if (!hasAmmo())
		animClass.static.playEquippableAnim(self, 'Wait_Idle');
	else
		super.playIdleAnim();
}


simulated function playEquipAnim()
{
	if (!hasAmmo())
		animClass.static.playEquippableAnim(self, 'Wait_Select');
	else
		Super.playEquipAnim();
}

simulated function playUnequipAnim()
{
	if (!hasAmmo())
		animClass.static.playEquippableAnim(self, 'Wait_Deselect');
	else
		Super.playEquipAnim();
}

simulated state Held
{
	simulated function BeginState()
	{
		super.BeginState();
	}
}

simulated state FirePressed
{
	simulated function TickFirePressed()
	{
		if (hasAmmo() && fireRatePassed())
			GotoState('Launching');
	}
}

simulated state Launching
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);
	}

begin:
	FireWeapon();

	Sleep(projSpawnDelay);

	fireLoc = rookMotor.getProjectileSpawnLocation();
	makeProjectile(getAimRotation(fireLoc), fireLoc);

	playIdleAnim();

	GotoState('Idle');
}

simulated state Dropped
{
	function setupDropped()
	{
		super.setupDropped();

		ammoCount = 1;

		if (proj != None)
		{
			proj.Destroy();
			proj = None;
		}
	}
}

defaultproperties
{
	bNetNotify = true

	firstPersonMesh = Mesh'Weapons.buckler'
	firstPersonOffset = (X=-15,Y=22,Z=-15)
	roundsPerSecond = 1.0

	bNeedIdleFX = true

	projSpawnDelay = 0.1

	lostReturnDelay = 3.0

	projectileClass = class'BucklerProjectile'
	projectileVelocity = 1000
	projectileInheritedVelFactor = 1.0

	checkingDamage = 15
	checkingDmgVelMultiplier = 0.01
	checkingMultiplier = 300
	minCheckRate = 0.2
	minCheckVelocity = 800

	deflectionAngle = 30.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Buckler"
	equippedArmAnim = "weapon_buckler_hold"

	bGenerateMissSpeechEvents = false
}