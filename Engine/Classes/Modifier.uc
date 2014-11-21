class Modifier extends Material
	native
	editinlinenew
	hidecategories(Material)
	abstract;

var() editinlineuse Material Material;
#if IG_SHARED	// Paul: functions to retreive the uSize & vSize of the material
function int GetUSize()
{
	if( Material != None )
		return Material.GetUSize();

	return 0;
}

function int GetVSize()
{
	if( Material != None )
		return Material.GetVSize();

	return 0;
}
#endif

function Reset()
{
	if( Material != None )
		Material.Reset();
	if( FallbackMaterial != None )
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if( Material != None )
		Material.Trigger( Other, EventInstigator );
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
     MaterialType=MT_Modifier
}
