class SpecCameraPoint extends Core.Object PerObjectConfig config(SpecMod);

var config vector Location;
var config rotator Rotation;

function Initialize(vector loc, rotator rot)
{
	Location = loc;
	Rotation = rot;
}