//====================================================================
//  This class implements the "Status" window of the UT2004 IRC client
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class TribesIRCSystem extends TribesIRCPage;

var   array<TribesIRCChannel>		Channels;

var         string              LinkClassName;
var			TribesIRCLink        Link;

var(TribesGui) private EditInline Config         TribesMPCommunityPanel   tp_Main;
var(TribesGui) private EditInline Config			TribesIRCPanel        p_IRC;

var			string				TestIRCString, LastServer;
var 		int 				CurChannel, PrevChannel;
var	private bool                bConnected, bAway,
								bSysInitialized;

var   config       string       NewNickMenu;
var() globalconfig string		OldPlayerName, NickName,
								FullName, UserIdent, DefaultChannel;
var	  config       string       ChanKeyMenu;

var localized string 			NotInAChannelText;
var localized string 			KickedFromText;
var localized string 			ByText;
var localized string 			IsAwayText;
var localized string            ChooseNewNickText;
var localized string            NickInUseText;
var localized string            NickInvalidText;
var localized string 	        LeavePrivateText;
var localized string            CloseWindowCaption;
var localized string            DisconnectCaption;
var localized string            ChangeNickCaption;
var localized string            InvalidModeText, InvalidKickText;
var localized string			NewNickString;

var enum EAwayMode
{
	AM_None,
	AM_Server,
	AM_InstantAction,
	AM_Menus
}   AwayMode;

delegate OnConnect();
delegate OnDisconnect();
delegate NewChannelSelected( int CurrentChannel );

// GUI functions
function InitComponent(GUIComponent MyOwner)
{
	local GUIComponent C;

	Super.InitComponent(MyOwner);

	//sp_Main.bDrawSplitter = false; // Dont draw this splitter
	//p_IRC.UpdateConnectionStatus( IsConnected() );

	for ( C = MenuOwner; C != None; C = C.MenuOwner )
	{
		if ( TribesMPCommunityPanel(C) != None )
		{
			tp_Main = TribesMPCommunityPanel(C);
			//Log("IRC:  "$self$" set tp_Main to "$tp_Main);
			break;
		}
	}

	Assert(tp_Main != None);
}

function bool CanShowPanel()
{
// MJ: No concept of menu init in our GUI system
	return true;
//	return Controller.bCurMenuInitialized;
}

function ShowPanel(bool bShow)
{
// MJ:  We don't have ShowPanel
//	Super.ShowPanel(bShow);

	//if ( bShow )
	//{
	//	if ( bInit )
	//		sp_Main.SplitterUpdatePositions();

	//	bInit = False;
	//}
}

event Timer()
{
	// michaelj:  Hack?  Not needed (it was setting your nickname to Player)
	//if(bConnected && PlayerOwner() != None && PlayerOwner().PlayerReplicationInfo != None && PlayerOwner().PlayerReplicationInfo.PlayerName != OldPlayerName)
	//{
	//	OldPlayerName = PlayerOwner().PlayerReplicationInfo.PlayerName;
	//	Link.SetNick(OldPlayerName);
	//	SystemText("SetNick: "$OldPlayerName);
	//}
}

// Whether the 'close window/leave channel' button is available
function bool LeaveAvailable( out string ButtonCaption )
{
	if ( !ValidChannelIndex(CurChannel) )
	{
		ButtonCaption = CloseWindowCaption;
		return false;
	}
	else if ( Channels[CurChannel].IsPrivate )
	{
		ButtonCaption = Repl(LeavePrivateText, "%ChanName%", GetCurrentChannelName());
		return true;
	}
	else
	{
		ButtonCaption = CloseWindowCaption;
		return true;
	}
}

// whether the 'disconnect' button is available
function bool DisconnectAvailable( out string ButtonCaption )
{
	ButtonCaption = DisconnectCaption;
	return IsConnected();
}

// Whether the 'set nick' button is available
function bool SetNickAvailable( out string ButtonCaption )
{
	ButtonCaption = ChangeNickCaption;
	return true;
}

// =====================================================================================================================
// =====================================================================================================================
//  Local Player
// =====================================================================================================================
// =====================================================================================================================

function bool InGame()
{
	return !Controller.bActive;
}

