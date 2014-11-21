class Shader extends RenderedMaterial
	editinlinenew
	native;

var() editinlineuse Material Diffuse;
var() editinlineuse Material Opacity;

#if IG_BUMPMAP // rowan: bumpmap Material params
var() editinlineuse Material	NormalMap;
var() editinlineuse Cubemap		PerPixelReflection;
var() editinlineuse Material	PerPixelReflectionMask;
var() enum EPerPixelSpecular
{
	PP_None,
	PP_Low,
	PP_Medium,
	PP_High,
} PerPixelSpecular;
var() enum EPerPixelSpecularType
{
	ST_AlgorithmicRV,
	ST_AlgorithmicNH,
} PerPixelSpecularType;
var() byte PerPixelSpecularBrightness;
#endif // IG
 
var() editinlineuse Material Specular;
var() editinlineuse Material SpecularityMask;

var() editinlineuse Material SelfIllumination;
var() editinlineuse Material SelfIlluminationMask;

#if IG_GLOW	// rowan: can override the selfiluum channel for glow effect if we want
var() byte GlowBrightness;
var() editinlineuse Material GlowMapOverride;
var() editinlineuse Material GlowMaskOverride;
#endif

var() editinlineuse Material Detail;
var() float DetailScale;

var() enum EOutputBlending
{
	OB_Normal,
	OB_Masked,
	OB_Modulate,
#if IG_TRIBES3	// rowan: need this for flame effects
	OB_AlphaTranslucent,	
#endif
	OB_Translucent,
	OB_Invisible,
	OB_Brighten,
	OB_Darken,
#if IG_SHARED	// rowan: need this for foilage
	OB_Feathered,
#endif
} OutputBlending;

#if IG_SHARED	// rowan: shader LOD settings
var(ShaderLOD) bool bAllowSelfIlluminationLOD;
#endif

var() bool TwoSided;
var() bool Wireframe;
var   bool ModulateStaticLighting2X;
var() bool PerformLightingOnSpecularPass;

#if IG_SHARED	// Paul: functions to retreive the uSize & vSize of the material
function int GetUSize()
{
	if( Diffuse != None)
		return Diffuse.GetUSize();
	if( SelfIllumination != None)
		return SelfIllumination.GetUSize();

	return 0;
}

function int GetVSize()
{
	if( Diffuse != None)
		return Diffuse.GetVSize();
	if( SelfIllumination != None)
		return SelfIllumination.GetVSize();

	return 0;
}
#endif

function Reset()
{
	if(Diffuse != None)
		Diffuse.Reset();
	if(Opacity != None)
		Opacity.Reset();
	if(Specular != None)
		Specular.Reset();
	if(SpecularityMask != None)
		SpecularityMask.Reset();
	if(SelfIllumination != None)
		SelfIllumination.Reset();
	if(SelfIlluminationMask != None)
		SelfIlluminationMask.Reset();
	if(FallbackMaterial != None)
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if(Diffuse != None)
		Diffuse.Trigger(Other,EventInstigator);
	if(Opacity != None)
		Opacity.Trigger(Other,EventInstigator);
	if(Specular != None)
		Specular.Trigger(Other,EventInstigator);
	if(SpecularityMask != None)
		SpecularityMask.Trigger(Other,EventInstigator);
	if(SelfIllumination != None)
		SelfIllumination.Trigger(Other,EventInstigator);
	if(SelfIlluminationMask != None)
		SelfIlluminationMask.Trigger(Other,EventInstigator);
	if(FallbackMaterial != None)
		FallbackMaterial.Trigger(Other,EventInstigator);
}

defaultproperties
{
	DetailScale=8.0

//#if IG_RENDERER	// rowan: set Materialtype for quick casts
	MaterialType = MT_Shader
//#endif

//#if IG_BUMPMAP	// rowan: default specular brightness
	PerPixelSpecularBrightness = 255
//#endif

//#if IG_GLOW		// rowan: default glow brightness
	GlowBrightness = 127
//#endif

	bAllowSelfIlluminationLOD = true
}