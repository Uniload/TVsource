class TsActionSetSkin extends TsAction;

var() array<Material> TargetSkins;


function bool OnStart()
{
	local int i;

	for (i = 0; i < TargetSkins.Length; i++)
	{
		Actor.Skins[i] = TargetSkins[i];
	}

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

event bool CanBeUsedWith(Actor actor)
{
	// only work with dynamic actors
	return actor.DrawType != DT_StaticMesh || !actor.bStatic;
}

defaultproperties
{
	DName			="Set Skins"
	Track			="Effects"
	Help			="Sets any number of the actors's skins. Skins can only be set on 'dynamic' static meshes or skeletal meshes."
}