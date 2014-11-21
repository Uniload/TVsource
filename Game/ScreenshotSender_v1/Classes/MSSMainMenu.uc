

defaultproperties
{
     Begin Object Class=GUIButton Name=SettingsMenuButton
         Caption="Settings"
         Hint="Opens the screenshot-sender settings menu."
         WinTop=0.423594
         WinLeft=0.065547
         WinWidth=0.178320
         WinHeight=0.050000
         TabOrder=7
         bBoundToParent=True
         OnClick=MSSMainMenu.Clicked
         OnKeyEvent=SettingsMenuButton.InternalOnKeyEvent
     End Object
     SettingsBut=GUIButton'screensenderF1U.MSSMainMenu.SettingsMenuButton'

     Begin Object Class=GUIButton Name=ScreenshotTakerButton
         Caption="Take screenshot"
         Hint="Opens a menu in which you can take screenshots."
         WinTop=0.173177
         WinLeft=0.202266
         WinWidth=0.261328
         WinHeight=0.050000
         TabOrder=7
         bBoundToParent=True
         OnClick=MSSMainMenu.Clicked
         OnKeyEvent=ScreenshotTakerButton.InternalOnKeyEvent
     End Object
     ScreenBut=GUIButton'screensenderF1U.MSSMainMenu.ScreenshotTakerButton'

     Begin Object Class=GUIButton Name=InformationButton
         Caption="Info"
         Hint="Credits, contact, etc."
         WinTop=0.423594
         WinLeft=0.520625
         WinWidth=0.178320
         WinHeight=0.050000
         TabOrder=7
         bBoundToParent=True
         OnClick=MSSMainMenu.Clicked
         OnKeyEvent=InformationButton.InternalOnKeyEvent
     End Object
     InfoBut=GUIButton'screensenderF1U.MSSMainMenu.InformationButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Closes this window."
         WinTop=0.689219
         WinLeft=0.291133
         WinWidth=0.178320
         WinHeight=0.050000
         TabOrder=7
         bBoundToParent=True
         OnClick=MSSMainMenu.Clicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseBut=GUIButton'screensenderF1U.MSSMainMenu.CloseButton'

     Begin Object Class=GUILabel Name=MenuNameLabel
         Caption="Screenshot Sender by Gugi"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=-0.056997
         WinLeft=0.255227
         WinWidth=0.295586
         bBoundToParent=True
     End Object
     MenuName=GUILabel'screensenderF1U.MSSMainMenu.MenuNameLabel'

     WinTop=0.460938
     WinLeft=0.277890
     WinWidth=0.440000
     WinHeight=0.271289
}
