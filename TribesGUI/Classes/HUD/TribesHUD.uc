class TribesHUD extends Gameplay.TribesHUDBase
	Config(TribesHUD)
	abstract;

import enum EMessageType from Gameplay.ClientSideCharacter;

var TribesHUDScript	HUDScript;
var config string	HUDScriptType;	// config
var string			HUDScriptName;

// Interaction variables
var bool			bAllowInteractions;
var bool			bAllowChat;
var HUDAction		Response;

// mouse cursor data
var config Texture	MouseCursorTexture;
var config Color	MouseCursorDrawColor;
var int				MouseX;
var int				MouseY;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetHUDScript(HUDScriptType);
	InitActionDelegates();

	clientSideChar.RadarUnderlayMaterial = Level.GetMapTexture();
	clientSideChar.mapOrigin = Level.GetMapTextureOrigin();
	clientSideChar.mapExtent = Level.GetMapTextureExtent();
}

simulated function Cleanup()
{
	CleanupActionDelegates();
}

simulated function bool NeedsKeyInput()
{
	return (bAllowInteractions || ((clientSideChar.bTalk || clientSideChar.bTeamTalk || clientSideChar.bQuickChat) && bAllowChat) || clientSideChar.bLoadoutSelection);
}

function SetHUDScript(string NewHUDScriptType)
{
	local class NewHUDClass;

	if(NewHUDScriptType != "")
	{
		HUDScriptType = NewHUDScriptType;
		NewHUDClass = class<TribesHUDScript>(DynamicLoadObject(HUDScriptType, class'class'));
		HUDScript = TribesHUDScript(new(None, HUDScriptName) NewHUDClass);
		if (HUDScript == None)
			Log("HUD ERROR:  HUDScript was None trying to set "$NewHUDScriptType);
	}
}

function HUDShown()
{
	super.HUDShown();
	HUDScript.PreShow(ClientSideChar);
}

function DrawHUD(Canvas canvas)
{
	if(HUDScript != None && ! bHideHUD)
		HUDScript.DoUpdate(canvas, Level.TimeSeconds);
}

function PostRender(Canvas canvas)
{
	super.PostRender(canvas);

	// render the mouse cursor
	if(bShowCursor)
	{
		MouseX = Clamp(MouseX, 0, canvas.SizeX);
		MouseY = Clamp(MouseY, 0, canvas.SizeY);

		if(canvas.Viewport.bWindowsMouseAvailable)
		{
			MouseX = Canvas.Viewport.WindowsMouseX;
			MouseY = Canvas.Viewport.WindowsMouseY;
		}

		canvas.bNoSmooth = True;
		canvas.DrawColor = MouseCursorDrawColor;
		canvas.Style = 2;
		canvas.SetPos(MouseX, MouseY);
		canvas.DrawIcon(MouseCursorTexture, 1.0);
		canvas.Style = 1;
	}
}

// Key events
function bool KeyType( EInputKey Key, optional string Unicode )
{
	if(HUDscript != None)
		return HUDScript.KeyType(Key, Unicode, response);

	return false;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	//
	// Grab the mouse events if the HUD wants to render a cursor
	//
	if(bShowCursor)
	{
		switch(Key)
		{
			case EInputKey.IK_MouseX:
				MouseX += Delta;
				break;
			case EinputKey.IK_MouseY:
				MouseY -= Delta;
				break;
		}
	}

	if(HUDscript != None)
		return HUDScript.KeyEvent(Key, Action, delta, response);

	return false;
}

// messaging
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local String quickChatTag, quickChatMessage;
	local ClientSideCharacter.HUDMessage NewMessage;
	local int splitIndex;
	local String PlayerNameString;
	local TribesReplicationInfo TRI;
	local class<TeamInfo> InfoClass;

	// PRI will be None if it's an announcer message
	if(PRI != None && Controller.IsMuted(PRI.PlayerName))
		return;

	if(PRI != None)
	{
		TRI = TribesReplicationInfo(PRI);
		if(TRI.team != None)
			InfoClass = TRI.team.class;
		if(HUDScript != None)
			PlayerNameString = HUDScript.EncodePlayerName(TRI.PlayerName, TRI.teamTag, clientSideChar.GetTeamAlignment(Controller, TRI), InfoClass);
		else
			PlayerNameString = TribesReplicationInfo(PRI).teamTag $ PRI.playerName;
	}

	if(MsgType == 'Subtitle')
	{
		NewMessage.Text = Msg;
		NewMessage.Type = MessageType_Subtitle;

		clientSideChar.Messages[clientSideChar.Messages.Length] = NewMessage;
	}
	else if(MsgType == 'Announcer')
	{
		Msg = ReplacePromptKeyBinds(Msg);
		clientSideChar.Announcements[clientSideChar.Announcements.Length] = Msg;
	}
	else if(! Controller.IsSinglePlayer())
	{
		// none of this stuff should be processed or displayed in sp
		if(MsgType == 'QuickChat' || MsgType == 'TeamQuickChat')
		{
			splitIndex = InStr(Msg, "?");

			quickChatTag = Left(Msg, splitIndex);
			quickChatMessage = Right(Msg, Len(Msg) - splitIndex - 1);

			if(quickChatMessage == "")
				quickChatMessage = Localize("QuickChat", quickChatTag, "Localisation\\Speech\\QuickChat");

			if(TribesReplicationInfo(PRI) != None && quickChatTag != "")
				Level.speechManager.PlayQuickChatSpeech(PRI, TribesReplicationInfo(PRI).VoiceSetPackageName, Name(quickChatTag));

			NewMessage.Text = PlayerNameString $": " $quickChatMessage;
			if(MsgType == 'TeamQuickChat')
				NewMessage.Type = MessageType_Ally;

			clientSideChar.Messages[clientSideChar.Messages.Length] = NewMessage;
		}
		else if(MsgType == 'Say' || MsgType == 'TeamSay')
		{
			// append the say message to the list of messages.
			NewMessage.Text = PlayerNameString $": " $Msg;
			if(MsgType == 'TeamSay')
				NewMessage.Type = MessageType_Ally;

			clientSideChar.Messages[clientSideChar.Messages.Length] = NewMessage;
		}
		else if(MsgType == 'System')
		{
			NewMessage.Text = Msg;
			NewMessage.Type = MessageType_System;

			clientSideChar.Messages[clientSideChar.Messages.Length] = NewMessage;
		}
		else
			Super.Message(PRI, Msg, MsgType);
	}
	else
		Super.Message(PRI, Msg, MsgType);

}

