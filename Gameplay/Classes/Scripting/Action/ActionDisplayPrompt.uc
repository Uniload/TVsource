class ActionDisplayPrompt extends ActionDisplayText;

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Display localised prompt " $ textID;
}

defaultproperties
{
	sectionName			= "Prompts"

	actionDisplayName	= "Display Prompt"
	actionHelp			= "Sends a localised string to the prompt display area of the HUD"
}