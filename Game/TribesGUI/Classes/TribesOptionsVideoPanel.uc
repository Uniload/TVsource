// ====================================================================
//  Class:  TribesGui.TribesOptionsVideoMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesOptionsVideoPanel extends TribesSettingsPanel
	native;

var(TribesGui) private EditInline Config GUIComboBox BMDBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox DSDBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox GlowDBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox TexDBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox ResolutionBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox RenderDetailBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox MacroBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox DecoBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox FluidBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox FogBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox WorldBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox PS2Box "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUISlider BrightnessSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUISlider ContrastSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUISlider GammaSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton ApplyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton DefaultsButton "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config localized Array<string> DetailChoices;
var(TribesGui) private EditInline Config localized Array<string> RenderDetailChoices;
var(TribesGui) private EditInline Config localized Array<string> OnOffChoices;
var(TribesGui) private EditInline Config localized string SwitchingResText;
var(TribesGui) private EditInline Config localized string ResSwitchedText;
var(TribesGui) private EditInline Config localized string ResFailedText;
var(TribesGui) private EditInline Config localized string ChangesText;

var string LastResolution;
var bool bIsDataDirty;
var bool bTimerHack;
var GUIDlg promptDlg;
var GUIPanel targetPanel;
var int InitialRenderDetail;
var bool bExiting;

function InitComponent(GUIComponent MyOwner)
{
    local int i;
	Super.InitComponent(MyOwner);

	for (i = 0; i < DetailChoices.Length; i++)
		BMDBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		DSDBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		GlowDBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		TexDBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		FluidBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		FogBox.AddItem(DetailChoices[i]);

	for (i = 0; i < DetailChoices.Length; i++)
		WorldBox.AddItem(DetailChoices[i]);

	for (i = 0; i < OnOffChoices.Length; i++)
		MacroBox.AddItem(OnOffChoices[i]);

	for (i = 0; i < OnOffChoices.Length; i++)
		DecoBox.AddItem(OnOffChoices[i]);

	for (i = 0; i < RenderDetailChoices.Length; i++)
		RenderDetailBox.AddItem(RenderDetailChoices[i]);

	for (i = 0; i < OnOffChoices.Length; i++)
		PS2Box.AddItem(OnOffChoices[i]);

	for( i = 0; i < GC.ScreenResolutionChoices.Length; i++ )
	{
       	ResolutionBox.AddItem(GC.ScreenResolutionChoices[i]);
    }

	ApplyButton.OnClick=OnApply;
	OnShow=InternalOnShow;
	OnHide=InternalOnHide;
	GUIPage(MenuOwner.MenuOwner).OnDlgReturned=InternalOnDlgReturned;
}

function InternalOnShow()
{
	InitialRenderDetail = int(PlayerOwner().ConsoleCommand( "GETRENDERDETAIL" ));

	DefaultsButton.bCanBeShown = false;
	DefaultsButton.Hide();

	bIsDataDirty = false;
	LoadSettings(true);
	DefaultsButton.OnClick=OnDefaults;
	
	GUITabControl(MenuOwner).OnSwitch = OnOwnerTabSwitch;
}

function InternalOnHide()
{
	GUITabControl(MenuOwner).OnSwitch = None;

	// reset render detail
	if (bIsDataDirty)
		PlayerOwner().ConsoleCommand("RENDERDETAIL "$InitialRenderDetail$" 0 1");
}

function OnSettingsDirty()
{
	GUIPage(MenuOwner.MenuOwner).OnDlgReturned=InternalOnConfirmApplyDlgReturned;
	Deactivate();
	TribesGUIPage(MenuOwner.MenuOwner).OpenDlg(ChangesText, QBTN_YesNo, "");
}

function bool OnOwnerTabSwitch(GUIPanel Target)
{
	if (bIsDataDirty)
	{
		targetPanel = Target;
		OnSettingsDirty();
		return true;
	}

	return false;
}

