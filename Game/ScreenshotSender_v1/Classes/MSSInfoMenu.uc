

defaultproperties
{
     Begin Object Class=GUILabel Name=Info0Label
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
         WinTop=0.370000
         WinLeft=0.370000
         WinWidth=0.570000
     End Object
     InfoLabels(0)=GUILabel'screensenderF1U.MSSInfoMenu.Info0Label'

     Begin Object Class=GUILabel Name=Info3Label
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
         WinTop=0.420000
         WinLeft=0.370000
         WinWidth=0.570000
         WinHeight=0.100000
     End Object
     InfoLabels(1)=GUILabel'screensenderF1U.MSSInfoMenu.Info3Label'

     Begin Object Class=GUILabel Name=Info4Label
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
         WinTop=0.600000
         WinLeft=0.417500
         WinWidth=0.570000
     End Object
     InfoLabels(2)=GUILabel'screensenderF1U.MSSInfoMenu.Info4Label'

     Begin Object Class=GUILabel Name=Info5Label
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
         WinTop=0.520000
         WinLeft=0.370000
         WinWidth=0.570000
     End Object
     InfoLabels(3)=GUILabel'screensenderF1U.MSSInfoMenu.Info5Label'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Close this window"
         WinTop=0.641719
         WinLeft=0.554922
         WinWidth=0.150000
         WinHeight=0.050000
         TabOrder=1
         OnClick=MSSInfoMenu.Clicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseBut=GUIButton'screensenderF1U.MSSInfoMenu.CloseButton'

     Info(0)="Screenshot Sender Final by Gugi"
     Info(2)="Copyright (C) 2007-2008 Gugi, All rights reserved."
     Info(3)="If you found any bugs or if you have any suggestions:"
     HPColor=(G=207,R=255,A=255)
     InfoColor=(B=255,G=255,R=255,A=255)
     WinTop=0.315000
     WinLeft=0.350000
     WinWidth=0.600000
     WinHeight=0.400000
}
