class ActionObjectiveRemoveActor extends ActionObjectiveBase
	dependsOn(ObjectiveInfo);

var() Name		actorLabel;

// execute
latent function Variable execute()
{
	local Array<ObjectivesList> list;
	local int i;

	super.execute();

	getListObjects(list);

	for (i = 0; i < list.Length; i++)
	{
		list[i].removeActor(objectiveName, actorLabel);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Remove actor " $ propertyDisplayString('actorLabel') $ " from objective " $ propertyDisplayString('objectiveName');
}


defaultproperties
{
	returnType			= None
	actionDisplayName	= "Objective Remove Actor"
	actionHelp			= "Removes an actor from the objective's actor list"
	category			= "Objective"

	team				= ""
	player				= ""
}