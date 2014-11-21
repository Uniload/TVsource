class promodPlasmaArea extends EquipmentClasses.ProjectileBurnerBurningArea config(promod);

var float damageAmt;

simulated function PostBeginPlay()
{
	TriggerEffectEvent('Alive');
}

simulated function Destroyed()
{
	UntriggerEffectEvent('Alive');
}

simulated function Tick(float Delta)
{
}

simulated function UnTouch(Actor Other)
{
}

function Timer()
{
	//UntriggerEffectEvent('Alive');
	Destroy();
}

defaultproperties
{
     burnTime=0.200000
     LifeSpan=0.200000
     bCollideActors=False
}
