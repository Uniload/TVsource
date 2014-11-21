class MPCheckpointMessages extends Engine.LocalMessage;

var() localized string	selfPassed;
var() localized string	selfFailed;
var() localized string	selfRaceCompleted;
var() localized string	selfLapCompleted;
var() localized string	globalRaceCompleted;

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString 
	)
{
	switch (Switch)
	{
		case 0:  return default.selfFailed;
		case 1:  return default.selfPassed;
		case 2:  return default.selfRaceCompleted;
		case 3:  return default.selfLapCompleted;
		case 4:  return default.globalRaceCompleted;
	}

	return "";
}

defaultproperties
{
	selfPassed			= "You passed a checkpoint."
	selfFailed			= "This is not your current checkpoint."
	selfRaceCompleted	= "You finished the race!  Total time:  %1"
	selfLapCompleted	= "You finished lap %1 of %2."
	globalRaceCompleted	= "%1 finished the race!  Position:  %1"
}