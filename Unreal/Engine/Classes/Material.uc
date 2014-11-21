//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Core.Object
	native
	hidecategories(Object)
	collapsecategories
	noexport;

var() Material FallbackMaterial;

var Material DefaultMaterial;
var const transient bool UseFallback;	// Render device should use the fallback.
var const transient bool Validated;		// Material has been validated as renderable.

#if IG_RENDERER	// rowan: material type enum... lets us do fast casting on materials
// NOTE: THIS MUST BE KEPT IN SYNC WITH DECL IN UNMATERIAL.H
enum EMaterialType
{
	MT_Material,
		// combiner
		MT_Combiner,
		
#if IG_GLOW // glow material type
		MT_GlowMaterial,
		MT_BlurMaterial,
#endif

		// modifiers
		MT_ModifierStart,
		MT_Modifier,
			MT_ColorModifier,
			MT_FinalBlend,
			MT_MaterialSequence,
			MT_MaterialSwitch,
			MT_OpacityModifier,

			// texture modifiers
			MT_TexModifierStart,
			MT_TexModifier,
				MT_TexCoordSource,
				MT_TexEnvMap,
				MT_TexMatrix,
				MT_TexOscillator,
				MT_TexPanner,
				MT_TexRotator,
				MT_TexScaler,
			MT_TexModifierEnd,
		MT_ModifierEnd,

		// rendered materials
		MT_RenderedMaterialStart,
		MT_RenderedMaterial,
			MT_Shader,
			MT_ProjectorMaterial,
			MT_ParticleMaterial,
			MT_TerrainMaterial,
			MT_VertexColor,
			
			// constant materials
			MT_ConstantMaterialStart,
			MT_ConstantMaterial,
				MT_ConstantColor,
				MT_FadeColor,
			MT_ConstantMaterialEnd,

			// bitmap materials
			MT_BitmapMaterialStart,
			MT_BitmapMaterial,
				MT_ScriptedTexture,
				MT_ShadowBitmapMaterial,

				// textures
				MT_TextureStart,
				MT_Texture,
					MT_Cubemap,
				MT_TextureEnd,
			MT_BitmapMaterialEnd,
		MT_RenderedMaterialEnd,
};
var const EMaterialType MaterialType;	// NOTE: this has to be an int, so the native impl can use an enum directly
#endif	// IG_RENDERER

#if IG_EFFECTS
//WARNING!  Please do not change or move entries in this enum!
//  ONLY add new MaterialVisualTypes to the END of this list.
//This list should be kept in sync with System/material_visual_types.lst,
//  which is read by the IGEffectsConfigurator.
enum EMaterialVisualType
{
    MVT_Default,
    MVT_Concrete,
    MVT_Carpet,
    MVT_Dirt,
    MVT_Mud,
    MVT_Glass,
    MVT_Grass,
    MVT_Ice,
    MVT_Metal,
    MVT_MetalCatwalk,
    MVT_Rubble,
    MVT_Sand,
    MVT_Snow,
    MVT_Water,
    MVT_Stone,
    MVT_VegitationRigid,
    MVT_VegitationSoft,
    MVT_WaterPipe,
    MVT_Wood,
    MVT_Armour,
    MVT_Flesh,
    MVT_Bone,
#if IG_TRIBES3	// rowan: new material types needed
	MVT_RockWasteland,
	MVT_RockRocky,
	MVT_RockMeadows,
	MVT_BeaglePipes,
	MVT_Energy,         // glenn: energy type for energy barriers, boundary volumes etc.
#endif
};

//tcohen: these are clasifications of the material for purposes of the effects system
var(MaterialType) int MaterialSoundType;
var(MaterialType) EMaterialVisualType MaterialVisualType;
#endif  //IG_EFFECTS

#if IG_SHARED	// Paul: functions to retreive the uSize & vSize of the material
function int GetUSize();
function int GetVSize();
#endif

function Reset()
{
	if( FallbackMaterial != None )
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
	FallbackMaterial=None
	DefaultMaterial=Texture'Engine_res.DefaultTexture'

#if IG_RENDERER	// rowan: set Materialtype for quick casts
	MaterialType = MT_Material
#endif
}