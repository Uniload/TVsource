class MPTarget extends MPActor;

var() editdisplay(displayActorLabel)
	  editcombotype(enumRook)
	  Rook	target				"The Rook that is to be a target";
var() bool	bCanComeBackToLife	"Whether or not the Rook can come back to life (if false, a BaseDevice won't be repairable and an AI won't respawn) NOT IMPLEMENTED";
var() int	teamPointsForDestruction	"The number of team points awarded for destroying this target";
var() int	teamPointsForDefending		"The number of team points awarded for defending this target for defendPeriod (NOT IMPLEMENTED)";
var() int	defendPeriod				"The number of seconds that this target must be defended in order for the defenders to score points (NOT IMPLEMENTED)";
var() MPTarget	nextTarget		"If provided, the nextTarget will be activated when this Target is successfully destroyed (or defended if defendPeriod is provided) (NOT IMPLEMENTED)";
var() bool	bChooseRandomNextTarget	"If true, overrides nextTarget to choose a random next target to activate from all eligible targets in the map (NOT IMPLEMENTED)";

// Stats
var(Stats)	class<Stat>	destroyStat			"Stat awarded for destroying this target";
var(Stats)	class<Stat> defendPerPeriodStat	"Stat awarded for defending this target per defendPeriod";

var() bool bActive				"Targets only appear if they're active";

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Register death message for the target
	registerMessage(class'MessageDeath', target.label);

	// Don't allow players on the Target's team to damage it
	target.teamDamagePercentage = 1.0;
}

function registerStats(StatTracker tracker)
{
	Super.registerStats(tracker);
	tracker.registerStat(destroyStat);
	tracker.registerStat(defendPerPeriodStat);
}

// addObjectives
function addObjectives()
{
	//team().objectives.add('Ball objective', 'Throw the ball into an enemy goal', ObjectiveStatus_Active, ObjectiveType_Primary);
}

function bool canBeDestroyedBy(Character c)
{
	return (c != None && (target.team() == None || team() != c.team()));
}

auto state NeverBeenDestroyed
{
	function onMessage(Message msg)
	{
		local Character killer;

		// We know this is a MessageDeath message for the target
		killer = Character(findByLabel(class'Character', MessageDeath(msg).killer));
		if (canBeDestroyedBy(killer))
		{
			awardStat(destroyStat, killer);
			scoreTeam(teamPointsForDestruction, killer.team());
			//killer.ClientMessage("You destroyed an enemy target!");
			//Level.Game.Broadcast(self, "A target was destroyed!");
			Level.Game.BroadcastLocalized(self, class'MPTargetMessages', 0, killer.tribesReplicationInfo, killer.team());
			GotoState('AlreadyBeenDestroyed');
		}
	}
}

state AlreadyBeenDestroyed
{
}

function enumRook(Engine.LevelInfo l, Array<Rook> a)
{
	local Rook r;

	ForEach DynamicActors(class'Rook', r)
	{
		a[a.length] = r;
	}
}

defaultproperties
{
	DrawType				= DT_None
    bUseCylinderCollision	= false	

	bCanComeBackToLife			= false
	teamPointsForDestruction	= 1
	teamPointsForDefending		= 1
	defendPeriod				= 240
	bActive						= true
}