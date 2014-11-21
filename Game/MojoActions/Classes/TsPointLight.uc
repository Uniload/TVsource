class TsPointLight extends Engine.Light;

function SetProperties(float brightness, byte hue, byte saturation)
{
	LightBrightness = brightness;
	LightHue = hue;
	LightSaturation = saturation;
	bLightChanged = true;
}

function SwitchOff()
{
	LightBrightness = 0;
}

defaultproperties
{
	bStatic=false
	bHidden=True
	bNoDelete=false
	Texture=S_Light
	CollisionRadius=+00024.000000
	CollisionHeight=+00024.000000
	LightType=LT_Steady
	LightBrightness=64
	LightSaturation=255
	LightRadius=64
	LightPeriod=32
	LightCone=128
	bMovable=False
}