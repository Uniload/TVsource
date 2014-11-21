class CloakPack extends Pack;

var float jammingPeriodSeconds;
var float jammingRadius;

var bool jammingSwitch;
var bool localJammingSwitch;

replication
{
	reliable if (Role == ROLE_Authority)
		jammingSwitch;
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	// check if jammed
	if (jammingSwitch != localJammingSwitch)
	{
		if (isInState('Activating'));
			finishActiveEffect();
		GotoState('Recharging');
		localJammingSwitch = jammingSwitch;
	}
}

simulated function startApplyPartialActiveEffect()
{
	setTimer(jammingPeriodSeconds, true);
}

simulated function applyPartialActiveEffect(float alpha, Character characterOwner)
{
	characterOwner.bHidden = true;
}

simulated function finishActiveEffect()
{
	heldBy.bHidden = false;

	setTimer(0, false);
}

simulated state Activating
{
	simulated function tick(float deltaSeconds)
	{
		super.tick(deltaSeconds);

		// if weapon is firing stop cloaking functionality
		if ((heldBy.weapon != None) && (heldBy.weapon.isInState('Firing')))
		{
			finishActiveEffect();
			GotoState('Recharging');
		}
	}

	// only occurs on server
	function timer()
	{
		local Character workCharacter;

		// check if being jammed
		foreach RadiusActors(class'Character', workCharacter, jammingRadius, heldBy.location)
		{
			if (heldBy.isFriendly(workCharacter))
				continue;

			if ((workCharacter.pack != None) && (CloakPack(workCharacter.pack) != None))
			{
				jammingSwitch = !jammingSwitch;
				finishActiveEffect();
				GotoState('Recharging');
			}
		}
	}
}

simulated state Active
{
	simulated function tick(float deltaSeconds)
	{
		super.tick(deltaSeconds);

		// if weapon is firing stop cloaking functionality
		if ((heldBy.weapon != None) && (heldBy.weapon.isInState('Firing')))
		{
			GotoState('Recharging');
		}
	}

	// only occurs on server
	function timer()
	{
		local Character workCharacter;

		// check if being jammed
		foreach RadiusActors(class'Character', workCharacter, jammingRadius, heldBy.location)
		{
			if (heldBy.isFriendly(workCharacter))
				continue;

			if ((workCharacter.pack != None) && (CloakPack(workCharacter.pack) != None))
			{
				jammingSwitch = !jammingSwitch;
				GotoState('Recharging');
			}
		}
	}
}

defaultProperties
{
	thirdPersonMesh = StaticMesh'Packs.CloakPack'
	StaticMesh = StaticMesh'Packs.CloakPackdropped'

	jammingPeriodSeconds = 0.2
	jammingRadius = 1600

	localJammingSwitch = false
	jammingSwitch = false
}