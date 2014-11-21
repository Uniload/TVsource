class ControllableTexturePanner extends Engine.TexModifier
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() Vector PanDirection;
var Matrix M;
var float Scale;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds)
	{
		FLOAT du = Scale * PanDirection.X;
		FLOAT dv = Scale * PanDirection.Y;

		M = FMatrix (
						FPlane(1,0,0,0),
						FPlane(0,1,0,0),
						FPlane(du,dv,1,0),
						FPlane(0,0,0,1)
					);

		return &M;
	}

}


defaultproperties
{
}
