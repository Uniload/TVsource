class ControllableTextureRotator extends Engine.TexModifier
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

var Rotator Rotation;
var Matrix M;
var float Scale;
var float UOffset;
var float VOffset;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds)
	{
		M = FRotationMatrix(Rotation * Scale);

		if( UOffset != 0.f || VOffset != 0.f )
		{
			FLOAT du = UOffset/MaterialUSize();
			FLOAT dv = VOffset/MaterialVSize();

			M = FMatrix(
						FPlane(1,0,0,0),
						FPlane(0,1,0,0),
						FPlane(-du,-dv,1,0),
						FPlane(0,0,0,1)
				) *
				M *
				FMatrix(
						FPlane(1,0,0,0),
						FPlane(0,1,0,0),
						FPlane(du,dv,1,0),
						FPlane(0,0,0,1)
				);
		}

		return &M;
	}

}


defaultproperties
{
}
