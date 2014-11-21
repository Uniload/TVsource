//
// Visualisation class for explosion debugging
//
class ExplosionVisualisation extends Engine.Actor;

var Explosion owner;

function UpdateVis()
{
	local vector newLocation;

	newLocation = owner.Location;
	newLocation.Z -= owner.Radius;
	unifiedSetPosition(newLocation);

	SetDrawScale(owner.Radius / 64);

	SetPhysics(PHYS_None);
}

defaultproperties
{
	StaticMesh = StaticMesh'PhysicsObjects.Sphere'
	DrawType = DT_StaticMesh

	bCollideWorld = false
	bUnlit = true
}