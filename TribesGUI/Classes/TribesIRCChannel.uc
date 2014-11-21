//====================================================================
//  IRC_Channel's handle all communication between the IRC_Link and
//  an IRC channel
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class TribesIRCChannel extends TribesIRCPage;

var(TribesGui) EditInline Config  TribesIRCSystem tp_System;
var string      ChannelName, ChannelTopic, DefaultListClass;

var localized string OpUserText, HelpUserText, VoiceUserText, ReasonText, MessageUserText, WhoisUserText,
                     DeopUserText, DehelpUserText, DevoiceUserText, KickUserText;

var bool    IsPrivate; // ChannelName will ~= Remote's Nick in this case

var(TribesGui) EditInline Config  GUIListBox  lb_User;

// =====================================================================================================================
//  Commands
// =====================================================================================================================

function ProcessInput(string Text)
{
    if(Left(Text, 4) ~= "/me ")
    {
        ChannelAction(tp_System.NickName, Mid(Text, 4));
        tp_System.Link.SendChannelAction(ChannelName, Mid(Text, 4));
    }
    else if(Left(Text, 1) == "/")
    {
        tp_System.Link.SendCommandText(Mid(Text, 1));
    }
    else
    {
        if(Text != "")
        {
            ChannelText(tp_System.NickName, Text);

            if ( Left(ChannelName,1) != "#" )
            	ChannelName = "#" $ ChannelName;

            tp_System.Link.SendChannelText(ChannelName, Text);
        }
    }
}

function Whois( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Whois(Nick);
}

function Op( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Op(Nick, ChannelName);
}

function Deop( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Deop(Nick, ChannelName);
}

function Voice( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Voice(Nick, ChannelName);
}

function DeVoice( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.DeVoice(Nick, ChannelName);
}

function Help( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.Help(Nick, ChannelName);
}

function DeHelp( string Nick )
{
	if ( tp_System == None )
		return;
	tp_System.DeHelp(Nick, ChannelName);
}

function Kick( string Nick, optional string Reason )
{
	if ( tp_System == None )
		return;

	tp_System.Kick(Nick, ChannelName, Reason);
}

function Ban( string Nick, optional string Reason )
{
	if ( tp_System == None )
		return;

	tp_System.Ban(Nick, ChannelName, Reason);
}

function Unban( string Nick )
{
	if ( tp_System == None )
		return;

	tp_System.Unban(Nick, ChannelName);
}


// =====================================================================================================================
//  Events
// =====================================================================================================================

function UserInChannel(string Nick)
{
    AddUser(Nick);
}

function AddUser( string Nick )
{
    local int i;

	Log("IRC:  Added user "$Nick);
    i = GetUser(Nick);
    if( i > -1 )
        return; // already in user list

    lb_User.List.Add(Nick);
	lb_User.List.bListIsDirty = true;
	lb_User.List.Sort();
}

function RemoveUser( string Nick )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return; // not in list

    lb_User.List.RemoveItem(Nick);
}

function ChangeOp( string Nick, bool NewOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "o", NewOp);
	lb_User.List.bListIsDirty = true;
    lb_User.List.Sort();
}

function ChangeHalfOp( string Nick, bool NewHalfOp )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;

    UserSetFlag(i, "h", NewHalfOp);
	lb_User.List.bListIsDirty = true;
    lb_User.List.Sort();
}

function ChangeVoice( string Nick, bool NewVoice )
{
    local int i;

    i = GetUser(Nick);
    if( i < 0 )
        return;
    UserSetFlag(i, "v", NewVoice);
	lb_User.List.bListIsDirty = true;
    lb_User.List.Sort();
}

