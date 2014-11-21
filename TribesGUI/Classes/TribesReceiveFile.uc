// ====================================================================
//  Class:  TribesGui.TribesReceiveFile
//
//  Shown while the client receives a file
// ====================================================================

class TribesReceiveFile extends TribesGUIPage;

var(TribesGui) private EditInline Config GUIProgressBar		Progress;
var(TribesGui) private EditInline Config GUILabel			Text1;
var(TribesGui) private EditInline Config GUILabel			Text2;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
    OnKeyEvent=InternalOnKeyEvent;
}

function InternalOnActivate()
{
	Progress.Value = 0;
	Progress.bCanBeShown = false;
	Progress.Hide();
	Text1.Caption = "";
	Text2.Caption = "";
}

function OnProgress(string Str1, string Str2)
{
	Text1.Caption = Str1;
	Text2.Caption = Str2;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (Key == EInputKey.IK_F10)
	{
		PlayerOwner().ConsoleCommand("CANCEL");
		return true;
	}

	return false;
}

defaultproperties
{
	OnActivate=InternalOnActivate
}