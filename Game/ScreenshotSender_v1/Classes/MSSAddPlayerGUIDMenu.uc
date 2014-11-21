

defaultproperties
{
     Begin Object Class=GUIButton Name=OkButton
         Caption="Add GUID"
         Hint="Adds the GUID/the GUID of the player to the list."
         WinTop=0.605729
         WinLeft=0.073907
         WinWidth=0.206055
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSAddPlayerGUIDMenu.Clicked
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     OkBut=GUIButton'screensenderF1U.MSSAddPlayerGUIDMenu.OkButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Closes this menu adding a GUID."
         WinTop=0.605729
         WinLeft=0.517265
         WinWidth=0.206055
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSAddPlayerGUIDMenu.Clicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseBut=GUIButton'screensenderF1U.MSSAddPlayerGUIDMenu.CloseButton'

     Begin Object Class=moComboBox Name=AllPlayersOnTheServerBox
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Choose player:"
         OnCreateComponent=AllPlayersOnTheServerBox.InternalOnCreateComponent
         Hint="Choose a player whose GUID you would like to add to the list."
         WinTop=0.176092
         WinLeft=0.043359
         WinWidth=0.451844
         WinHeight=0.372500
         TabOrder=6
         bBoundToParent=True
     End Object
     PlayersBox=moComboBox'screensenderF1U.MSSAddPlayerGUIDMenu.AllPlayersOnTheServerBox'

     Begin Object Class=moEditBox Name=ManualGUIDBox
         CaptionWidth=0.100000
         Caption="or enter GUID:"
         OnCreateComponent=ManualGUIDBox.InternalOnCreateComponent
         Hint="Use this to manually specify a GUID."
         WinTop=0.381510
         WinLeft=0.102930
         WinWidth=0.422547
         WinHeight=0.033000
         TabOrder=7
         bBoundToParent=True
         OnChange=MSSAddPlayerGUIDMenu.ComponentChanged
     End Object
     GUIDBox=moEditBox'screensenderF1U.MSSAddPlayerGUIDMenu.ManualGUIDBox'

     Begin Object Class=GUILabel Name=MenuNameLabel
         Caption="Add a GUID to a list"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=-0.020507
         WinLeft=0.346328
         WinWidth=0.290703
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     MenuName=GUILabel'screensenderF1U.MSSAddPlayerGUIDMenu.MenuNameLabel'

     WinTop=0.290468
     WinLeft=0.281250
     WinWidth=0.500977
     WinHeight=0.205703
}
