class TerrainMaterial extends RenderedMaterial
	native
	noteditinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct native TerrainMaterialLayer
{
	var material		Texture;
	var bitmapmaterial	AlphaWeight;
	var Matrix			TextureMatrix;
};
 
var const array<TerrainMaterialLayer> Layers;
#if IG_R // rowan: MacroTexture related
var const Texture	MacroTexture;
var const Matrix	MacroTextureTransform;
var const bool		ForceFogOverride;
#endif
#if IG_TRIBES3 // rowan: macro texture lightmapping
var const bool		DisableLayer2xModulate;	// need to disable 2x modulate per layer (its applied in lightmap pass instead)
#endif
var const byte RenderMethod;
var const bool FirstPass;

cpptext
{
	virtual UMaterial* CheckFallback();
	virtual UBOOL HasFallback();

}


defaultproperties
{
     MaterialType=MT_TerrainMaterial
}
