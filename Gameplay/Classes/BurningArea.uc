class BurningArea extends Engine.Actor;

var() float burnTime "The number of seconds this burning area will burn for";
var() float burnDamageRate "The amount of damage per second caused when burned by this burning area";
var() float burnDamageRateReduction "The amount by which the burnDamageRate will decrease per second";

var() class<ProjectileDamageType>	damageType	"Damage type for the burn area object";

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(burnTime, false);
}

function Timer()
{
	Destroy();
}

simulated function Destroyed()
{
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{
		if (Rook(Touching[i]) != None)
			Rook(Touching[i]).flameDamageReductionPerSecond = burnDamageRateReduction;
	}

	super.Destroyed();
}

simulated function Tick(float Delta)
{
	local Rook r;
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{
		if (!Touching[i].bProjTarget)
			continue;

		r = Rook(Touching[i]);

		if (r != None && r.flameDamagePerSecond < burnDamageRate && FastTrace(r.Location))
		{
			if (r.flameDamagePerSecond == 0.0)
				r.TriggerEffectEvent('Burning');

			r.flameSource = Instigator;
			r.flameDamageType = damageType;
			r.flameDamagePerSecond = burnDamageRate;
			r.flameDamageReductionPerSecond = 0.0;
		}
	}
}

simulated function UnTouch(Actor Other)
{
	if (Rook(Other) != None)
	{
		Rook(Other).flameDamageReductionPerSecond = burnDamageRateReduction;
	}
}

defaultproperties
{
     burnTime=5.000000
     burnDamageRate=10.000000
     burnDamageRateReduction=2.000000
     DamageType=Class'ProjectileDamageType'
     DrawType=DT_None
     RemoteRole=ROLE_SimulatedProxy
     CollisionRadius=300.000000
     CollisionHeight=300.000000
     bCollideActors=True
     bNeedLifetimeEffectEvents=True
}