// LocalizedMessage
simulated function LocalizedMessage(class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Core.Object OptionalObject, optional string CriticalString, optional string OptionalString)
{
	local class<MPEventMessage> SentEventMessage;
	local class<TribesGameMessage> SentGameMessage;
	local class<MPPersonalMessage> SentPersonalMessage;
	local ClientSideCharacter.EventMessage newMessage;
	local ClientSideCharacter.HUDMessage newHUDMessage;
	local EMessageType MessageType;
	local TribesReplicationInfo TRI;
	local class<TeamInfo> InfoClass;

	SentPersonalMessage = class<MPPersonalMessage>(Message);
	SentGameMessage = class<TribesGameMessage>(Message);
	SentEventMessage = class<MPEventMessage>(Message);
	
	// no localised messages in sp
	if(! Controller.IsSinglePlayer())
	{
		if(SentEventMessage != None)
		{
			newMessage.StringOne = SentEventMessage.static.GetStringOne(newMessage.StringOneType, Switch, Related1, Related2, OptionalObject, OptionalString);
			newMessage.StringTwo = SentEventMessage.static.GetStringTwo(newMessage.StringTwoType, Switch, Related1, Related2, OptionalObject, OptionalString);
			newMessage.IconMaterial = SentEventMessage.static.GetIconMaterial(Switch, Related1, Related2, OptionalObject, OptionalString);

			// hacky: Related1 is None for suicides, so on a death message where 
			// related1 is none we make it equal related2
			if(Related1 == None && class<MPDeathMessages>(Message) != None && TribesReplicationInfo(Related2) != None)
				Related1 = Related2;

			if(TribesReplicationInfo(Related1) != None && HUDScript != None)
			{
				TRI = TribesReplicationInfo(Related1);
				if(TRI.team != None)
					InfoClass = TRI.team.class;
				newMessage.StringOne = "" $ HUDScript.EncodePlayerName(TRI.PlayerName, TRI.teamTag, ClientSideChar.GetTeamAlignment(Controller, TRI), InfoClass);
			}
			if(TribesReplicationInfo(Related2) != None && (Related1 != Related2) && HUDScript != None)
			{
				TRI = TribesReplicationInfo(Related2);
				if(TRI.team != None)
					InfoClass = TRI.team.class;
				newMessage.StringTwo = "" $ HUDScript.EncodePlayerName(TRI.PlayerName, TRI.teamTag, ClientSideChar.GetTeamAlignment(Controller, TRI), InfoClass);
			}

			clientSideChar.EventMessages[clientSideChar.EventMessages.Length] = newMessage;
		}
		else if(SentGameMessage != None)
		{
			newHUDMessage.Text = SentGameMessage.static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
			newHUDMessage.Type = MessageType_System;

			clientSideChar.Messages[clientSideChar.Messages.Length] = newHUDMessage;
		}
		else if(SentPersonalMessage != None)
		{
			MessageType = MessageType_System;

			newHUDMessage.Text = SentPersonalMessage.static.GetPersonalString(MessageType, Switch, Related1, Related2, OptionalObject, OptionalString);
			newHUDMessage.Type = MessageType;

			clientSideChar.PersonalMessages[clientSideChar.PersonalMessages.Length] = newHUDMessage;
		}
		else
			PlayerOwner.ClientMessage(Message.static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString));
	}
	else
		PlayerOwner.ClientMessage(Message.static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString));
}

//
// initialises any action delegates for the hud response
function InitActionDelegates()
{
	// chat delegates
	if(Response == None)
		Response = new class'HUDAction';

	Response.CancelChat = impl_CancelChat;
	Response.SendChatMessage = impl_SendChatMessage;
	Response.SendQuickChatMessage = impl_SendQuickChatMessage;
}

