class ActionDisplayText extends Scripting.Action
	abstract;

var() string textID;
var string sectionName; // The localisation section name

latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	// TEMP: Currently there is no text display areas on the HUD, so just send the string to the script log
//	SLog(sectionName $ ": " $ Localize(sectionName, textID, "Gameplay"));

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if(pcc != None)
		pcc.TeamMessage(None, Localize(SectionName, textID, "Localisation\\GUI\\Prompts"), 'Announcer');

	return None;
}

defaultproperties
{
	returnType			= None
	category			= "Other"
}