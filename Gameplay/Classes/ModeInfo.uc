class ModeInfo extends MultiplayerGameInfo;

var() Array< class<MPActor> >	allowedMPActorList			"List of allowed MPActors for this mode.  All other MPActors will be filtered.";
var() Array< class<BaseDevice> > baseDeviceObjectives		"List of base devices that will appear as secondary objectives.";
var() Array< class<BaseDevice> > baseDeviceExclusionList	"List of base devices that will get filtered when this mode loads.";

var StatTracker Tracker;

var float	speedCheckTime;
var float	speedCheckInterval;
var float	teamBalanceCheckTime;
var config float	teamBalanceCheckInterval;

enum EProjectileDamageStat
{
	PDS_HeadShot,
	PDS_Backstab,
	PDS_PlayerDamage,
	PDS_ObjectDamage,
};

struct projectileDamageStat
{
	var() class<DamageType> damageTypeClass;
	var() class<Stat>		playerDamageStatClass;
	var() class<Stat>		objectDamageStatClass;
	var() class<Stat>		headShotStatClass;
	var() class<Stat>		backstabStatClass;
};

struct extendedProjectileDamageStat
{
	var() class<DamageType>		damageTypeClass;
	var() class<ExtendedStat>	extendedStatClass;
};

struct baseDeviceAreaStat
{
	var() class<Stat>		statClass;
	var() class<BaseDevice>	baseDeviceClass;
	var() int				radius;
};

struct baseDeviceStat
{
	var() class<Stat>		statClass;
	var() class<BaseDevice> baseDeviceClass;
};

// Some default stats
var(Stats) class<Stat> suicideStat;
var(Stats) class<Stat> killStat;
var(Stats) class<Stat> deathStat;
var(Stats) class<Stat> teamKillStat;
var(Stats) class<Stat> rawDamageStat;
var(Stats) class<Stat> highestSpeedStat;
var(Stats) class<Stat> vehicleKillStat;
var(Stats) class<Stat> vehicleTeamKillStat;
var(Stats) array<projectileDamageStat> projectileDamageStats;
var(Stats) array<extendedProjectileDamageStat> extendedProjectileDamageStats;
var(Stats) array<baseDeviceAreaStat> baseDeviceAreaStats;
var(Stats) array<baseDeviceStat> baseDeviceDestroyStats;
var(Stats) array<baseDeviceStat> baseDeviceRepairStats;

var array<MPActor> playerKillListeners;

var localized string protectYourString		"String used for base device objectives";
var localized string destroyTheirString		"String used for base device objectives";

// PostBeginPlay
function PostBeginPlay()
{
	local MPActor a;
	local BoundaryVolume bv;
	local int i;
	local TeamInfo t;
	local BaseDevice bd;


	Tracker = new class'StatTracker';
	Tracker.initialize();

	// Register some default game stats
	Tracker.registerStat(killStat);
	Tracker.registerStat(suicideStat);
	Tracker.registerStat(teamKillStat);
	Tracker.registerStat(deathStat);
	Tracker.registerStat(highestSpeedStat);
	Tracker.registerStat(vehicleKillStat);
	Tracker.registerStat(vehicleTeamKillStat);

	registerDamageTypeStats();
	registerBaseDeviceStats();

	// Parent filters non-game objects first
	Super.PostBeginPlay();

	// Filter MPActors based on ModeInfo
	// Also register stats for those that aren't filtered
	ForEach DynamicActors(class'MPActor', a)
	{
		if (!allowMPActorAtLoad(a))
		{
			//Log("Filtering a "$a);

			// First manually destroy any dynamically spawned instances
			a.cleanup();

			// Now filter the actor itself
			a.Destroy();
		}
		else
		{
			// This isn't optimal since every instance will call registerStats() when really
			// only the first instances needs to call it.  Couldn't get this working using
			// static functions due to designer classes not registering as default properties.
			a.registerStats(Tracker);

			// Every instance is given the chance to add objectives.  Do it here so that
			// filtered mpactors don't add objectives.
			a.addDefaultObjectives();
		}
	}

	// Filter boundary volumes by enabling/disabling
	ForEach DynamicActors(class'BoundaryVolume', bv)
	{
		if (allowObjectAtLoad(bv))
		{
			//Log("Enabling "$bv);
			bv.EnableBoundary(true);
		}
		else
		{
			//Log("Disabling "$bv);
			bv.EnableBoundary(false);
		}
	}

	// Filter base devices
	ForEach AllActors(class'BaseDevice', bd)
	{
		if (!allowBaseDeviceAtLoad(bd))
		{
			//Log("Filtering "$bd);
			bd.destroy();
		}
	}

	// Create objectives
	ForEach DynamicActors(class'Teaminfo', t)
	{
		for(i=0; i<baseDeviceObjectives.Length; i++)
		{
			createFriendlyBaseDeviceObjectives(baseDeviceObjectives[i], t);
			createEnemyBaseDeviceObjectives(baseDeviceObjectives[i], t);
		}
	}

	// Old attempt to register mp stats using static function
	// Register stats for each MPActor class
//	for (i=0; i<allowedMPActorList.Length; i++)
//	{
//		allowedMPActorList[i].static.registerStats(Tracker);
//	}
}