function bool InMenus()
{
	if ( InGame() )
		return false;

	//if (UT2K4ServerBrowser(Controller.ActivePage) != None &&
	//	UT2K4ServerBrowser(Controller.ActivePage).c_Tabs != None &&
	//	UT2K4ServerBrowser(Controller.ActivePage).c_Tabs.ActiveTab != None &&
	//	UT2K4Browser_IRC(UT2K4ServerBrowser(Controller.ActivePage).c_Tabs.ActiveTab.MyPanel) != None)
		return false;

	return true;
}


function UpdateIdent()
{
	local int i;

	if(UserIdent == "")
	{
		UserIdent = "u";
		for(i=0;i<7;i++)
			UserIdent = UserIdent $ Chr((Rand(10)+48));

		Log("Created new UserIdent: "$UserIdent,'IRC');
		SaveConfig();
	}
}

function bool IsMe( string Test )
{
	return Test ~= NickName;
}

function bool IsConnected()
{
	return bConnected && Link != None;
}

function bool IsAway()
{
	return bAway;
}

function NotifyQuitUnreal() // !! todo hook this up?
{
	CloseLink(Link,False,"Exit Game");
}

function ChangeConnectStatus( bool NewStatus )
{
	bConnected = NewStatus;
	//p_IRC.UpdateConnectionStatus( bConnected );
//	tp_Main.CheckRefreshButton(bConnected);
}

function ChangeAwayStatus( bool NewStatus )
{
	local string URL;

	bAway = NewStatus;
	if ( PlayerOwner() == None || PlayerOwner().Level == None )
		return;

	if ( IsConnected() )
	{
		if ( IsAway() )
		{
			URL = PlayerOwner().Level.GetAddressURL();
			if( InStr(URL, ":") > 0 && (AwayMode != AM_Server || LastServer != URL) )
			{
				LastServer = URL;
				Link.SetAway( PlayerOwner().GetURLProtocol()$"://"$URL );
				AwayMode = AM_Server;
			}

			else if( InGame() && AwayMode != AM_InstantAction )
			{
				AwayMode = AM_InstantAction;
				Link.SetAway("local game");
			}

			else if ( AwayMode != AM_Menus )
			{
				Link.SetAway("in menus");
				AwayMode = AM_Menus;
			}
		}

		else if ( AwayMode != AM_None )
		{
			Link.SetAway("");
			AwayMode = AM_None;
		}
	}
}

function NewNickPageClosed( bool bCancelled )
{
	local string NewNick;

	if ( !bCancelled )
	{
//		NewNick = Controller.ActivePage.GetDataString();
		if ( NewNick != "" )
		{
			if ( Link != None )
				Link.SetNick( NewNick );

			else ChangedNick(NickName, NewNick);
		}
	}
}

