class TsActionRemoveUnrealCameraEffect extends TsCameraAction;

var() class<CameraEffect> EffectClass;

function bool OnStart()
{
	local int i;

	if (EffectClass == None) // remove all
	{
		PC.CameraEffects.Length = 0;
	}
	else
	{
		i = 0;

		while (i < PC.CameraEffects.Length)
		{
			if (PC.CameraEffects[i].Class == EffectClass)
				PC.CameraEffects.Remove(i, 1);
			else
				i++;
		}
	}

	return true;
}

function bool OnTick(float delta)
{
	return false;
}


defaultproperties
{
	DName			="Remove Unreal Camera Effect"
	Track			="Effects"
	Help			="Remove an Unreal camera effect of the given class. Set the class to 'None' to remove all effects."
}