//
// Defines the heirachy of loadout menus
// available for perusal in game.
//
class LoadoutMenu extends Core.Object
	PerObjectConfig
	Config(LoadoutMenu);

import enum EInputKey from Engine.Interactions;

var() config int			loadoutSlotIndex;
var() config EInputKey		keyBinding;
var() config Array<Name>	subMenuNames;

var String				loadoutName;
var Array<LoadoutMenu>	subMenu;
var LoadoutMenu			parentMenu;
var bool				bEmpty;
var bool				bEnabled;

var localized String	moreText;
var localized String	emptyText;

function InitMenu()
{
	local int i;

	for(i = 0; i < subMenuNames.Length; ++i)
	{
		subMenu[i] = new(None, String(subMenuNames[i])) class'LoadoutMenu';
		subMenu[i].InitMenu();
	}
}

function RefreshMenu(Array<String> loadoutNames, Array<byte> enabled)
{
	local int i;

	if(loadoutSlotIndex == -1)
	{
		loadoutName = moreText;
		bEmpty = true;
		bEnabled = true;
	}
	else if(loadoutSlotIndex < loadoutNames.Length)
	{
		loadoutName = loadoutNames[loadoutSlotIndex];
		bEmpty = false;
		bEnabled = enabled[loadoutSlotIndex] == 1;
	}
	else
	{
		loadoutName = emptyText;
		bEmpty = true;
		bEnabled = false;
	}

	if(IsCategoryMenu())
	{
		for(i = 0; i < subMenu.Length; ++i)
		{
			subMenu[i].RefreshMenu(loadoutNames, enabled);
			if(! subMenu[i].bEmpty)
				bEmpty = false;
		}
	}
}

function bool IsCategoryMenu()
{
	return (subMenu.Length > 0);
}

defaultproperties
{
	loadoutName="Loadout"
	loadoutSlotIndex=-1
	keyBinding=IK_Q

	moreText="More..."
	emptyText="[Empty]"
}