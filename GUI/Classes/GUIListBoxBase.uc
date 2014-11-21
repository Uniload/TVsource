// ====================================================================
//  Class:  GUI.GUIListBoxBase
//
//  The GUIListBoxBase is a wrapper for a GUIList and it's ScrollBar
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUIListBoxBase extends GUIMultiComponent
		Native;
 
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var  GUIVertScrollBar	MyScrollBar;
var  GUIListBase		MyActiveList;
var(GUIListBoxBase) config	bool	bVisibleWhenEmpty "List box is visible when empty.";
var(GUIListBoxBase) config	bool	bReadOnly "List box is Unselectable.";

function OnConstruct(GUIController MyController)
{
    Super.OnConstruct(MyController);

    MyScrollBar=GUIVertScrollBar(AddComponent( "GUI.GUIVertScrollBar" , self.Name$"_SBar"));
}

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	MyScrollBar.bVisible=false;
	MyScrollBar.bActiveInput=bActiveInput;
}

function InitBaseList(GUIListBase LocalList)
{
    LocalList.StyleName = StyleName;
    LocalList.Style = Style;

	LocalList.bVisibleWhenEmpty = bVisibleWhenEmpty;
	LocalList.bAllowHTMLTextFormatting = bAllowHTMLTextFormatting;
	LocalList.MyScrollBar = MyScrollBar;
	
	LocalList.bReadOnly = bReadOnly;
	
	SetVisibility(bVisible);
	SetActive(bActiveInput);
	
	SetActiveList( LocalList );
}

function SetActiveList( GUIListBase LocalList )
{
	local int i;

    MyActiveList = LocalList;
	MyScrollBar.MyList = LocalList;

	for (i=0;i<MyScrollBar.Controls.Length;i++)
		MyScrollBar.Controls[i].SetFocusInstead(LocalList);

	MyScrollBar.SetFocusInstead(LocalList);
}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
}

function int Num()
{
    return MyActiveList.ItemCount;
}

function Clear()
{
    MyActiveList.Clear();
}

cpptext
{
	void PreDraw(UCanvas* Canvas);
	void Draw(UCanvas* Canvas);								// Handle drawing of the component natively
	void UpdateComponent(UCanvas* Canvas);

}


defaultproperties
{
     bVisibleWhenEmpty=True
     StyleName="STY_ListBox"
     bDrawStyle=True
}
