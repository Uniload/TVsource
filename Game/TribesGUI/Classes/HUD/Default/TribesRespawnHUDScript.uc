class TribesRespawnHUDScript extends TribesCommandHUDScript;

var LabelElement PromptLabel;
var LabelElement PromptLabelLarge;
var ClientSideCharacter csc;

var localized string CountdownText;
var localized string PromptText;
var localized string CancelText;
var localized string RespawnLimitText;
var localized string ClickToSeeMapText;
var localized string NoMoreFuelText;
var localized string InstantRespawnText;
var localized string RoundStartText;

var int ExitRespawnKeyBinding;
var bool bShowingRespawnMap;

var ClientSideCharacter localData;
var HUDRespawnAction ActionHandler;

overloaded function Construct()
{
	PromptLabelLarge = LabelElement(AddElement("TribesGUI.LabelElement", "default_PromptLabelLarge"));
	PromptLabelLarge.bAutoSize = true;

	commandHUDContainer = HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_CommandHUDContainer"));

	bodyContainer = HUDContainer(commandHUDContainer.AddClonedElement("TribesGUI.HUDContainer", "default_CommandHUDBodyContainer"));

	commandMapContainer = HUDContainer(bodyContainer.AddClonedElement("TribesGUI.HUDContainer", "default_CommandMapContainer"));
	objectivesContainer = HUDContainer(bodyContainer.AddClonedElement("TribesGUI.HUDContainer", "default_objectivesContainer"));

	commandMap = HUDRespawnMap(commandMapContainer.AddClonedElement("TribesGUI.HUDRespawnMap", "default_CommandMap"));

	titleLabel = LabelElement(objectivesContainer.AddClonedElement("TribesGUI.LabelElement", "default_CommandMapTitleLabel"));
	titleLabel.SetText(TitleString);

	mapInfoLabel = LabelElement(objectivesContainer.AddClonedElement("TribesGUI.LabelElement", "default_MapInfoLabel"));
	mapInfoLabel.bAutoSize = true;
	mapInfoLabel.SetText("Map Information");

	primaryObjectivesLabel = LabelElement(objectivesContainer.AddClonedElement("TribesGUI.LabelElement", "default_PrimaryObjectivesLabel"));
	primaryObjectivesLabel.SetText(class'ObjectiveInfo'.static.typeText(ObjectiveType_Primary));
	primaryObjectivesList = HUDObjectiveList(objectivesContainer.AddClonedElement("TribesGUI.HUDObjectiveList", "default_PrimaryObjectivesList"));

	secondaryObjectivesLabel = LabelElement(objectivesContainer.AddClonedElement("TribesGUI.LabelElement", "default_SecondaryObjectivesLabel"));
	secondaryObjectivesLabel.SetText(class'ObjectiveInfo'.static.typeText(ObjectiveType_Secondary));
	secondaryObjectivesList = HUDObjectiveList(objectivesContainer.AddClonedElement("TribesGUI.HUDObjectiveList", "default_SecondaryObjectivesList"));

	PromptLabel = LabelElement(commandMapContainer.AddElement("TribesGUI.LabelElement", "default_PromptLabel"));
	PromptLabel.bAutoSize = true;
	PromptLabel.SetText(PromptText);

	ConstructBaseComponents();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response)
{
	// do the super first if the respawn map is already showing
	// MJ:  added check for bShowingRespawnMap because mouse clicks were passing through
	// and prematurely clicking respawn markers
	// PCD: now it's been removed, the respawn markers wont act on events untill
	// bShowingRespawnMap is true
	if(Super.KeyEvent(Key, Action, Delta, Response))
		return true;

	ActionHandler = HUDRespawnAction(Response);

	if(Action == EInputAction.IST_Press)	// only on pressed events
	{
		if(! bShowingRespawnMap || localData.bInstantRespawnMode)
		{
			if(Key == EInputKey.IK_LeftMouse)	// left mouse button
			{
				if(localData.bInstantRespawnMode)
					HUDRespawnAction(Response).SelectRespawnBase(-1);
				else
					HUDRespawnAction(Response).DisplayRespawnMap();
				return true;
			}
		}
		else
		{
			if(Key == EInputKey.IK_LeftMouse)	// left mouse button
			{
				// if the user clicked on nothing (checked in super()) then we should send a
				// value to indicate that they want to spawn, if they are allowed to
				HUDRespawnAction(Response).SelectRespawnBase(-3);
			}
			if(Key >= IK_1 && Key <= IK_9) // between 1 & 9 inclusive
			{
				HUDRespawnMap(commandMap).SelectSpawnPointByIndex(Key - IK_1);
				HUDRespawnAction(Response).SelectRespawnBase(HUDRespawnMap(commandMap).positionIndices[Key - IK_1]);	// take the index back to 0 based
				return true;
			}
			else if(Key >= IK_NumPad1 && Key <= IK_NumPad9) // between 1 & 9 inclusive (numpad)
			{
				HUDRespawnMap(commandMap).SelectSpawnPointByIndex(Key - IK_NumPad1);
				HUDRespawnAction(Response).SelectRespawnBase(HUDRespawnMap(commandMap).positionIndices[Key - IK_NumPad1]);	// take the index back to 0 based
				return true;
			}
			else if(Key == ExitRespawnKeyBinding || (Key == IK_Escape && csc.bCanExitRespawnHud))		// Escape at the moment...
			{
				HUDRespawnAction(Response).ExitRespawnHUD();
				return true;
			}
		}
	}

	return false;
}

