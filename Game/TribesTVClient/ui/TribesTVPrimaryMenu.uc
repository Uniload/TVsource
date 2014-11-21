//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVPrimaryMenu extends ut2k3guIPage;

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
	local int a, prev, mark;
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

	//label total clients
	Controls[2].WinHeight = ItemHeight;
	Controls[2].WinWidth = BoxWidth*0.4;
	Controls[2].WinTop = Controls[1].WinTop + ItemGap * 2 + ItemHeight;
	Controls[2].WinLeft = Controls[1].WinLeft;


	///mmuuu

	//label mute
	Controls[24].WinHeight = ItemHeight;
	Controls[24].WinWidth = BoxWidth*0.4;
	Controls[24].WinTop = Controls[2].WinTop + ItemGap + ItemHeight;
	Controls[24].WinLeft = Controls[2].WinLeft;

	//divider
	Controls[26].WinHeight = 0.005;
	Controls[26].WinWidth = BoxWidth - (MarginWidth * 2);
	Controls[26].WinTop = Controls[24].WinTop + ItemGap + ItemHeight;
	Controls[26].WinLeft = Controls[2].WinLeft;



	//label serveraddress
	Controls[3].WinHeight = ItemHeight;
	Controls[3].WinWidth = Controls[24].WinWidth;
	Controls[3].WinTop = Controls[24].WinTop + ItemGap * 3 + ItemHeight;
	Controls[3].WinLeft = Controls[24].WinLeft;

	//rest of the labels
	prev=3;
	mark=0;
	for(a=4;a<11;++a){
		if ((a == 8) && (mark == 0)) {		//would renumbering have been easier? :)
			a = 22;
			mark = 1;
		}
		Controls[a].WinHeight = ItemHeight;
		Controls[a].WinWidth = Controls[prev].WinWidth;
		Controls[a].WinTop = Controls[prev].WinTop + ItemGap + ItemHeight;
		Controls[a].WinLeft = Controls[prev].WinLeft;

		prev=a;
		if ((a == 22) && (mark == 1))
			a = 7;
	}

	//ok button
	Controls[11].WinHeight = ItemHeight;
	Controls[11].WinWidth = Controls[10].WinWidth;
	Controls[11].WinTop = Controls[10].WinTop + ItemHeight * 2;
	Controls[11].WinLeft = Controls[10].WinLeft;

	//textbox total clients
	Controls[12].WinHeight = ItemHeight;
	Controls[12].WinWidth = BoxWidth*0.5;
	Controls[12].WinTop = Controls[1].WinTop + ItemGap * 2 + ItemHeight;
	Controls[12].WinLeft = Controls[0].WinLeft+BoxWidth*0.5;


	//muu
	//checkbox mute chat
	Controls[25].WinHeight = ItemHeight;
	Controls[25].WinWidth = ItemHeight;
	Controls[25].WinTop = Controls[12].WinTop + ItemGap + ItemHeight;
	Controls[25].WinLeft = Controls[12].WinLeft;


	//textbox serveraddress
	Controls[13].WinHeight = ItemHeight;
	Controls[13].WinWidth = BoxWidth*0.4;
	Controls[13].WinTop = Controls[25].WinTop + ItemGap * 3 + ItemHeight;
	Controls[13].WinLeft = Controls[25].WinLeft;

	//rest of the textboxes
	prev=13;
	mark=0;
	for(a=14;a<21;++a){
		if ((a == 18) && (mark == 0)) {
			a = 23;
			mark = 1;
		}
		Controls[a].WinHeight = ItemHeight;
		Controls[a].WinWidth = Controls[prev].WinWidth;
		Controls[a].WinTop = Controls[prev].WinTop + ItemGap + ItemHeight;
		Controls[a].WinLeft = Controls[prev].WinLeft;

		prev=a;
		if ((a == 23) && (mark == 1))
			a = 17;
	}

	//reset button
	Controls[21].WinHeight = ItemHeight;
	Controls[21].WinWidth = Controls[20].WinWidth;
	Controls[21].WinTop = Controls[20].WinTop + ItemHeight * 2;
	Controls[21].WinLeft = Controls[20].WinLeft;

	foreach AllObjects (class'TribesTVInteraction', tui) {
		ui = tui;
	}
	foreach AllObjects (class'TribesTVReplication', tur) {
		ur = tur;
	}

	GUILabel(Controls[12]).Caption=string(ui.Clients);
	GUIEditBox(Controls[13]).TextStr=ui.ServerAddress;
	GUIEditBox(Controls[14]).TextStr=string(ui.ServerPort);
	GUIEditBox(Controls[15]).TextStr=string(ui.ListenPort);
	GUIEditBox(Controls[16]).TextStr=ui.JoinPassword;
	GUIEditBox(Controls[17]).TextStr=ui.PrimaryPassword;
	GUIEditBox(Controls[18]).TextStr=ui.NormalPassword;
	GUIEditBox(Controls[19]).TextStr=string(ui.Delay);
	GUIEditBox(Controls[20]).TextStr=string(ui.MaxClients);
	GUIEditBox(Controls[23]).TextStr=ui.VipPassword;
	GUICheckBoxButton(Controls[25]).bChecked=!ur.MuteChat;

	OnKeyEvent = InternalOnKeyEvent;
	OnClose = InternalOnClose;
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
	if (Sender == Controls[11])	//Ok button
	{
		ur.MuteChat=!GUICheckBoxButton(Controls[25]).bChecked;
        SendChanges ();
		Controller.CloseMenu ();
	}
	if (Sender == Controls[21])	//Reset button
	{
		ui.p.ClientMessage ("Resetting server");
        SendChanges ();
        ResetServer ();
		Controller.CloseMenu ();
	}

	return true;
}

