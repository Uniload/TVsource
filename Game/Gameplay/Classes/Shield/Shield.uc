class Shield extends Engine.Actor
	native;

var float				health;
var float				offlineSeconds;
var()	float				max					"The number of hitpoints that the shield has";
var()	float				rechargeRate			"Number of health points that the shield regenerates per second";
var()	float				offlineSecondsScale	"Number of seconds that the shield stays disabled for when energy is depleted: offline seconds = damage * offlineSecondsScale";
var()	float				maxOfflineSeconds		"The maximum number of seconds that the shield can stay disabled for in response to damage";

// shield effect
var()	Material			effectMaterial		"Overlay material when shield takes a hit";
var()	float				effectDisplayTime	"How long the shield effect is displayed for after a hit";

var bool	bActive;
var float	clientHealth;
var float	shieldEffectTime;

replication
{
	reliable if (ROLE == ROLE_Authority)
		health;
}

function PostBeginPlay()
{
	health = max;
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	clientHealth = health;
	shieldEffectTime = 0;
}

simulated function PostNetReceive()
{
	if (Level.NetMode == NM_Client && clientHealth != health)
	{
		if (health < clientHealth)
			triggerDamageEffect();

		clientHealth = health;
	}
}

simulated function triggerDamageEffect()
{
	// TBD: it would be cool to have a different damage effect when the shield goes offline
	shieldEffectTime = effectDisplayTime;
}

simulated function updateDamageEffect(float Delta)
{
	shieldEffectTime -= Delta;
	if (shieldEffectTime < 0)
		shieldEffectTime = 0;
}

simulated function Tick(float Delta)
{
	recharge(Delta);
	updateDamageEffect(Delta);
}

simulated function bool EffectActive()
{
	return (shieldEffectTime > 0);
}

simulated native function Material GetEffectMaterial();

function recharge(float Delta)
{
	if (!bActive)
		return;

	// recharge shield
	if (offlineSeconds > 0)
	{
		offlineSeconds -= Delta;
	}
	else if (health < max)
	{
		health += rechargeRate * Delta;
		if (health > max)
			health = max;
	}
}

// Applies damage.  Any damage not done to shields is returned as overflow.
function int applyDamage(float Damage, float otherHealth)
{
	local int overflow;

	if (!active())
		return Damage;

	health -= Damage;
	if (health < 0)
	{
		overflow = -health;
		if (health <= 0 && health > -1)
			health = -1;

		offlineSeconds = -otherHealth * offlineSecondsScale;
		FClamp(offlineSeconds, 0, maxOfflineSeconds);
	}

	// servers and sp trigger damage fx here. clients trigger it on PostNetReceive
	if (Damage > 0 && Level.NetMode != NM_Client)
		triggerDamageEffect();

	return overflow;
}

function activate()
{
	bActive = true;
}

function deactivate()
{
	health = 0;
	bActive = false;
}

function bool active()
{
	return health > 0 && bActive;
}

defaultproperties
{
	DrawType				= DT_None
	RemoteRole				= ROLE_SimulatedProxy

	bActive					= true
	bNetNotify				= true
	rechargeRate			= 3
	max						= 50

	effectDisplayTime		= 0.3
	effectMaterial			= Material'BaseObjects.ResupplyStationLum'
}