//
// Renders the weapon icon as a selected slot. Has a button on
// the component to assign a weapon to the slot.
//
class TribesInventoryWeaponSlot extends GUI.GUIMultiComponent;

var localized String SlotText;

var GUIButton		AssignButton;
var GUIImage		WeaponImage;
var GUILabel		SlotLabel;

var	class<Weapon>	weaponClass;
var	int				slotIndex;

function InitComponent(GUIComponent MyOwner)
{
	super.InitComponent(MyOwner);

	AssignButton = GUIButton(AddComponent("GUI.GUIButton", "", true));
	AssignButton.WinHeight = 0.45;
	AssignButton.WinWidth = (ActualHeight() / ActualWidth()) * AssignButton.WinHeight;
	AssignButton.WinLeft = 0.5 - (AssignButton.WinWidth * 0.5);
	AssignButton.WinTop = 0.025;
	AssignButton.Caption = SlotText @ (slotIndex + 1);
	AssignButton.StyleName = StyleName;
	AssignButton.bNeverFocus = true;
	AssignButton.InitComponent(self);

	WeaponImage = GUIImage(AddComponent("GUI.GUIImage", "", true));
	WeaponImage.WinLeft = 0.0;
	WeaponImage.WinTop = 0.5;
	WeaponImage.WinHeight = 0.5;
	WeaponImage.WinWidth = 1.0;
	WeaponImage.ImageStyle = ISTY_Justified;
	WeaponImage.ImageRenderStyle = MSTY_Alpha;
	WeaponImage.ImageAlign = IMGA_Center;

	SlotLabel = GUILabel(AddComponent("GUI.GUILabel", "", true));
	SlotLabel.WinLeft = 0.0;
	SlotLabel.WinTop = 1.0 - (12 / ActualHeight());
	SlotLabel.WinWidth = 1.0;
	SlotLabel.WinHeight = 12 / ActualHeight();
	SlotLabel.TextAlign = TXTA_Center;
	SlotLabel.Caption = SlotText @ (slotIndex + 1);
	SlotLabel.StyleName = StyleName;
	SlotLabel.InitComponent(Self);

	AssignButton.OnClick = InternalOnClick;
}

Delegate OnAssign(TribesInventoryWeaponSlot AssignedSlot);

function InternalOnClick(GUIComponent Sender)
{
	OnAssign(self);
}

function SetWeaponClass(class<Weapon> newClass)
{
	if(newClass != weaponClass)
	{
		weaponClass = newClass;
		if(weaponClass != None)
			WeaponImage.Image = weaponClass.default.inventoryIcon;
		else
			WeaponImage.Image = None;
	}
}

function SetEnabled(bool value)
{
	AssignButton.SetEnabled(value);
}

defaultproperties
{
	SlotText = "Slot"
	bNeverFocus = true
	PropagateState=false
}