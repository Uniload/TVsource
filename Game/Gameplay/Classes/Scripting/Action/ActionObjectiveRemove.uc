class ActionObjectiveRemove extends ActionObjectiveBase;

// execute
latent function Variable execute()
{
	local Array<ObjectivesList> list;
	local int i;

	super.execute();

	getListObjects(list);

	for (i = 0; i < list.Length; i++)
	{
		list[i].remove(objectiveName);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Remove Objective " $ propertyDisplayString('objectiveName');
}


defaultproperties
{
	returnType			= None
	actionDisplayName	= "Objective Remove"
	actionHelp			= "Removes an objective for either everyone, a team or a player."
	category			= "Objective"
}