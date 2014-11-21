class BaseInfo extends Engine.Info
	native
	placeable;

enum enumBaseType
{
	BaseType_Primary,
	BaseType_Secondary,
	BaseType_Mobile
};

var()	editdisplay(displayActorLabel)
		editcombotype(enumTeamInfo)
		TeamInfo				team				"The team that the base belongs to";
var()	enumBaseType			baseType			"The base type for this base";
var()	localized string		description			 "A short description for this base which gets displayed when players respawn";
var()	editdisplay(displayActorLabel)
		editcombotype(enumSpawnArray)
		SpawnArray				spawnArray			"A spawn array that is associated with this base";
var		Vector					SpawnArrayLocation;

var()	editdisplay(displayActorLabel)
		editcombotype(enumContainer)
		MPCarryableContainer	container			"An optional carryable container that is associated with this base.  Carryables are withdrawn and given to the player when spawning at the base";

var		Array<BaseDevice>		devices;			// list of devices owned by the base
var		Array<PowerGenerator>	generators;			// list of power generators (subset of 'devices')
var		Array<PlayerStart>		playerStarts;		// list of player starts
var		Array<PowerIndicator>	powerIndicators;	// list of power indicators

var		bool					bValidRespawnBase;

var		private TeamInfo		m_oldTeam;
var		private bool			m_bPowered;	// Whether the base is powered or not

replication
{
	reliable if(Role == ROLE_Authority)
		Team, SpawnArrayLocation;
}

// Intialize is called by GameInfo after object filtering occurs
function Initialize()
{
	local BaseDevice d;
	local PlayerStart start;
	local PowerIndicator pi;

	// build list of devices and power generators
    ForEach DynamicActors(class'BaseDevice', d)
	{
		if (d.ownerBase == self)
		{
			devices[devices.Length] = d;

			if (PowerGenerator(d) != None)
			{
				generators[generators.Length] = PowerGenerator(d);
			}
		}
	}

	// build an array of player starts 
    ForEach DynamicActors(class'PlayerStart', start)
	{
		if(start.baseInfo == self)
			playerStarts[playerStarts.Length] = start;
	}

	// build an array of power indicators
    ForEach DynamicActors(class'PowerIndicator', pi)
	{
		if(pi.ownerBase == self)
			powerIndicators[powerIndicators.Length] = pi;
	}

	// check that this base has at least one player start 
	// associated with it so it can be a valid spawn base
	bValidRespawnBase = (playerStarts.Length > 0);

	onTeamChanged();
	m_oldTeam = team;
	
	SpawnArrayLocation = spawnArray.Location;

	checkForPower();
}

// Tick
function Tick(float Delta)
{
	// check for changed team
	if (team != m_oldTeam)
	{
		onTeamChanged();
		m_oldTeam = team;
	}

	// check for power outage or restoration
	checkForPower();
}

// onTeamChanged
// Switches the base and all its equipment to the new team
// Achieved publicly by setting the 'team' variable
private function onTeamChanged()
{
	local int i;

	// add the base to the new teamInfo base array, & remove
	// it from the old one
	if (m_oldTeam != None)
		m_oldTeam.RemoveBase(self);
	team.AddBase(self);
	
	// set teams of base devices and power generators
	for (i = 0; i < devices.Length; i++)
	{
		devices[i].setTeam(team);
	}

	for(i = 0; i < playerStarts.Length; ++i)
		playerStarts[i].team = team;
}

// checkForPower
// Check the conditions for the base being powered or unpowered, and adjust the state of the
// base objects accordingly.
function checkForPower()
{
	local int i;
	local bool bHasActiveGenerators;

	for (i = 0; i < generators.Length; i++)
	{
		if (generators[i] != None && generators[i].IsInState('Active'))
		{
			bHasActiveGenerators = true;
			break;
		}
	}

	if (m_bPowered)
	{
		// if powered, check for power loss
		if (!bHasActiveGenerators)
			setPowered(false);
	}
	else
	{
		if (bHasActiveGenerators)
			setPowered(true);
	}
}

// setPowered
// Disable or enable base objects according to the powered state
function setPowered(bool bPowered)
{
	local int i;

	// set state of base devices
	for (i = 0; i < devices.Length; i++)
	{
		devices[i].setHasPower(bPowered);
	}

	for (i = 0; i < powerIndicators.Length; ++i)
	{
		powerIndicators[i].setPower(bPowered);
	}

	m_bPowered = bPowered;
}

// isPowered
function bool isPowered()
{
	return m_bPowered;
}

// enumTeamInfo
function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

// enumSpawnArray
function enumSpawnArray(Engine.LevelInfo l, out Array<SpawnArray> s)
{
	local SpawnArray sa;

	ForEach l.AllActors(class'SpawnArray', sa)
	{
		s[s.Length] = sa;
	}
}

// displayActorLabel
function string displayActorLabel(Actor t)
{
	return string(t.label);
}

function enumContainer(Engine.LevelInfo l, Array<MPCarryableContainer> a)
{
	local MPCarryableContainer c;

	ForEach DynamicActors(class'MPCarryableContainer', c)
	{
		if (team == c.team())
			a[a.length] = c;
	}
}

defaultproperties
{
	RemoteRole			= ROLE_SimulatedProxy
	bHiddenEd			= true
	bAlwaysRelevant		= true
	baseType			= BaseType_Primary
	bValidRespawnBase	= false
}