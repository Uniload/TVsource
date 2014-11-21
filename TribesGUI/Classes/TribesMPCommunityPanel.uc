// ====================================================================
//  Class:  TribesGui.TribesMPCommunityPanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPCommunityPanel extends TribesMPPanel
     ;

var(TribesGui) private EditInline Config GUIButton connectButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton disconnectButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) EditInline Config GUIButton leaveButton "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config  GUITabControl		c_Channel;

var(TribesGui) private EditInline Config  TribesIRCSystem		tp_System;
var(TribesGui) EditInline Config  TribesIRCChannel		defaultChannel;
//var() config  string	SystemPageClass, PublicChannelClass, PrivateChannelClass;
var() string	SystemPageClass, PublicChannelClass, PrivateChannelClass;

var localized string	SystemLabel;
var localized string	ChooseNewNickText;


function InitComponent(GUIComponent MyOwner)
{
	local GUIPanel NewPanel;
	local GUIButton NewButton;
	Log("IRC init: "$self);

	Super.InitComponent(MyOwner);

	connectButton.OnClick=OnConnectClicked;
	disconnectButton.OnClick=OnDisconnectClicked;
	leaveButton.OnClick=OnLeaveClicked;

	c_Channel.OnSwitch = TabChange;
	c_Channel.AddTab(SystemPageClass, Self.Name$"_Tab"$SystemLabel, "GUI.GUIButton", Self.Name$SystemLabel, NewPanel, NewButton);
	NewButton.Caption = SystemLabel;
	//TribesIRCChannel(NewPanel).MyButton = NewButton;
	Realign();
	tp_System = TribesIRCSystem(NewPanel);
	tp_System.OnDisconnect = IRCDisconnected;
	tp_System.NewChannelSelected = SetCurrentChannel;
	disconnectButton.SetEnabled(false);
	leaveButton.SetEnabled(true);
	OnShow=InternalOnShow;

	tp_System.SetCurrentChannel(-1); // Initially, System page is shown
}

function InternalOnShow()
{
	Realign();
}

function Realign()
{
    c_Channel.AlignTabs( DIRECTION_LeftToRight, true, 5, 20, 1.0, 2.0 );
}

function IRCDisconnected()
{
	local int i;

	for ( i = c_Channel.MyTabs.Length - 1; i >= 0; i-- )
		if ( c_Channel.MyTabs[i].TabPanel != None && c_Channel.MyTabs[i].TabPanel != tp_System )
			c_Channel.RemoveTab(c_Channel.MyTabs[i].TabPanel);

	disconnectButton.SetEnabled(false);
	connectButton.SetEnabled(true);
}

// MJ:  We have no Closed event?
event Closed(GUIComponent Sender, bool bCancelled)
{
	// TODO: Am I not calling Super.Closed() on purpose here?
//	Super.Closed(Sender,bCancelled);
	tp_System.IRCClosed();
}

function ShowPanel(bool bShow)
{
//	Super.ShowPanel(bShow);

//	if ( bInit && bShow )
//	{
		tp_System.SetCurrentChannel(-1); // Initially, System page is shown
//		bInit = False;
//	}
}

// Called when a new tab is activated
function bool TabChange(GUIPanel Target)
{
	local int i;
	local TribesIRCPage TabPanel;

	TabPanel = TribesIRCPage(Target);
	if ( TabPanel == none)// || !Controller.bCurMenuInitialized)
		return true;

	i = tp_System.FindPublicChannelIndex( TabPanel.MyButton.Caption, True );
	//Log("Updating current channel to index "$i);
	UpdateCurrentChannel(i);
	return false;
}

function SetCurrentChannel( int Index )
{
	local GUI.GUIButton But;
	local int i;

	if( Index == -1 )
		But = tp_System.MyButton;
	else
	{
		i = c_Channel.GetTabIndexByHeaderCaption( tp_System.Channels[Index].ChannelName );
		if ( i >= 0 && i < c_Channel.MyTabs.Length )
			But = c_Channel.MyTabs[i].TabHeader;
	}

	c_Channel.OpenTab( But );
}