// allowMPActorAtLoad
// Returns true if the current game mode supports the given MPActor
function bool allowMPActorAtLoad(MPActor a)
{
	local int i;

	for (i=0; i<allowedMPActorList.Length; i++)
	{
		if (a.IsA(allowedMPActorList[i].Name))
			return true;
	}

	return false;
}

function bool allowBaseDeviceAtLoad(BaseDevice bd)
{
	local int i;

	for (i=0; i<baseDeviceExclusionList.Length; i++)
	{
		if (bd.IsA(baseDeviceExclusionList[i].Name))
			return false;
	}

	return true;
}

function ScoreKill(Controller Killer, Controller Other)
{
	local TribesReplicationInfo killerTRI, otherTRI;
	
	if (killer != None)
		killerTRI = TribesReplicationInfo(Killer.PlayerReplicationInfo);

	if (other != None)
		otherTRI = TribesReplicationInfo(Other.PlayerReplicationInfo);

	//Log("ScoreKill called with killer "$killer$" and other "$Other);
	if( (killer == Other) || (killer == None) )
	{
    	if ( Other!=None )
        {
			Tracker.awardStat(Other, suicideStat);
        }
	}
	else if ( killerTRI.team != otherTRI.team )
	{
		Killer.PlayerReplicationInfo.Kills++;
		Tracker.awardStat(Killer, killStat, Other);
		Tracker.awardStat(Other, deathStat);

		awardBaseDeviceAreaStats(Killer, Other);
		notifyPlayerKillListeners(Killer, Other);
	}
	else
	{
		// Teamkill
		Tracker.awardStat(Killer, teamkillStat, Other);
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer != None) || (MaxLives > 0) )
	CheckScore(Killer.PlayerReplicationInfo);
}

// PostLogin
function PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

	// Update TRI with stats used in this map
	TribesReplicationInfo(NewPlayer.PlayerReplicationInfo).updateStatData();
}

function createWeaponKillStats()
{
	// Create a stat for each weapon kill
	// Reference some sort of equipment registry?
}

function createWeaponDeathStats()
{
	// Create a stat for each weapon death
}

function createFriendlyBaseDeviceObjectives(class<BaseDevice> bdc, TeamInfo t)
{
	local int i;
	local ObjectiveActors oaFriendly;
	local array<BaseDevice> baseDeviceList;
	local BaseDevice bd;

	// Find all base devices of the specified class
	ForEach DynamicActors(class'BaseDevice', bd)
	{
		if (ClassIsChildOf(bd.Class, bdc) && bd.radarInfoClass != None)
		{
			baseDeviceList[baseDeviceList.Length] = bd;
		}
	}

	if (baseDeviceList.Length == 0)
		return;

	// Assume max ONE of these base devices per team for now.  That way we can reference the objective's name by
	// using the base device instance's name
	oaFriendly = new class'objectiveActors';
	for (i=0; i<baseDeviceList.Length; i++)
	{
		if (baseDeviceList[i].team() == t)
		{
			Log("Adding friendly objective named "$baseDeviceList[i].Name$" to team "$t);
			oaFriendly.objectiveActors[oaFriendly.objectiveActors.Length] = baseDeviceList[i];
			break;
		}
	}

	t.objectives.addUsingString(baseDeviceList[i].Name, replaceStr(protectYourString, bdc.default.localizedName), ObjectiveStatus_Active, ObjectiveType_Secondary, oaFriendly);
}

