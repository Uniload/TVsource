class Combiner extends Material
	editinlinenew
	native;

enum EColorOperation
{
	CO_Use_Color_From_Material1,
	CO_Use_Color_From_Material2,
	CO_Multiply,
	CO_Add,
	CO_Subtract,
	CO_AlphaBlend_With_Mask,
	CO_Add_With_Mask_Modulation,
	CO_Use_Color_From_Mask,
};

enum EAlphaOperation
{
	AO_Use_Mask,
	AO_Multiply,
	AO_Add,
	AO_Use_Alpha_From_Material1,
	AO_Use_Alpha_From_Material2,
};


var() EColorOperation CombineOperation;
var() EAlphaOperation AlphaOperation;
var() editinlineuse Material Material1;
var() editinlineuse Material Material2;
var() editinlineuse Material Mask;
var() bool InvertMask;
var() bool Modulate2X;
var() bool Modulate4X;

#if IG_SHARED	// Paul: functions to retreive the uSize & vSize of the material
function int GetUSize()
{
	local int mat1Size;
	local int mat2Size;

	if(Material1 != None)
		mat1Size = Material1.GetUSize();
	if(Material2 != None)
		mat2Size = Material2.GetUSize();

	return Max(mat1Size, mat2Size);
}

function int GetVSize()
{
	local int mat1Size;
	local int mat2Size;

	if(Material1 != None)
		mat1Size = Material1.GetVSize();
	if(Material2 != None)
		mat2Size = Material2.GetVSize();

	return Max(mat1Size, mat2Size);
}

#endif

defaultproperties
{
     MaterialType=MT_Combiner
}
