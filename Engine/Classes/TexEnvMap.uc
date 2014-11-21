class TexEnvMap extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() enum ETexEnvMapType
{
	EM_WorldSpace,
	EM_CameraSpace,
} EnvMapType;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds);

}


defaultproperties
{
     EnvMapType=EM_CameraSpace
     TexCoordCount=TCN_3DCoords
     MaterialType=MT_TexEnvMap
}