function createEnemyBaseDeviceObjectives(class<BaseDevice> bdc, TeamInfo t)
{
	local int i;
	local ObjectiveActors oaEnemy;
	local array<BaseDevice> baseDeviceList;
	local BaseDevice bd;

	// Find all base devices of the specified class
	ForEach DynamicActors(class'BaseDevice', bd)
	{
		if (ClassIsChildOf(bd.Class, bdc) && bd.radarInfoClass != None)
		{
			baseDeviceList[baseDeviceList.Length] = bd;
		}
	}

	if (baseDeviceList.Length == 0)
		return;

	// For each base device of the specified type, add objectives for the specified team
	oaEnemy = new class'objectiveActors';
	for (i=0; i<baseDeviceList.Length; i++)
	{
		if (baseDeviceList[i].team() != t)
		{
			Log("Adding enemy objective named "$baseDeviceList[i].Name$" to team "$t);
			oaEnemy.objectiveActors[oaEnemy.objectiveActors.Length] = baseDeviceList[i];
			break;
		}
	}

	t.objectives.addUsingString(baseDeviceList[i].Name, replaceStr(destroyTheirString, bdc.default.localizedName), ObjectiveStatus_Active, ObjectiveType_Secondary, oaEnemy);
}

function registerDamageTypeStats()
{
	local int i;

	for (i=0; i<projectileDamageStats.Length; i++)
	{
		if (projectileDamageStats[i].headShotStatClass != None)
			Tracker.registerStat(projectileDamageStats[i].headShotStatClass);

		if (projectileDamageStats[i].playerDamageStatClass != None)
			Tracker.registerStat(projectileDamageStats[i].playerDamageStatClass);

		if (projectileDamageStats[i].objectDamageStatClass != None)
			Tracker.registerStat(projectileDamageStats[i].objectDamageStatClass);

		if (projectileDamageStats[i].backstabStatClass != None)
			Tracker.registerStat(projectileDamageStats[i].backstabStatClass);
	}

	for (i=0; i<extendedProjectileDamageStats.Length; i++)
	{
		if (extendedProjectileDamageStats[i].extendedStatClass != None)
			Tracker.registerStat(extendedProjectileDamageStats[i].extendedStatClass);
	}
}

function bool getProjectileDamageStat(class<DamageType> damageType, out projectileDamageStat pds, EProjectileDamageStat statType)
{
	local int i;

	for (i=0; i<projectileDamageStats.Length; i++)
	{
		if (ClassIsChildOf(damageType, projectileDamageStats[i].damageTypeClass))
		{
			pds = projectileDamageStats[i];
			switch(statType)
			{
				case PDS_HeadShot: if (projectileDamageStats[i].headShotStatClass != None) return true; break;
				case PDS_Backstab: if (projectileDamageStats[i].backstabStatClass != None) return true; break;
				case PDS_PlayerDamage: if (projectileDamageStats[i].playerDamageStatClass != None) return true; break;
				case PDS_ObjectDamage: if (projectileDamageStats[i].objectDamageStatClass != None) return true; break;
			}
		}
	}

	return false;
}

function OnBaseDeviceOnline(BaseDevice bd, optional Character firstRepairer)
{
	local ObjectiveInfo o;
	local TeamInfo t;
	local int i;

	//Log("OnBDOnline called with bd "$bd$" and repairer "$firstRepairer);
	// Award repair stat here, if applicable
	if (firstRepairer != None)
	{
		for (i=0; i<baseDeviceRepairStats.Length; i++)
		{
			if (ClassIsChildOf(bd.Class, baseDeviceRepairStats[i].baseDeviceClass))
			{
				Tracker.awardStat(firstRepairer.Controller, baseDeviceRepairStats[i].statClass);
			}
		}
	}

	if (!isABaseDeviceObjective(bd))
		return;

	// Set its objective state to non-flashing
	ForEach DynamicActors(class'TeamInfo', t)
	{
		o = t.objectives.objectiveFromName(bd.Name);

		if (o != None)
		{
			o.state = 0;
		}
	}

	// If bd is a power generator, stop showing emergency station icons for this team
	if (ClassIsChildOf(bd.Class, class'PowerGenerator'))
		setEmergencyIconVisibility(bd.team(), false);
}

