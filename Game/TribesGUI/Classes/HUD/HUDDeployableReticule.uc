//
// class: HUDDeployableReticule
//
// Reticule that indicates whether a deployable can be placed or not.
//
class HUDDeployableReticule extends HUDReticule;

import enum eDeployableInfo from Gameplay.Deployable;

var localized string textTooFar;
var localized string textBadSurface;
var localized string textBlocked;
var localized string textSameTypeTooNear;
var localized string textInvalidTargetObject;

var LabelElement	infoLabel;
var float			lastUseTime;
var float			labelHideTime;

function InitElement()
{
	super.InitElement();

	infoLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_deployable_reticuleInfoLabel"));
}

function UpdateReticule(ClientSideCharacter c)
{
	if (!c.bDeployableActive || c.deployable == None || c.bZoomed)
	{
		bVisible = false;
		return;
	}

	bVisible = true;

	if (c.deployableState == DeployableInfo_Ok)
	{
		reticuleMaterial.material = c.deployable.default.hudReticuleOk;
		retWidth = c.deployable.default.hudReticuleOkWidth;
		retHeight = c.deployable.default.hudReticuleOkHeight;
		hotspotX = c.deployable.default.hudReticuleOkCenterX;
		hotspotY = c.deployable.default.hudReticuleOkCenterY;
	}
	else
	{
		reticuleMaterial.material = c.deployable.default.hudReticuleBad;
		retWidth = c.deployable.default.hudReticuleBadWidth;
		retHeight = c.deployable.default.hudReticuleBadHeight;
		hotspotX = c.deployable.default.hudReticuleBadCenterX;
		hotspotY = c.deployable.default.hudReticuleBadCenterY;
	}

	if (lastUseTime != c.deployableUseTime)
	{
		lastUseTime = c.deployableUseTime;
		labelHideTime = c.levelTimeSeconds + 3;
		switch (c.deployableState)
		{
		case DeployableInfo_Ok:
			infoLabel.SetText("");
			break;
		case DeployableInfo_TooFar:
			infoLabel.SetText(textTooFar);
			break;
		case DeployableInfo_NoSurface:
			infoLabel.SetText(textBadSurface);
			break;
		case DeployableInfo_SameTypeTooNear:
			infoLabel.SetText(textSameTypeTooNear);
			break;
		case DeployableInfo_InvalidTargetObject:
			infoLabel.SetText(textInvalidTargetObject);
			break;
		default:
			infoLabel.SetText(textBlocked);
		}
	}

	infoLabel.bVisible = c.levelTimeSeconds < labelHideTime;
}

defaultproperties
{
	textTooFar = "The deployment point is too far away."
	textBadSurface = "You must deploy this item on a flat surface."
	textBlocked = "The deployment point is blocked."
	textSameTypeTooNear = "The deployment point is too close to another deployable of the same type."
	textInvalidTargetObject = "You cannot deploy on that object."
}