//
// cleans up any action delegates for the hud response
function CleanupActionDelegates()
{
	if(Response != None)
	{
		Response.CancelChat = None;
		Response.SendChatMessage = None;
		Response.SendQuickChatMessage = None;
	}
}

//
// The base functionality for this function is to add all the info
// which is required for all (or most) HUDs
//
simulated function UpdateHUDData()
{
	super.UpdateHUDData();

	// mouse pointer info
	ClientSideChar.MouseX = MouseX;
	ClientSideChar.MouseY = MouseY;

	// Game and round data
	UpdateHUDGameData();
	clientSideChar.respawnTime = Controller.respawnDelay;
	clientSideChar.livesLeft = Controller.livesLeft;
	clientSideChar.bWaitingForRoundEnd = Controller.bWaitingForRoundEnd;
	if(Controller.PlayerReplicationInfo != None)
		clientSideChar.ping = Controller.PlayerReplicationInfo.ping;

	clientSideChar.bDisplayChatWindow = clientSideChar.gameClass == None || clientSideChar.gameClass.static.showChatWindow();

	if(ClassIsChildOf(clientSideChar.gameClass, class'Gameplay.MultiPlayerGameInfo'))
		clientSideChar.bQuickChat = (Controller.bQuickChat == 1 && ! Controller.CanUseQuickInventoryLoadoutMenu());
	else
		clientSideChar.bQuickChat = false;

	clientSideChar.levelTimeSeconds = Level.TimeSeconds;

	if(Controller.IsSinglePlayer())
		clientSideChar.CurrentChatWindowSize = Controller.SPChatWindowSizes[Controller.SPChatWindowSizeIndex];
	else
		clientSideChar.CurrentChatWindowSize = Controller.ChatWindowSizes[Controller.ChatWindowSizeIndex];

	UpdateRoundInfoData();
}

function UpdateRoundInfoData()
{
	local RoundInfo RoundInfo;

	RoundInfo = Controller.RoundInfo;
	if(RoundInfo != None)
	{
		// Assume multiplayer (this variable determines whether or not the timer will be visible)
		clientSideChar.bNeedCountDownTimer = true;

		if(RoundInfo.replicatedRemainingCountdown > 0)
		{
			// If a pre-match countdown is in progress, replicate that
			clientSideChar.bRoundCountingDown = true;
			clientSideChar.countDown = RoundInfo.replicatedRemainingCountdown;
		}
		else
		{
			// Otherwise, replicate the match duration
			clientSideChar.bRoundCountingDown = false;
			clientSideChar.countDown = RoundInfo.replicatedRemainingDuration;
		}
	}
	else
	{
		clientSideChar.bNeedCountDownTimer = Controller.bCountDown;
		clientSideChar.countDown = Controller.countDown;
	}
}

//-------------------------------------------------------------
// Delegate function implementation

//
// Cancels chat message window
function impl_CancelChat()
{
	clientSideChar.bTalk = false;
	clientSideChar.bTeamTalk = false;
}

//
// Sends a chat message, and cancels the chat message window
function impl_SendChatMessage(String msg)
{
	if(clientSideChar.bTalk)
		Controller.Say(msg);
	else if(clientSideChar.bTeamTalk)
		Controller.TeamSay(msg);

	clientSideChar.bTalk = false;
	clientSideChar.bTeamTalk = false;
}

//
// Sends a quick chat message, then cancels the quick chat menu
function impl_SendQuickChatMessage(QuickChatMenu menuItem)
{
	local String MessageText;

	// dont bother sending the text if there was no override, 
	// because it will be localized at the other end anyway.
	if(menuItem.MessageOverride != "")
		MessageText = menuItem.MessageOverride;

	if(menuItem.sayType == 'Say')
		Controller.QuickChat(MessageText, String(menuItem.chatTag), menuItem.bLocal, menuItem.animationName);
	else if(menuItem.sayType == 'TeamSay')
		Controller.TeamQuickChat(MessageText, String(menuItem.chatTag), menuItem.bLocal, menuItem.animationName);
	clientSideChar.bQuickChat = false;

	// force the controller QC to false, for v-chat system
	Controller.bQuickChat = 0;
}

defaultproperties
{
	bAllowChat = true
	bAllowInteractions = false
	bShowCursor = false
	ConsoleMessagePosX = 0.00
	ConsoleMessagePosY = 0.45
    ConsoleMessageCount=5

	HUDScriptName = ""

    FontArrayNames(0)="Engine_res.SmallFont"
    FontArrayNames(1)="Engine_res.SmallFont"
    FontArrayNames(2)="Engine_res.SmallFont"
    FontArrayNames(3)="Engine_res.SmallFont"
    FontArrayNames(4)="Engine_res.SmallFont"
    FontArrayNames(5)="Engine_res.SmallFont"
    FontArrayNames(6)="Engine_res.SmallFont"
    FontArrayNames(7)="Engine_res.SmallFont"
    FontArrayNames(8)="Engine_res.SmallFont"

	MouseCursorTexture=Texture'guitribes.mousecursor'
	MouseCursorDrawColor=(R=255,G=255,B=255,A=255)
}
