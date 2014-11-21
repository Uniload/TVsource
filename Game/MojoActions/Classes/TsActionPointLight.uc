class TsActionPointLight extends TsAction;

var(Action) MojoKeyframe position;
var(Action) float duration;

var(LightColor) float LightBrightness;
var(LightColor) byte LightHue, LightSaturation;

var transient TsPointLight light;
var transient float elapsedTime;

function bool OnStart()
{
	elapsedTime = 0;

	// spawn light
	light = actor.spawn(class'TsPointLight', , , position.position);
	if (light == None)
		Log("Failed to spawn light.");

	light.SetProperties(LightBrightness, LightHue, LightSaturation);

	return true;
}

function bool OnTick(float delta)
{
	elapsedTime += delta;

	if (elapsedTime > duration)
	{
		light.SwitchOff();
		light.Destroyed();
		return false;
	}
	else
	{
		return true;
	}
}

defaultproperties
{
	DName			="Point Light"
	Track			="Effects"
	Help			="Creates a point light."

	duration		=3
	LightBrightness	=64
	LightSaturation	=255
}