function InternalOnChange(GUIComponent Sender)
{
}

function SendChanges ()
{
	local string s;

	ui.ServerAddress=GUIEditBox(Controls[13]).TextStr;
	ui.ServerPort=int(GUIEditBox(Controls[14]).TextStr);
	ui.ListenPort=int(GUIEditBox(Controls[15]).TextStr);
	ui.JoinPassword=GUIEditBox(Controls[16]).TextStr;
	ui.PrimaryPassword=GUIEditBox(Controls[17]).TextStr;
	ui.NormalPassword=GUIEditBox(Controls[18]).TextStr;
	ui.Delay=float(GUIEditBox(Controls[19]).TextStr);
	ui.MaxClients=int(GUIEditBox(Controls[20]).TextStr);
	ui.VipPassword=GUIEditBox(Controls[23]).TextStr;

	s="5 serveraddress=" $ ui.ServerAddress;
	s=s $ " serverport=" $ ui.ServerPort;
	s=s $ " listenport=" $ ui.ListenPort;
	s=s $ " joinpassword=" $ ui.JoinPassword;
	s=s $ " primarypassword=" $ ui.PrimaryPassword;
	s=s $ " vippassword=" $ ui.VipPassword;
	s=s $ " normalpassword=" $ ui.NormalPassword;
	s=s $ " delay=" $ ui.Delay;
	s=s $ " maxclients=" $ ui.maxclients;

	ur.SendToServer(s);
}

