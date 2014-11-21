class TribesInventoryButton extends GUI.GUIToggleButton
	HideCategories(Menu,Object);

// flashing buttons for the tutorial
var bool bWasChecked;
var float FlashDuration;
var float FlashFrequency;
var float FlashTimeStarted;
var bool bIsFlashing;

function bool IsChecked()
{
	return bChecked;
}

function DoFlash(float CurrentTime, float Duration)
{
	bWasChecked = bChecked;

	FlashDuration = Duration;
	FlashTimeStarted = PlayerOwner().Level.TimeSeconds;
	bIsFlashing = true;
	SetTimer(FlashFrequency, true);
}

event Timer()
{
	if(! bIsFlashing)
		return;

	if(PlayerOwner().Level.TimeSeconds >= (FlashTimeStarted + FlashDuration))
	{
		KillTimer();
		bChecked = bWasChecked;
		bIsFlashing = false;
	}
	else // flip the checked value to flash the button
		bChecked = ! bChecked;
}

defaultproperties
{
	FlashFrequency = 0.5

	bNeverFocus=true
}