function ChanKeyPageClosed( bool bCancelled )
{
	local string JoinReq;
	if ( !bCancelled )
	{
//		JoinReq = Controller.ActivePage.GetDataString();
		if ( JoinReq != "" )
		{
			if ( Link != None )	Link.JoinChannel(JoinReq);
		}
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Commands
// =====================================================================================================================
// =====================================================================================================================

function bool Connect(string NewServer)
{
	local PlayerController PC;
	local TribesIRCLink NewLink;
	local PlayerProfile p;

    PC = PlayerOwner();

    if (NewServer == "")
    	return false;

	NewLink = CreateNewLink();
	if ( NewLink == None )
		return false;

//    if( PC.PlayerReplicationInfo != None )
//    {
//	    if( PC.PlayerReplicationInfo.PlayerName != OldPlayerName)
//	    {
//		    NickName = PC.PlayerReplicationInfo.PlayerName;

	// michaelj:  Use active Tribes profile name
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();
	NickName = p.playerName;
	OldPlayerName = NickName;
	if( FullName == "" )
		FullName = NickName;
	SaveConfig();
  //	}
  //  }
  //  else
  //  {
  //      NickName = PC.GetUrlOption( "Name" );
		//OldPlayerName = NickName;
		//if(FullName == "")
		//	FullName = NickName;
		//SaveConfig();
  //  }

	UpdateIdent();

	// Implement perform buffer here - use delegate OnConnect()
	NewLink.Connect( Self, NewServer, NickName, UserIdent, FullName, GetDefaultChannel() );
	ChangeConnectStatus( True );

	SetTimer( 1.0, True );
	return true;
}

function Disconnect()
{
	CloseLink(Link,False);
}

function CloseLink( TribesIRCLink OldLink, bool bSwitchingServers, optional string Reason )
{
	local string ServerName;

	ServerName = OldLink.ServerAddress;

	if ( Reason == "" )
		Reason = "Disconnected";

	if ( Link != None )
	{
		if ( Link != OldLink )
		{
			OldLink.DestroyLink();
			return;
		}

		Link.DisconnectReason = Reason;
		Link.DestroyLink();
	}

	Link = None;

	Channels.Remove(0, Channels.Length);
	OnDisconnect();

	SystemText( "Disconnected from server"@ServerName );
	ChangeConnectStatus( bSwitchingServers );

	// Make system tab active (if not already)
	SetCurrentChannel(-1);
	KillTimer();
}

function ProcessInput(string Text)
{
	local int i;

    if( CurChannel > -1 )
        Channels[CurChannel].ProcessInput(Text);

    else
    {
	    if(Left(Text, 1) != "/")
		    SystemText("*** "$NotInAChannelText);

	    else
		{
			Text = Mid(Text,1);

			if ( Left(Text, 7) ~= "connect" || Left(Text,6) ~= "server" )
			{
				i = InStr(Text, " ");
				if ( i != -1 )
					Connect( Mid(Text,i+1) );
			}

			else if ( Left(Text,4) ~= "echo" )
			{
				i = InStr(Text, " ");
				if ( i != -1 )
					SystemText( Mid(Text,i+1) );
			}

			else if (Link != None)
				Link.SendCommandText(Text);
		}
    }
}

function JoinChannel(string ChannelName)
{
	local TribesIRCChannel P;

	P = FindChannelWindow(ChannelName);

	if(P == None)
		Link.JoinChannel(ChannelName);
	else
        SetCurrentChannel(FindPublicChannelIndex(ChannelName));
}

// Leave the currently active channel
function PartCurrentChannel()
{
	//log("Attempting to part current channel:"$CurChannel@Channels[CurChannel].ChannelName);
	if ( !ValidChannelIndex(CurChannel) )
		return;

	PartChannel(Channels[CurChannel].ChannelName);
}

function PartChannel(string ChannelName)
{
	local TribesIRCChannel P;

	P = FindChannelWindow(ChannelName, True);
	if( P != None )
	{
		if ( P.IsPrivate )
			RemoveChannel(ChannelName);
		else Link.PartChannel(ChannelName);
	}
}

function ChangeCurrentNick()
{
	//if ( Controller.OpenMenu(NewNickMenu, ChooseNewNickText, NickName) )
	//	Controller.ActivePage.OnClose = NewNickPageClosed;
}

function Whois( string Nick )
{
	if ( Link == None )
		return;

	Link.SendCommandText( "WHOIS" @ Nick );
}

function Op( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "o", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), True, Nick );
}

function Deop( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "o", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), False, Nick );
}

function Voice( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "v", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), True, Nick );
}

function DeVoice( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "v", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), False, Nick );
}

function Help( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "h", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), True, Nick );
}

function DeHelp( string Nick, string ChannelName )
{
	if ( Link == None )
		return;

	SetMode( "h", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), False, Nick );
}

function Kick( string Nick, string ChannelName, optional string Reason )
{
	if ( Link == None )
	{
		SystemText(NotInAChannelText);
		return;
	}

	if ( Nick == "" || ChannelName == "" )
	{
		SystemText(Repl(InvalidKickText, "%Cmd%", "KICK"));
		return;
	}

	Link.SendCommandText( "KICK" @ Nick $ Eval(Reason != "", " :" $ Reason, "") );
}

function Ban( string Nick, string ChannelName, optional string Reason )
{
	SetMode( "b", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), True, Nick );
	Kick(Nick, ChannelName, Reason);
}

function Unban( string Nick, string ChannelName )
{
	SetMode( "b", Eval(Left(ChannelName,1) == "#", ChannelName, "#" $ ChannelName), False, Nick );
}

function SetMode( string Modes, string Target, bool On, optional string Extra )
{
	if ( Link == None )
	{
		SystemText(NotInAChannelText);
		return;
	}

	if ( Modes == "" || Target == "" )
	{
		SystemText(InvalidModeText);
		return;
	}

	if ( Link != None )
		Link.SendCommandText( "MODE" @ Target @ Eval(On, "+", "-") $ Modes $ Eval(Extra != "", " " $ Extra, "") );
}

// =====================================================================================================================
// =====================================================================================================================
//  Events
// =====================================================================================================================
// =====================================================================================================================

