// A path node marker that is manually placed by designers.

class PlacedNode extends Engine.Actor
	abstract
	native;

var() Array<Name> doNotConnectTo;

var() bool road;

struct native ConnectToElement
{
	var() name node;
	var() bool jetpack;
	var() Name obstacleLabel;
};

var() Array<ConnectToElement> connectToData;

var() bool pathNodeSnap;

defaultProperties
{
	Texture=Texture'Engine_res.S_Navp'
	bHidden=true
	bCollideWhenPlacing=true
	CollisionRadius=+00080.000000
	CollisionHeight=+00100.000000
	bStatic=true
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false

	pathNodeSnap=true

	road=false
}