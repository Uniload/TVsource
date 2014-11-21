class HUDObjectiveNotification extends HUDContainer;

var() config  float PulseFrequency;
var LabelElement KeyLabel;

var float LastPulseTime;
var bool bNotifyOn;

function InitElement()
{
	super.InitElement();

	KeyLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_ObjectiveNotificationLabel"));
}

function UpdateData(ClientSideCharacter c)
{
	local int i;

	super.UpdateData(c);

	if (c.ShowCommandMapKeyText == "")
	{
		bVisible = false;
		return;
	}

	bVisible = true;
	KeyLabel.SetText(c.ShowCommandMapKeyText);

	bNotifyOn = false;
	for(i = 0; i < c.ObjectiveData.Length; ++i)
	{
		if(c.ObjectiveData[i].bFlashing)
		{
			bNotifyOn = true;
			break;
		}
	}

	// pulse it
	if(bNotifyOn)
		SetAlpha(1.0 - FClamp((TimeSeconds % PulseFrequency) / PulseFrequency, 0.f, 1.f));
	else
		SetAlpha(1.0);
}

defaultproperties
{
	PulseFrequency=0.7
	bCentered = true
}