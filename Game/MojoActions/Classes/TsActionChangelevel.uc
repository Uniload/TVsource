class TsActionChangelevel extends TsAction;

var(Action) string URL;
var(Action) bool bShowLoadingMessage;

function bool OnStart()
{
	if( bShowLoadingMessage )
		Actor.Level.ServerTravel(URL, false);
	else
		Actor.Level.ServerTravel(URL$"?quiet", false);
	return false;
}

function string GetSummaryString()
{
	return Name@URL;
}

defaultproperties
{
	DName		="Change Level"
	Track		="Misc"
	Help		="Change to a different level file"

	bShowLoadingMessage =false

	DisableInMojo = true;
}

