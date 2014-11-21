class BitmapMaterial extends RenderedMaterial
	abstract
	native
	noexport;

var(TextureFormat) const editconst enum ETextureFormat
{
	TEXF_P8,
	TEXF_RGBA7,
	TEXF_RGB16,
	TEXF_DXT1,
	TEXF_RGB8,
	TEXF_RGBA8,
	TEXF_NODATA,
	TEXF_DXT3,
	TEXF_DXT5,
	TEXF_L8,
	TEXF_G16,
	TEXF_RRRGGGBBB,
#if IG_BUMPMAP	// rowan: compressed normalmap texture format
	TEXF_CxV8U8,
	TEXF_DXT5N,
	TEXF_3DC,
#endif
} Format;

var(Texture) enum ETexClampMode
{
	TC_Wrap,
	TC_Clamp,
} UClampMode, VClampMode;

var const byte  UBits, VBits;
var const int   USize, VSize;
var(Texture) const int UClamp, VClamp;

#if IG_SHARED	// Paul: functions to retreive the uSize & vSize of the material
function int GetUSize()
{
	return USize;
}

function int GetVSize()
{
	return VSize;
}
#endif

defaultproperties
{
     MaterialType=MT_BitmapMaterial
}
