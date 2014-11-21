//================================================================
// Class: TribesHUDScript
//
// A safe, client side script to allow users to write their own HUD
// scripts without exposing core game objects which would facilitate cheating
//
//================================================================

class TribesHUDScript extends TribesHUDScriptBase
	native
	abstract;

var Array<HUDElement>	keyEventReceptors;
var Array<HUDElement>	mouseEventReceptors;
var int LastMouseX;
var int LastMouseY;

var bool				bIsChatEnabled;
var bool				bIsQuickChatEnabled;
var HUDChatEntry		chatEntry;
var HUDQuickChatMenu	quickChatMenu;
var HUDMessageWindow	messageWindow;
var HUDContainer		messageContainer;

var HUDContainer		quickChatMenuContainer;
var QuickChatMenu		rootQuickChatMenuObject;
var String				rootQuickChatMenuObjectName;
var bool				bOldQuickChat;

var HUDAnnouncerMessageWindow	AnnouncementsWindow;
var bool						bIsAnnouncmentsEnabled;

var HUDEventMessageWindow	EventMessageWindow;
var bool					bEventMessagesEnabled;

var bool bShowScoreboard;
var HUDContainer scoreboardGroup;
var LabelElement teamOneScoreLabel;
var LabelElement teamOneLabel;
var HUDCountDown countDown;
var LabelElement teamTwoLabel;
var LabelElement teamTwoScoreLabel;

overloaded function Construct()
{
	super.Construct();

	ConstructBaseComponents();
}

function PreShow(ClientSideCharacter csc)
{
	LocalData = csc;
	InitElementHeirachy(self, None); // Has no parent
	ForceNeedsLayout();
}

function ConstructBaseComponents()
{
	if(bEventMessagesEnabled)
		EventMessageWindow = HUDEventMessageWindow(AddElement("TribesGui.HUDEventMessageWindow", "default_EventMessageWindow"));

	if(bIsChatEnabled)
	{
		messageContainer = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_MessageContainer"));
		messageWindow = HUDMessageWindow(messageContainer.AddElement("TribesGUI.HUDMessageWindow", "default_MessageWindow"));
		chatEntry = HUDChatEntry(messageContainer.AddElement("TribesGUI.HUDChatEntry", "default_ChatEntry"));
		RegisterKeyEventReceptor(chatEntry);
	}

	if(bIsQuickChatEnabled)
	{
		quickChatMenuContainer = HUDContainer(AddElement("TribesGUI.HUDContainer", "default_QuickChatMenuContainer"));
		quickChatMenu = HUDQuickChatMenu(quickChatMenuContainer.AddElement("TribesGUI.HUDQuickChatMenu", "default_QuickChatMenu"));
		RegisterKeyEventReceptor(quickChatMenu);

		// load up the root menu (only once!)
		rootQuickChatMenuObject = QuickChatMenu(FindObject("RootQuickChatMenu", class'Gameplay.QuickChatMenu'));
		if(rootQuickChatMenuObject == None)
		{
			rootQuickChatMenuObject = new (None, "RootQuickChatMenu") class'TribesGUI.QuickChatMenu';
			rootQuickChatMenuObject.InitMenu();
			quickChatMenu.InitMenu(rootQuickChatMenuObject, None, quickChatMenuContainer);
		}
	}

	if(bIsAnnouncmentsEnabled)
		AnnouncementsWindow = HUDAnnouncerMessageWindow(AddElement("TribesGui.HUDAnnouncerMessageWindow", "default_AnnouncementsWindow"));

	if(bShowScoreboard)
	{
		scoreboardGroup	= HUDContainer(AddElement("TribesGUI.HUDContainer", "default_scoreboardGroup"));
		teamOneScoreLabel = LabelElement(scoreboardGroup.AddElement("TribesGUI.LabelElement", "default_teamOneScore"));
		teamOneLabel = LabelElement(scoreboardGroup.AddElement("TribesGUI.LabelElement", "default_teamOneLabel"));
		countDown = HUDCountDown(scoreboardGroup.AddElement("TribesGUI.HUDCountDown", "default_countDown"));
		teamTwoLabel = LabelElement(scoreboardGroup.AddElement("TribesGUI.LabelElement", "default_teamTwoLabel"));
		teamTwoScoreLabel = LabelElement(scoreboardGroup.AddElement("TribesGUI.LabelElement", "default_teamTwoScore"));
	}
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	if(messageWindow != None)
		messageWindow.ForcedMaxVisibleLines = -1;

	if(bIsQuickChatEnabled)
	{
		// always cancel the menu if we are not enabled
		if(! c.bQuickChat)
			quickChatMenu.CancelAll();
		else if(bOldQuickChat != c.bQuickChat)
			quickChatMenu.OpenMenu();

		bOldQuickChat = c.bQuickChat;
	}

	if(bShowScoreboard)
		UpdateScoreboard();
}

