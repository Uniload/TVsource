class CinematicOverlay extends GUI.GUIPage;

var() config GUILabel SubtitleLabel "Subtitle Label";

function Timer()
{
	SubtitleLabel.Caption = "";
}

function AddSubtitle(String Subtitle, float lifetime)
{
	if (Subtitle == "")
	{
		log("NOTE: Empty subtitle string passed to AddSubtitle");
		SubtitleLabel.Caption = "";
	}
	else
		SubtitleLabel.Caption = "- "$Subtitle;
	SetTimer(lifetime, false);
}

function ClearSubtitle()
{
	SubtitleLabel.Caption = "";
}

defaultproperties
{
	bAcceptsInput = false
	bSwallowAllKeyEvents = false
	bHideMouseCursor = true
}