function SystemText(string Text)
{
	// FIXME!! should do something better with this
	if(Text != "You have been marked as being away" && Text != "You are no longer marked as being away")
	{
		InterpretColorCodes(Text);
        lb_TextDisplay.AddText( MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

		//if(!MyButton.bActive)
		//	MyButton.bForceFlash = true;
	}
}

function ChannelText(string Channel, string Nick, string Text)
{
	local TribesIRCChannel P;

	P = FindChannelWindow(Channel);
	if(P != None)
		P.ChannelText(Nick, Text);
}

function PrivateText(string Nick, string Text)
{
    FindPrivateWindow(Nick).PrivateText(Nick, Text);
}

function ChannelAction(string Channel, string Nick, string Text)
{
	local TribesIRCChannel P;

	P = FindChannelWindow(Channel);
	if(P != None)
		P.ChannelAction(Nick, Text);
}

function PrivateAction(string Nick, string Text)
{
    FindPrivateWindow(Nick).PrivateAction(Nick, Text);
}

function JoinedChannel(string Channel, optional string Nick)
{
	local TribesIRCChannel NewCh;
	local TribesIRCChannel W;

    log(Nick@"JoinedChannel "$Channel,'IRC');

	if(Nick == "")	// We joined a new channel
	{
		NewCh = AddChannel( Channel );
		if ( NewCh != None )
	        SetCurrentChannelPage(NewCh);
	}

	if(Nick == "")
		Nick = NickName;

	W = FindChannelWindow(Channel);
	Log("FindChannelWindow = "$W);
	if(W != None)
		W.JoinedChannel(Nick);
}

function PartedChannel(string Channel, optional string Nick)
{
	local TribesIRCChannel W;

	W = FindChannelWindow(Channel);

	if(Nick == "")
	{
        RemoveChannel(Channel);
	}
	else
	{
		if(W != None)
			W.PartedChannel(Nick);
	}
}

function KickUser(string Channel, string KickedNick, string Kicker, string Reason)
{
	local TribesIRCChannel W;
	local string S;

	W = FindChannelWindow(Channel);

	if(KickedNick == NickName)
	{
        RemoveChannel(Channel);
		S = repl(KickedFromText, "%channel%", Channel);
		S = repl(S, "%kicker%", Kicker) $" ("$Reason$")";
		SystemText("*** "$S);
	}
	else
	{
		if(W != None)
			W.KickUser(KickedNick, Kicker, Reason);
	}
}

function UserInChannel(string Channel, string Nick)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.UserInChannel(Nick);
}

function NotifyNickInUse()
{
	// If we dont have it up already..
	if ( TribesIRCNewNick(Controller.ActivePage) == None )
	{
		//if ( Controller.OpenMenu( NewNickMenu, NickInUseText, NickName ) )
		//	Controller.ActivePage.OnClose = NewNickPageClosed;
	}
}

function NotifyInvalidNick()
{
	// If we dont have it up already..
	if ( TribesIRCNewNick(Controller.ActivePage) == None )
	{
		//if ( Controller.OpenMenu( NewNickMenu, NickInvalidText, NickName ) )
		//	Controller.ActivePage.OnClose = NewNickPageClosed;
	}
}

function NotifyChannelKey(string chan)
{
	// If we dont have it up already..
	if ( TribesIRCChanKey(Controller.ActivePage) == None )
	{
		//if ( Controller.OpenMenu( ChanKeyMenu, chan ) )
		//	Controller.ActivePage.OnClose = ChanKeyPageClosed;
	}
}

function ChangedNick(string OldNick, string NewNick)
{
    local int i;

	if(OldNick == NickName)
	{
		NickName = NewNick;

		if ( Link != None )
			Link.NickName = NewNick;

		SaveConfig();
	}
	SystemText(NewNickString@NewNick);

    for( i = 0; i < Channels.Length; i++ )
        if( Channels[i].FindNick(OldNick) )
            Channels[i].ChangedNick(OldNick, NewNick);

	// If this was the active channel, then change the 'close window' caption
	if ( GetCurrentChannelName() ~= NewNick )
		tp_Main.SetCloseCaption(NewNick);
}

function UserQuit(string Nick, string Reason)
{
    local int i;

    for( i = 0; i < Channels.Length; i++ )
        if( Channels[i].FindNick(Nick) )
            Channels[i].UserQuit(Nick, Reason);
}

function UserNotice(string Nick, string Text)
{
    local int i;

    for( i = 0; i < Channels.Length; i++ )
        if( Channels[i].FindNick(Nick) )
            Channels[i].UserNotice(Nick, Text);
}

