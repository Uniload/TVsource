class HUDCountDown extends HUDNumericTextureLabel;

var bool bCountDown;
var float FlashStart;

function UpdateData(ClientSideCharacter c)
{
	local int minutes;
	local int seconds;
	local String NewString;

	if(bCountDown != c.bNeedCountdownTimer)
	{
		FlashStart = c.LevelTimeSeconds;
		FlashElement(FlashPeriod, FlashDuration, 0.5, 1.0);
		bCountDown = c.bNeedCountdownTimer;
		bVisible = true;
	}

	bVisible = c.countDown > 0;

	NewString = "";
	if(bVisible)
	{
		minutes = c.countDown / 60.0;
		seconds = c.countDown - minutes * 60.0;

		if(minutes < 10)
			NewString = "0";

		NewString $= minutes $ ":";

		if (seconds < 10)
			NewString $= "0";

		NewString $= seconds;
	}

	SetDataString(NewString);
}

defaultproperties
{
	FlashDuration=2
	FlashPeriod=0.5
}