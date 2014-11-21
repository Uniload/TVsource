class ActionDisplayInfo extends ActionDisplayText;

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Display localised info " $ textID;
}

defaultproperties
{
	sectionName			= "Infos"

	actionDisplayName	= "Display Info"
	actionHelp			= "Sends a localised string to the info display area of the HUD"
}