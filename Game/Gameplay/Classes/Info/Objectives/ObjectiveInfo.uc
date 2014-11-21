class ObjectiveInfo extends Engine.Info;

enum EObjectiveStatus
{
	ObjectiveStatus_Active,
	ObjectiveStatus_Completed,
	ObjectiveStatus_Failed
};

enum EObjectiveType
{
	ObjectiveType_Primary,
	ObjectiveType_Secondary
};

enum EAllyType
{
	AllyType_Friendly,
	AllyType_Enemy,
	AllyType_Neutral
};

enum EStateType
{
	StateType_None,
	StateType_New,
	StateType_Dead
};

var Name				description;
var String				intDescription;
var EObjectiveStatus	status;
var byte				state;	// not to be confused with status, the state is an index for the icon to be used when rendering this objective
var EObjectiveType		type;
var class<RadarInfo>	radarInfoClass;
var class<TeamInfo>		TeamInfoClass;
var ObjectiveInfo		next;
var bool				bShouldFlash;
var bool				bIsTallied;
var int					TallyMax;
var int					TallyCurrent;

const MAX_OBJECTIVE_ACTORS = 10;

var int				numObjectiveActors;
var Array<Actor>	objectiveActors;
var float			creationTime;
var Vector			pos[MAX_OBJECTIVE_ACTORS];
var EAllyType		allyType[MAX_OBJECTIVE_ACTORS];
var class<TeamInfo>	TeamInfoClasses[MAX_OBJECTIVE_ACTORS];

var Array<float>		actorRemoveTime;
var Array<EStateType>	actorStateOverride;

// Localisation strings
var localized string Status_Active;
var localized string Status_Completed;
var localized string Status_Failed;
var localized string Type_Primary;
var localized string Type_Secondary;

replication
{
	reliable if (Role == ROLE_Authority)
		description, status, state, type, next, numObjectiveActors, pos, allyType, TeamInfoClasses, intDescription, radarInfoClass, TeamInfoClass,
		TallyCurrent, TallyMax;
}

// statusText
static function string statusText(EObjectiveStatus status)
{
	switch (status)
	{
		case ObjectiveStatus_Active:	return default.Status_Active;
		case ObjectiveStatus_Completed: return default.Status_Completed;
		case ObjectiveStatus_Failed:	return default.Status_Failed;
	}
}

// typeText
static function string typeText(EObjectiveType type)
{
	switch (type)
	{
		case ObjectiveType_Primary:		return default.Type_Primary;
		case ObjectiveType_Secondary:	return default.Type_Secondary;
	}
}

function Initialise()
{
	local int i;

	creationTime = Level.TimeSeconds;

	for(i = 0; i < numObjectiveActors; ++i)
		actorStateOverride[i] = StateType_New;

	TallyMax = numObjectiveActors;
}

// descriptionText
simulated function string getDescription()
{
	local String desc;

	if(description != '')
		desc = LocalizeMapText("Objectives", String(description));
	else
		desc = intDescription;

	if(TallyMax > 1)
		desc $= " (" $TallyCurrent $"/" $TallyMax $")";

	//if(desc != intDescription && desc != "")
	//	intDescription = desc;

	return desc;
}

function UpdateTally(int current, int max)
{
	TallyCurrent = current;
	TallyMax = max;
}

function setStatus(EObjectiveStatus newStatus)
{
	local int i;

	status = newStatus;

	if (status == ObjectiveStatus_Completed)
	{
//		objectiveActors.length = 0;
//		numObjectiveActors = 0;

		// remove remaining actors associated with this objective
		for (i = 0; i < objectiveActors.Length; i++)
			removeActor(objectiveActors[i]);
	}
}

function removeActor(Actor a)
{
	local int i;

	for (i = 0; i < objectiveActors.Length; i++)
	{
		if (objectiveActors[i] == a && actorStateOverride[i] != StateType_Dead)
		{
			actorRemoveTime[i] = Level.TimeSeconds;
			actorStateOverride[i] = StateType_Dead;
			return;
		}
	}
}

function updateObjectiveActors(TeamInfo team)
{
	local int i;
	local bool actorRemoved;
	local bool newActorExists, deadActorExists;
	local float deadFlashDuration;

	assert(numObjectiveActors <= MAX_OBJECTIVE_ACTORS);

	if(radarInfoClass != None)
		deadFlashDuration = radarInfoClass.default.deadDuration;
	else
		deadFlashDuration = 3;	// arbitrary fallback... should not happen

	deadActorExists = false;
	i = 0;
	while (i < objectiveActors.length)
	{
		actorRemoved = false;
		if(actorStateOverride[i] == StateType_Dead)
		{
			actorRemoved = (actorRemoveTime[i] + deadFlashDuration) < Level.TimeSeconds;
			deadActorExists = deadActorExists || ! actorRemoved;
		}

		if (objectiveActors[i] == None || actorRemoved)
		{
			objectiveActors.Remove(i, 1);
			actorStateOverride.Remove(i, 1);
			actorRemoveTime.Remove(i, 1);
		}
		else
			++i;
	}

	numObjectiveActors = objectiveActors.length;

	// hack :(
	if (Level.Game != None && SingleplayerGameInfo(Level.Game) != None)
		UpdateTally(TallyMax - numObjectiveActors, TallyMax);

	if (status == ObjectiveStatus_Completed)
	{
		bShouldFlash = (newActorExists || deadActorExists);
		return;
	}

	newActorExists = false;
	for (i = 0; i < numObjectiveActors; ++i)
	{
		pos[i] = objectiveActors[i].Location;
		allyType[i] = AllyType_Friendly;
		TeamInfoClasses[i] = TeamInfoClass;
		if(actorStateOverride[i] == StateType_New)
		{
			newActorExists = true;
			if((creationTime + radarInfoClass.default.newDuration) < Level.TimeSeconds)
				actorStateOverride[i] = StateType_None;
		}
		
		if(objectiveActors[i].IsA('Rook'))
		{
			pos[i] = Rook(objectiveActors[i]).GetObjectiveLocation();
			if(team != None && ! team.IsFriendly(Rook(objectiveActors[i]).team()))
				allyType[i] = AllyType_Enemy;
		}
	}

	bShouldFlash = (newActorExists || deadActorExists);
}

defaultproperties
{
	RemoteRole = ROLE_DumbProxy
	bAlwaysRelevant = true
}