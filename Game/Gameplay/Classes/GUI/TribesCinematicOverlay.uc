class TribesCinematicOverlay extends GUI.GUIPage;

var() config GUILabel SubtitleLabel "Subtitle Label";

function Timer()
{
	SubtitleLabel.Caption = "";
}

function AddSubtitle(String Subtitle, float lifetime)
{
	SubtitleLabel.Caption = "- "$Subtitle;
	SetTimer(lifetime, false);
}