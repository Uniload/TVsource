class ActionObjectiveSetStatus extends ActionObjectiveBase
	dependsOn(ObjectiveInfo);

var() actionnoresolve ObjectiveInfo.EObjectiveStatus	status;


// execute
latent function Variable execute()
{
	local Array<ObjectivesList> list;
	local int i;

	super.execute();

	getListObjects(list);

	for (i = 0; i < list.Length; i++)
	{
		list[i].setStatus(objectiveName, status);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Set Objective " $ propertyDisplayString('objectiveName') $ " Status to " $ 
		class'ObjectiveInfo'.static.statusText(status);
}


defaultproperties
{
	returnType			= None
	actionDisplayName	= "Objective Set Status"
	actionHelp			= "Sets the status of an objective for either everyone, a team or a player."
	category			= "Objective"
}