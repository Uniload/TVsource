class MPConsumable extends MPActor;

var() Name			idleAnim					"An animation to play.";
var() float			respawnTime					"The amount of time it takes this consumable to respawn after being consumed.  -1 means it won't respawn.";
var() float			energyChange				"Change the player's energy by this amount when consumed.";
var() float			healthChange				"Change the player's health by this amount when consumed.";
var() float			speedScaleChange			"Scale the player's speed by this amount when consumed.";

// Stats
var(Stats) class<Stat>	consumeStat				"The stat awarded for consuming this consumable.";


// PostBeginPlay
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (DrawType == DT_Mesh && hasAnim(idleAnim))
		LoopAnim(idleAnim);

}

function registerStats(StatTracker tracker)
{
	Super.registerStats(tracker);

	tracker.registerStat(consumeStat);
}

function onConsumed(Character c)
{
}

singular function Touch(Actor Other)
{
	local Character c;

	c = Character(Other);

	if (c == None || bHidden)
		return;

	consume(c);
}

function consume(Character c)
{
	awardStat(consumeStat, c);
	if (energyChange != 0)
		c.changeEnergy(energyChange);
	if (healthChange != 0)
		c.changeHealth(healthChange);
	if (speedScaleChange != 1.0)
		c.unifiedSetVelocity(c.unifiedGetVelocity() * speedScaleChange);

	onConsumed(c);
	GotoState('Consumed');
}

// Available state
auto simulated state Available
{
	function CheckTouching()
	{
		local Character c;

		ForEach TouchingActors(class'Character',c)
		{
			consume(c);
			return;
		}
	}

Begin:
	// After setting to its home location, see if anyone is touching it
	CheckTouching();
}

// Locked state
// When a consumable is consumed, it is invisible for a certain period of time
state Consumed
{
	function BeginState()
	{
		if (respawnTime >= 0)
			SetTimer(respawnTime, false);
		bHidden = true;
	}

	function Timer()
	{
		SetTimer(0, false);
		GotoState('Available');
	}

	function EndState()
	{
		bHidden = false;
	}
}

defaultproperties
{
	DrawType					= DT_StaticMesh
	StaticMesh					= StaticMesh'MPGameObjects.Ball'
	Physics						= PHYS_None
    bUseCylinderCollision		= false	
	bCollideActors				= true
	bCollideWorld				= true
	bStatic						= false
	bBlockActors				= false
	bBlockPlayers				= false

	bRotateToDesired			= false
	bHardAttach					= true
	bBlockKarma					= false

    bDynamicLight=true
    LightHue=40
    LightBrightness=200
    LightType=LT_Steady
    LightEffect=LE_QuadraticNonIncidence
    LightRadius=10

	respawnTime					= 20
	energyChange				= 0
	healthChange				= 0
	speedScaleChange			= 1.0
}
