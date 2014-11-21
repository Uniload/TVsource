class ShadowBitmapMaterial extends BitmapMaterial
	native;

var const transient int	TextureInterfaces[2];

var Actor	ShadowActor;
var vector	LightDirection;
var float	LightDistance,
			LightFOV;
var bool	Dirty,
			Invalid,
			bBlobShadow;
var float   CullDistance;
var byte	ShadowDarkness;

var BitmapMaterial	BlobShadow;

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

#if IG_SHARED	// rowan: script interface for native GetShadowLocation
native final function vector GetShadowLocation();
#endif

#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: script change shadow resolution
native final function SetResolution(INT Resolution);
#endif

//
//	Default properties
//

cpptext
{
	virtual void Destroy();

	virtual FBaseTexture* GetRenderInterface();
	virtual UBitmapMaterial* Get(FTime Time,UViewport* Viewport);
#if IG_SHARED	// rowan: GetShadowLocation, needed for shadow projector culling
	FVector	GetShadowLocation();
#endif

#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: native change shadow resolution
	void SetResolution(INT Resolution);
#endif

}


defaultproperties
{
     Dirty=True
     ShadowDarkness=255
     BlobShadow=Texture'Engine_res.BlobTexture'
     Format=TEXF_RGBA8
     UClampMode=TC_Clamp
     VClampMode=TC_Clamp
     UBits=7
     VBits=7
     USize=128
     VSize=128
     UClamp=128
     VClamp=128
     MaterialType=MT_ShadowBitmapMaterial
}
