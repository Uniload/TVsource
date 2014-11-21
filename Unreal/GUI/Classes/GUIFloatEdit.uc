// ====================================================================
// (C) 2002, Epic Games
// ====================================================================
/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUIFloatEdit extends GUIMultiComponent
        HideCategories(Menu,Object)
	Native;


cpptext
{
		void Draw(UCanvas* Canvas);
}

var   GUIEditBox MyEditBox;
var   GUISpinnerButton MyPlus;
var   GUISpinnerButton MyMinus;

var(GUIFloatEdit) config string				Value "Current value of this edit box";
var(GUIFloatEdit) config bool				bLeftJustified "Justified to the left";
var(GUIFloatEdit) config float				MinValue "Minimum acceptable value";
var(GUIFloatEdit) config float				MaxValue "Maximum acceptable value";
var(GUIFloatEdit) config float				Step "Amount applied to an add or subtract button click";

function OnConstruct(GUIController MyController)
{
    Super.OnConstruct(MyController);

	MyEditBox=GUIEditBox(AddComponent( "GUI.GUIEditBox" , self.Name$"_Editbox"));
	MyPlus=GUISpinnerButton(AddComponent( "GUI.GUISpinnerButton" , self.Name$"_Plus"));
	MyMinus=GUISpinnerButton(AddComponent( "GUI.GUISpinnerButton" , self.Name$"_Minus"));
}

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	MyEditBox.SetText("");
	MyEditBox.bFloatOnly=true;
	
	MyPlus.PlusButton=true;
	
	MyMinus.PlusButton=false;

	MyEditBox.OnChange = EditOnChange;
	MyEditBox.SetText(Value);
	MyEditBox.OnKeyEvent = EditKeyEvent;

	CalcMaxLen();

	MyPlus.OnClick = SpinnerPlusClick;
	MyPlus.SetFocusInstead(MyEditBox);
	MyMinus.OnClick = SpinnerMinusClick;
	MyMinus.SetFocusInstead(MyEditBox);

    SetHint(Hint);

}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
}

function CalcMaxLen()
{
	local int digitcount,x;

	digitcount=1;
	x=10;
	while (x<MaxValue)
	{
		digitcount++;
		x*=10;
	}

	MyEditBox.MaxWidth = DigitCount+4;
}
function SetValue(float V)
{
	if (v<MinValue)
		v=MinValue;

	if (v>MaxValue)
		v=MaxValue;

	MyEditBox.SetText(""$v);
}

function SpinnerPlusClick(GUIComponent Sender)
{
	local float v;

	v = float(Value) + Step;
    SetValue(v);
}

function SpinnerMinusClick(GUIComponent Sender)
{
	local float v;

	v = float(Value) - Step;
	SetValue(v);
}

function bool EditKeyEvent(out byte Key, out byte State, float delta)
{
	if ( (key==0xEC) && (State==3) )
	{
		SpinnerPlusClick(none);
		return true;
	}

	if ( (key==0xED) && (State==3) )
	{
		SpinnerMinusClick(none);
		return true;
	}

	return MyEditBox.InternalOnKeyEvent(Key,State,Delta);


}

function EditOnChange(GUIComponent Sender)
{
	Value = MyEditBox.GetText();
    OnChange(Sender);
}

defaultproperties
{
	Value="0.0"
	Step=1.0
	bAcceptsInput=true;
	bLeftJustified=false;
	WinHeight=0.06

	PropagateVisibility=true

}