// Updates the scoreboard at the top of the screen
function UpdateScoreboard()
{
	local int scoreLimit;
	local String scoreTextOwn, scoreTextOther;
	local class<ModeInfo> modeClass;

	modeClass = class<ModeInfo>(LocalData.gameClass);

	// Don't do this in single player
	if (modeClass == None)
		return;

	scoreLimit = modeClass.default.scoreLimit;

	// Only display team information if a second team is present
	if (LocalData.otherTeam != "" && modeClass.default.numTeams > 1)
	{
		TeamOneLabel.SetText(LocalData.ownTeam);
		TeamTwoLabel.SetText(LocalData.otherTeam);
		scoreTextOwn = string(LocalData.ownTeamScore);
		scoreTextOther = string(LocalData.otherTeamScore);
		if(scoreLimit > 0)
		{
			scoreTextOwn $= "/" $ string(scoreLimit);
			scoreTextOther $= "/" $ string(scoreLimit);
		}

		teamOneScoreLabel.SetText(scoreTextOwn);
		teamTwoScoreLabel.SetText(scoreTextOther);
	}
}

function DoUpdate(Canvas canvas, float NewTimeSeconds)
{
	local bool bWasOverElement, bOverElement;
	local int i;

	if(screenWidth != canvas.SizeX || screenHeight != canvas.SizeY)
		ForceNeedsLayout();

	// check for mouse movement
	if(LastMouseX != LocalData.MouseX || LastMouseY != LocalData.MouseY)
	{
		for(i = 0; i < mouseEventReceptors.Length; ++i)
		{
			bWasOverElement = mouseEventReceptors[i].PointInElement(LastMouseX, LastMouseY);
			bOverElement = mouseEventReceptors[i].PointInElement(LocalData.MouseX, LocalData.MouseY);

			if(bWasOverElement && ! bOverElement)
				mouseEventReceptors[i].OnMouseExited(mouseEventReceptors[i]);
			else if(! bWasOverElement && bOverElement)
				mouseEventReceptors[i].OnMouseEntered(mouseEventReceptors[i]);
		}
	}

	// do the data update + rendering
	TimeSeconds = NewTimeSeconds;
	UpdateData(LocalData);
//	if(bNeedsLayout)
		DoLayout(canvas);
	Render(canvas);

	// update previous values
	LastMouseX = LocalData.MouseX;
	LastMouseY = LocalData.MouseY;
}

function RegisterMouseEventReceptor(HUDElement element)
{
	mouseEventReceptors[mouseEventReceptors.Length] = element;
}

function UnRegisterMouseEventReceptor(HUDElement element)
{
	local int i;

	for(i = 0; i < mouseEventReceptors.Length; ++i)
	{
		if(mouseEventReceptors[i] == element)
		{
			mouseEventReceptors.Remove(i, 1);
			--i;
		}
	}
}

function RegisterKeyEventReceptor(HUDElement element)
{
	keyEventReceptors[keyEventReceptors.Length] = element;
}

function UnRegisterKeyEventReceptor(HUDElement element)
{
	local int i;

	for(i = 0; i < keyEventReceptors.Length; ++i)
	{
		if(keyEventReceptors[i] == element)
		{
			keyEventReceptors.Remove(i, 1);
			--i;
		}
	}
}

//Key events
function bool KeyType( EInputKey Key, string Unicode, HUDAction Response )
{
	local int i;

	for(i = 0; i < keyEventReceptors.Length; ++i)
	{
		if(keyEventReceptors[i].KeyType(Key, Unicode, Response))
			return true;
	}
	
	return false;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response )
{
	local int i;

	if(Key == EInputKey.IK_LeftMouse && (Action == EInputAction.IST_Press || Action == EInputAction.IST_Repeat))
	{
		for(i = 0; i < mouseEventReceptors.Length; ++i)
		{
			if(mouseEventReceptors[i].PointInElement(LastMouseX, LastMouseY))
			{
				if(Action == EInputAction.IST_Press)
					mouseEventReceptors[i].OnMouseClicked(mouseEventReceptors[i]);
				else if(Action == EInputAction.IST_Repeat)
					mouseEventReceptors[i].OnMouseDoubleClicked(mouseEventReceptors[i]);
			}
		}
	}
	else
	{
		for(i = 0; i < keyEventReceptors.Length; ++i)
		{
			if(keyEventReceptors[i].KeyEvent(Key, Action, Delta, Response))
				return true;
		}
	}

	return false;
}

defaultproperties
{
	bIsChatEnabled = true
	bIsQuickChatEnabled = true
	bEventMessagesEnabled = true
	bIsAnnouncmentsEnabled = true

	bRelativePositioning = true
	bShowScoreboard = true
}