function OnOptionsEnding()
{
	if (bIsDataDirty)
	{
		bExiting = true;
		OnSettingsDirty();
	}
	else
	{
		Super.OnOptionsEnding();
	}
}

function OnVideoApplyFinished()
{
	if (targetPanel != None)
	{
		GUITabControl(MenuOwner).OpenTab(targetPanel);
		targetPanel = None;
	}
	else if (bExiting)
	{
		bExiting = false;
		Super.OnOptionsEnding();
	}
}

function InternalOnConfirmApplyDlgReturned(int Button, string Passback)
{
	Activate();

	if (Button == QBTN_Yes)
	{
		ApplyVidSettings();
	}
	else
	{
		OnVideoApplyFinished();
	}
}

function OnApply(GUIComponent Sender)
{
	ApplyVidSettings();
}

function OnCustomSelection(GUIComponent Sender)
{
	RenderDetailBox.SetIndex(4);
	bIsDataDirty = true;
}

function OnRenderDetail(GUIComponent Sender)
{
	SetRenderDetail(true);
	if (RenderDetailBox.GetIndex() != 4)
	{
		LoadSettings(false);
	}
}

function SetRenderDetail(bool save)
{
	if (RenderDetailBox.GetIndex() == 4)
	{
		LOG("Custom detail (-1)");
		PlayerOwner().ConsoleCommand("RENDERDETAIL -1 0 "$int(save));
	}
	else
	{
		LOG("Setting render detail to "$RenderDetailBox.GetIndex());
		PlayerOwner().ConsoleCommand("RENDERDETAIL "$RenderDetailBox.GetIndex()$" 0 "$int(save));
	}

	bIsDataDirty = true;
}

// returns true if changed res
function ApplyVidSettings()
{
	SetRenderDetail(true);

	SetRenderDetailSetting( "SET Engine.RenderConfig BumpmapDetail", BMDBox.GetIndex() );
    SetRenderDetailSetting( "SET Engine.RenderConfig DynamicShadowDetail", DSDBox.GetIndex() );
    SetRenderDetailSetting( "SET Engine.RenderConfig GlowEffectDetail", GlowDBox.GetIndex() );
    SetRenderDetailSetting( "SET Engine.RenderConfig FluidSurfaceDetail", FluidBox.GetIndex() );
    SetRenderDetailSetting( "SET Engine.RenderConfig FogDistance", FogBox.GetIndex() );
    PlayerOwner().ConsoleCommand( "SET Engine.RenderConfig DisableDecoLayers "$DecoBox.GetIndex() );
    PlayerOwner().ConsoleCommand( "SET Engine.RenderConfig DisableTerrainMacro "$MacroBox.GetIndex() );
    PlayerOwner().ConsoleCommand( "SET Engine.RenderConfig Allow20Shaders "$!bool(PS2Box.GetIndex()) );
	PlayerOwner().ConsoleCommand( "TextureDetail "$TexDBox.GetIndex()$" 0 1" );
	PlayerOwner().ConsoleCommand( "WorldDetail "$WorldBox.GetIndex()$" 0 1" );
    PlayerOwner().ConsoleCommand( "SET WinDrv.WindowsClient Brightness "$BrightnessSlider.Value );
    PlayerOwner().ConsoleCommand( "SET WinDrv.WindowsClient Contrast "$ContrastSlider.Value );
    PlayerOwner().ConsoleCommand( "SET WinDrv.WindowsClient Gamma "$GammaSlider.Value );

	bIsDataDirty = false;

	if (PlayerOwner().ConsoleCommand( "GETCURRENTRES" ) != ResolutionBox.GetText())
	{
		TryResSwitch();
		return;
	}

	PlayerOwner().ConsoleCommand("FLUSH");
	OnVideoApplyFinished();
}

