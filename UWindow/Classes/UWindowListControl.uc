//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class UWindowListControl extends UWindowDialogControl;

var class<UWindowList>	ListClass;
var UWindowList			Items;
var Color				SelectionBkgColor;
var Color				SelectionColor;
var bool				bNoSelectionBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	// Declared in Subclass
}

function Created()
{
	Super.Created();

	Items = New ListClass;
	Items.Last = Items;
	Items.Next = None;	
	Items.Prev = None;
	Items.Sentinel = Items;
}

defaultproperties
{
     SelectionBkgColor=(B=192,A=255)
     SelectionColor=(B=255,G=255,R=255,A=255)
}
