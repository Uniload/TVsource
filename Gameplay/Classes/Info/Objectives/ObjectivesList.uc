class ObjectivesList extends Engine.Info;

var private ObjectiveInfo objectivesLinkedList;

var private float lastUpdateTime;

replication
{
	reliable if (Role == ROLE_Authority)
		objectivesLinkedList;
}


// objectiveFromName
// returns None if the objective does not exist
simulated function ObjectiveInfo objectiveFromName(Name name)
{
	local ObjectiveInfo o;

	o = objectivesLinkedList;
	while (o != None)
	{
		if (o.label == name)
			return o;

		o = o.next;
	}

	return None;
}

// first
simulated function ObjectiveInfo first()
{
	return objectivesLinkedList;
}

// getStatus
// returns false if objective does not exist
simulated function ObjectiveInfo.EObjectiveStatus getStatus(Name name)
{
	local ObjectiveInfo o;

	o = objectiveFromName(name);

	if (o != None)
	{
		return o.status;
	}
	else
	{
		LOG("Objectives Manager: cannot get status of non-existent objective "$name);
		return ObjectiveStatus_Failed;
	}
}

// getNumActors
// returns -1 if objective does not exist
simulated function int getNumActors(Name name)
{
	local ObjectiveInfo o;

	o = objectiveFromName(name);

	if (o != None)
	{
		return o.objectiveActors.Length;
	}
	else
	{
		LOG("Objectives Manager: cannot get number of objective actors for non-existent objective "$name);
		return -1;
	}
}

function ObjectiveInfo addInternal(Name name, ObjectiveInfo.EObjectiveStatus status, ObjectiveInfo.EObjectiveType type, optional ObjectiveActors oa, optional class<RadarInfo> radarInfoClass)
{
	local ObjectiveInfo newInfo;
	local ObjectiveInfo o;
	local int i;

	newInfo = objectiveFromName(name);

	// add new info to end of linked list
	if (newInfo == None)
	{
		newInfo = spawn(class'ObjectiveInfo');

		o = objectivesLinkedList;
		if (o == None)
		{
			objectivesLinkedList = newInfo;
		}
		else
		{
			while (o != None)
			{
				if (o.next == None)
				{
					o.next = newInfo;
					break;
				}

				o = o.next;
			}
		}
	}

	newInfo.label = name;
	newInfo.status = status;
	newInfo.type = type;
	newInfo.radarInfoClass = radarInfoClass;

	for (i = 0; i < oa.objectiveActors.length; ++i)
	{
		if (i < class'ObjectiveInfo'.const.MAX_OBJECTIVE_ACTORS)
		{
			// if we dont have a radar info yet, then add
			//  the one from this objective actor
			if(newInfo.radarInfoClass == None)
				newInfo.radarInfoClass = class<RadarInfo>(oa.objectiveActors[i].GetRadarInfoClass());
			newInfo.objectiveActors[i] = oa.objectiveActors[i];
			newInfo.allyType[i] = AllyType_Friendly;
			newinfo.pos[i] = oa.objectiveActors[i].Location;
			if(Rook(oa.objectiveActors[i]) != None)
			{
				newInfo.TeamInfoClasses[i] = Rook(oa.objectiveActors[i]).team().class;
				if(newInfo.TeamInfoClass == None)
					newInfo.TeamInfoClass = newInfo.TeamInfoClasses[i];
			}
		}
		else
		{
			Log("OBJECTIVE WARNING: Tried to add actor " $ oa.objectiveActors[i].Label $ " to objective " $ name $ " but the max was already reached");
		}
	}

	newInfo.numObjectiveActors = newInfo.objectiveActors.length;
	newInfo.Initialise();
	return newInfo;
}

// add
function add(Name name, Name description, ObjectiveInfo.EObjectiveStatus status, ObjectiveInfo.EObjectiveType type, optional ObjectiveActors oa, optional class<RadarInfo> radarInfoClass)
{
	local ObjectiveInfo newInfo;

	newInfo = addInternal(name, status, type, oa, radarInfoClass);
	newInfo.description = description;
}

// alternate add which allows you to specify a string description
function addUsingString(Name name, string description, ObjectiveInfo.EObjectiveStatus status, ObjectiveInfo.EObjectiveType type, optional ObjectiveActors oa, optional class<RadarInfo> radarInfoClass)
{
	local ObjectiveInfo newInfo;

	newInfo = addInternal(name, status, type, oa, radarInfoClass);
	newInfo.intDescription = description;
}

// remove
function bool remove(Name name)
{
	local ObjectiveInfo o;
	local ObjectiveInfo newNext;

	if (objectivesLinkedList == None)
		return false;

	if (objectivesLinkedList.label == name)
	{
		newNext = objectivesLinkedList.next;
		objectivesLinkedList.Destroy();
		objectivesLinkedList = newNext;
	}

	o = objectivesLinkedList;
	while (o != None)
	{
		if (o.next != None && o.next.label == name)
		{
			newNext = o.next.next;
			o.next.Destroy();
			o.next = newNext;
			return true;
		}

		o = o.next;
	}

	return false;
}

// setStatus
function bool setStatus(Name name, ObjectiveInfo.EObjectiveStatus status)
{
	local ObjectiveInfo o;

	o = objectiveFromName(name);

	if (o != None)
	{
		o.setStatus(status);
		// TBD: Message dispatch
		return true;
	}
	else
	{
		LOG("Objectives Manager: cannot set status of non-existent objective "$name);
		return false;
	}
}

function bool setDescription(Name name, string desc)
{
	local ObjectiveInfo o;

	o = objectiveFromName(name);

	if (o != None)
	{
		o.intDescription = desc;
		// TBD: Message dispatch
		return true;
	}
	else
	{
		LOG("Objectives Manager: cannot set description of non-existent objective "$name);
		return false;
	}
}

function bool removeActor(Name name, Name label)
{
	local ObjectiveInfo o;
	local Actor a;

	o = objectiveFromName(name);
	if (o == None)
	{
		LOG("Objectives Manager: cannot remove actor from non-existent objective "$name);
		return false;
	}

	a = findByLabel(class'Actor', label);
	if (a == None)
	{
		LOG("Objectives Manager: cannot find actor "$label$" to remove from objective "$name);
		return false;
	}

	o.removeActor(a);
	return true;
}

function updateObjectives(float updateRate, TeamInfo team)
{
	local ObjectiveInfo o;

	if (Level.TimeSeconds - lastUpdateTime < updateRate)
		return;

	lastUpdateTime = Level.TimeSeconds;

	o = objectivesLinkedList;
	while (o != None)
	{
		if (o.numObjectiveActors != 0)
			o.updateObjectiveActors(team);

		o = o.next;
	}
}


defaultproperties
{
	RemoteRole = ROLE_DumbProxy
	bAlwaysRelevant = true
}