// MPActor
// Base class for "UGM" objects as described in the Tribes3 design doc
class MPActor extends Rook
	native
	dependsOn(ObjectiveInfo);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// A localized name to uniquely identify this object in text messages
var() localized string	localizedName;
var() bool bAllowSpectators											"If true, spectators can switch to view this object";

var(Objectives) localized String	primaryFriendlyObjectiveDesc	"The localized description of the primary objective";
var(Objectives) localized String	primaryEnemyObjectiveDesc		"The localized description of the primary objective";
var(Objectives) localized String	primaryNeutralObjectiveDesc		"The localized description of the primary objective";
var(Stats) class<Stat>	defendStat									"The stat awarded for killing enemies near this object if it's on the same team";
var(Stats) class<Stat>	attackStat									"The stat awarded for killing enemies near this object if it's on the enemy team";
var(Stats) int			defendRadius								"Radius within which you're considered to be defending this object";
var(Stats) int			attackRadius								"Radius within which you're considered to be attacking this object";

var() Name							idleAnim						"An animation to play when this object is idle";
var(LocalMessage) class<MPEventMessage>	secondaryMessageClass			"The class to use for secondary game event messages";


var array<PlayerCharacterController> spectatorList;

//function PreBeginPlay()
//{
//	registerMessage(class'MessageLevelStart', "GameInfo");
//}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (DrawType == DT_Mesh && hasAnim(idleAnim))
		LoopAnim(idleAnim);
}

// onMessage
//function onMessage(Message msg)
//{
//	// add objectives on level start
//	addDefaultObjectives();
//}

// PostTakeDamage
// MPActors take no damage by default
function PostTakeDamage( float Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
}

// Override cleanup() in base classes to manually destroy any dynamically created
// instances.  This ensures that everything gets filtered properly on map load.
function cleanup()
{
	removeDefaultObjectives();
}

// Override this function to register any stats with StatTracker
function registerStats(StatTracker tracker)
{
	local ModeInfo mode;

	tracker.registerStat(defendStat);
	tracker.registerStat(attackStat);

	mode = ModeInfo(Level.Game);

	if (mode != None && (attackStat != None || defendStat != None))
	{
		mode.registerPlayerKillListener(self);
	}
}

// Helper functions

// getNearest
// Gets the nearest rook of the given class
function Rook getNearest(class<Rook> type, Vector from, optional TeamInfo onlyTeam)
{
	local float maxDist;
	local float dist;
	local Actor nearest;
	local Actor a;
	local Rook r;

	maxDist = 9999999999;

	ForEach DynamicActors(type, a)
	{
		r = Rook(a);

		dist = VSize(r.Location - from);
        if (dist < maxDist && (onlyTeam == None || onlyTeam == r.Team()))
		{
			maxDist = dist;
			nearest = r;
		}
	}

	return r;
}

// scoreTeam
// increments the score for the object's team, or an optional other team
function scoreTeam(int amount, optional TeamInfo otherTeam)
{
	local TeamInfo scoringTeam;

	if (otherTeam != None)
	{
		scoringTeam = otherTeam;
	}
	else if (team() != None)
	{
		scoringTeam = team();
	}

	dispatchMessage(new class'MessageTeamScored'(scoringTeam));

	scoringTeam.score += amount;
	if (MultiplayerGameInfo(Level.Game) != None)
		MultiplayerGameInfo(Level.Game).postTeamScored(scoringTeam, amount, self);
}

// scoreIndividual
// Sets an individual's score
function scoreIndividual(Character who, int amount)
{
	if (who.tribesReplicationInfo != None)
	{
		who.tribesReplicationInfo.score += amount;
		who.tribesReplicationInfo.offenseScore += amount;
	}
}

function awardStat( Class<Stat> s, Character who, optional Controller target, optional int amount )
{
	local ModeInfo mode;

	mode = ModeInfo(Level.Game);
	if (mode != None && who != None)
	{
		mode.Tracker.awardStat(Controller(who.tribesReplicationInfo.Owner), s, target, amount);
	}
}

function incrementStatAttempt( Class<Stat> s, Character who )
{
	local ModeInfo mode;

	mode = ModeInfo(Level.Game);
	if (mode != None && who != None)
	{
		mode.Tracker.incrementStatAttempt(who, s);
	}
}

