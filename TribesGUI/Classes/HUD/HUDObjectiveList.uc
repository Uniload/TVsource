class HUDObjectiveList extends HUDList;

import enum EObjectiveStatus from ObjectiveInfo;
import enum EObjectiveType from ObjectiveInfo;
import enum EIconType from RadarInfo;

var() config HUDMaterial completedObjectiveIconOverlay;

var() config EObjectiveType typeMask;
var() config Color completedDrawColor;
var() config Color failedDrawColor;
var() config Color activeDrawColor;

// columns
var HUDList iconList;
var HUDList textList;

function InitElement()
{
	super.InitElement();

	iconList = HUDList(AddClonedElement("TribesGUI.HUDList", "default_objectiveIconColumn"));

	textList = HUDList(AddClonedElement("TribesGUI.HUDList", "default_objectiveTextColumn"));
}

function SetObjective(EObjectiveStatus status, class<RadarInfo> radarInfo, String text, int index, int state, bool isFriendly, bool bForceFlash, class<TeamInfo> teamInfoClass)
{
	local LabelElement newLabel;
	local HUDIcon objectiveIcon;

	if(textList.children.Length > index)
	{
		objectiveIcon = HUDIcon(iconList.children[index]);

		if(radarInfo != None)
		{
			if(teamInfoClass != None)
				HUDIcon(iconList.children[index]).iconMaterial = class'HUDRadarBase'.static.GetHUDMaterial(radarInfo, state, isFriendly, ICON_Radar, TeamInfoClass.default.TeamColor, LocalData.UserPrefColorType, bForceFlash);
			else
				HUDIcon(iconList.children[index]).iconMaterial = class'HUDRadarBase'.static.GetHUDMaterial(radarInfo, state, isFriendly, ICON_Radar, LocalData.ownTeamColor, COLOR_Neutral, bForceFlash);
		}
		else
			HUDIcon(iconList.children[index]).iconMaterial.Material = None;

		LabelElement(textList.children[index]).SetText(text);

		switch(status)
		{
		case ObjectiveStatus_Active:
			LabelElement(textList.children[index]).textColor = activeDrawColor;
			break;
		case ObjectiveStatus_Completed:
			LabelElement(textList.children[index]).textColor = completedDrawColor;
			HUDIcon(iconList.children[index]).iconMaterial.drawColor = completedDrawColor;
			HUDIcon(iconList.children[index]).foregroundTexture = completedObjectiveIconOverlay;
			break;
		case ObjectiveStatus_Failed:
			LabelElement(textList.children[index]).textColor = failedDrawColor;
			HUDIcon(iconList.children[index]).iconMaterial.drawColor = failedDrawColor;
			break;
		}
	}
	else
	{
		objectiveIcon = HUDIcon(iconList.AddClonedElement("TribesGUI.HUDIcon", "default_ObjectiveIcon"));
		if(radarInfo != None)
		{
			if(teamInfoClass != None)
				objectiveIcon.iconMaterial = class'HUDRadarBase'.static.GetHUDMaterial(radarInfo, state, isFriendly, ICON_Radar, TeamInfoClass.default.TeamColor, LocalData.UserPrefColorType, bForceFlash);
			else
				objectiveIcon.iconMaterial = class'HUDRadarBase'.static.GetHUDMaterial(radarInfo, state, isFriendly, ICON_Radar, LocalData.ownTeamColor, COLOR_Neutral, bForceFlash);
		}

		newLabel = LabelElement(textList.AddClonedElement("TribesGUI.LabelElement", "default_ObjectiveTextLabel"));
		newLabel.bAutoSize = false;
		newLabel.SetText(text);

		switch(status)
		{
		case ObjectiveStatus_Active:
			newLabel.textColor = activeDrawColor;
			break;
		case ObjectiveStatus_Completed:
			newLabel.textColor = completedDrawColor;
			objectiveIcon.iconMaterial.DrawColor = completedDrawColor;
			objectiveIcon.foregroundTexture = completedObjectiveIconOverlay;
			break;
		case ObjectiveStatus_Failed:
			newLabel.textColor = failedDrawColor;
			objectiveIcon.iconMaterial.DrawColor = failedDrawColor;
			break;
		}

		SetNeedsLayout();
	}

	// flash the material, if neccesary
	if(objectiveIcon.IconMaterial.bFading)
	{
		objectiveIcon.IconMaterial.fadeStartTime = TimeSeconds - (TimeSeconds % objectiveIcon.IconMaterial.fadeDuration);
		objectiveIcon.IconMaterial.fadeProgress = FClamp((TimeSeconds - objectiveIcon.IconMaterial.fadeStartTime) / objectiveIcon.IconMaterial.fadeDuration, 0.f, 1.f);
	}
}

function RemoveObjective(int index)
{
	iconList.RemoveElementAt(index);
	textList.RemoveElementAt(index);
}

function UpdateData(ClientSideCharacter c)
{
	local int i, listIndex;
	local class<RadarInfo> radarInfoClass;
	local ClientSideCharacter.ClientObjectiveInfo nextObjective;

	super.UpdateData(c);

	// add the objectives
	for(i = 0; i < c.ObjectiveData.Length; ++i)
	{
		nextObjective = c.ObjectiveData[i]; 

		// only add objectives with the same type as the mask
		if(typeMask == nextObjective.type)
		{
			radarInfoClass = class<RadarInfo>(nextObjective.RadarInfoClass);
			SetObjective(nextObjective.Status, radarInfoClass, nextObjective.Description, listIndex++, nextObjective.State, nextObjective.IsFriendly, nextObjective.bFlashing, nextObjective.TeamInfoClass);
		}
	}

	// have to dump any objectives which are remaining in the list:
	for(i = textList.children.Length - 1; i >= listIndex; --i)
		RemoveObjective(i);

	bVisible = (textList.children.Length > 0);
}

defaultproperties
{
	completedDrawColor=(R=135,G=135,B=135,A=255)
	failedDrawColor=(R=255,G=0,B=0,A=255)
	activeDrawColor=(R=255,G=255,B=255,A=255)

	completedObjectiveIconOverlay=(Material=texture'HUD.Radar',Coords=(U=49,V=218,UL=22,VL=22),style=1,drawColor=(R=0,G=255,B=0,A=255))

	bAutoHeight=true
}