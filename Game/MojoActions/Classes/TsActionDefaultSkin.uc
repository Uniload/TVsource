class TsActionDefaultSkin extends TsAction;

function bool OnStart()
{
	Actor.Skins.Length = 0;

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Default Skin"
	Track			="Effects"
	Help			="Sets the actors's skin to its default."
}