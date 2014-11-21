// ====================================================================
//  Class:  TribesGui.TribesOptionsAudioMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesOptionsAudioPanel extends TribesSettingsPanel
	native;

var(TribesGui) private EditInline Config GUISlider SoundVolumeSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUISlider MusicVolumeSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUISlider SpeechVolumeSlider "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton DefaultsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGUI) private EditInline Config GUICheckBoxButton Use3DCheck;
var(TribesGUI) private EditInline Config GUICheckBoxButton UseDefaultDriverCheck;
//var(TribesGUI) private EditInline Config GUICheckBoxButton UseEAXCheck;
var(TribesGUI) private EditInline Config GUICheckBoxButton CompatibilityCheck;
var(TribesGUI) private EditInline Config GUICheckBoxButton ReverseStereoCheck;
var(TribesGUI) private EditInline Config GUICheckBoxButton LowQualityCheck;
var(TribesGUI) private EditInline Config GUICheckBoxButton ChatWindowCheck;

var bool bIsDataDirty;


function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	SoundVolumeSlider.OnChange=OnSliderChange;
    MusicVolumeSlider.OnChange=OnSliderChange;
    SpeechVolumeSlider.OnChange=OnSliderChange;
	Use3DCheck.OnClick=OnUse3D;
	UseDefaultDriverCheck.OnClick=OnUseDefaultDriver;
	//UseEAXCheck.OnClick=OnUseEAX;
	CompatibilityCheck.OnClick=OnCompatibility;
	ReverseStereoCheck.OnClick=OnReverseStereo;
	LowQualityCheck.OnClick=OnLowQuality;
	ChatWindowCheck.OnClick=OnChatWindow;

	OnShow=InternalOnShow;
	OnHide=InternalOnHide;

	bIsDataDirty = false;
}

function InternalOnShow()
{
	DefaultsButton.bCanBeShown = true;
	DefaultsButton.Show();

	DefaultsButton.OnClick=OnDefaults;

	SoundVolumeSlider.Value = float(PlayerOwner().ConsoleCommand("get alaudio.alaudiosubsystem soundvolume"));
	MusicVolumeSlider.Value = float(PlayerOwner().ConsoleCommand("get alaudio.alaudiosubsystem musicvolume"));
	SpeechVolumeSlider.Value = float(PlayerOwner().ConsoleCommand("get alaudio.alaudiosubsystem SpeechVolume"));
	Use3DCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem Use3DSound"));
	UseDefaultDriverCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem UseDefaultDriver"));
	//UseEAXCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem UseEAX"));
	CompatibilityCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem CompatibilityMode"));
	ReverseStereoCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem ReverseStereo"));
	LowQualityCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET ALAudio.ALAudioSubsystem LowQualitySound"));
	ChatWindowCheck.bChecked = bool(PlayerOwner().ConsoleCommand("GET Gameplay.SinglePlayerGameInfo bShowSubtitles"));
}

function InternalOnHide()
{
	if (bIsDataDirty)
		PlayerOwner().ConsoleCommand("SOUND_REBOOT 1");
}

function OnSliderChange(GUIComponent Sender)
{
	switch(Sender)
	{
		case SoundVolumeSlider:
			PlayerOwner().ConsoleCommand("set alaudio.alaudiosubsystem soundvolume "$GUISlider(Sender).Value);
			PlayerOwner().TriggerEffectEvent('Watched',,,,,,,,'STY_RoundLargeButton');
			break;
		case MusicVolumeSlider:
			PlayerOwner().ConsoleCommand("set alaudio.alaudiosubsystem musicvolume "$GUISlider(Sender).Value);
			break;
		case SpeechVolumeSlider:
			PlayerOwner().ConsoleCommand("set alaudio.alaudiosubsystem SpeechVolume "$GUISlider(Sender).Value);
			break;
	}
}

function OnUse3D(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem Use3DSound "$Use3DCheck.bChecked);
	bIsDataDirty = true;
}

function OnUseDefaultDriver(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem UseDefaultDriver "$UseDefaultDriverCheck.bChecked);
	bIsDataDirty = true;
}

function OnUseEAX(GUIComponent Sender)
{
	//PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem UseEAX "$UseEAXCheck.bChecked);
	//bIsDataDirty = true;
}

function OnCompatibility(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem CompatibilityMode "$CompatibilityCheck.bChecked);
	bIsDataDirty = true;
}

function OnReverseStereo(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem ReverseStereo "$ReverseStereoCheck.bChecked);
	bIsDataDirty = true;
}

function OnLowQuality(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET ALAudio.ALAudioSubsystem LowQualitySound "$LowQualityCheck.bChecked);
}

function OnChatWindow(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("SET Gameplay.SinglePlayerGameInfo bShowSubtitles "$ChatWindowCheck.bChecked);
	PlayerOwner().ConsoleCommand("SET MojoActions.TsAction bShowSubtitles "$ChatWindowCheck.bChecked);
	bIsDataDirty = true;
}

function OnDefaults(GUIComponent Sender)
{
	RestoreDefaults();
	InternalOnShow();

	PlayerOwner().ConsoleCommand("SET MojoActions.TsAction bShowSubtitles "$ChatWindowCheck.bChecked);
}

native function RestoreDefaults();

defaultproperties
{
}
