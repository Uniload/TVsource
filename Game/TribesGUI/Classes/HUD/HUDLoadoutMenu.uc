//
// Displays the heirachy of loadout menus
//
class HUDLoadoutMenu extends HUDContainer;

enum EOpeningState
{
	STATE_Opening,
	STATE_Open,
	STATE_Closing,
	STATE_Closed
};

var() config float GutterX;
var() config float GutterY;
var() config int numRows;
var() config int numColumns;
var() config float animateTime;

var HUDLoadoutMenu activeChildMenu;
var HUDLoadoutMenu parentMenu;

var float animatePosX;
var float animatePosY;
var EOpeningState menuState;
var float animateStartTime;
var float animateProgress;

var LoadoutMenu menu;

function InitMenu(LoadoutMenu menuObject, HUDLoadoutMenu parent, HUDContainer parentContainer)
{
	local int i;
	local HUDLoadoutMenuItem nextItem;

	menu = menuObject;
	parentMenu = parent;
	menuState = STATE_Closed;

	for(i = 0; i < menu.subMenu.Length; ++i)
	{
		nextItem = HUDLoadoutMenuItem(AddClonedElement("TribesGUI.HUDLoadoutMenuItem", "default_LoadoutMenuItem"));
		nextItem.InitMenu(menu.subMenu[i], self, parentContainer);
	}
}

function RefreshData()
{
	local int i;

	for(i = 0; i < children.Length; ++i)
		HUDLoadoutMenuItem(children[i]).RefreshData();
}

function OpenMenu(optional HUDLoadoutMenuItem trigger)
{
	if(menuState == STATE_Opening || menuState == STATE_Open || activeChildMenu != None)
		return;

	RefreshData();

	animatePosX = 0;
	animatePosY = 0;
	if(trigger != None)
	{
		animatePosX = trigger.PosX;
		animatePosY = trigger.PosY;
	}

	bVisible = true;
	menuState = STATE_Opening;
	animateStartTime = timeSeconds;
	animateProgress = 0.0;
	SetNeedsLayout();
}

function CloseMenu(optional HUDLoadoutMenuItem trigger)
{
	if(menuState == STATE_Closing || menuState == STATE_Closed)
		return;

	animatePosX = 0;
	animatePosY = 0;
	if(trigger != None)
	{
		animatePosX = trigger.PosX;
		animatePosY = trigger.PosY;
	}

	menuState = STATE_Closing;
	animateStartTime = timeSeconds;
	animateProgress = 0.0;
	SetNeedsLayout();
}

function DoLayout(Canvas c)
{
	local int i, row, col;
	local float CurX, CurY, MaxHeight;
	local HUDLoadoutMenuItem nextItem;

	super.DoLayout(c);

	if(menuState == STATE_Opening || menuState == STATE_Closing)
	{
		animateProgress += ((timeSeconds - animateStartTime) / animateTime);
		if(animateProgress >= 1.0)
		{
			animateProgress = 1.0;
			if(menuState == STATE_Opening)
			{
				menuState = STATE_Open;
				bVisible = true;
			}
			else if(menuState == STATE_Closing)
			{
				menuState = STATE_Closed;
				bVisible = false;
			}
		}

		if(menuState == STATE_Opening)
			SetAlpha(animateProgress);
		else if(menuState == STATE_Closing)
			SetAlpha(1.0 - animateProgress);
	}

	for(row = 0; row < numRows; ++row)
	{
		for(col = 0; col < numColumns; ++col)
		{
			if(i < children.Length)
			{
				nextItem = HUDLoadoutMenuItem(children[i]);
				if(nextItem != None)
				{
					if(! nextItem.menu.bEmpty)
					{
						nextItem.bVisible = true;

						nextItem.PosX = CurX;
						nextItem.PosY = CurY;

						// force the change in values
						CurX += GutterX + nextItem.Width;
						MaxHeight = Max(MaxHeight, nextItem.Height);
					}
					else
					{
						nextItem.bVisible = false;
					}
				}
			}

			++i;
		}

		CurX = 0;
		CurY += GutterY + MaxHeight;
	}

	if(menuState == STATE_Opening || menuState == STATE_Closing)
	{
		for(i = 0; i < children.Length; ++i)
		{
			if(menuState == STATE_Opening)
			{
				children[i].PosX = animatePosX + animateProgress * (children[i].PosX - animatePosX);
				children[i].PosY = animatePosY + animateProgress * (children[i].PosY - animatePosY);
			}
			else
			{
				children[i].PosX = children[i].PosX - animateProgress * (children[i].PosX - animatePosX);
				children[i].PosY = children[i].PosY - animateProgress * (children[i].PosY - animatePosY);
			}
		}

		SetNeedsLayout();
	}
}

function HUDLoadoutMenu GetRootMenu()
{
	if(parentMenu != None)
		return parentMenu.GetRootMenu();

	return self;
}

function CancelAll()
{
	bVisible = false;
	menuState = STATE_Closed;
	if(activeChildMenu != None)
	{
		activeChildMenu.CancelAll();
		activeChildMenu = None;
	}
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta, HUDAction Response )
{
	local int i;

	if(activeChildMenu != None && menu.IsCategoryMenu())
		return activeChildMenu.KeyEvent(Key, Action, Delta, Response);
	else if(menuState == STATE_Opening || menuState == STATE_Open)
	{
		for(i = 0; i < children.Length; i++)
		{
			if(children[i].KeyEvent(Key, Action, Delta, Response))
				return true;
		}
	}

	return false;
}

defaultproperties
{
	animateTime=0.7
	bVisible = false
	GutterX = 10
	GutterY = 10

	numRows = 3
	numColumns = 3
}