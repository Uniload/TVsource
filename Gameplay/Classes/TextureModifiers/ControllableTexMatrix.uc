class ControllableTexMatrix extends Engine.TexMatrix
	native;

cpptext
{
	// UTexMatrix interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds);
}

var Rotator rotationAxis;
var float rotation;
var float panU;
var float panV;
var float scale;

defaultproperties
{
	rotationAxis = (pitch=0,yaw=65536,roll=0)
}