function SetRespawnMapVisibility(bool value)
{
	bShowingRespawnMap = value;
	commandHUDContainer.bVisible = value;
	PromptLabelLarge.bVisible = ! value;

	commandHUDContainer.SetNeedsLayout();
	commandHUDContainer.ForceNeedsLayout();
}

function UpdateData(ClientSideCharacter c)
{
	local string text, tempText;

	Super.UpdateData(c);

	csc = c;
	localData = c;

	SetRespawnMapVisibility(c.bShowRespawnMap);

	// only force resizing of the chat window when the map is showing.
	if(messageWindow != None && bShowingRespawnMap)
		messageWindow.ForcedMaxVisibleLines = 3;
	else
		messageWindow.ForcedMaxVisibleLines = -1;

	ExitRespawnKeyBinding = c.ExitRespawnKeyBinding;

	if(localData.bInstantRespawnMode)
	{
		PromptLabelLarge.SetText(InstantRespawnText);
	}
	else if(bShowingRespawnMap)
	{
		// print respawn info
		if(c.livesLeft == 0)
		{
			text = RespawnLimitText;
		}
		else if (c.bNoMoreCarryables == true)
		{
			text = NoMoreFuelText;
		}
		else
		{
			if(c.respawnTime > 0)
			{
				tempText = replaceStr(CountdownText, ""$c.respawnTime);
				text $= tempText;
			}
			//else if (c.countdown > 0)
			//{
			//	tempText = replaceStr(RoundStartText, c.countdown);
			//	text $= tempText;
			//}

			text $= PromptText;

			if(c.bCanExitRespawnHUD)
			{
				tempText = replaceStr(CancelText, c.ExitRespawnKeyText);
				text $= tempText;
			}
		}

		PromptLabel.SetText(text);
	}
	else
	{
		if(c.respawnTime > 0)
		{
			tempText = replaceStr(CountdownText, ""$c.respawnTime);
			text $= tempText;
		}

		text $= ClickToSeeMapText;

		PromptLabelLarge.SetText(text);
	}

}

defaultproperties
{
	TitleString			= "Respawn Menu"

	NoMoreFuelText		= "Your team has run out of fuel.¼You can't spawn until they get more."
	RespawnLimitText	= "You have reached your respawn limit. You must wait until the next round"
	CountdownText		= "Respawn in %1 seconds¼"
	PromptText			= "Use the Number keys to select a spawn point¼"
	CancelText			= "Press '%1' to cancel"
	ClickToSeeMapText	= "Press Fire to see respawn map"
	InstantRespawnText	= "Press Fire to respawn"
	RoundStartText		= "You have %1 seconds to select a spawn point and choose equipment"
}