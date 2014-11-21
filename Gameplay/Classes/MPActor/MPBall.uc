class MPBall extends MPCarryable;
simulated function onGoal(MPGoal goal)
{
	//TriggerEffectEvent('Goal');
	returnToHome();
}

defaultproperties
{
	CarryableMessageClass	= class'MPBallMessages'
	StaticMesh				= StaticMesh'MPGameObjects.Ball'
	idleAnim				= None;
	returnTime				= 15
	elasticity				= 0.4
	droppedPhysics			= PHYS_Havok
	bBlockHavok				= true
	bEnableHavokBackstep	= true
	bBlockActorsWhenDropped = false
}