function OnBaseDeviceOffline(BaseDevice bd, Pawn lastAttacker)
{
	local ObjectiveInfo o;
	local TeamInfo t;
	local int i;

	// Award destruction stat here, if applicable
	for (i=0; i<baseDeviceDestroyStats.Length; i++)
	{
		if (ClassIsChildOf(bd.Class, baseDeviceDestroyStats[i].baseDeviceClass))
		{
			Tracker.awardStat(lastAttacker.Controller, baseDeviceDestroyStats[i].statClass);
		}
	}

	//Log("Base device offline:  "$bd);
	if (!isABaseDeviceObjective(bd))
		return;

	// Set its objective state to flashing, if applicable
	ForEach DynamicActors(class'TeamInfo', t)
	{
		o = t.objectives.objectiveFromName(bd.Name);

		// Assume it has a flashing state
		if (o != None)
		{
			//Log("Setting flashing state for "$o);
			o.state = 1;
		}
	}

	// If bd is a power generator, show emergency station icons for this team
	if (ClassIsChildOf(bd.Class, class'PowerGenerator'))
		setEmergencyIconVisibility(bd.team(), true);
}

function OnHeadShot(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount)
{
	local projectileDamageStat pds;

	// Don't track friendly or weak head shots
	if (Rook(instigatedBy).team() == Rook(target).team() || amount < 40)
		return;

	if (getProjectileDamageStat(damageType, pds, PDS_Headshot))
		Tracker.awardStat(instigatedBy.Controller, pds.headShotStatClass, target.Controller);
}

function OnBackstab(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount)
{
	local projectileDamageStat pds;

	// Don't track friendly or weak backstabs
	if (Rook(instigatedBy).team() == Rook(target).team() || amount < 30)
		return;

	if (getProjectileDamageStat(damageType, pds, PDS_Backstab))
		Tracker.awardStat(instigatedBy.Controller, pds.backstabStatClass, target.Controller);
}

function OnPlayerDamage(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount)
{
	local projectileDamageStat pds;
	local int i;
	local class<ExtendedStat> extendedStatClass;

	// Don't award any stats if the damageType is the default class
	if (damageType == class'DamageType')
		return;

	// Don't award any stats if for some reason there was no target
	if (target == None)
		return;

	if (rawDamageStat != None)
		Tracker.awardStat(instigatedBy.Controller, rawDamageStat, target.Controller, int (amount));

	if (getProjectileDamageStat(damageType, pds, PDS_PlayerDamage))
		Tracker.awardStat(instigatedBy.Controller, pds.playerDamageStatClass, target.Controller, int (amount));

	// Award any extended stats
	for (i=0; i<extendedProjectileDamageStats.Length; i++)
	{
		extendedStatClass = extendedProjectileDamageStats[i].extendedStatClass;
		if (ClassIsChildOf(extendedProjectileDamageStats[i].damageTypeClass, damageType) && 
			extendedStatClass.static.isEligible(instigatedBy.Controller, target.Controller, amount))
		{
			Tracker.awardStat(instigatedBy.Controller, extendedStatClass, target.Controller);
		}
	}
}

function OnBaseDeviceDamage(Pawn instigatedBy, Pawn target, class<DamageType> damageType, float amount)
{
	local projectileDamageStat pds;

	if (getProjectileDamageStat(damageType, pds, PDS_ObjectDamage))
		Tracker.awardStat(instigatedBy.Controller, pds.objectDamageStatClass, target.Controller, int (amount));
}

function OnVehicleDestroyed(Pawn instigatedBy, Pawn target, class<DamageType> damageType)
{
	if (Rook(instigatedBy).isFriendly(Rook(target)))
	{
		if (vehicleTeamKillStat != None)
			Tracker.awardStat(instigatedBy.Controller, vehicleTeamKillStat);
	}
	else
	{
		if (vehicleKillStat != None)
			Tracker.awardStat(instigatedBy.Controller, vehicleKillStat);
	}
}

function setEmergencyIconVisibility(TeamInfo t, bool on)
{
	local EmergencyStation es;

	ForEach AllActors(class'EmergencyStation', es)
	{
		if (es.team() == t)
		{
			es.bForceIconVisible = true;
		}
	}
}

function bool isABaseDeviceObjective(BaseDevice bd)
{
	local int i;

	for(i=0; i<baseDeviceObjectives.Length; i++)
	{
		if (ClassIsChildOf(bd.Class, baseDeviceObjectives[i]))
			return true;
	}

	return false;
}

function class<InventoryStationAccess> getInventoryStationAccessClass()
{
	// Allow roundData overriding here (not yet implemented)
	return inventoryStationAccessClass;
}