function ChangeMode(string Channel, string Nick, string Mode)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeMode(Nick, Mode);
}

function ChangeOp(string Channel, string Nick, bool bOp)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeOp(Nick, bOp);
}

function ChangeHalfOp(string Channel, string Nick, bool bHalfOp)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeHalfOp(Nick, bHalfOp);
}

function ChangeVoice(string Channel, string Nick, bool bVoice)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
		W.ChangeVoice(Nick, bVoice);
}

function ChangeTopic(string Channel, string NewTopic)
{
	local TribesIRCChannel W;
	W = FindChannelWindow(Channel);
	if(W != None)
	{
		Log("Topic (Channel: "$Channel$") : "$NewTopic,'IRC');
		W.ChangeTopic(NewTopic);
	}
}

function CTCP(string Channel, string Nick, string Message)
{
	if(Channel == "" || Channel == NickName)
		SystemText("["$Nick$": "$Message$"]");
	else
		SystemText("["$Nick$":"$Channel$" "$Message$"]");
}

// =====================================================================================================================
// =====================================================================================================================
//  Channel Interface
// =====================================================================================================================
// =====================================================================================================================
function TribesIRCPage GetCurrentChannel()
{
    if( CurChannel != -1 )
        return Channels[CurChannel];

    return self;
}

function string GetCurrentChannelName()
{
	// MJ HACK:  return defaultChannel's name for now
	//return tp_Main.defaultChannel.ChannelName;

	if (CurChannel != -1)
		return Channels[CurChannel].ChannelName;

	return "";
}

function string GetDefaultChannel()
{
	//Log("Returning DefaultChannel "$DefaultChannel);
	return DefaultChannel;
}

function TribesIRCChannel FindChannelWindow(string Channel, optional bool bIncludePrivate)
{
    local int i;

	// MJ HACK:  return defaultChannel for now
	//return tp_Main.defaultChannel;

	i = FindPublicChannelIndex(Channel,bIncludePrivate);
	if ( i != -1 )
		return Channels[i];

	return None;
}

function TribesIRCPrivate FindPrivateWindow(string Nick)
{
    local int i;

	i = FindPrivateChannelIndex(Nick);
	if ( i != -1 )
  		return TribesIRCPrivate(Channels[i]);

	return TribesIRCPrivate(AddChannel(Nick,True));
}

function int FindPublicChannelIndex( string ChannelName, optional bool bIncludePrivate )
{
	local int i;

    for( i = 0; i < Channels.Length; i++ )
    {
    	if ( Channels[i].ChannelName ~= ChannelName )
    	{
    		if ( !Channels[i].IsPrivate || bIncludePrivate )
   				return i;
    	}
    }

    return -1;
}

function int FindPrivateChannelIndex( string ChannelName )
{
	local int i;

	for ( i = 0; i < Channels.Length; i++ )
		if ( Channels[i].IsPrivate && ChannelName ~= Channels[i].ChannelName )
			return i;

	return -1;
}


function SetCurrentChannelPage( TribesIRCChannel ChannelPage )
{
	local int i;

	for( i = 0; i < Channels.Length; i++)
	{
		if(Channels[i] == ChannelPage)
		{
			SetCurrentChannel(i);
			return;
		}
	}
}

function SetCurrentChannel( int idx )
{
	if ( idx == CurChannel )
		return;

	idx = Clamp( idx, -1, Channels.Length - 1 );

	// Make the current channel the active tab (if its not already).
	NewChannelSelected( idx );
	UpdateCurrentChannel( idx );
}

function UpdateCurrentChannel( int NewCurrent )
{
	//Log("UpdateCurrentChannel called with new index "$NewCurrent);
    PrevChannel = CurChannel;
    CurChannel = NewCurrent;

    //if ( !ValidChannelIndex(CurChannel) || !Channels[CurChannel].IsPrivate )
    //	tp_Main.SetCloseCaption();
    //else tp_Main.SetCloseCaption(GetCurrentChannelName());

	if (CurChannel >= 0)
		Channels[CurChannel].ed_TextEntry.Focus();
	tp_Main.leaveButton.SetEnabled(NewCurrent >= 0);
}

// =====================================================================================================================
// =====================================================================================================================
//  Query / Utility / Internal
// =====================================================================================================================
// =====================================================================================================================

