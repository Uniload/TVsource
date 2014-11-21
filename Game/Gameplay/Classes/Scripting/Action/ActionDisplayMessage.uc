class ActionDisplayMessage extends ActionDisplayText;

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Display localised message " $ textID;
}

defaultproperties
{
	sectionName			= "Messages"

	actionDisplayName	= "Display Message"
	actionHelp			= "Sends a localised string to the message display area of the HUD"
}