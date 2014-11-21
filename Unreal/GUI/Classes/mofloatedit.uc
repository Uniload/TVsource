// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class moFloatEdit extends GUIMenuOption;

var		GUIFloatEdit	MyNumericEdit;
var		float			MinValue, MaxValue, Step;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	MyNumericEdit = GUIFloatEdit(MyComponent);
	MyNumericEdit.MinValue = MinValue;
	MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
	MyNumericEdit.CalcMaxLen();
	MyNumericEdit.OnChange = InternalOnChange;
}

function SetValue(float V)
{
	MyNumericEdit.SetValue(v);
}

function float GetValue()
{
	return float(MyNumericEdit.Value);
}

function InternalOnChange(GUIComponent Sender)
{
	OnChange(self);
}


defaultproperties
{
	ComponentClassName="GUI.GUIFloatEdit"
	OnClickSound=CS_Click
}