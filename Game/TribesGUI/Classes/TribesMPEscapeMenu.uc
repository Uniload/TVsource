// ====================================================================
//  Class:  TribesGui.TribesMPEscapeMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPEscapeMenu extends TribesGUIPage
     ;

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

var(TribesGui) private EditInline Config GUIButton		    ResumeGameButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DisconnectButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    OptionsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    QuitButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUITabControl		MyTabControl "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPPlayersPanel		MPPlayersPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPAdminPanel			MPAdminPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPStatsPanel			MPStatsPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPWeaponStatsPanel	MPWeaponStatsPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPGameStatsPanel		MPGameStatsPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPHintsPanel			MPHintsPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel ServerNameLabel	 "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel EmailLabel "A component of this page which has its behavior defined in the code for this page's class.";


function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    ResumeGameButton.OnClick=InternalOnClick;
    DisconnectButton.OnClick=InternalOnClick;
    OptionsButton.OnClick=InternalOnClick;
    QuitButton.OnClick=InternalOnClick;
	
	OnActivate=InternalOnActivate;
}

event HandleParameters(string Param1, string Param2, optional int param3)
{
	local int i;

	if (Param1 == "")
		return;

	// First param is name of panel to open
	for (i=0; i<MyTabControl.MyTabs.Length; i++)
	{
		if (MyTabControl.MyTabs[i].TabPanel.isA(Name(Param1)))
		{
			MyTabControl.OpenTab(MyTabControl.MyTabs[i].TabPanel);
			return;
		}
	}
}

function InternalOnActivate()
{
	// Hard code the hiding of admin panel, which is #5
	//if (PlayerOwner().PlayerReplicationInfo.bAdmin)
	//	MyTabControl.MyTabs[4].TabHeader.Show();
	//else
	//	MyTabControl.MyTabs[4].TabHeader.Hide();

	ServerNameLabel.Caption = PlayerOwner().GameReplicationInfo.ServerName;
	EmailLabel.Caption = PlayerOwner().GameReplicationinfo.AdminEmail;
}

function InternalOnClick(GUIComponent Sender)
{
	switch (Sender)
	{
		case DisconnectButton:	
            TribesGuiController(Controller).PlayerDisconnect();
			Controller.CloseAll();
			Controller.OpenMenu("TribesGui.TribesMultiplayerMenu", "TribesMultiplayerMenu");
			break;
		case ResumeGameButton:
			Controller.CloseAll();
			break;
		case OptionsButton:
			Controller.OpenMenu("TribesGui.TribesOptionsMenu", "TribesOptionsMenu", "TribesMPEscapeMenu");
			break;
		case QuitButton:
			Quit();
			break;
	}
}

function int getKeyCode(string key)
{
	local int i;

	// If it's a single character, assume we can just fetch the ascii representation
	if (Len(key) == 1)
		return Asc(Key);

	// Otherwise, do some hacky special processing to handle F-keys and TAB, which are the most likely
	// keys that useers will want to bind to the MP escape panels
	if (Left(key, 1) ~= "f")
	{
		i = int(Right(key, 1));
		return EInputKey.IK_F1 + i - 1;
	}

	if (key ~= "TAB")
		return EInputKey.IK_Tab;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local PlayerCharacterController pcc;
	local int gameStatsKey, myStatsKey, adminKey;

	pcc = PlayerCharacterController(PlayerOwner());
	gameStatsKey = getKeyCode(pcc.gameStatsKey);
	myStatsKey = getKeyCode(pcc.myStatsKey);
	adminKey = getKeyCode(pcc.adminKey);
    if( bVisible && bActiveInput && State == EInputAction.IST_Press )
    {
		switch(Key)
		{
			case EInputKey.IK_Escape:
					Controller.CloseAll();
					return true;

			// michaelj:  Moved closing to PCC so it's not hard-coded
			case gameStatsKey:
				if (MyTabControl.ActiveTab.TabPanel == MPPlayersPanel)
					Controller.CloseAll();
				else
					MyTabControl.OpenTab(MPPlayersPanel);
				return true;

			case myStatsKey:
				if (MyTabControl.ActiveTab.TabPanel == MPStatsPanel)
					Controller.CloseAll();
				else
					MyTabControl.OpenTab(MPStatsPanel);
				return true;

			case adminKey:
				if (MyTabControl.ActiveTab.TabPanel == MPAdminPanel)
					Controller.CloseAll();
				else
					MyTabControl.OpenTab(MPAdminPanel);
				return true;
		}

		//MyTabControl.OpenTab(MyTabControl.MyTabs[i].TabPanel);
    }

    return Super.InternalOnKeyEvent(Key, State, delta);
}

defaultproperties
{
	OnKeyEvent=InternalOnKeyEvent
}