function ResetServer ()
{
	local string s;

	s="6 ";
	ur.SendToServer(s);
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
		Caption="TribesTV2003 Primary settings"
		TextAlign=TXTA_Center
		TextColor=(R=255,G=255,B=0,A=255)
		bTransparent=true
		Name="TitleText"
	End Object
	Controls(1)=GUILabel'TitleText'

	Begin Object class=GUILabel name=Label1
	  Caption="Total clients"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(2)=GUILabel'Label1'

	Begin Object class=GUILabel name=LabelSA
	  Caption="Server address"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(3)=GUILabel'LabelSA'

	Begin Object class=GUILabel name=LabelSP
	  Caption="Server port"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(4)=GUILabel'LabelSP'

	Begin Object class=GUILabel name=LabelLP
	  Caption="Listen port"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(5)=GUILabel'LabelLP'

	Begin Object class=GUILabel name=LabelJP
	  Caption="Join password"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(6)=GUILabel'LabelJP'

	Begin Object class=GUILabel name=LabelPP
	  Caption="Primary password"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(7)=GUILabel'LabelPP'

	Begin Object class=GUILabel name=LabelVP
	  Caption="VIP password"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(22)=GUILabel'LabelVP'

	Begin Object class=GUILabel name=LabelNP
	  Caption="Normal password"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(8)=GUILabel'LabelNP'

	Begin Object class=GUILabel name=LabelD
	  Caption="Delay"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(9)=GUILabel'LabelD'

	Begin Object class=GUILabel name=LabelMC
	  Caption="Max clients"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(10)=GUILabel'LabelMC'

	Begin Object Class=GUIButton Name=OkButton
		StyleName="MidGameButton"
		OnClick=InternalOnClick
		Caption="OK"
	End Object
	Controls(11)=GUIButton'OkButton'

	Begin Object class=GUILabel name=LabelTC
	  Caption="tc"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	  bMultiLine=true
	End Object
	Controls(12)=GUILabel'LabelTC'

	Begin Object class=GUIEditBox name=BoxSA
	  Caption=""
	End Object
	Controls(13)=GUIEditBox'BoxSA'

	Begin Object class=GUIEditBox name=BoxSP
	  Caption=""
	  bIntOnly=true;
	End Object
	Controls(14)=GUIEditBox'BoxSP'

	Begin Object class=GUIEditBox name=BoxLP
	  Caption=""
	  bIntOnly=true;
	End Object
	Controls(15)=GUIEditBox'BoxLP'

	Begin Object class=GUIEditBox name=BoxJP
	  Caption=""
	End Object
	Controls(16)=GUIEditBox'BoxJP'

	Begin Object class=GUIEditBox name=BoxPP
	  Caption=""
	End Object
	Controls(17)=GUIEditBox'BoxPP'

	Begin Object class=GUIEditBox name=BoxVP
	  Caption=""
	End Object
	Controls(23)=GUIEditBox'BoxVP'

	Begin Object class=GUIEditBox name=BoxNP
	  Caption=""
	End Object
	Controls(18)=GUIEditBox'BoxNP'

	Begin Object class=GUIEditBox name=BoxD
	  Caption=""
	  bFloatOnly=true;
	End Object
	Controls(19)=GUIEditBox'BoxD'

	Begin Object class=GUIEditBox name=BoxMC
	  Caption=""
	  bIntOnly=true;
	End Object
	Controls(20)=GUIEditBox'BoxMC'

	Begin Object Class=GUIButton Name=ResetButton
		StyleName="MidGameButton"
		OnClick=InternalOnClick
		Caption="Reset"
	End Object
	Controls(21)=GUIButton'ResetButton'

	Begin Object class=GUILabel name=LabelMute
	  Caption="Show TribesTV Chat"
	  TextColor=(R=255,G=255,B=255,A=255)
	  TextFont="UT2MidGameFont"
	  bTransparent=true
	End Object
	Controls(24)=GUILabel'LabelMute'

	Begin Object class=GUICheckBoxButton name=MuteButton
	End Object
	Controls(25)=GUICheckBoxButton'MuteButton'

	Begin Object Class=GUIEditBox name=HorizLine
		bAcceptsInput=false
		bNeverFocus=true
		Caption=""
	End Object
	Controls(26)=GUIButton'HorizLine'

	bIgnoreEsc=true
	bRequire640x480=false
	bAllowedAsLast=true
	bRenderWorld=true

	BoxHeight=0.74
	BoxWidth=0.5
	MarginWidth=0.02
	ItemHeight=0.04
	ItemGap=0.01

	OpenSound=none
}
