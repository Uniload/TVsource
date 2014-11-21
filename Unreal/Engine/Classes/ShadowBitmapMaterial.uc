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

#if IG_SHARED	// rowan: script interface for native GetShadowLocation
native final function vector GetShadowLocation();
#endif

#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: script change shadow resolution
native final function SetResolution(INT Resolution);
#endif

//
//	Default properties
//

defaultproperties
{
	Format=TEXF_RGBA8
	UClampMode=TC_Clamp
	VClampMode=TC_Clamp
	USize=128
	VSize=128
	UClamp=128
	VClamp=128
	UBits=7
	VBits=7
	Dirty=True
	Invalid=False
	BlobShadow=Texture'Engine_res.BlobTexture'
	ShadowDarkness=255

#if IG_RENDERER	// rowan: set Materialtype for quick casts
	MaterialType = MT_ShadowBitmapMaterial
#endif
}