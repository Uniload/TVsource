class ControllableTexMatrix extends Engine.TexMatrix
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Rotator rotationAxis;
var float rotation;
var float panU;
var float panV;
var float scale;

cpptext
{
	// UTexMatrix interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds);

}


defaultproperties
{
     rotationAxis=(Yaw=65536)
}
