class HUDEquipmentIcon extends HUDContainer;

var() config HUDMaterial	fullTexture;
var() config HUDMaterial	emptyTexture;
var() config bool			bDrawKey;
var() config bool			bDrawQuantity;
var() config String			keyTemplateObjectName;
var() config String			quantityTemplateObjectName;
var() config float			NewItemFlashDuration;
var() config float			NewItemFlashPeriod;
var() config float			NewItemFlashAlphaMin;
var() config float			NewItemFlashAlphaMax;

var	LabelElement		keyLabel;
var	LabelElement		quantityLabel;
var HUDValueBar			equipmentBar;

function InitElement()
{
	super.InitElement();

	// config the weapon bar
	if(equipmentBar == None)
	{
		equipmentBar = HUDValueBar(AddElement("TribesGUI.HUDValueBar", ""));
		equipmentBar.fullTexture = fullTexture;
		equipmentBar.activeFullTexture = fullTexture;
		equipmentBar.emptyTexture = emptyTexture;
		equipmentBar.activeEmptyTexture = emptyTexture;
		equipmentBar.bRelativePositioning = true;
	}

	if(keyLabel == None)
	{
		// config the key label
		keyLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", keyTemplateObjectName));
		keyLabel.bVisible = bDrawKey;
	}

	if(quantityLabel == None)
	{
		// config the quantity label	
		quantityLabel = LabelElement(AddClonedElement("TribesGUI.LabelElement", quantityTemplateObjectName));
		quantityLabel.bVisible = bDrawQuantity;
	}
}

function DoUpdateFlash()
{
	// HACK: only flash elements if we are not the help hud script
	if(TribesHelpHUDScript(BaseScript) == None)
		FlashElement(NewItemFlashPeriod, NewItemFlashDuration, 
			NewItemFlashAlphaMin, NewItemFlashAlphaMax);
}

function UpdateData(ClientSideCharacter c)
{
	quantityLabel.bVisible = bDrawQuantity;
	keyLabel.bVisible = bDrawKey;
}

defaultproperties
{
	bDrawKey					= true
	bDrawQuantity				= true
	keyTemplateObjectName		= "default_EquipmentHotkeyLabel"
	quantityTemplateObjectName	= "default_EquipmentQuantityLabel"

	NewItemFlashDuration		= 1.5
	NewItemFlashPeriod			= 0.25
	NewItemFlashAlphaMin		= 0.2
	NewItemFlashAlphaMax		= 1.0
}