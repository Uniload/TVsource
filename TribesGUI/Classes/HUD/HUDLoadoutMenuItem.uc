class HUDLoadoutMenuItem extends HUDContainer;

var LabelElement KeyLabel;
var LabelElement TextLabel;

var HUDLoadoutMenu subMenu;
var HUDLoadoutMenu parentMenu;

var LoadoutMenu menu;

function InitElement()
{
	super.InitElement();

	KeyLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", "default_LoadoutKey"));
	TextLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", "default_LoadoutText"));
}

function RefreshData()
{
	KeyLabel.SetText(Chr(menu.keyBinding));
	TextLabel.SetText(menu.loadoutName);
	if(menu.bEnabled)
	{
		KeyLabel.LoadConfig("default_LoadoutKey", KeyLabel.class);
		TextLabel.LoadConfig("default_LoadoutText", TextLabel.class);
	}
	else
	{
		KeyLabel.LoadConfig("default_LoadoutKeyDisabled", KeyLabel.class);
		TextLabel.LoadConfig("default_LoadoutTextDisabled", TextLabel.class);
	}
}

function InitMenu(LoadoutMenu menuObject, HUDLoadoutMenu parent, HUDContainer parentContainer)
{
	menu = menuObject;
	parentMenu = parent;

	KeyLabel.SetText(Chr(menu.keyBinding));
	TextLabel.SetText(menu.loadoutName);

	if(menu.IsCategoryMenu())
	{
		subMenu = HUDLoadoutMenu(parentContainer.AddClonedElement("TribesGUI.HUDLoadoutMenu", "default_QuickChatMenu"));
		subMenu.InitMenu(menu, parentMenu, parentContainer);
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
	if(! bVisible)
		return false;

	if(Action == IST_Press)
	{
		if(Key == menu.keyBinding)
		{
			// close this menu, and do the action
			if(menu.IsCategoryMenu())
				ActivateMenu();
			else if(menu.bEnabled)
			{
				Response.SelectLoadout(menu.loadoutSlotIndex);
				parentMenu.GetRootMenu().CancelAll();
			}
			else
			{
				// should probably do a bloop sound here
			}

			return true;
		}
	}

	return false;
}
