class HUDQuickChatMenuItem extends HUDContainer;

var LabelElement KeyLabel;
var LabelElement TextLabel;

var HUDQuickChatMenu subMenu;
var HUDQuickChatMenu parentMenu;

var QuickChatMenu menu;

function UpdateData(ClientSideCharacter c)
{
	if(menu.SayType == 'TeamSay' && TextLabel != None)
	{
		TextLabel.TextColor = LocalData.GetTeamColor(TA_Friendly, true);
	}
}

function InitMenu(QuickChatMenu menuObject, HUDQuickChatMenu parent, HUDContainer parentContainer)
{
	menu = menuObject;
	parentMenu = parent;

	// dummy items have no sub components
	if(menu.bDummyItem)
	{
		RemoveAll();
	}
	else
	{
		if(KeyLabel == None)
			KeyLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", "default_QuickChatKey"));
		if(TextLabel == None)
			TextLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", "default_QuickChatText"));

		KeyLabel.SetText(Chr(menu.keyBinding));
		TextLabel.SetText(menu.messageText);

		if(menu.IsCategoryMenu())
		{
			subMenu = HUDQuickChatMenu(parentContainer.AddClonedElement("TribesGUI.HUDQuickChatMenu", "default_QuickChatMenu"));
			subMenu.InitMenu(menu, parentMenu, parentContainer);
		}
	}
}

function ActivateMenu()
{
	if(parentMenu != None)
	{
		parentMenu.activeChildMenu = subMenu;
		parentMenu.CloseMenu(self);
	}
	subMenu.activeChildMenu = None;
	subMenu.OpenMenu(self);
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response )
{
	if(menu.bDummyItem)
		return false;

	if(Action == IST_Press)
	{
		if(Key == menu.keyBinding)
		{
			// close this menu, and do the action
			if(menu.IsCategoryMenu())
				ActivateMenu();
			else
			{
				Response.SendQuickChatMessage(menu);
				parentMenu.GetRootMenu().CancelAll();
			}

			return true;
		}
	}

	return false;
}
