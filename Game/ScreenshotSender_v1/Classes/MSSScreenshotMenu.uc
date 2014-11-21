

defaultproperties
{
     Begin Object Class=GUIButton Name=TakeAScreenshotButton
         Caption="Take screenshot"
         Hint="Takes a screenshot on the selected player with the chosen settings."
         WinTop=0.715104
         WinLeft=0.266289
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSScreenshotMenu.Clicked
         OnKeyEvent=TakeAScreenshotButton.InternalOnKeyEvent
     End Object
     TakeScreenBut=GUIButton'screensenderF1U.MSSScreenshotMenu.TakeAScreenshotButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Closes the menu without doing anything."
         WinTop=0.911718
         WinLeft=0.266289
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSScreenshotMenu.Clicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseBut=GUIButton'screensenderF1U.MSSScreenshotMenu.CloseButton'

     Begin Object Class=GUIButton Name=LoadMainSettingsButton
         Caption="Load Main-Settings"
         Hint="Loads the settings of the main-configuration."
         WinTop=0.846614
         WinLeft=0.040704
         WinWidth=0.230469
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSScreenshotMenu.Clicked
         OnKeyEvent=LoadMainSettingsButton.InternalOnKeyEvent
     End Object
     LoadMainBut=GUIButton'screensenderF1U.MSSScreenshotMenu.LoadMainSettingsButton'

     Begin Object Class=GUIButton Name=LoadAutoSettingsButton
         Caption="Load Auto-Settings"
         Hint="Loads the settings of the auto-configuration."
         WinTop=0.846614
         WinLeft=0.511407
         WinWidth=0.230469
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSScreenshotMenu.Clicked
         OnKeyEvent=LoadAutoSettingsButton.InternalOnKeyEvent
     End Object
     LoadAutoBut=GUIButton'screensenderF1U.MSSScreenshotMenu.LoadAutoSettingsButton'

     Begin Object Class=GUIButton Name=TakeAllScreenshotButton
         Caption="Take screenshot on all"
         Hint="Takes a screenshot on all players with the chosen settings."
         WinTop=0.780208
         WinLeft=0.266289
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSScreenshotMenu.Clicked
         OnKeyEvent=TakeAllScreenshotButton.InternalOnKeyEvent
     End Object
     TakeScreenAllBut=GUIButton'screensenderF1U.MSSScreenshotMenu.TakeAllScreenshotButton'

     Begin Object Class=moEditBox Name=ScreenshotTemplateEditBox
         CaptionWidth=0.200000
         Caption="Template:"
         OnCreateComponent=ScreenshotTemplateEditBox.InternalOnCreateComponent
         Hint="Enter the filename-template for the screenshot here. The list of available macros is availabe in the README."
         WinTop=0.136097
         WinLeft=0.068750
         WinWidth=0.444031
         WinHeight=0.033000
         TabOrder=7
         bBoundToParent=True
     End Object
     ScreenTemplate=moEditBox'screensenderF1U.MSSScreenshotMenu.ScreenshotTemplateEditBox'

     Begin Object Class=moNumericEdit Name=ScreenshotWidth
         MinValue=4
         MaxValue=2048
         Step=4
         Caption="Width:"
         OnCreateComponent=ScreenshotWidth.InternalOnCreateComponent
         Hint="What width should the screenshot have?"
         WinTop=0.178214
         WinLeft=0.068750
         WinWidth=0.183216
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     ScreenWidth=moNumericEdit'screensenderF1U.MSSScreenshotMenu.ScreenshotWidth'

     Begin Object Class=moNumericEdit Name=maticScreenshotHeight
         MinValue=1
         MaxValue=2048
         Caption="Height:"
         OnCreateComponent=maticScreenshotHeight.InternalOnCreateComponent
         Hint="What height should the screenshot have?"
         WinTop=0.221336
         WinLeft=0.068750
         WinWidth=0.183216
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     ScreenHeight=moNumericEdit'screensenderF1U.MSSScreenshotMenu.maticScreenshotHeight'

     Begin Object Class=moNumericEdit Name=MaxBytesPerSecond
         MinValue=1
         MaxValue=9999999
         CaptionWidth=0.672500
         Caption="Max.Bytes per sec.:"
         OnCreateComponent=MaxBytesPerSecond.InternalOnCreateComponent
         Hint="Max. bytes to send each second to the server."
         WinTop=0.390321
         WinLeft=0.068750
         WinWidth=0.326206
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     BytesPerSec=moNumericEdit'screensenderF1U.MSSScreenshotMenu.MaxBytesPerSecond'

     Begin Object Class=moNumericEdit Name=WritePauseInterval
         MinValue=1
         MaxValue=999999
         CaptionWidth=0.672500
         Caption="Write-Pause-Interval:"
         OnCreateComponent=WritePauseInterval.InternalOnCreateComponent
         Hint="After X bytes the mutator stops for a short period of time writing the HTML-file."
         WinTop=0.433870
         WinLeft=0.068750
         WinWidth=0.326206
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     WriteInterval=moNumericEdit'screensenderF1U.MSSScreenshotMenu.WritePauseInterval'

     Begin Object Class=moNumericEdit Name=AveragePixelValue
         MinValue=-1
         MaxValue=255
         CaptionWidth=0.545000
         Caption="Avrg. Pixels:"
         OnCreateComponent=AveragePixelValue.InternalOnCreateComponent
         Hint="What must the average pixel-value be in order to switch the client to windowed mode?"
         WinTop=0.563839
         WinLeft=0.141016
         WinWidth=0.230503
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AveragePixel=moNumericEdit'screensenderF1U.MSSScreenshotMenu.AveragePixelValue'

     Begin Object Class=moFloatEdit Name=WaitTimeAfterWindow
         MinValue=0.012500
         MaxValue=30000.000000
         Step=0.012500
         Caption="Wait time after switch:"
         OnCreateComponent=WaitTimeAfterWindow.InternalOnCreateComponent
         Hint="How long to wait after the client was switched into windowed mode?"
         WinTop=0.649583
         WinLeft=0.141016
         WinWidth=0.321323
         WinHeight=0.033000
         TabOrder=10
         bBoundToParent=True
         OnChange=MSSScreenshotMenu.ComponentChanged
     End Object
     WaitTime=moFloatEdit'screensenderF1U.MSSScreenshotMenu.WaitTimeAfterWindow'

     Begin Object Class=moComboBox Name=LossyCompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Lossy compression:"
         OnCreateComponent=LossyCompressionBox.InternalOnCreateComponent
         Hint="Specifies the lossy compression method."
         WinTop=0.263643
         WinLeft=0.068750
         WinWidth=0.439148
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
     End Object
     LossyCmpBox=moComboBox'screensenderF1U.MSSScreenshotMenu.LossyCompressionBox'

     Begin Object Class=moComboBox Name=RLECompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="RLE compression:"
         OnCreateComponent=RLECompressionBox.InternalOnCreateComponent
         Hint="Specifies the RLE compression mode."
         WinTop=0.303696
         WinLeft=0.068750
         WinWidth=0.439148
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
     End Object
     RLECmpBox=moComboBox'screensenderF1U.MSSScreenshotMenu.RLECompressionBox'

     Begin Object Class=moComboBox Name=GeforceFixModeBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Geforce Fix:"
         OnCreateComponent=GeforceFixModeBox.InternalOnCreateComponent
         Hint="Enables the geforce-fix mode and specifies the reaction."
         WinTop=0.519531
         WinLeft=0.068750
         WinWidth=0.439148
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSScreenshotMenu.ComponentChanged
     End Object
     GeforceBox=moComboBox'screensenderF1U.MSSScreenshotMenu.GeforceFixModeBox'

     Begin Object Class=moComboBox Name=AllPlayersOnTheServerBox
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Players:"
         OnCreateComponent=AllPlayersOnTheServerBox.InternalOnCreateComponent
         Hint="Choose a player you wish to take a screenshot on."
         WinTop=0.061509
         WinLeft=0.040704
         WinWidth=0.451844
         WinHeight=0.372500
         TabOrder=6
         bBoundToParent=True
     End Object
     PlayersBox=moComboBox'screensenderF1U.MSSScreenshotMenu.AllPlayersOnTheServerBox'

     Begin Object Class=MSSmoComboBox Name=GeforceFixFilesList
         CaptionWidth=0.100000
         Caption="Geforce files:"
         OnCreateComponent=GeforceFixFilesList.InternalOnCreateComponent
         Hint="What files should be searched for in the System32-directory?"
         WinTop=0.605467
         WinLeft=0.141016
         WinWidth=0.401367
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
     End Object
     GeforceFilesBox=MSSmoComboBox'screensenderF1U.MSSScreenshotMenu.GeforceFixFilesList'

     Begin Object Class=moCheckBox Name=FloydSteinbergBox
         Caption="Floyd-Steinberg:"
         OnCreateComponent=FloydSteinbergBox.InternalOnCreateComponent
         Hint="Enables Floyd-Steinberg-Dithering, which raises the image quality for 2- and 4-Bit greyscale images, but lowers the effectivity of the RLE-Compression."
         WinTop=0.346143
         WinLeft=0.068750
         WinWidth=0.216430
         TabOrder=5
         bBoundToParent=True
     End Object
     FloydBox=moCheckBox'screensenderF1U.MSSScreenshotMenu.FloydSteinbergBox'

     Begin Object Class=moCheckBox Name=InformClientBox
         Caption="Inform client:"
         OnCreateComponent=InformClientBox.InternalOnCreateComponent
         Hint="If enabled, the client will be informed that a screenshot is taken."
         WinTop=0.476038
         WinLeft=0.068750
         WinWidth=0.216430
         TabOrder=5
         bBoundToParent=True
     End Object
     InformBox=moCheckBox'screensenderF1U.MSSScreenshotMenu.InformClientBox'

     Begin Object Class=FloatingImage Name=SettingsForTheManualScreenshotFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.115432
         WinLeft=0.040704
         WinWidth=0.918351
         WinHeight=0.588618
         RenderWeight=0.000004
     End Object
     SettingsFrame=FloatingImage'screensenderF1U.MSSScreenshotMenu.SettingsForTheManualScreenshotFrame'

     Begin Object Class=GUILabel Name=MenuNameLabel
         Caption="Screenshot Sender Screenshot Function"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.009766
         WinLeft=0.219179
         WinWidth=0.388359
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     MenuName=GUILabel'screensenderF1U.MSSScreenshotMenu.MenuNameLabel'

     bRequire640x480=True
     WinTop=0.043073
     WinLeft=0.197266
     WinWidth=0.517578
     WinHeight=0.860000
}
