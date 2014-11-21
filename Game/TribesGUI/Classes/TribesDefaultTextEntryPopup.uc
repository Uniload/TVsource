// ====================================================================
//  Class:  TribesGui.TribesDefaultTextEntryPopup
//  Parent: TribesGUIPage
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesDefaultTextEntryPopup extends TribesGuiPage
     ;

import enum EInputKey from Engine.Interactions;

var(TribesGui) EditInline Config GUIEditBox  MyEditBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel    MyTitleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	MyOKButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	MyCancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var String      Passback;       //passback string

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    MyOKButton.OnClick=InternalOnClick;
    MyCancelButton.OnClick=InternalOnClick;
    MyEditBox.OnEntryCompleted = InternalOnEntryCompleted;
}

event HandleParameters(string Param1, string Param2, optional int param3)
{
    MyTitleLabel.Caption = Param1;
    Passback = Param2;
	if (param3 != 0)
		MyEditBox.MaxWidth = param3;
}

function InternalOnClick(GUIComponent Sender)
{
    local GUIListElem theElem;
	switch (Sender)
	{
		case MyOKButton:
			if( MyEditBox.GetText() != "" )
            {
				theElem.item=MyEditBox.GetText();
				MyEditBox.SetText("");
				Controller.ParentPage().OnPopupReturned( theElem, Passback );
				Controller.CloseMenu();
			}
//			Log("DLG:  popup ok clicked, parentpage = "$parentpage);

            break;
		case MyCancelButton:
            Controller.CloseMenu();
            break;
	}
}

function InternalOnEntryCompleted(GUIComponent Sender)
{
    local GUIListElem theElem;
    switch (Sender)
    {
        case MyEditBox:
            if( MyEditBox.GetText() != "" )
            {
                theElem.item=MyEditBox.GetText();
                MyEditBox.SetText("");
		        Controller.ParentPage().OnPopupReturned( theElem, Passback );
                Controller.CloseMenu();
            }
            break;
    }
}

defaultproperties
{
	bPersistent=false
}