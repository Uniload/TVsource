class DynamicProjector extends Projector;

function Tick(float DeltaTime)
{
	DetachProjector();
	AttachProjector();
}

defaultproperties
{
	bMovable=True
	bStatic=False
	bDynamicAttach=True
}