function onPlayerKilled(Controller Killer, Controller Target)
{
	local ModeInfo mode;

	mode = ModeInfo(Level.Game);

	if (mode == None)
		return;

	// Award defense stat; killer or target can be in radius
	// TODO:  Distribute points according to who damaged Target the most?
	if (defendStat != None && Rook(Killer.Pawn).team() == team() && Rook(Target.Pawn).team() != team() &&
		(VDist(Location, Target.Location) <= defendRadius || VDist(Location, Killer.Location) <= defendRadius))
	{
		mode.Tracker.awardStat(Killer, defendStat, Target);
	}
	// Award attack stat; target must be in radius
	else if (attackStat != None && Rook(Killer.Pawn).team() != team() && Rook(Target.Pawn).team() == team() &&
		VDist(Location, Target.Location) <= attackRadius)
	{
		mode.Tracker.awardStat(Killer, attackStat, Target);
	}
}

function addDefaultObjectives()
{
	if (primaryFriendlyObjectiveDesc != "")
		addFriendlyObjective(primaryFriendlyObjectiveDesc);
	if (primaryEnemyObjectiveDesc != "")
		addEnemyObjective(primaryEnemyObjectiveDesc);
	if (primaryNeutralObjectiveDesc != "")
		addNeutralObjective(primaryNeutralObjectiveDesc);

	evaluateObjectiveState();
}

function removeDefaultObjectives()
{
	local TeamInfo t;

	// Quick and dirty...just try removing them from all TeamInfos
	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (t.objectives.remove(getUniqueObjectiveName()))
			Log("Removing "$getUniqueObjectiveName()$" from "$t);
	}

	evaluateObjectiveState();
}

function removePersonalObjective(PlayerCharacterController c)
{
	c.objectives.remove(getPersonalObjectiveName());
}

function setPersonalObjective(PlayerCharacterController c, string desc, optional Actor other)
{
	local ObjectiveActors oa;

	oa = new class'objectiveActors';

	if (other != None)
		oa.objectiveActors[0] = other;
	else
		oa.objectiveActors[0] = self;

	// Only allow one personal objective
	c.objectives.addUsingString(getPersonalObjectiveName(), desc, ObjectiveStatus_Active, ObjectiveType_Primary, oa);
}

function addFriendlyObjective(string desc, optional Actor other)
{
	local ObjectiveActors oa;
	local TeamInfo t;

	if (team() == None)
		return;

	oa = new class'objectiveActors';

	if (other != None)
		oa.objectiveActors[0] = other;
	else
		oa.objectiveActors[0] = self;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (t == team())
		{
			//Log("Adding friendly objective for "$self$" to team "$t$" using name "$getUniqueObjectiveName());
			t.objectives.addUsingString(getUniqueObjectiveName(), desc, ObjectiveStatus_Active, ObjectiveType_Primary, oa);
		}
	}
}

function addEnemyObjective(string desc, optional Actor other)
{
	local ObjectiveActors oa;
	local TeamInfo t;

	if (team() == None)
		return;

	oa = new class'objectiveActors';

	if (other != None)
		oa.objectiveActors[0] = other;
	else
		oa.objectiveActors[0] = self;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		if (t != team())
		{
			//Log("Adding enemy objective for "$self$" to team "$t$" using name "$getUniqueObjectiveName());
			t.objectives.addUsingString(getUniqueObjectiveName(), desc, ObjectiveStatus_Active, ObjectiveType_Primary, oa);
		}
	}
}

function addNeutralObjective(string desc, optional Actor other)
{
	local ObjectiveActors oa;
	local TeamInfo t;

	if (team() != None)
		return;

	oa =  new class'objectiveActors';

	if (other != None)
		oa.objectiveActors[0] = other;
	else
		oa.objectiveActors[0] = self;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		//Log("Adding neutral objective for "$self$" to team "$t$" using name "$getUniqueObjectiveName());
		t.objectives.addUsingString(getUniqueObjectiveName(), desc, ObjectiveStatus_Active, ObjectiveType_Primary, oa);
	}
}