function registerPlayerKillListener(MPActor listener)
{
	local int i;

	// Don't allow duplicates
	for (i=0; i<playerKillListeners.Length; i++)
	{
		if (playerKillListeners[i] == listener)
			return;
	}

	playerKillListeners[playerKillListeners.Length] = listener;
}

function notifyPlayerKillListeners(Controller Killer, Controller Target)
{
	local int i;

	// Don't allow duplicates
	for (i=0; i<playerKillListeners.Length; i++)
	{
		playerKillListeners[i].onPlayerKilled(Killer, Target);
	}
}

function awardBaseDeviceAreaStats(Controller Killer, Controller Target)
{
	local int i;
	local BaseDevice bd;

	// Cycle through tracked base devices and see if they're close enough to award a stat.
	// Decided not to do this in the same way as MPActors because MPActors encapsulate all
	// their functionality, particulary game rules and scoring, whereas base devices are
	// more general in these respects.
	for (i=0; i<baseDeviceAreaStats.Length; i++)
	{
		ForEach Level.AllActors(class'BaseDevice', bd)
		{
			if (ClassIsChildOf(bd.Class, baseDeviceAreaStats[i].baseDeviceClass) && VDist(bd.location, Killer.Location) <= baseDeviceAreaStats[i].radius)
			{
				Tracker.awardStat(Killer, baseDeviceAreaStats[i].statClass);
			}
		}
	}
}

function registerBaseDeviceStats()
{
	local int i;

	// Area stats
	for (i=0; i<baseDeviceAreaStats.Length; i++)
	{
		Tracker.registerStat(baseDeviceAreaStats[i].statClass);
	}

	// Damage stats
	for (i=0; i<baseDeviceDestroyStats.Length; i++)
	{
		Tracker.registerStat(baseDeviceDestroyStats[i].statClass);
	}

	// Repair stats
	for (i=0; i<baseDeviceRepairStats.Length; i++)
	{
		Tracker.registerStat(baseDeviceRepairStats[i].statClass);
	}
}

function bool GameInfoShouldTick()
{
	return true;
}

function Tick(float Delta)
{
	Super.Tick(Delta);

	speedCheckTime += Delta;
	if (highestSpeedStat != None && speedCheckTime > speedCheckInterval)
	{
		speedCheckTime = 0;
		updateSpeedStats();
	}

	teamBalanceCheckTime += Delta;
	if (teamBalanceCheckInterval > 0 && teamBalanceCheckTime > teamBalanceCheckInterval)
	{
		teamBalanceCheckTime = 0;
		checkTeamBalance();
	}
}

function updateSpeedStats()
{
	local PlayerCharacterController PCC;
	local Character c;
	local TribesReplicationInfo TRI;

	ForEach DynamicActors(class'PlayerCharacterController', PCC)
	{
		c = Character(PCC.Pawn);
		if (c == None)
			continue;

		TRI = TribesReplicationInfo(c.PlayerReplicationInfo);

		if (c.movementHorizontalSpeed > TRI.getStatData(highestSpeedStat).amount)
			Tracker.setStat(PCC, highestSpeedStat, c.movementHorizontalSpeed);
	}
}

function checkTeamBalance()
{
	local TeamInfo t, smallestTeam, largestTeam;

	// If there is more than a 1 player difference between teams, and the team with fewer players
	// is losing, broadcast a message
	ForEach AllActors(class'TeamInfo', t)
	{
		if (smallestTeam == None)
			smallestTeam = t;
		else
		{
			if (t.numPlayers() < smallestTeam.numPlayers())
			{
				largestTeam = smallestTeam;
				smallestTeam = t;
			}
			else
			{
				largestTeam = t;
			}
		}
	}

	if (smallestTeam.numPlayers() + 1 < largestTeam.numPlayers() && smallestTeam.score < largestTeam.score)
		BroadcastLocalized(self, GameMessageClass, 23);
}

function OnGameEnd()
{
	super.OnGameEnd();

	// Notify stat tracker for cleanup and serialization
	Tracker.onMapEnd();
}

// Hints
static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.gameHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.gameHints.Length; i++ )
		Hints[Hints.Length] = default.gameHints[i];

	return Hints;
}

defaultproperties
{
     speedCheckInterval=1.000000
     teamBalanceCheckInterval=30.000000
     protectYourString="Protect your %1"
     destroyTheirString="Destroy their %1"
     bLoggingGame=True
     bEnableStatLogging=True
}
