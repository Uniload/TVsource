class SphereVisActor extends Engine.Actor;

var float radius;

function SetSphereCenter(vector newLocation)
{
	newLocation.Z -= radius;
	SetLocation(newLocation);
}

defaultproperties
{
	StaticMesh = StaticMesh'PhysicsObjects.Sphere'
	DrawType = DT_StaticMesh

	Physics = PHYS_None
	bCollideWorld = false
	bUnlit = true
}