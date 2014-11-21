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

defaultproperties
{
     pathNodeSnap=True
     bStatic=True
     bHidden=True
     Texture=Texture'Engine_res.S_NavP'
     bCollideWhenPlacing=True
     CollisionRadius=80.000000
     CollisionHeight=100.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
