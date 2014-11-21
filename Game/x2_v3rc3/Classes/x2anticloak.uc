class x2anticloak extends Gameplay.Cloakpack;

simulated function startApplyPartialActiveEffect()
{
	setTimer(0, true);
}

simulated function applyPartialActiveEffect(float alpha, Character characterOwner)
{
        characterOwner.bHidden = false;
}


defaultproperties
{
}
