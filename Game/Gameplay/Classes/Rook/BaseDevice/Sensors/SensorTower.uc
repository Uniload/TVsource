class SensorTower extends BaseDevice;

simulated latent function latentBeginActive()
{
	// Do nothing. SensorTower handles its own animations
}

function setTeam(TeamInfo info)
{
	if (m_team != None)
		m_team.removeTeamSensorSensorTower(self);

	super.setTeam(info);

	if (m_team != None)
		m_team.addTeamSensor(self);
}

simulated state Active
{
	simulated function BeginState()
	{
		super.BeginState();

		if (!IsAnimating() && HasAnim('Stand'))
			LoopBDAnim('Stand');
	}

	simulated function EndState()
	{
		super.EndState();

		if (!isFunctional())
			StopAnimating();
	}
}

simulated state Damaged
{
	function BeginState()
	{
		super.BeginState();

		if (!IsAnimating() && HasAnim('Stand'))
			LoopBDAnim('Stand');
	}

	function EndState()
	{
		super.EndState();

		if (!isFunctional())
			StopAnimating();
	}
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh = SkeletalMesh'BaseObjects.SensorTower'

	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bBlockKarma=true
	bAlwaysRelevant=true

	baseDeviceMessageClass			= class'MPBaseDeviceMessages'
}