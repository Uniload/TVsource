class SkeletalRook extends Rook;

var Name playedAnim;
var() localized string	localizedName	"The name that will be displayed when viewing this object";

simulated function PostLoadGame()
{
	if (playedAnim != '')
	{
		PlayAnim(playedAnim);
		SetAnimFrame(1.0);
	}
}

simulated function string GetHumanReadableName()
{
	local string value;

	value = localizedName;

	if(value == "")
		value = super.GetHumanReadableName();

	if(value == "")
		value = string(class.name);

	return value;
}

simulated function PlayScriptedAnim(name AnimToPlay)
{
	playedAnim = animToPlay;
	PlayAnim(AnimToPlay);
}

defaultproperties
{
	localizedName = "Skeletal Rook"
}