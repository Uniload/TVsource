//================================================================
// Class: TribesCommandHUDScript
//
// Command map HUD script implementation
//
//================================================================

class TribesCommandHUDScript extends TribesEditableHUDScript;

import enum EObjectiveType from ObjectiveInfo;

var HUDContainer		commandHUDContainer;
var HUDContainer		commandMapContainer;
var LabelElement		titleLabel;
var HUDContainer		bodyContainer;
var HUDCommandMap		commandMap;
var HUDContainer		objectivesContainer;
var LabelElement		mapInfoLabel;
var LabelElement		primaryObjectivesLabel;
var HUDObjectiveList	primaryObjectivesList;
var LabelElement		secondaryObjectivesLabel;
var HUDObjectiveList	secondaryObjectivesList;

var localized String TitleString;

overloaded function Construct()
{
	commandHUDContainer = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_CommandHUDContainer"));

	bodyContainer = HUDContainer(commandHUDContainer.AddElement("TribesGUI.HUDContainer", "default_CommandHUDBodyContainer"));

	commandMapContainer = HUDContainer(bodyContainer.AddElement("TribesGUI.HUDContainer", "default_CommandMapContainer"));
	objectivesContainer = HUDContainer(bodyContainer.AddElement("TribesGUI.HUDContainer", "default_objectivesContainer"));

	commandMap = HUDCommandMap(commandMapContainer.AddElement("TribesGUI.HUDCommandMap", "default_CommandMap"));

	titleLabel = LabelElement(objectivesContainer.AddElement("TribesGUI.LabelElement", "default_CommandMapTitleLabel"));
	titleLabel.SetText(TitleString);

	mapInfoLabel = LabelElement(objectivesContainer.AddElement("TribesGUI.LabelElement", "default_MapInfoLabel"));
	mapInfoLabel.bAutoSize = true;
	mapInfoLabel.SetText("Map Information");

	primaryObjectivesLabel = LabelElement(objectivesContainer.AddElement("TribesGUI.LabelElement", "default_PrimaryObjectivesLabel"));
	primaryObjectivesLabel.SetText(class'ObjectiveInfo'.static.typeText(ObjectiveType_Primary));
	primaryObjectivesList = HUDObjectiveList(objectivesContainer.AddElement("TribesGUI.HUDObjectiveList", "default_PrimaryObjectivesList"));

	secondaryObjectivesLabel = LabelElement(objectivesContainer.AddElement("TribesGUI.LabelElement", "default_SecondaryObjectivesLabel"));
	secondaryObjectivesLabel.SetText(class'ObjectiveInfo'.static.typeText(ObjectiveType_Secondary));
	secondaryObjectivesList = HUDObjectiveList(objectivesContainer.AddElement("TribesGUI.HUDObjectiveList", "default_SecondaryObjectivesList"));

	super.Construct();
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);
	
	primaryObjectivesLabel.bVisible = (! primaryObjectivesList.IsListEmpty());
	secondaryObjectivesLabel.bVisible = (! secondaryObjectivesList.IsListEmpty());

	mapInfoLabel.SetText(c.levelDescription);

	if(messageWindow != None)
		messageWindow.ForcedMaxVisibleLines = 3;
}

defaultproperties
{
	bIsAnnouncmentsEnabled=false

	TitleString="Command Map"
}