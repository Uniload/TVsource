

defaultproperties
{
     Begin Object Class=GUIButton Name=SaveButton
         Caption="Save"
         Hint="Saves the settings and closes this menu."
         WinTop=1.002863
         WinLeft=0.017266
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     SaveBut=GUIButton'screensenderF1U.MSSSettingsMenu.SaveButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Closes this menu without saving anything."
         WinTop=1.002863
         WinLeft=0.714531
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseBut=GUIButton'screensenderF1U.MSSSettingsMenu.CloseButton'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Load Defaults"
         Hint="Loads the default values WITHOUT saving them (doesn't load the excluded and admin GUIDs)."
         WinTop=1.002863
         WinLeft=0.365874
         WinWidth=0.250000
         WinHeight=0.050000
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     ResetBut=GUIButton'screensenderF1U.MSSSettingsMenu.ResetButton'

     Begin Object Class=GUIButton Name=AutomaticAddToExcludedListButton
         Caption="Add"
         Hint="Adds a new entry to the Exluded-List of the automatic mode."
         WinTop=0.873959
         WinLeft=0.791900
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=AutomaticAddToExcludedListButton.InternalOnKeyEvent
     End Object
     AutoAddExclBut=GUIButton'screensenderF1U.MSSSettingsMenu.AutomaticAddToExcludedListButton'

     Begin Object Class=GUIButton Name=AutomaticDeleteFromExcludedListButton
         Caption="Del."
         Hint="Removes the selected entry from the Excluded-List of the automatic mode."
         WinTop=0.873959
         WinLeft=0.923784
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=AutomaticDeleteFromExcludedListButton.InternalOnKeyEvent
     End Object
     AutoDelExclBut=GUIButton'screensenderF1U.MSSSettingsMenu.AutomaticDeleteFromExcludedListButton'

     Begin Object Class=GUIButton Name=MainAddToExcludedListButton
         Caption="Add"
         Hint="Adds a new entry to the Exluded-List of the manual mode."
         WinTop=0.949479
         WinLeft=0.165997
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=MainAddToExcludedListButton.InternalOnKeyEvent
     End Object
     MainAddExclBut=GUIButton'screensenderF1U.MSSSettingsMenu.MainAddToExcludedListButton'

     Begin Object Class=GUIButton Name=MainDeleteFromExcludedListButton
         Caption="Del."
         Hint="Removes the selected entry from the Excluded-List of the manual mode."
         WinTop=0.949479
         WinLeft=0.293927
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=MainDeleteFromExcludedListButton.InternalOnKeyEvent
     End Object
     MainDelExclBut=GUIButton'screensenderF1U.MSSSettingsMenu.MainDeleteFromExcludedListButton'

     Begin Object Class=GUIButton Name=MainAddNewAdminGUIDButton
         Caption="Add"
         Hint="Adds a new entry to the Admin-GUIDs list."
         WinTop=0.284874
         WinLeft=0.165997
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=MainAddNewAdminGUIDButton.InternalOnKeyEvent
     End Object
     MainAddAdminBut=GUIButton'screensenderF1U.MSSSettingsMenu.MainAddNewAdminGUIDButton'

     Begin Object Class=GUIButton Name=MainDeleteAdminGUIDButton
         Caption="Del."
         Hint="Removes the selected entry from the Admin-GUIDs list."
         WinTop=0.284874
         WinLeft=0.293927
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=MainDeleteAdminGUIDButton.InternalOnKeyEvent
     End Object
     MainDelAdminBut=GUIButton'screensenderF1U.MSSSettingsMenu.MainDeleteAdminGUIDButton'

     Begin Object Class=GUIButton Name=AutomaticAddToTargetsListButton
         Caption="Add"
         Hint="Adds a new entry to the Targets-List of the automatic mode."
         WinTop=0.955730
         WinLeft=0.791900
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=AutomaticAddToTargetsListButton.InternalOnKeyEvent
     End Object
     AutoAddTargetBut=GUIButton'screensenderF1U.MSSSettingsMenu.AutomaticAddToTargetsListButton'

     Begin Object Class=GUIButton Name=AutomaticDeleteFromTargetsListButton
         Caption="Del."
         Hint="Removes the selected entry from the Targets-List of the automatic mode."
         WinTop=0.955730
         WinLeft=0.923784
         WinWidth=0.088867
         WinHeight=0.035352
         TabOrder=27
         bBoundToParent=True
         OnClick=MSSSettingsMenu.Clicked
         OnKeyEvent=AutomaticDeleteFromTargetsListButton.InternalOnKeyEvent
     End Object
     AutoDelTargetBut=GUIButton'screensenderF1U.MSSSettingsMenu.AutomaticDeleteFromTargetsListButton'

     Begin Object Class=moEditBox Name=AutomaticScreenshotTemplateEditBox
         CaptionWidth=0.200000
         Caption="Template:"
         OnCreateComponent=AutomaticScreenshotTemplateEditBox.InternalOnCreateComponent
         Hint="Enter the filename-template for automatic screenshots here. The list of available macros is availabe in the README."
         WinTop=0.322295
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=7
         bBoundToParent=True
     End Object
     AutoScreenTemplate=moEditBox'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotTemplateEditBox'

     Begin Object Class=moEditBox Name=MainScreenshotTemplateEditBox
         CaptionWidth=0.200000
         Caption="Template:"
         OnCreateComponent=MainScreenshotTemplateEditBox.InternalOnCreateComponent
         Hint="Enter the filename-template for manaul screenshots here. The list of available macros is availabe in the README."
         WinTop=0.376983
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=7
         bBoundToParent=True
     End Object
     MainScreenTemplate=moEditBox'screensenderF1U.MSSSettingsMenu.MainScreenshotTemplateEditBox'

     Begin Object Class=moEditBox Name=MainMutatorNameInServerInfoEditBox
         CaptionWidth=0.265000
         Caption="Mut.Name:"
         OnCreateComponent=MainMutatorNameInServerInfoEditBox.InternalOnCreateComponent
         Hint="Specifies what name should appear in the server-info."
         WinTop=0.207031
         WinLeft=-0.071875
         WinWidth=0.412781
         TabOrder=7
         bBoundToParent=True
     End Object
     MainMutName=moEditBox'screensenderF1U.MSSSettingsMenu.MainMutatorNameInServerInfoEditBox'

     Begin Object Class=moNumericEdit Name=AutomaticScreenshotWidth
         MinValue=4
         MaxValue=2048
         Step=4
         Caption="Width:"
         OnCreateComponent=AutomaticScreenshotWidth.InternalOnCreateComponent
         Hint="What width should the screenshot have? Must be a multiple of 4."
         WinTop=0.361808
         WinLeft=0.555078
         WinWidth=0.153919
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AutoScreenWidth=moNumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotWidth'

     Begin Object Class=moNumericEdit Name=AutomaticScreenshotHeight
         MinValue=1
         MaxValue=2048
         Caption="Height:"
         OnCreateComponent=AutomaticScreenshotHeight.InternalOnCreateComponent
         Hint="What height should the screenshot have?"
         WinTop=0.401024
         WinLeft=0.555078
         WinWidth=0.153919
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AutoScreenHeight=moNumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotHeight'

     Begin Object Class=moNumericEdit Name=AutomaticMaxBytesPerSecond
         MinValue=1
         MaxValue=9999999
         Step=100
         CaptionWidth=0.625000
         Caption="Max.Bytes per sec.:"
         OnCreateComponent=AutomaticMaxBytesPerSecond.InternalOnCreateComponent
         Hint="Max. bytes to send each second to the server. For an optimum of speed/lag only use multiples of 255."
         WinTop=0.556988
         WinLeft=0.555078
         WinWidth=0.296909
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AutoBytesPerSec=moNumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticMaxBytesPerSecond'

     Begin Object Class=moNumericEdit Name=AutomaticWritePauseInterval
         MinValue=1
         MaxValue=999999
         Caption="Write-Pause-Interval:"
         OnCreateComponent=AutomaticWritePauseInterval.InternalOnCreateComponent
         Hint="After X bytes the mutator stops for a short period of time writing the HTML-file."
         WinTop=0.596631
         WinLeft=0.555078
         WinWidth=0.326206
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AutoWriteInterval=moNumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticWritePauseInterval'

     Begin Object Class=moNumericEdit Name=AutomaticAveragePixelValue
         MinValue=0
         MaxValue=255
         CaptionWidth=0.625000
         Caption="Avrg. Pixels:"
         OnCreateComponent=AutomaticAveragePixelValue.InternalOnCreateComponent
         Hint="What must the average pixel-value be in order to switch the client to windowed mode?"
         WinTop=0.713579
         WinLeft=0.600000
         WinWidth=0.282261
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     AutoAveragePixel=moNumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticAveragePixelValue'

     Begin Object Class=moNumericEdit Name=MainScreenshotWidth
         MinValue=4
         MaxValue=2048
         Step=4
         Caption="Width:"
         OnCreateComponent=MainScreenshotWidth.InternalOnCreateComponent
         Hint="What width should the screenshot have? Must be a multiple of 4."
         WinTop=0.417798
         WinLeft=-0.071875
         WinWidth=0.153919
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     MainScreenWidth=moNumericEdit'screensenderF1U.MSSSettingsMenu.MainScreenshotWidth'

     Begin Object Class=moNumericEdit Name=MainScreenshotHeight
         MinValue=1
         MaxValue=2048
         Caption="Height:"
         OnCreateComponent=MainScreenshotHeight.InternalOnCreateComponent
         Hint="What height should the screenshot have?"
         WinTop=0.458316
         WinLeft=-0.071875
         WinWidth=0.153919
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     MainScreenHeight=moNumericEdit'screensenderF1U.MSSSettingsMenu.MainScreenshotHeight'

     Begin Object Class=moNumericEdit Name=MainMaxBytesPerSecond
         MinValue=100
         MaxValue=9999999
         CaptionWidth=0.625000
         Caption="Max.Bytes per sec.:"
         OnCreateComponent=MainMaxBytesPerSecond.InternalOnCreateComponent
         Hint="Max. bytes to send each second to the server. For an optimum of speed/lag only use multiples of 255."
         WinTop=0.623393
         WinLeft=-0.071875
         WinWidth=0.296909
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     MainBytesPerSec=moNumericEdit'screensenderF1U.MSSSettingsMenu.MainMaxBytesPerSecond'

     Begin Object Class=moNumericEdit Name=MainWritePauseInterval
         MinValue=1
         MaxValue=999999
         Caption="Write-Pause-Interval:"
         OnCreateComponent=MainWritePauseInterval.InternalOnCreateComponent
         Hint="After X bytes the mutator stops for a short period of time writing the HTML-file."
         WinTop=0.664338
         WinLeft=-0.071875
         WinWidth=0.326206
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     MainWriteInterval=moNumericEdit'screensenderF1U.MSSSettingsMenu.MainWritePauseInterval'

     Begin Object Class=moNumericEdit Name=MainAveragePixelValue
         MinValue=0
         MaxValue=255
         CaptionWidth=0.625000
         Caption="Avrg. Pixels:"
         OnCreateComponent=MainAveragePixelValue.InternalOnCreateComponent
         Hint="What must the average pixel-value be in order to switch the client to windowed mode?"
         WinTop=0.791703
         WinLeft=-0.026953
         WinWidth=0.282261
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
     End Object
     MainAveragePixel=moNumericEdit'screensenderF1U.MSSSettingsMenu.MainAveragePixelValue'

     Begin Object Class=moFloatEdit Name=AutomaticWaitTimeAfterWindow
         MinValue=0.012500
         MaxValue=30000.000000
         Step=0.012500
         Caption="Wait time after switch:"
         OnCreateComponent=AutomaticWaitTimeAfterWindow.InternalOnCreateComponent
         Hint="How long to wait after the client was switched into windowed mode?"
         WinTop=0.796719
         WinLeft=0.600000
         WinWidth=0.321323
         WinHeight=0.033000
         TabOrder=10
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoWaitTime=moFloatEdit'screensenderF1U.MSSSettingsMenu.AutomaticWaitTimeAfterWindow'

     Begin Object Class=moFloatEdit Name=MainWaitTimeAfterWindow
         MinValue=0.012500
         MaxValue=30000.000000
         Step=0.012500
         Caption="Wait time after switch:"
         OnCreateComponent=MainWaitTimeAfterWindow.InternalOnCreateComponent
         Hint="How long to wait after the client was switched into windowed mode?"
         WinTop=0.872239
         WinLeft=-0.026953
         WinWidth=0.321323
         WinHeight=0.033000
         TabOrder=10
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainWaitTime=moFloatEdit'screensenderF1U.MSSSettingsMenu.MainWaitTimeAfterWindow'

     Begin Object Class=moComboBox Name=AutomaticLossyCompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Lossy compression:"
         OnCreateComponent=AutomaticLossyCompressionBox.InternalOnCreateComponent
         Hint="Specifies the lossy compression method."
         WinTop=0.440726
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoLossyCmpBox=moComboBox'screensenderF1U.MSSSettingsMenu.AutomaticLossyCompressionBox'

     Begin Object Class=moComboBox Name=AutomaticRLECompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="RLE compression:"
         OnCreateComponent=AutomaticRLECompressionBox.InternalOnCreateComponent
         Hint="Specifies the RLE compression mode."
         WinTop=0.480779
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoRLECmpBox=moComboBox'screensenderF1U.MSSSettingsMenu.AutomaticRLECompressionBox'

     Begin Object Class=moComboBox Name=AutomaticGeforceFixModeBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Geforce Fix:"
         OnCreateComponent=AutomaticGeforceFixModeBox.InternalOnCreateComponent
         Hint="Enables the geforce-fix mode and specifies the reaction."
         WinTop=0.673177
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoGeforceBox=moComboBox'screensenderF1U.MSSSettingsMenu.AutomaticGeforceFixModeBox'

     Begin Object Class=moComboBox Name=MainLossyCompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Lossy compression:"
         OnCreateComponent=MainLossyCompressionBox.InternalOnCreateComponent
         Hint="Specifies the lossy compression method."
         WinTop=0.500622
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainLossyCmpBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainLossyCompressionBox'

     Begin Object Class=moComboBox Name=MainRLECompressionBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="RLE compression:"
         OnCreateComponent=MainRLECompressionBox.InternalOnCreateComponent
         Hint="Specifies the RLE compression mode."
         WinTop=0.543278
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.372500
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainRLECmpBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainRLECompressionBox'

     Begin Object Class=moComboBox Name=MainGeforceFixModeBox
         bReadOnly=True
         CaptionWidth=0.372500
         Caption="Geforce Fix:"
         OnCreateComponent=MainGeforceFixModeBox.InternalOnCreateComponent
         Hint="Enables the geforce-fix mode and specifies the reaction."
         WinTop=0.749999
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainGeforceBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainGeforceFixModeBox'

     Begin Object Class=moComboBox Name=MainSelfCheckToPreventHackedPkgBox
         bReadOnly=True
         CaptionWidth=0.265000
         Caption="Self Check:"
         OnCreateComponent=MainSelfCheckToPreventHackedPkgBox.InternalOnCreateComponent
         Hint="Enables the self check which prevents that a client hacked this package to bypass the screenshot."
         WinTop=0.042968
         WinLeft=-0.071875
         WinWidth=0.412781
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainSelfCheckBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainSelfCheckToPreventHackedPkgBox'

     Begin Object Class=moComboBox Name=MainSecurityProblemReactionBox
         bReadOnly=True
         CaptionWidth=0.265000
         Caption="Security Problem React.:"
         OnCreateComponent=MainSecurityProblemReactionBox.InternalOnCreateComponent
         Hint="Specifies the reaction if a security problem occurs (like a not-taken screenshot)."
         WinTop=0.084895
         WinLeft=-0.071875
         WinWidth=0.412781
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainSecProbReactionBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainSecurityProblemReactionBox'

     Begin Object Class=moComboBox Name=MainSecurityProblemNonWindowsReactionBox
         bReadOnly=True
         CaptionWidth=0.265000
         Caption="Security Problem (NonWin) React:"
         OnCreateComponent=MainSecurityProblemNonWindowsReactionBox.InternalOnCreateComponent
         Hint="Specifies the reaction if a security problem occurs, which can happen legally on non-windows systems."
         WinTop=0.126562
         WinLeft=-0.071875
         WinWidth=0.412781
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainSecProbNonWinReactionBox=moComboBox'screensenderF1U.MSSSettingsMenu.MainSecurityProblemNonWindowsReactionBox'

     Begin Object Class=MSSmoComboBox Name=AutomaticGeforceFixFilesList
         CaptionWidth=0.372500
         Caption="Geforce files:"
         OnCreateComponent=AutomaticGeforceFixFilesList.InternalOnCreateComponent
         Hint="What files should be searched for in the System32-directory?"
         WinTop=0.753905
         WinLeft=0.600000
         WinWidth=0.378906
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoGeforceFilesBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.AutomaticGeforceFixFilesList'

     Begin Object Class=MSSmoComboBox Name=AutomaticExcludedGUIDsList
         CaptionWidth=0.372500
         Caption="Excluded GUIDs:"
         OnCreateComponent=AutomaticExcludedGUIDsList.InternalOnCreateComponent
         Hint="No automatic screenshot will be taken on players with a GUID in this list. Disabled, if the targets exist."
         WinTop=0.837239
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoExcludedBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.AutomaticExcludedGUIDsList'

     Begin Object Class=MSSmoComboBox Name=MainGeforceFixFilesList
         CaptionWidth=0.372500
         Caption="Geforce files:"
         OnCreateComponent=MainGeforceFixFilesList.InternalOnCreateComponent
         Hint="What files should be searched for in the System32-directory?"
         WinTop=0.830727
         WinLeft=-0.026953
         WinWidth=0.378906
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainGeforceFilesBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.MainGeforceFixFilesList'

     Begin Object Class=MSSmoComboBox Name=MainExcludedGUIDsList
         CaptionWidth=0.372500
         Caption="Excluded GUIDs:"
         OnCreateComponent=MainExcludedGUIDsList.InternalOnCreateComponent
         Hint="No screenshot will be taken on players with a GUID in this list, if the screenshot was started though the TakeScreenAll-command."
         WinTop=0.912759
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainExcludedBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.MainExcludedGUIDsList'

     Begin Object Class=MSSmoComboBox Name=MainAdminGUIDsList
         CaptionWidth=0.237500
         Caption="Admin GUIDs:"
         OnCreateComponent=MainAdminGUIDsList.InternalOnCreateComponent
         Hint="Players, whose GUID is in this list, can perfrom ALL commands of the screenshot sender without logging in as admin."
         WinTop=0.248698
         WinLeft=-0.071875
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainAdminGUIDsBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.MainAdminGUIDsList'

     Begin Object Class=MSSmoComboBox Name=AutomaticTagetsGUIDsList
         CaptionWidth=0.372500
         Caption="Auto. Targets:"
         OnCreateComponent=AutomaticTagetsGUIDsList.InternalOnCreateComponent
         Hint="If this has at least 1 element, the automatic screenshots are only taken for players in this list. The excluded players list is then disabled and not used anymore."
         WinTop=0.919010
         WinLeft=0.555078
         WinWidth=0.412781
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoTargetsBox=MSSmoComboBox'screensenderF1U.MSSSettingsMenu.AutomaticTagetsGUIDsList'

     Begin Object Class=moCheckBox Name=AutomaticFloydSteinbergBox
         Caption="Floyd-Steinberg:"
         OnCreateComponent=AutomaticFloydSteinbergBox.InternalOnCreateComponent
         Hint="Enables Floyd-Steinberg-Dithering, which raises the image quality for 2- and 4-Bit greyscale images, but lowers the effectivity of the RLE-Compression."
         WinTop=0.519320
         WinLeft=0.555078
         WinWidth=0.182250
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoFloydBox=moCheckBox'screensenderF1U.MSSSettingsMenu.AutomaticFloydSteinbergBox'

     Begin Object Class=moCheckBox Name=AutomaticInformClientBox
         Caption="Inform client:"
         OnCreateComponent=AutomaticInformClientBox.InternalOnCreateComponent
         Hint="If enabled, the client will be informed that a screenshot is taken."
         WinTop=0.634893
         WinLeft=0.555078
         WinWidth=0.177367
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoInformBox=moCheckBox'screensenderF1U.MSSSettingsMenu.AutomaticInformClientBox'

     Begin Object Class=moCheckBox Name=MainFloydSteinbergBox
         Caption="Floyd-Steinberg:"
         OnCreateComponent=MainFloydSteinbergBox.InternalOnCreateComponent
         Hint="Enables Floyd-Steinberg-Dithering, which raises the image quality for 2- and 4-Bit greyscale images, but lowers the effectivity of the RLE-Compression."
         WinTop=0.584423
         WinLeft=-0.071875
         WinWidth=0.182250
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainFloydBox=moCheckBox'screensenderF1U.MSSSettingsMenu.MainFloydSteinbergBox'

     Begin Object Class=moCheckBox Name=MainInformClientBox
         Caption="Inform client:"
         OnCreateComponent=MainInformClientBox.InternalOnCreateComponent
         Hint="If enabled, the client will be informed that a screenshot is taken."
         WinTop=0.706506
         WinLeft=-0.071875
         WinWidth=0.177367
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainInformBox=moCheckBox'screensenderF1U.MSSSettingsMenu.MainInformClientBox'

     Begin Object Class=moCheckBox Name=MainKickPlayersForExceptionsBox
         Caption="Kick for exceptions:"
         OnCreateComponent=MainKickPlayersForExceptionsBox.InternalOnCreateComponent
         Hint="If enabled, the clients will be kicked for unexcepted errors."
         WinTop=0.167445
         WinLeft=-0.071875
         WinWidth=0.269164
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     MainKickForExceptionsBox=moCheckBox'screensenderF1U.MSSSettingsMenu.MainKickPlayersForExceptionsBox'

     Begin Object Class=FloatingImage Name=AutomaticSettingsFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.304688
         WinLeft=0.535156
         WinWidth=0.607030
         WinHeight=0.700572
         RenderWeight=0.000004
     End Object
     AutoFrame=FloatingImage'screensenderF1U.MSSSettingsMenu.AutomaticSettingsFrame'

     Begin Object Class=FloatingImage Name=MainSettingsFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.356166
         WinLeft=-0.089844
         WinWidth=0.607030
         WinHeight=0.645885
         RenderWeight=0.000004
     End Object
     MainFrame=FloatingImage'screensenderF1U.MSSSettingsMenu.MainSettingsFrame'

     Begin Object Class=FloatingImage Name=AutmaticEnableSettingsFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.020046
         WinLeft=0.535156
         WinWidth=0.607030
         WinHeight=0.269583
         RenderWeight=0.000004
     End Object
     AutoEnableFrame=FloatingImage'screensenderF1U.MSSSettingsMenu.AutmaticEnableSettingsFrame'

     Begin Object Class=FloatingImage Name=OtherMainSettingsFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.020046
         WinLeft=-0.089844
         WinWidth=0.607030
         WinHeight=0.319062
         RenderWeight=0.000004
     End Object
     MainOtherFrame=FloatingImage'screensenderF1U.MSSSettingsMenu.OtherMainSettingsFrame'

     Begin Object Class=FloatingImage Name=AutomaticExcludedAndTargetsFrame
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         DropShadow=None
         ImageColor=(G=156,R=66,A=190)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.830066
         WinLeft=0.542969
         WinWidth=0.591404
         WinHeight=0.168541
         RenderWeight=0.000004
     End Object
     AutoExclTargetsFrame=FloatingImage'screensenderF1U.MSSSettingsMenu.AutomaticExcludedAndTargetsFrame'

     Begin Object Class=GUILabel Name=MenuNameLabel
         Caption="Screenshot Sender Settings"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=-0.036458
         WinLeft=0.383437
         WinWidth=0.290703
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     MenuName=GUILabel'screensenderF1U.MSSSettingsMenu.MenuNameLabel'

     Begin Object Class=GUILabel Name=MainSettingsHeaderLabel
         Caption="Manual screenshot settings:"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.337240
         WinLeft=-0.066758
         WinWidth=0.272148
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     MainSettingsHeader=GUILabel'screensenderF1U.MSSSettingsMenu.MainSettingsHeaderLabel'

     Begin Object Class=GUILabel Name=AutoSettingsHeaderLabel
         Caption="Automatic screenshot settings:"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.287760
         WinLeft=0.565078
         WinWidth=0.296562
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoSettingsHeader=GUILabel'screensenderF1U.MSSSettingsMenu.AutoSettingsHeaderLabel'

     Begin Object Class=GUILabel Name=AutoEnableHeaderLabel
         Caption="Automatic screenshots:"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.002604
         WinLeft=0.565078
         WinWidth=0.223320
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoEnableHeader=GUILabel'screensenderF1U.MSSSettingsMenu.AutoEnableHeaderLabel'

     Begin Object Class=GUILabel Name=MainOtherHeaderLabel
         Caption="Other settings:"
         TextColor=(B=0,G=207,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.002604
         WinLeft=-0.066758
         WinWidth=0.145195
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     MainOtherHeader=GUILabel'screensenderF1U.MSSSettingsMenu.MainOtherHeaderLabel'

     Begin Object Class=moCheckBox Name=AutomaticScreenshotsAreEnabledBox
         Caption="Automatic screenshots:"
         OnCreateComponent=AutomaticScreenshotsAreEnabledBox.InternalOnCreateComponent
         Hint="Enables the automatic screenshots feature."
         WinTop=0.065104
         WinLeft=0.555078
         WinWidth=0.270202
         TabOrder=5
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoEnabled=moCheckBox'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotsAreEnabledBox'

     Begin Object Class=GUINumericEdit Name=AutomaticScreenshotIntervalMin
         MinValue=1
         MaxValue=999999
         Hint="Specifies the lower bound of the interval after which an automatic screenshot is taken."
         WinTop=0.162760
         WinLeft=0.643945
         WinWidth=0.087852
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
         OnDeActivate=AutomaticScreenshotIntervalMin.ValidateValue
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoNumMin=GUINumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotIntervalMin'

     Begin Object Class=GUINumericEdit Name=AutomaticScreenshotIntervalMax
         MinValue=1
         MaxValue=999999
         Hint="Specifies the upper bound of the interval after which an automatic screenshot is taken."
         WinTop=0.162760
         WinLeft=0.784570
         WinWidth=0.087852
         WinHeight=0.033000
         TabOrder=8
         bBoundToParent=True
         OnDeActivate=AutomaticScreenshotIntervalMax.ValidateValue
         OnChange=MSSSettingsMenu.ComponentChanged
     End Object
     AutoNumMax=GUINumericEdit'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotIntervalMax'

     Begin Object Class=GUILabel Name=AutomaticScreenshotsTextOneLabel
         Caption="Take a screenshot after"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.113282
         WinLeft=0.600000
         WinWidth=0.272148
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoText1=GUILabel'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotsTextOneLabel'

     Begin Object Class=GUILabel Name=AutomaticScreenshotsTextTwoLabel
         Caption="-"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.162760
         WinLeft=0.768555
         WinWidth=0.012383
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoText2=GUILabel'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotsTextTwoLabel'

     Begin Object Class=GUILabel Name=AutomaticScreenshotsTextThreeLabel
         Caption="and"
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.218750
         WinLeft=0.643945
         WinWidth=0.042656
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoText3=GUILabel'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotsTextThreeLabel'

     Begin Object Class=GUILabel Name=AutomaticScreenshotsTextFourLabel
         Caption="loop."
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2MidGameFont"
         WinTop=0.218750
         WinLeft=0.833633
         WinWidth=0.081718
         WinHeight=0.035586
         bBoundToParent=True
     End Object
     AutoText4=GUILabel'screensenderF1U.MSSSettingsMenu.AutomaticScreenshotsTextFourLabel'

     Begin Object Class=GUIComboBox Name=AutoScreenOnDeathBox
         bReadOnly=True
         Hint="Changes if the interval specifies the number of deaths or time."
         WinTop=0.162760
         WinLeft=0.908203
         WinWidth=0.119812
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
         OnKeyEvent=AutoScreenOnDeathBox.InternalOnKeyEvent
     End Object
     AutoDeathBox=GUIComboBox'screensenderF1U.MSSSettingsMenu.AutoScreenOnDeathBox'

     Begin Object Class=GUIComboBox Name=AutoScreenLoopBox
         bReadOnly=True
         Hint="Specifies if more than one automatic screenshot is taken."
         WinTop=0.218750
         WinLeft=0.699219
         WinWidth=0.090515
         WinHeight=0.033000
         TabOrder=6
         bBoundToParent=True
         OnChange=MSSSettingsMenu.ComponentChanged
         OnKeyEvent=AutoScreenLoopBox.InternalOnKeyEvent
     End Object
     AutoLoopBox=GUIComboBox'screensenderF1U.MSSSettingsMenu.AutoScreenLoopBox'

     bRequire640x480=True
     WinTop=0.062604
     WinLeft=0.107422
     WinWidth=0.750000
     WinHeight=0.860000
}