function LoadSettings(bool UpdateRes)
{
	local int RenderDetail;

	RenderDetailBox.OnListIndexChanged=None;
	BMDBox.OnListIndexChanged=None;
	DSDBox.OnListIndexChanged=None;
	GlowDBox.OnListIndexChanged=None;
	TexDBox.OnListIndexChanged=None;
	FluidBox.OnListIndexChanged=None;
	DecoBox.OnListIndexChanged=None;
	MacroBox.OnListIndexChanged=None;
	WorldBox.OnListIndexChanged=None;
	FogBox.OnListIndexChanged=None;
	PS2Box.OnListIndexChanged=None;
	BrightnessSlider.OnChange=None;
	ContrastSlider.OnChange=None;
	GammaSlider.OnChange=None;
	
	RenderDetail = int(PlayerOwner().ConsoleCommand( "GETRENDERDETAIL" ));
	if (RenderDetail == -1)
		RenderDetailBox.SetIndex(4);
	else
		RenderDetailBox.SetIndex(RenderDetail);

	log("Render detail is "$RenderDetail);

	GetRenderDetailSetting(TexDBox, "Get Engine.RenderConfig TextureDetail");
    GetRenderDetailSetting(BMDBox, "GET Engine.RenderConfig BumpmapDetail");
    GetRenderDetailSetting(DSDBox, "GET Engine.RenderConfig DynamicShadowDetail");
    GetRenderDetailSetting(GlowDBox, "GET Engine.RenderConfig GlowEffectDetail");
    GetRenderDetailSetting(FluidBox, "GET Engine.RenderConfig FluidSurfaceDetail");
    GetRenderDetailSetting(FogBox, "GET Engine.RenderConfig FogDistance");
    GetRenderDetailSetting(WorldBox, "GET Engine.RenderConfig WorldDetail");
	DecoBox.SetIndex( int(PlayerOwner().ConsoleCommand( "GET Engine.RenderConfig DisableDecoLayers" )) );
	MacroBox.SetIndex( int(PlayerOwner().ConsoleCommand( "GET Engine.RenderConfig DisableTerrainMacro" )) );
	PS2Box.SetIndex( int(!bool(PlayerOwner().ConsoleCommand( "GET Engine.RenderConfig Allow20Shaders" ))) );
	if (UpdateRes)
		ResolutionBox.Find( PlayerOwner().ConsoleCommand( "GETCURRENTRES" ) );
    BrightnessSlider.SetValue( float(PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Brightness" ) ));
    ContrastSlider.SetValue( float(PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Contrast" ) ));
    GammaSlider.SetValue( float(PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Gamma" ) ));

	RenderDetailBox.OnListIndexChanged=OnRenderDetail;
	BMDBox.OnListIndexChanged=OnCustomSelection;
	DSDBox.OnListIndexChanged=OnCustomSelection;
	GlowDBox.OnListIndexChanged=OnCustomSelection;
	TexDBox.OnListIndexChanged=OnCustomSelection;
	FluidBox.OnListIndexChanged=OnCustomSelection;
	DecoBox.OnListIndexChanged=OnCustomSelection;
	MacroBox.OnListIndexChanged=OnCustomSelection;
	WorldBox.OnListIndexChanged=OnCustomSelection;
	FogBox.OnListIndexChanged=OnCustomSelection;
	PS2Box.OnListIndexChanged=OnCustomSelection;
	BrightnessSlider.OnChange=OnBrightness;
	ContrastSlider.OnChange=OnContrast;
	GammaSlider.OnChange=OnGamma;
}

function GetRenderDetailSetting(GUIComboBox box, string cmd)
{
	local string Setting;
	Setting = PlayerOwner().ConsoleCommand( cmd );
	if (Setting == "Off")
		box.SetIndex(0);
	else if (Setting == "Low")
		box.SetIndex(1);
	else if (Setting == "Medium")
		box.SetIndex(2);
	else if (Setting == "High")
		box.SetIndex(3);
}

function SetRenderDetailSetting(string cmd, int idx)
{
	switch (idx)
	{
	case 0:
		cmd $= " Off";
		break;
	case 1:
		cmd $= " Low";
		break;
	case 2:
		cmd $= " Medium";
		break;
	case 3:
		cmd $= " High";
		break;
	}

	log(cmd);
	PlayerOwner().ConsoleCommand( cmd );
}

function TryResSwitch()
{
	GUIPage(MenuOwner.MenuOwner).OnDlgReturned=InternalOnDlgReturned;
	Deactivate();
	TribesGUIPage(MenuOwner.MenuOwner).OpenDlg(SwitchingResText, QBTN_OkCancel, "1");
}

function Timer()
{
	Activate();
	if (bTimerHack)
	{
		// this is needed because of a large-delta frame problem with GUI timers
		SetTimer(15, false);
		bTimerHack = false;
	}
	else
	{
		PlayerOwner().ConsoleCommand( "SETRES "$LastResolution );
		ResolutionBox.Find( LastResolution );
		MenuOwner.MenuOwner.EnableComponent();
		MenuOwner.MenuOwner.Focus();
		GUIPage(MenuOwner.MenuOwner).RemoveComponent(promptDlg);
	}
}

function InternalOnDlgReturned(int Button, string Passback)
{
	Activate();

	if (Passback == "1")
	{
		if (Button == QBTN_Ok)
		{
			Controller.OnPostPrecache = OnPostPrecache;
			LastResolution = PlayerOwner().ConsoleCommand( "GETCURRENTRES" );
			PlayerOwner().ConsoleCommand( "SETRES "$ResolutionBox.GetText() );
		}
	}
	else if (Passback == "2")
	{
		SetTimer(0, false);

		OnVideoApplyFinished();
	}
}

function OnPostPrecache()
{
	log("Precache Finished");
	GUIPage(MenuOwner.MenuOwner).OnDlgReturned=InternalOnDlgReturned;
	Controller.OnPostPrecache = None;
	bTimerHack = true;
	SetTimer(1, false);

	if (PlayerOwner().ConsoleCommand( "GETCURRENTRES" ) == ResolutionBox.GetText())
	{
		Deactivate();
		promptDlg = TribesGUIPage(MenuOwner.MenuOwner).OpenDlg(ResSwitchedText, QBTN_Ok, "2");
	}
	else
	{
		ResolutionBox.Find( PlayerOwner().ConsoleCommand( "GETCURRENTRES" ) );
		Deactivate();
		promptDlg = TribesGUIPage(MenuOwner.MenuOwner).OpenDlg(ResFailedText, QBTN_Ok, "2");
	}
}

function OnDefaults(GUIComponent Sender)
{
	RestoreDefaults();
	LoadSettings(true);
	PlayerOwner().ConsoleCommand( "BRIGHTNESS "$PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Brightness" ));
	PlayerOwner().ConsoleCommand( "CONTRAST "$PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Contrast" ));
	PlayerOwner().ConsoleCommand( "GAMMA "$PlayerOwner().ConsoleCommand( "GET WinDrv.WindowsClient Gamma" ));
	OnRenderDetail(RenderDetailBox);
}

native function RestoreDefaults();

function OnBrightness(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand( "BRIGHTNESS "$GUISlider(Sender).Value);
	bIsDataDirty = true;
}

function OnContrast(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand( "CONTRAST "$GUISlider(Sender).Value);
	bIsDataDirty = true;
}

function OnGamma(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand( "GAMMA "$GUISlider(Sender).Value);
	bIsDataDirty = true;
}

defaultproperties
{
	DetailChoices=("Low/Off","Medium","High","Ultra-High")
	RenderDetailChoices=("Low","Medium","High","Ultra-High","Custom")
	OnOffChoices=("On","Off")
	SwitchingResText="The screen's resolution will now be changed. If you experience problems, wait 15 seconds and the resolution setting will be restored."
	ResSwitchedText="Press OK to keep this resolution setting."
	ChangesText="Changes to video settings will be lost unless they are applied. Would you like to apply them now?"
	ResFailedText="Your video card is unable to display the game at that resolution. The next closest match has been selected. Press OK to keep this resolution."
}
