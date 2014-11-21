class ActionObjectiveAdd extends ActionObjectiveBase
	dependsOn(ObjectiveInfo);

const MAX_OBJECTIVE_ACTORS = 10;

var() Name												description;
var() actionnoresolve ObjectiveInfo.EObjectiveStatus	status;
var() actionnoresolve ObjectiveInfo.EObjectiveType		type;
var() actionnoresolve Name								objectiveActors[MAX_OBJECTIVE_ACTORS];
var() actionnoresolve class<RadarInfo>					radarInfoClass;

// execute
latent function Variable execute()
{
	local Array<ObjectivesList> list;
	local int i, j;
	local ObjectiveActors oa;
	local Actor a;

	super.execute();

	getListObjects(list);

	oa = new class'ObjectiveActors';

	for (i = 0; i < list.Length; i++)
	{
		oa.objectiveActors.length = 0;

		for (j = 0; j < MAX_OBJECTIVE_ACTORS && objectiveActors[j] != ''; ++j)
		{
			foreach parentScript.actorLabel(class'Actor', a, objectiveActors[j])
			{
				oa.objectiveActors[oa.objectiveActors.length] = a;
			}
		}

		list[i].add(objectiveName, description, status, type, oa, radarInfoClass);
	}

	oa.Delete();

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Add Objective " $ propertyDisplayString('objectiveName') $ ", " $ 
		class'ObjectiveInfo'.static.statusText(status) $ " " $
		class'ObjectiveInfo'.static.typeText(type);
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Objective Add"
	actionHelp			= "Adds an objective for either all teams, a single team or a single player."
	category			= "Objective"
}