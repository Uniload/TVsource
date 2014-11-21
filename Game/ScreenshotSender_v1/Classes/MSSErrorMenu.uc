

defaultproperties
{
     Begin Object Class=GUILabel Name=ErrorDescLabel
         Caption="Error!"
         TextColor=(B=0,R=255)
         TextFont="UT2MidGameFont"
         bMultiLine=True
         WinTop=0.231719
         WinLeft=0.420000
         WinWidth=0.290234
         WinHeight=0.104883
     End Object
     ErrorDesc=GUILabel'screensenderF1U.MSSErrorMenu.ErrorDescLabel'

     Begin Object Class=GUIButton Name=OK_ReadTheTextButton
         Caption="OK"
         Hint="Closes all windows."
         WinTop=0.338229
         WinLeft=0.465000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=1
         OnClick=MSSErrorMenu.Clicked
         OnKeyEvent=OK_ReadTheTextButton.InternalOnKeyEvent
     End Object
     OkBut=GUIButton'screensenderF1U.MSSErrorMenu.OK_ReadTheTextButton'

     bAllowedAsLast=True
     WinTop=0.199000
     WinLeft=0.400000
     WinWidth=0.330000
     WinHeight=0.220000
}
