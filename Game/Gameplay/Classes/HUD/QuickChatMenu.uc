//
// Defines the heirachy of quick chat menus
// available for perusal in game.
//
class QuickChatMenu extends Core.Object
	PerObjectConfig
	Config(QuickChatMenu);

import enum EInputKey from Engine.Interactions;

var() config Name chatTag;
var() config Name sayType;
var() config String animationName;
var() config bool bLocal;
var() config String messageOverride;
var() config EInputKey keyBinding;
var() config Array<Name> subMenuNames;
var() config bool bDummyItem;

var String					messageText;
var Array<QuickChatMenu>	subMenu;
var QuickChatMenu			parentMenu;

function InitMenu()
{
	local int i;

	if(bDummyItem)
		return;

	if(messageOverride == "")
		messageText = Localize("QuickChat", String(ChatTag), "Localisation\\Speech\\QuickChat");
	else
		messageText = messageOverride;

	for(i = 0; i < subMenuNames.Length; ++i)
	{
		subMenu[i] = new(None, String(subMenuNames[i])) class'QuickChatMenu';
		subMenu[i].InitMenu();
	}
}

function bool IsCategoryMenu()
{
	return (subMenu.Length > 0);
}

defaultproperties
{
	chatTag=NO_TAG_SET
	sayType=Say
	keyBinding=IK_Q
	messageOverride="Message text"
}