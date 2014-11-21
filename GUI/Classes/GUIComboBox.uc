// ====================================================================
//	Class: GUI.GUIComboBox
//
//  A Combination of an EditBox, a Down Arrow Button and a ListBox
//
//  Written by Michel Comeau
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

class GUIComboBox extends GUIMultiComponent
        HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var   	GUIEditBox 		Edit;
var   	GUIComboButton 	MyShowListBtn;
var   	GUIListBox 		MyListBox;
var		GUIList			List;


var(GUIComboBox) config int		MaxVisibleItems "Maximum number of lines to display at once";
var(GUIComboBox) config bool		bShowListOnFocus "Show the attached list when this recieves focus";
var(GUIComboBox) config bool		bReadOnly "Is this ComboBox read only";

var		int		Index;
var		string	TextStr;

function OnConstruct(GUIController MyController)
{
    Super.OnConstruct(MyController);

    MyListBox=GUIListBox(AddComponent( "GUI.GUIListBox", self.Name$"_LBox" ));
    Edit=GUIEditBox(AddComponent( "GUI.GUIEditBox" , self.Name$"_EditBox"));
    MyShowListBtn=GUIComboButton(AddComponent( "GUI.GUIComboButton" ,self.Name$"_ComboB"));
}


function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	Edit.SetText("");

    MyShowListBtn.bRepeatClick=false;

	List 			  = MyListBox.List;
	List.bHotTrack	  = true;
	List.OnChange 	  = SubComponentChanged;
	List.OnLostFocus  = SubComponentFocusLost;

	Edit.OnChange 		= SubComponentChanged;
	Edit.OnClick     	= SubComponentClicked;
	Edit.OnLostFocus    = SubComponentFocusLost;
	Edit.bReadOnly  	= bReadOnly;
    if( bReadOnly )
    	Edit.SetFocusInstead(List);

	MyShowListBtn.OnClick = SubComponentClicked;
	MyShowListBtn.SetFocusInstead(List);

#if IG_TRIBES3	// michaelj:  By default, set bNeverFocus parameters here so that when you click outside
				//            of the combobox control, the combobox closes
	Edit.bNeverFocus = false;
	MyShowListBtn.bNeverFocus = false;
#endif

    SetHint(Hint);
}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
}

event Show()
{
	Super.Show();
	MyListBox.Hide();
    SetDirty();
}

event Activate()
{
	Super.Activate();
	MyListBox.DeActivate();
    SetDirty();
}

function SubComponentFocusLost(GUIComponent Sender)
{
    switch (Sender)
    {
        case Edit:
        case List:
            MyListBox.Hide();
	        MyListBox.DeActivate();
            break;
    }
}


function SubComponentClicked(GUIComponent Sender)
{
    switch (Sender)
    {
        case Edit:
            if( !Edit.bReadOnly )
                break;
        case MyShowListBtn:
	        if (MyListBox.bVisible)
	        {
                InternalCloseList();
	        }
	        else
	        {
                InternalOpenList();
            }
            break;
    }
}

#if IG_TRIBES3 // dbeswick: box closes when others open
native function	CloseAllCombos();
#endif

private function InternalOpenList()
{
#if IG_TRIBES3 // dbeswick: box closes when others open
	CloseAllCombos();
#endif

	MyListBox.Show();
	MyListBox.Activate();
	MyListBox.Focus();
	
	if( GUIMultiComponent(MenuOwner) != None )
	    GUIMultiComponent(MenuOwner).BringToFront( Self );
}

#if IG_TRIBES3 // dbeswick: box closes when others open
private event InternalCloseList()
#else
private function InternalCloseList()
#endif
{
#if IG_TRIBES3 // dbeswick: box closes when others open
	if (MyListBox == None)
		return;
#endif
	MyListBox.Hide();
	MyListBox.DeActivate();
}

function SubComponentChanged(GUIComponent Sender)
{
    switch (Sender)
    {
        case List:
	        Edit.SetText(List.SelectedText(-1));
	        Index = List.Index;
            OnListIndexChanged(Sender);
            break;
        case Edit:
	        TextStr = Edit.GetText();
	        OnChange(self);
	        MyListBox.Hide();
	        MyListBox.DeActivate();
            break;
    }
}

delegate OnListIndexChanged(GUIComponent Sender);

function SetText(string NewText)
{
	List.Find(NewText);
	Edit.SetText(NewText);
}

#if IG_TRIBES3 // dbeswick
function bool SetFromExtra(string ExtraText)
{
	local int i;

	for (i = 0; i < List.Elements.Length; i++)
	{
		if (List.Elements[i].ExtraStrData == ExtraText)
		{
			SetText(List.Elements[i].item);
			return true;
		}
	}

	return false;
}
#endif

function string GetText() 
{
	return Edit.GetText();
}

function string Get()
{
	local string temp;

	temp = List.Get();

	if ( temp~=Edit.GetText() )
		return List.Get();
	else
		return "";
}

function object GetObject()
{
	local string temp;

	temp = List.Get();

	if ( temp~=Edit.GetText() )
		return List.GetObject();
	else
		return none;
}

function string GetExtra()
{
	local string temp;

	temp = List.Get();

	if ( temp~=Edit.GetText() )
		return List.GetExtra();
	else
		return "";
}

function int GetInt()
{
	return List.GetExtraIntData();
}

function bool GetBool()
{
	return List.GetExtraBoolData();
}

function SetIndex(int I)
{
	List.SetIndex(i);
}

function int GetIndex()
{
	return List.Index;
}

function Clear()
{
    List.Clear();
}

function AddItem(string Item, Optional object Extra, Optional string Str, optional int theInt, optional bool theBool)
{
	List.Add(Item,Extra,Str,theInt,theBool);
}

function RemoveItem(int item, optional int Count)
{
	List.Remove(item, Count);
}

function string GetItem(int index)
{
	List.SetIndex(Index);
	return List.Get();
}

function object GetItemObject(int index)
{
	List.SetIndex(Index);
	return List.GetObject();
}

function string find(string Text, optional bool bExact, optional bool bDontSetIndex)
{
	return List.Find(Text,bExact, bDontSetIndex);
}

function int ItemCount()
{
	return List.ItemCount;
}

function ReadOnly(bool b)
{
	Edit.bReadOnly = b;
}

cpptext
{
		void PreDraw(UCanvas* Canvas);
		void UpdateComponent(UCanvas* Canvas);

}


defaultproperties
{
     MaxVisibleItems=8
     bReadOnly=True
     StyleName="STY_ComboListBox"
     WinHeight=0.060000
     RenderWeight=0.951000
}