function UpdateCurrentChannel( int Index )
{
//	log("UpdateCurrentChannel:"$Index);
//	CheckSpectateButton(tp_System.ValidChannelIndex(Index));
/*	if ( tp_System.ValidChannelIndex(Index) )
	{
		Chan = tp_System.Channels[Index];
		if ( Chan == None )
			return;

		// Set the text of the 'close window' button to the channel name
		if ( Chan.IsPrivate )
			SetCloseCaption( Chan.ChannelName );
		else SetCloseCaption();

		// Enable the 'close window' button
		CheckSpectateButton(True);
	}

	else
	{
		SetCloseCaption();

		// Disable the 'close window' button
		CheckSpectateButton(False);
	}
*/
	tp_System.UpdateCurrentChannel(Index);
}

function SetCloseCaption( optional string NewName )
{
	// MJ:  No idea what this is for
	//if ( NewName != "" )
	//	SetSpectateCaption( Repl(class'TribesIRCSystem'.default.LeavePrivateText, "%ChanName%", NewName) );
	//else SetSpectateCaption(class'TribesIRCSystem'.default.CloseWindowCaption);
	//RefreshFooter(None,string(!bCommonButtonWidth));
}

function TribesIRCChannel AddChannel( string ChannelName, optional bool bPrivate )
{
	local GUIPanel NewPanel;
	local GUIButton NewButton;

	//Log("IRC adding tab named "$ChannelName);
	c_Channel.AddTab(Eval( bPrivate, PrivateChannelClass, PublicChannelClass ), Self.Name$"_Tab"$ChannelName, "GUI.GUIButton", Self.Name$ChannelName, NewPanel, NewButton );
	TribesIRCChannel(NewPanel).MyButton = NewButton;
	NewButton.Caption = ChannelName;
	Realign();
	return TribesIRCChannel(NewPanel);
}

function bool RemoveChannel( string ChannelName )
{
	if ( ChannelName ~= SystemLabel || ChannelName == "" )
		return false;

	//Log("IRC removing tab named "$ChannelName);
	c_Channel.RemoveTab(ChannelName);
	Realign();
	return true;
}

//========================================================================================
//========================================================================================
// Server Browser callbacks
//========================================================================================
//========================================================================================

function JoinClicked()
{
	if ( tp_System != None )
		tp_System.ChangeCurrentNick();
}

function SpectateClicked()
{
	if ( tp_System != None )
		tp_System.PartCurrentChannel();
}

function RefreshClicked()
{
	if ( tp_System != None )
		tp_System.Disconnect();
}

// Returns whether the refresh button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsRefreshAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.DisconnectAvailable(ButtonCaption);
	return false;
}

// Returns whether the spectate button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsSpectateAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.LeaveAvailable(ButtonCaption);
}

// Returns whether the join button should be available for this panel - also gives chance to modify caption, if necessary
function bool IsJoinAvailable( out string ButtonCaption )
{
	return tp_System != None && tp_System.SetNickAvailable(ButtonCaption);
	return true;
}

function OnConnectClicked(GUIComponent Sender)
{
	tp_System.Connect( "irc.dynamix.com" );
	if( tp_System.IsConnected() )
	{
		Log("Connected!");
	}
	disconnectButton.SetEnabled(true);
	connectButton.SetEnabled(false);
}

function OnDisconnectClicked(GUIComponent Sender)
{
	tp_System.Disconnect();
	connectButton.SetEnabled(true);
	disconnectButton.SetEnabled(false);
}

function OnLeaveClicked(GUIComponent Sender)
{
	tp_System.PartCurrentChannel();
}

defaultproperties
{
	//Begin Object Class=GUITabControl Name=ChannelTabControl
	//	WinWidth=1.0
	//	WinLeft=0
	//	WinTop=0
	//	WinHeight=1
	//	TabHeight=0.04
	//	bFillSpace=False
	//	bAcceptsInput=true
	//	bDockPanels=true
	//End Object
	//c_Channel=ChannelTabControl

	SystemLabel="System"
	//PanelCaption="Tribes Internet Chat Client"
	SystemPageClass="TribesGUI.TribesIRCSystem"
	PublicChannelClass="TribesGUI.TribesIRCChannel"
	PrivateChannelClass="TribesGUI.TribesIRCPrivate"
	//bCommonButtonWidth=false
}