function setObjectiveState(int i)
{
	local ObjectiveInfo o;
	local TeamInfo t;

	//log("Setting objective state "$i$" on "$self);

	// set friendly and enemy states
	ForEach DynamicActors(class'TeamInfo', t)
	{
		o = t.objectives.objectiveFromName(getUniqueObjectiveName());

		if (o != None)
		{
			//Log("Setting objective state of "$o$" for team "$t$" to "$i);
			o.state = i;
		}
	}
}

function setObjectiveTally(int num, int max)
{
	local ObjectiveInfo o;
	local TeamInfo t;

	ForEach DynamicActors(class'TeamInfo', t)
	{
		o = t.objectives.objectiveFromName(getUniqueObjectiveName());

		if (o != None)
		{
			//Log("Setting objective state of "$o$" for team "$t$" to "$i);
			o.UpdateTally(num, max);
		}
	}
}

function evaluateObjectiveState()
{
	// Overridden in subclasses
}

function name getUniqueObjectiveName()
{
	return self.Name;
}

function name getPersonalObjectiveName()
{
	return 'PersonalObjective';
}

simulated function string GetHumanReadableName()
{
	local string value;

	value = localizedName;

	if(value == "")
		value = super.GetHumanReadableName();

	if(value == "")
		value = string(class.name);

	return value;
}

simulated function expandLattice(TeamInfo t)
{
	local LatticeInfo l;

	if (GameInfo(Level.Game) != None)
	{
		l = GameInfo(Level.Game).Lattice;
		if (l != None)
			l.makeNeighboursAvailable(self, t);
	}
}

simulated function contractLattice(TeamInfo t)
{
	local LatticeInfo l;

	if (GameInfo(Level.Game) != None)
	{
		l = GameInfo(Level.Game).Lattice;
		if (l != None)
			l.makeNeighboursUnavailable(self, t);
	}
}

simulated function onAvailableToLattice()
{
	// Subclasses can provide code to support lattices
}

simulated function onUnavailableToLattice()
{
	// Subclasses can provide code to support lattices
}

function setSpectatorViewTarget(Pawn target)
{
	local Controller C;
	local PlayerCharacterController pcc;

	if (!bAllowSpectators)
		return;

	for (C=Level.ControllerList; C!=None; C=C.NextController)
	{
		pcc = PlayerCharacterController(C);
		if (pcc == None || !pcc.playerReplicationInfo.bIsSpectator)
			continue;

		if (pcc.viewTarget == self)
		{
			pcc.SetViewTarget(target);
			pcc.ClientSetViewTarget(target);

			// Remember that this player was spectating self
			addSpectator(pcc);
		}
	}
}

function addSpectator(PlayerCharacterController pcc)
{
	local int i;

	// Don't allow duplicates
	for (i=0; i<spectatorList.Length; i++)
	{
		if (spectatorList[i] == pcc)
			return;
	}

	spectatorList[spectatorList.Length] = pcc;
}

function removeSpectator(PlayerCharacterController pcc)
{
	local int i;

	for (i=0; i<spectatorList.Length; i++)
	{
		if (spectatorList[i] == pcc)
		{
			spectatorList.Remove(i, 1);
			return;
		}
	}
}

function resetSpectatorViewTarget()
{
	local int i;
	local PlayerCharacterController pcc;

	if (!bAllowSpectators)
		return;

	// Force all remembered spectators back to viewing self
	for (i=0; i<spectatorList.Length; i++)
	{
		pcc = spectatorList[i];

		if (pcc == None || !pcc.playerReplicationInfo.bIsSpectator)
			continue;

		pcc.SetViewTarget(self);
		pcc.ClientSetViewTarget(self);
	}

	// Clear the list
	spectatorList.Length = 0;
}

function Pawn getViewTarget()
{
	return self;
}

// An GameOver state
state GameOver
{
	// Don't do anything
}

cpptext
{
	// stats recording
	virtual UBOOL Tick(float deltaSeconds, ELevelTick tickType);

}


defaultproperties
{
     bAllowSpectators=True
     bAIThreat=False
     bCanBeSensed=False
     bUseCompressedPosition=False
     bNeedPostRenderCallback=True
     bCanBeDamaged=False
     bBlockKarma=True
     bTriggerEffectEventsBeforeGameStarts=True
}
