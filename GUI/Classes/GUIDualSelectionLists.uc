// ====================================================================
//	Class: GUI.GUIDualSelectionLists
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

class GUIDualSelectionLists extends GUIMultiComponent
        HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//the lists
var GUIListBox      ListBoxA;
var GUIListBox      ListBoxB;

//the list headers
var GUILabel        ListBoxAH;
var GUILabel        ListBoxBH;

//the list buttons
var GUIGFXButton    AtoB;
var GUIGFXButton    BtoA;


//the initial references
var private GUIListBox LBA;
var private GUIListBox LBB;
var private GUILabel LBAH;
var private GUILabel LBBH;
var private GUIGFXButton ABButton;
var private GUIGFXButton BAButton;


var(GUIDualSelectionLists) config bool	bSwitchListBoxLocations "If true, will layout the list boxes & headers in the other order";
var(GUIDualSelectionLists) config bool	bVerticalLayout "If true, will layout this component vertically instead of horizontally";
var(GUIDualSelectionLists) config float	ListBoxSpacing "Determines spacing of the lists (80% default)";
var(GUIDualSelectionLists) config float	HeaderPercent "Determines spacing of the headers (100% default)";


var(GUIDualSelectionLists) config localized String	BoxAHeader "Caption to use over ListBox A";
var(GUIDualSelectionLists) config localized String	BoxBHeader "Caption to use over ListBox B";

var(GUIDualSelectionLists) config localized String	LeftCaption "Caption to use on Arrow Pointing Left";
var(GUIDualSelectionLists) config localized String	RightCaption "Caption to use on Arrow Pointing Right";
var(GUIDualSelectionLists) config localized String	UpCaption "Caption to use on Arrow Pointing Up";
var(GUIDualSelectionLists) config localized String	DownCaption "Caption to use on Arrow Pointing Down";
var(GUIDualSelectionLists) config Material LeftImage "Image to use on Arrow Pointing Left";
var(GUIDualSelectionLists) config Material RightImage "Image to use on Arrow Pointing Right";
var(GUIDualSelectionLists) config Material UpImage "Image to use on Arrow Pointing Up";
var(GUIDualSelectionLists) config Material DownImage "Image to use on Arrow Pointing Down";

function OnConstruct(GUIController MyController)
{
    Super.OnConstruct(MyController);

    ListBoxA=GUIListBox(AddComponent( "GUI.GUIListBox", self.Name$"_LBA" ));
    ListBoxB=GUIListBox(AddComponent( "GUI.GUIListBox", self.Name$"_LBB" ));

    ListBoxAH=GUILabel(AddComponent( "GUI.GUILabel", self.Name$"_HeaderA" ));
    ListBoxBH=GUILabel(AddComponent( "GUI.GUILabel", self.Name$"_HeaderB" ));

    AtoB=GUIGFXButton(AddComponent( "GUI.GUIGFXButton", self.Name$"_AB" ));
    BtoA=GUIGFXButton(AddComponent( "GUI.GUIGFXButton", self.Name$"_BA" ));
}


function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    AssignComponents();

    ListBoxAH.TextAlign = TXTA_Center;
    ListBoxBH.TextAlign = TXTA_Center;

    ListBoxAH.SetCaption( BoxAHeader );
    ListBoxBH.SetCaption( BoxBHeader );
    
    if( bVerticalLayout )
    {
        if( !bSwitchListBoxLocations )
        {
            ABButton.SetCaption( UpCaption );
            BAButton.SetCaption( DownCaption );
            ABButton.Graphic = UpImage;
            BAButton.Graphic = DownImage;
        }
        else
        {
            ABButton.SetCaption( DownCaption );
            BAButton.SetCaption( UpCaption );
            ABButton.Graphic = DownImage;
            BAButton.Graphic = UpImage;
        }
    }
    else
    {
        if( !bSwitchListBoxLocations )
        {
            ABButton.SetCaption( LeftCaption );
            BAButton.SetCaption( RightCaption );
            ABButton.Graphic = LeftImage;
            BAButton.Graphic = RightImage;
        }
        else
        {
            ABButton.SetCaption( RightCaption );
            BAButton.SetCaption( LeftCaption );
            ABButton.Graphic = RightImage;
            BAButton.Graphic = LeftImage;
        }
    }

    ABButton.OnClick = MoveAB;
    BAButton.OnClick = MoveBA;
    
    LBA.List.OnDblClick = MoveAB;
    LBB.List.OnDblClick = MoveBA;

    LBA.OnClick = OnListClicked;
    LBB.OnClick = OnListClicked;
}

event Activate()
{
    Super.Activate();
    
    CheckListSelection(LBA);
    CheckListSelection(LBB);
}

event OnChangeLayout()
{
    AssignComponents();

    LBAH.SetCaption( BoxAHeader );
    LBBH.SetCaption( BoxBHeader );
    
    Super.OnChangeLayout();
}

function MoveAB(GUIComponent Sender)
{
    LBB.List.AddElement( LBA.List.GetElement() );
    LBA.List.Remove( LBA.List.Index );

    CheckListSelection(LBA);
    CheckListSelection(LBB);
    OnChange(self);
}

function MoveBA(GUIComponent Sender)
{
    LBA.List.AddElement( LBB.List.GetElement() );
    LBB.List.Remove( LBB.List.Index );

    CheckListSelection(LBA);
    CheckListSelection(LBB);
    OnChange(self);
}

function OnListClicked(GUIComponent Sender)
{
    local GUIListBox ListBox;
    ListBox = GUIListBox(Sender);
    Assert( ListBox != None );
    
    CheckListSelection(ListBox);
    SetDirty();
    OnChange(self);
}

private function CheckListSelection(GUIListBox ListBox)
{
    //check if an element is selected
    if( ListBox.List.Index < 0 || ListBox.List.Index > ListBox.List.ItemCount )
    {
        switch(ListBox)
        {
            case LBA:
                    AtoB.DisableComponent();
                break;
            case LBB:
                    BtoA.DisableComponent();
                break;
        }
    }
    else
    {
        switch(ListBox)
        {
            case LBA:
                    AtoB.EnableComponent();
                break;
            case LBB:
                    BtoA.EnableComponent();
                break;
        }
    }
}

private function AssignComponents()
{
    if( bSwitchListBoxLocations )
    {
        LBA=ListBoxB;
        LBB=ListBoxA;

        LBAH=ListBoxBH;
        LBBH=ListBoxAH;
    }
    else
    {
        LBA=ListBoxA;
        LBB=ListBoxB;

        LBAH=ListBoxAH;
        LBBH=ListBoxBH;
    }

    ABButton=AtoB;
    BAButton=BtoA;
}

cpptext
{
		void PreDraw(UCanvas* Canvas);
	void UpdateComponent(UCanvas* Canvas);

}


defaultproperties
{
     ListBoxSpacing=0.930000
     HeaderPercent=1.000000
     LeftCaption="<<<"
     RightCaption=">>>"
     UpCaption="^^^"
     DownCaption="vvv"
     WinTop=0.300000
     WinLeft=0.050000
     WinWidth=0.900000
     WinHeight=0.400000
}
