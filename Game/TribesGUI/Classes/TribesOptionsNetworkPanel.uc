// ====================================================================
//  Class:  TribesGui.TribesOptionsNetworkPanel
//
// ====================================================================

class TribesOptionsNetworkPanel extends TribesSettingsPanel;

var(TribesGui) private EditInline Config GUIComboBox ConnectionSpeedBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton DynamicNetspeedCheckBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton DefaultsButton "A component of this page which has its behavior defined in the code for this page's class.";

var int iNetSpeed;
var localized array<String> ConnectionStrings;

function InitComponent(GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyOwner);

	OnShow=InternalOnShow;
	OnHide=InternalOnHide;
	ConnectionSpeedBox.OnChange=OnConnectionSpeedChange;

	// Populate connection speed dropdown
	for (i=0; i<ConnectionStrings.Length; i++)
	{
		ConnectionSpeedBox.AddItem(ConnectionStrings[i]);
	}
}

function InternalOnShow()
{
	DefaultsButton.bCanBeShown = true;
	DefaultsButton.Show();

	DefaultsButton.OnClick=OnDefaultsClick;
	Refresh();
}

function InternalOnHide()
{
	SaveSettings();
}

function Refresh()
{
	local int i;

    if ( PlayerOwner().Player != None )
        i = PlayerOwner().Player.ConfiguredInternetSpeed;
    else i = class'Player'.default.ConfiguredInternetSpeed;

	// Set these values according to UT2004
    if (i <= 2600)
        iNetSpeed = 0;

    else if (i <= 5000)
        iNetSpeed = 1;

    else if (i <= 10000)
        iNetSpeed = 2;

    else iNetSpeed = 3;

    ConnectionSpeedBox.SetIndex(iNetSpeed);

	DynamicNetspeedCheckbox.bChecked = PlayerOwner().bDynamicNetSpeed;
}

function SaveSettings()
{
	local PlayerController PC;

	PC = PlayerOwner();

	// Save net speed
	if ( PC.Player != None )
	{
		switch (iNetSpeed)
		{
			case 0: PC.Player.ConfiguredInternetSpeed = 2600; break;
			case 1: PC.Player.ConfiguredInternetSpeed = 5000; break;
			case 2: PC.Player.ConfiguredInternetSpeed = 10000; break;
			case 3: PC.Player.ConfiguredInternetSpeed = 20000; break;
		}

		PC.Player.SaveConfig();
	}

	else
	{
		switch (iNetSpeed)
		{
			case 0: class'Player'.default.ConfiguredInternetSpeed = 2600; break;
			case 1: class'Player'.default.ConfiguredInternetSpeed = 5000; break;
			case 2: class'Player'.default.ConfiguredInternetSpeed = 10000; break;
			case 3: class'Player'.default.ConfiguredInternetSpeed = 20000; break;
		}

		class'Player'.static.StaticSaveConfig();
	}

	// Save dynamic net setting
	PC.bDynamicNetSpeed = DynamicNetspeedCheckBox.bChecked;
	PC.SaveConfig();
}

function OnConnectionSpeedChange(GUIComponent Sender)
{
	iNetSpeed = ConnectionSpeedBox.GetIndex();
}

function OnDefaultsClick(GUIComponent Sender)
{
    class'Engine.Player'.static.ResetConfig("ConfiguredInternetSpeed");
    PlayerOwner().ResetConfig("bDynamicNetSpeed");
	Refresh();
}

defaultproperties
{
	ConnectionStrings(0)	= "Modem"
	ConnectionStrings(1)	= "ISDN"
	ConnectionStrings(2)	= "Cable/ADSL"
	ConnectionStrings(3)	= "LAN/T1"
}
