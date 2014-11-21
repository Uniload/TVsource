//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVWatcherMenu extends GUIPage;

var bool bIgnoreEsc;

var float BoxHeight;
var float BoxWidth;
var float MarginWidth;
var float ItemHeight;
var float ItemGap;

var TribesTVInteraction ui;
var TribesTVReplication ur;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local TribesTVInteraction tui;
	local TribesTVReplication tur;

	super.InitComponent(MyController, MyOwner);

	//The window
	Controls[0].WinHeight = BoxHeight;
	Controls[0].WinWidth = BoxWidth;
	Controls[0].WinTop = 0.5 - (0.5 * BoxHeight);
	Controls[0].WinLeft = 0.5 - (0.5 * BoxWidth);

	//Headline
	Controls[1].WinHeight = ItemHeight;
	Controls[1].WinWidth = BoxWidth - (MarginWidth * 2);
	Controls[1].WinTop = Controls[0].WinTop + ItemGap * 2;
	Controls[1].WinLeft = Controls[0].WinLeft + MarginWidth;

	//label
	Controls[2].WinHeight = ItemHeight;
	Controls[2].WinWidth = Controls[1].WinWidth;
	Controls[2].WinTop = Controls[1].WinTop + ItemGap * 2 + ItemHeight;
	Controls[2].WinLeft = Controls[1].WinLeft;

	//combobox
	Controls[3].WinHeight = ItemHeight;
	Controls[3].WinWidth = Controls[1].WinWidth;
	Controls[3].WinTop = Controls[2].WinTop + ItemHeight - ItemGap;
	Controls[3].WinLeft = Controls[1].WinLeft;
	moComboBox (Controls[3]).AddItem ("Locked during free flight");
	moComboBox (Controls[3]).AddItem ("Completely locked");
	moComboBox (Controls[3]).AddItem ("Completely free");
	moComboBox (Controls[3]).ReadOnly (true);
	moComboBox (Controls[3]).SetIndex (class'TribesTVReplication'.default.ViewMode);

	//label delay
	Controls[4].WinHeight = ItemHeight;
	Controls[4].WinWidth = Controls[3].WinWidth;
	Controls[4].WinTop = Controls[3].WinTop + ItemGap * 2 + ItemHeight;
	Controls[4].WinLeft = Controls[3].WinLeft;

	//label clients
	Controls[5].WinHeight = ItemHeight;
	Controls[5].WinWidth = Controls[4].WinWidth;
	Controls[5].WinTop = Controls[4].WinTop + ItemGap + ItemHeight;
	Controls[5].WinLeft = Controls[4].WinLeft;

	//ok button
	Controls[6].WinHeight = ItemHeight;
	Controls[6].WinWidth = Controls[1].WinWidth / 2;
	Controls[6].WinTop = Controls[5].WinTop + ItemHeight * 4 + ItemGap;
	Controls[6].WinLeft = 0.5 - (0.5 * Controls[6].WinWidth);

	//label follow primary
	Controls[7].WinHeight = ItemHeight;
	Controls[7].WinWidth = Controls[5].WinWidth;
	Controls[7].WinTop = Controls[5].WinTop + ItemGap + ItemHeight;
	Controls[7].WinLeft = Controls[5].WinLeft;

	//button follow primary
	Controls[8].WinHeight = ItemHeight;
	Controls[8].WinWidth = ItemHeight;
	Controls[8].WinTop = Controls[5].WinTop + ItemHeight;
	Controls[8].WinLeft = Controls[5].WinLeft+Controls[5].WinWidth/2;

	//label show TribesTV chat
	Controls[9].WinHeight = ItemHeight;
	Controls[9].WinWidth = Controls[7].WinWidth;
	Controls[9].WinTop = Controls[7].WinTop + ItemGap + ItemHeight;
	Controls[9].WinLeft = Controls[7].WinLeft;

	//button show TribesTV chat
	Controls[10].WinHeight = ItemHeight;
	Controls[10].WinWidth = ItemHeight;
	Controls[10].WinTop = Controls[7].WinTop + ItemHeight;
	Controls[10].WinLeft = Controls[7].WinLeft+Controls[7].WinWidth/2;

	OnKeyEvent = InternalOnKeyEvent;
	OnClose = InternalOnClose;

	foreach AllObjects (class'TribesTVInteraction', tui) {
		ui = tui;
	}
	foreach AllObjects (class'TribesTVReplication', tur) {
		ur = tur;
	}

	GUILabel(Controls[4]).Caption='Delay ' $ string(ui.Delay);
	GUILabel(Controls[5]).Caption='Total clients ' $ string(ui.Clients);
	GUICheckBoxButton(Controls[8]).bChecked=ur.FollowPrimary;
	GUICheckBoxButton(Controls[10]).bChecked=!ur.MuteChat;
	if(!ur.SeeAll){
		GUILabel(Controls[7]).Caption="See all mode disabled";
		Controls[8].WinHeight = 0;
		Controls[8].WinWidth = 0;
	}
	if(ur.NoPrimary){
		GUILabel(Controls[7]).Caption="See all mode without primary client";
		Controls[8].WinHeight = 0;
		Controls[8].WinWidth = 0;
	}
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if(bIgnoreEsc && Key == 0x1B)
	{
		bIgnoreEsc = false;
		return true;
	}
}