function ChangedNick(string OldNick, string NewNick)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( NowKnownAsText, "%OldName%", OldNick );
	S = Repl( S, "%NewName%", NewNick );

    lb_TextDisplay.AddText( S );
    ChangeNick(OldNick, NewNick);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function ChangeTopic( string NewTopic )
{
    ChannelTopic = NewTopic;

	//lb_TextDisplay.AddText("*** "$newTopicText$": "$NewTopic);
	InterpretColorCodes(NewTopic);
    lb_TextDisplay.AddText( MakeColorCode(IRCInfoColor)$"*** "$NewTopicText$": "$NewTopic);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function ChannelText(string Nick, string Text)
{
	//if(MyButton.bActive && bIRCTextToSpeechEnabled)
	//	PlayerOwner().TextToSpeech( StripColorCodes(Text), 1 );

	//lb_TextDisplay.AddText("<"$Nick$"> "$Text);
	InterpretColorCodes(Text);
    lb_TextDisplay.AddText( MakeColorCode(IRCNickColor)$"<"$Nick$"> "$MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function ChannelAction(string Nick, string Text)
{
	//lb_TextDisplay.AddText("* "$Nick$" "$Text);
	InterpretColorCodes(Text);
    lb_TextDisplay.AddText( MakeColorCode(IRCActionColor)$"* "$Nick$" "$Text );

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function UserNotice(string Nick, string Text)
{
	//lb_TextDisplay.AddText(Text);
	InterpretColorCodes(Text);
    lb_TextDisplay.AddText(MakeColorCode(IRCActionColor)$"-"$Nick$"- "$Text);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function JoinedChannel(string Nick)
{
	local string S;

	Log("IRC:  JoinedChannel "$Nick);
	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( HasJoinedText, "%Name%", Nick );
	S = Repl( S, "%Chan%", ChannelName );

	InterpretColorCodes(Nick);
	lb_TextDisplay.AddText( S );
    AddUser(Nick);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function PartedChannel(string Nick)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( HasLeftText, "%Name%", Nick );
	S = Repl( S, "%Chan%", ChannelName );

	InterpretColorCodes(Nick);
    lb_TextDisplay.AddText(S);
    RemoveUser(Nick);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function KickUser(string KickedNick, string Kicker, string Reason)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( WasKickedByText, "%Kicked%", KickedNick );
	S = Repl( S, "%Kicker%", Kicker );
	S = Repl( S, "%Reason%", Reason );

	InterpretColorCodes(Reason);
    lb_TextDisplay.AddText( S );
    RemoveUser(KickedNick);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function UserQuit(string Nick, string Reason)
{
	local string S;

	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( QuitText, "%Name%", Nick );
	S = Repl( S, "%Reason%", Reason );

	InterpretColorCodes(Reason);
    lb_TextDisplay.AddText( S );
    RemoveUser(Nick);

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
    //    MyButton.bForceFlash = true;
}

function ChangeMode(string Nick, string Mode)
{
  	local string S;

	S = MakeColorCode(IRCInfoColor);
	S = S $ Repl( SetsModeText, "%Name%", Nick );
	S = Repl( S, "%Mode%", Mode );

    lb_TextDisplay.AddText( S );

	// MJ:  Our GUIPanels don't know about their associated button
    //if(!MyButton.bActive)
     //   MyButton.bForceFlash = true;
}

// =====================================================================================================================
//  Query / Utility / Internal
// =====================================================================================================================

function InitComponent(GUIComponent MyOwner)
{
    Super.InitComponent(MyOwner);

	// MJ:  Create new lb_User here since InternalOnCreateComponent doesn't get called
	lb_User = GUIListBox(AddComponent("GUI.GUIListBox", self.Name$"_GUIListBox", true ));

    if (lb_User != None)
    {
        // Set delegates for user list box
		lb_user.List.bNativeSort=false;
        lb_User.List.OnDrawItem=MyOnDrawItem;
        lb_User.List.CompareItem=MyCompareItem;
        lb_User.List.OnDblClick=MyListDblClick;
		lb_User.WinTop=0;
		lb_User.WinLeft=0.79000;
		lb_User.WinWidth=0.22500;
		lb_User.WinHeight=0.846000;
    }
}

function ShowPanel(bool bShow)
{
	// MJ:  Our GUI system doesn't have ShowPanel()
    //Super.ShowPanel(bShow);

    //if (bShow && bInit)
    //{
    //    sp_Main.SplitterUpdatePositions();
    //    bInit=False;
    //}
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIListBox(NewComp) != None)
    {
        lb_User = GUIListBox(NewComp);
        lb_User.FillOwner();
    }

    else Super.InternalOnCreateComponent(NewComp, Sender);
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
    //if (Sender == sp_Main)
    //    sp_Main.SplitPosition = MainSplitterPosition;
}

function InternalOnReleaseSplitter(GUIComponent Sender, float NewPos)
{
   // if (Sender == sp_Main)
   // {
   //     MainSplitterPosition = NewPos;
   //     SaveConfig();
    //}
}

function MyListDblClick(GUIComponent Sender)
{
    local string UserName;
    UserName = lb_User.List.Get();

    if(UserName == "")
        return;

	 // Make new channel active in this case
	tp_System.AddChannel(UserName, True, True);
    return;
}

// Sort alphabetically, but with ops first, then voice, then plebs :)
function bool MyCompareItem(GUIListElem ElemA, GUIListElem ElemB)
{
    local string s1, s2;

    // Add some extra spaces to the start of the names if they are ops or voice (to rank them towards the top)
	//Log("MyCompareItem called for "$ElemA.item$" with ExtraStrData = "$ElemA.ExtraStrData);
    if( InStr(ElemA.ExtraStrData,"o") != -1)
	{
        s1 = "   "$ElemA.item;
	}
    else if( InStr(ElemA.ExtraStrData,"h") != -1)
        s1 = "  "$ElemA.item;
    else if( InStr(ElemA.ExtraStrData,"v") != -1)
        s1 = " "$ElemA.item;
    else
        s1 = ElemA.item;

    if( InStr(ElemB.ExtraStrData,"o") != -1)
        s2 = "   "$ElemB.item;
    else if( InStr(ElemB.ExtraStrData,"h") != -1)
        s2 = "  "$ElemB.item;
    else if( InStr(ElemB.ExtraStrData,"v") != -1)
        s2 = " "$ElemB.item;
    else
        s2 = ElemB.item;

    s1 = Caps(s1);
    s2 = Caps(s2);

    // ugh.. need script strcmp
    if(s1 > s2)
        return true;
    else if(s1 < s2)
        return false;
    else
        return false;
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected)//, bool bPending)
{
    local string DrawName, NickName, Flags;
    local GUIStyles S;

	if ( lb_User.List.Style == None )
		return;

    NickName = lb_User.List.GetItemAtIndex(i);
    Flags = lb_User.List.GetExtraAtIndex(i);

    if( InStr(Flags,"o") != -1)
        DrawName = "@"$NickName;
    else if( InStr(Flags,"h") != -1)
        DrawName = "%"$NickName;
    else if( InStr(Flags,"v") != -1)
        DrawName = "+"$NickName;
    else
        DrawName = NickName;

	// MJ:  We don't have SelectedStyle
	//if ( bSelected )//&& lb_User.List.SelectedStyle != None )
	//{
		//S = lb_User.List.SelectedStyle;
	//	S.Draw( Canvas, lb_User.List.MenuState, X, Y, W, H );
	//}
	//else
		S = lb_User.List.Style;

    S.DrawText( Canvas, MSAT_Blurry, X, Y, W, H, TXTA_Left, DrawName);//, lb_User.FontScale );
}

function int GetUser( string Nick )
{
	return lb_User.List.FindIndex(Nick);
}

function string GetFlags( string NickName )
{
	local int i;

	i = GetUser(NickName);
	if ( i != -1 )
		return lb_User.List.GetExtraAtIndex(i);

	return "";
}

function bool FindNick( string Nick )
{
    if( GetUser(Nick) > -1 )
        return true;
    return false;
}

function bool UserIsOp( string NickName )
{
	return InStr(GetFlags(NickName), "o") != -1;
}

function bool UserIsHelper( string NickName )
{
	return InStr(GetFlags(NickName), "h") != -1;
}

function bool UserIsVoice( string NickName )
{
	return InStr(GetFlags(NickName), "v") != -1;
}

function ChangeNick( string OldNick, string NewNick)
{
    local int i;

    i = GetUser(OldNick);
    if( i < 0 )
        return;

    lb_User.List.SetItemAtIndex(i, NewNick);
	lb_User.List.bListIsDirty = true;
    lb_User.List.Sort();
}

function UserSetFlag(int i, string flag, bool bSet)
{
    local string flags, s;
    local int flagPos;

    flags = lb_User.List.GetExtraAtIndex(i);

	for ( s = Left(flag,1); s != ""; s = Mid(s,1) )
	{
	    if(bSet) // TURN FLAG ON
	    {
	        // If user already has flag set, do nothing.
	        if( InStr(flags, s) != -1 )
	            return;

	        // Add to end of existing flags.
	        lb_User.List.SetExtraAtIndex(i, flags$s);
	    }
	    else // TURN FLAG OFF
	    {
	        flagPos = InStr(flags, s);

	        // If flag not in flag list, do nothing;
	        if(flagPos == -1)
	            return;

	        // Remove flags from string
	        flags = Repl(flags, s, "");

	        lb_User.List.SetExtraAtIndex(i, flags);
	    }
	}
}

// =====================================================================================================================
//  Context Menu
// =====================================================================================================================

function bool ContextMenuOpen(GUI.GUIContextMenu Sender)
{
	local string SelectedNick;

	if ( Sender.ContextItems.Length > 0 )
		Sender.ContextItems.Remove(0, Sender.ContextItems.Length);

	// TODO Add code to modify items in list based on context of user's position in channel
	if ( Controller == None || Controller.ActiveControl != lb_User.List )
		return false;

	SelectedNick = lb_User.List.Get();
	if ( tp_System.IsMe(SelectedNick) )
		return false;

	AddUserContextOptions( Sender, SelectedNick );
	AddControlContextOptions( Sender, SelectedNick );

	return true;
}

function AddUserContextOptions( GUI.GUIContextMenu Menu, string Nick )
{
	Menu.AddItem( MessageUserText );
	Menu.AddItem( WhoisUserText );
}

function AddControlContextOptions( GUI.GUIContextMenu Menu, string Nick )
{
	if ( Menu == None || tp_System == None || !UserIsOp(tp_System.NickName) )
		return;

	Menu.AddItem("-");

	if ( UserIsOp(Nick) )
		Menu.AddItem(DeopUserText);
	else Menu.AddItem(OpUserText);

	if ( UserIsHelper(Nick) )
		Menu.AddItem(DehelpUserText);
	else Menu.AddItem(HelpUserText);

	if ( UserIsVoice(Nick) )
		Menu.AddItem(DevoiceUserText);
	else Menu.AddItem(VoiceUserText);

	Menu.AddItem( "-" );
	Menu.AddItem( KickUserText );
	Menu.AddItem( KickUserText $ "..." );
}

function ContextMenuClick(GUI.GUIContextMenu Sender, int ClickIndex)
{
	local int AbsIndex;
	local string Nick;

	Nick = lb_User.List.Get();

	AbsIndex = GetAbsoluteIndex(Sender, ClickIndex);
	switch ( AbsIndex )
	{
	case 0: // Msg
		tp_System.AddChannel(Nick, True, True);
		break;

	case 1:	// Whois
		Whois(Nick);
		break;

	case 2: // Op
		Op(Nick);
		break;

	case 3: // Deop
		Deop(Nick);
		break;

	case 4: // Help
		Help(Nick);
		break;

	case 5: // Dehelp
		Dehelp(Nick);
		break;

	case 6: // Voice
		Voice(Nick);
		break;

	case 7: // Devoice
		Devoice(Nick);
		break;

	case 8: // Kick
		Kick(Nick);
		break;

	case 9:	// Kick with reason
		//if ( Controller.OpenMenu(Controller.RequestDataMenu, "", ReasonText) )
		//	Controller.ActivePage.OnClose = KickReasonClose;
		break;
	}
}

function int GetAbsoluteIndex( GUI.GUIContextMenu Menu, int Index )
{
	if ( Menu == None || Index < 0 || Index >= Menu.ContextItems.Length )
		return -1;

	if ( Index == 0 || Index == 1 )
		return Index;

	if ( Menu.ContextItems[Index] == "-" )
		Index++;

	switch ( Menu.ContextItems[Index] )
	{
		case MessageUserText: return 0;
		case WhoisUserText:   return 1;
		case OpUserText:      return 2;
		case DeopUserText:    return 3;
		case HelpUserText:    return 4;
		case DehelpUserText:  return 5;
		case VoiceUserText:   return 6;
		case DevoiceUserText: return 7;
		case KickUserText:    return 8;
		case KickUserText $ "...": return 9;

		default:              return 1;
	}
}

function KickReasonClose( bool bCancelled )
{
	if ( !bCancelled )
		Kick(lb_User.List.Get(), "Kicked");//Controller.ActivePage.GetDataString());
}

defaultproperties
{
 //   Begin Object Class=GUISplitter Name=SplitterA
 //       WinWidth=1.0
 //       WinHeight=0.95
 //       WinTop=0
 //       WinLeft=0
 //       OnCreateComponent=InternalOnCreateComponent
 //       DefaultPanels(0)="GUI.GUIScrollTextBox"
 //       DefaultPanels(1)="GUI.GUIListBox"
 //       SplitOrientation=SPLIT_Horizontal
 //       SplitPosition=0.75
 //       bFixedSplitter=false
 //       IniOption="@Internal"
 //       OnLoadIni=InternalOnLoadIni
 //       OnReleaseSplitter=InternalOnReleaseSplitter
 //   End Object
 //   sp_Main=SplitterA

 //   MainSplitterPosition=0.75

 //   Begin Object Class=GUIContextMenu Name=RCMenu
 //   	OnOpen=ContextMenuOpen
 //   	OnSelect=ContextMenuClick
 //   End Object

 //   ContextMenu=RCMenu

	ReasonText="Reason: "

	MessageUserText="Open Query"
	WhoisUserText="Whois"
    OpUserText="Make Op"
    DeopUserText="Remove Op"

    HelpUserText="Make Helper"
    DeHelpUserText="Remove Helper"

    VoiceUserText="Make Voice"
    DevoiceUserText="Remove Voice"

    KickUserText="Kick User"

//  WinWidth=1.000000
//  WinHeight=0.752727
//  WinLeft=0.000000
//  WinTop=79.954597

}