// Update the clients 'away' string
function UpdateAway()
{
	if( IsConnected() )
	{
		if( InGame() || InMenus() )
			ChangeAwayStatus(True);

		else if ( IsAway() )
			ChangeAwayStatus(False);
	}
}

function PrintAwayMessage(string Nick, string Message)
{
	local TribesIRCPrivate W;

	W = FindPrivateWindow(Nick);

	if(W != None)
		W.PrintAwayMessage(Nick, Message);
	else
		SystemText(repl(IsAwayText, "%name%", Nick) $ ": " $ Message);
}

function IRCClosed()
{
	UpdateAway();
}

protected function TribesIRCLink CreateNewLink()
{
	local class<TribesIRCLink> NewLinkClass;
	local TribesIRCLink NewLink;

	if ( PlayerOwner() == None )
		return None;

	if ( LinkClassName != "" )
		NewLinkClass = class<TribesIRCLink>(DynamicLoadObject( LinkClassName, class'Class'));

	if ( NewLinkClass != None )
	    NewLink = PlayerOwner().Spawn( NewLinkClass );

    return NewLink;
}

function TribesIRCChannel AddChannel( string ChannelName, optional bool bPrivate, optional bool bActivate )
{
	local TribesIRCChannel NewCh;

	NewCh = tp_Main.AddChannel( ChannelName, bPrivate );
	if ( NewCh != None )
	{
		NewCh.tp_System = self;

        NewCh.IsPrivate = bPrivate;
        NewCh.ChannelName = ChannelName;

        Channels[Channels.Length] = NewCh;
        if ( bActivate )
        	SetCurrentChannel( Channels.Length - 1 );
    }

    return NewCh;
}

function bool RemoveChannelAt( int Index )
{
	if ( !ValidChannelIndex(Index) )
		return false;

	if ( Index == CurChannel )
		SetCurrentChannel(PrevChannel);    // Set current channel to previous channel

	tp_Main.RemoveChannel( Channels[Index].ChannelName );
	Channels.Remove(Index,1);          // remove from channels list

	return true;
}

function RemoveChannel( string Channel )
{
    local int i;

	// Find channel in channel array
	i = FindPublicChannelIndex(Channel,True);
	if ( i != -1 )
		RemoveChannelAt(i);
}

function bool ValidChannelIndex(int Index)
{
	if ( Index < 0 || Index >= Channels.Length )
		return false;

	return true;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( TribesIRCPanel(NewComp) != None )
		p_IRC = TribesIRCPanel(NewComp);

	Super.InternalOnCreateComponent(NewComp, Sender);
}

defaultproperties
{
    // Splitter to divide main window in two: chat window & entry box
    //Begin Object Class=GUISplitter Name=SplitterA
    //    WinWidth=1.0
    //    WinHeight=0.95
    //    WinTop=0
    //    WinLeft=0
    //    //OnCreateComponent=InternalOnCreateComponent
    //    DefaultPanels(0)="XInterface.GUIScrollTextBox"
    //    DefaultPanels(1)="TribesGUI.TribesIRCPanel"
    //    SplitOrientation=SPLIT_Vertical
    //    SplitPosition=0.8
    //    bFixedSplitter=true
    //    TabOrder=1
    //End Object
    //sp_Main=SplitterA

    MainSplitterPosition=0.5
	NotInAChannelText="Not in a channel!"
	KickedFromText="You were kicked from %channel% by %kicker%"
	InvalidModeText="Invalid parameters for MODE - Syntax: /MODE [#]target [[+|-]modes [Extra Params]]"
	InvalidKickText="Invalid parameters for %Cmd% - Syntax: /%Cmd% #ChannelName Nick :[Reason]"
	ChooseNewNickText="Choose A New IRC Nickname"
	NickInUseText="Nickname Already In Use"
	NickInvalidText="Nickname Is Invalid"
	NewNickMenu="TribesGUI.TribesIRCNewNick"
	ChanKeyMenu="TribesGUI.TribesIRCChanKey"

	ByText="by"
	IsAwayText="%name% is away"
    CurChannel=-2
    PrevChannel=-1

	LinkClassName="TribesGUI.TribesIRCLink"
	LeavePrivateText="CLOSE %ChanName% "
	ChangeNickCaption="CHANGE NICK"
	CloseWindowCaption="LEAVE CHANNEL"
	DisconnectCaption="DISCONNECT"

	DefaultChannel="#tribes"
	NewNickString="* Your nick is now"
}