function InternalOnClose(optional bool bCanceled)
{
	local PlayerController pc;

	pc = PlayerOwner();

	if(pc != None && pc.Level.Pauser != None)
		pc.SetPause(false);

	Super.OnClose(bCanceled);
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender == Controls[6])	//Ok button
	{
		if(!ur.NoPrimary)
			ur.FollowPrimary=GUICheckBoxButton(Controls[8]).bChecked;
		ur.MuteChat=!GUICheckBoxButton(Controls[10]).bChecked;
        SaveDefaults ();
		Controller.CloseMenu ();
	}

	return true;
}

function InternalOnChange(GUIComponent Sender)
{
}

function SaveDefaults ()
{
	class 'TribesTVReplication'.default.ViewMode = moComboBox(Controls[3]).GetIndex ();
	class 'TribesTVReplication'.static.StaticSaveConfig ();
}

defaultproperties
{
	Begin Object Class=GUIButton name=Background
		bAcceptsInput=false
		bNeverFocus=true
		StyleName="SquareBar"
	End Object
	Controls(0)=GUIButton'Background'

	Begin Object class=GUILabel Name=TitleText
		Caption="TribesTV2003 Watcher settings"
		TextAlign=TXTA_Center
		TextColor=(R=255,G=255,B=0,A=255)
		bTransparent=true
		bMultiLine=true
		Name="TitleText"
	End Object
	Controls(1)=GUILabel'TitleText'

	Begin Object class=GUILabel name=Label1
	  Caption="View rotation"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	  bMultiLine=true
	End Object
	Controls(2)=GUILabel'Label1'

	Begin Object class=moComboBox Name=ComboBox
	  Caption=""
      CaptionWidth=0.0
	  OnChange=InternalOnChange
	End Object
	Controls(3)=moComboBox'ComboBox'

	Controls(4)=GUILabel'Label1'
	Controls(5)=GUILabel'Label1'

	Begin Object Class=GUIButton Name=OkButton
		StyleName="MidGameButton"
		OnClick=InternalOnClick
		Caption="OK"
	End Object
	Controls(6)=GUIButton'OkButton'

	Begin Object class=GUILabel name=Label2
	  Caption="Follow primary"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	  bMultiLine=true
	End Object
	Controls(7)=GUILabel'Label2'

	Begin Object class=GUICheckBoxButton name=Button2
	End Object
	Controls(8)=GUICheckBoxButton'Button2'

	Begin Object class=GUILabel name=Label3
	  Caption="Show TribesTV Chat"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	  bMultiLine=true
	End Object
	Controls(9)=GUILabel'Label3'

	Begin Object class=GUICheckBoxButton name=Button3
	End Object
	Controls(10)=GUICheckBoxButton'Button3'

	bIgnoreEsc=true
	bRequire640x480=false
	bAllowedAsLast=true
	bRenderWorld=true

	BoxHeight=0.46
	BoxWidth=0.5
	MarginWidth=0.02
	ItemHeight=0.04
	ItemGap=0.01

	OpenSound=none
}
