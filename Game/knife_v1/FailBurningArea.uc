class FailBurningArea extends EquipmentClasses.ProjectileBurnerBurningArea;

function Timer()
{
	UntriggerEffectEvent('Alive');
	Destroy();
}

defaultproperties
{
     burnTime=1.500000
}
