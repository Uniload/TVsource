class SphereVisActor extends Engine.Actor;

var float radius;

function SetSphereCenter(vector newLocation)
{
	newLocation.Z -= radius;
	SetLocation(newLocation);
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'PhysicsObjects.Sphere'
     bUnlit=True
}
