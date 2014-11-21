class HUDRadar extends HUDRadarBase;

var() config Material		radarMask				"";
var() config Material		radarNoise				"";
var() config Material		compassMaterial			"";
var() config HUDMaterial	radarSurroundMaterial	"";

var Shader					mapShader;
var ControllableTexMatrix	mapTexture;
var ControllableTexMatrix	compassTexture;
var TexMatrix				mapMask;
var Texture					mapNoiseMask;
var Shader					mapTextureNoise;

var float targetZoomFactor;

function InitElement()
{
	super.InitElement();

	mapTexture = new class'ControllableTexMatrix';
	mapTexture.Material = None;

	mapTextureNoise = new class'Shader';
	mapTextureNoise.Diffuse = radarNoise;
	mapTextureNoise.Opacity = radarMask;
	mapTextureNoise.OutputBlending = OB_AlphaTranslucent;

	mapMask = new class'TexMatrix';
	mapMask.Material = radarMask;

	mapShader = new class'Shader';
	mapShader.Diffuse = mapTexture;
	mapShader.Opacity = mapMask;

	// intialise the compass
	compassTexture = new class'ControllableTexMatrix';
	compassTexture.Material = compassMaterial;

	// initialise the mask
	mapMask.Matrix.XPlane.X = 0.60546875;
	mapMask.Matrix.XPlane.Y = 0;
	mapMask.Matrix.YPlane.X = 0;
	mapMask.Matrix.YPlane.Y = 0.60546875;
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	currentData = c;
	mapCenter = c.charLocation;
	mapExtent = c.mapExtent;
	targetZoomFactor = c.zoomFactor;
	mapRotation.Yaw = -Normalize(c.charRotation).Yaw - 16384;

	mapTexture.Material = c.RadarUnderlayMaterial;
	if(targetZoomFactor != zoomFactor)
	{
		if(targetZoomFactor > zoomFactor)
			zoomFactor += 0.5 * (targetZoomFactor - zoomFactor);
		else
			zoomFactor -= 0.5 * (zoomFactor - targetZoomFactor);

		if(abs(zoomFactor - targetZoomFactor) < 0.005)
			zoomFactor = targetZoomFactor;
	}

	compassTexture.rotation = (Normalize(c.charRotation).yaw + 16384) / 65536.0;
	compassTexture.panU = 0.0;
	compassTexture.panV = 0.0;
	compassTexture.scale = 1.0;

	mapTexture.rotation = (Normalize(c.charRotation).yaw + 16384) / 65536.0;
	mapTexture.scale = zoomFactor;
	mapTexture.panU = (c.charLocation.X - c.mapOrigin.X) / c.mapExtent;
	mapTexture.panV = (c.charLocation.Y - c.mapOrigin.Y) / c.mapExtent;
}

function RenderElement(Canvas c)
{
	SetColor(c, c.MakeColor(255, 255, 255, 255));

	// render the map underlay
	c.DrawTileClipped(mapShader, width, height);
	c.CurX = 0;
	c.CurY = 0;

	if(! currentData.bSensorGridFunctional)
	{
		c.DrawTileClipped(mapTextureNoise, width * 1.6516129032258064, height * 1.6516129032258064);
		c.CurX = 0;
		c.CurY = 0;
	}

	// render the compass
	c.DrawTileClipped(compassTexture, width, height);
	c.CurX = 0;
	c.CurY = 0;

	super.RenderElement(c);

	RenderHUDMaterial(c, radarSurroundMaterial, width, height);

	RenderAllies(c);
	RenderEnemies(c);
	RenderObjectives(c);
}

function bool ShouldRender(class<RadarInfo> radarInfoClass)
{
	if(super.ShouldRender(radarInfoClass) && radarInfoClass.default.bDisplayRadar)
		return true;

	return false;
}

defaultproperties
{	
	radarMask				= texture'HUD.RadarMask';
	compassMaterial			= texture'HUD.Compass';
	radarNoise				= TexPanner'HUD.TalkingHeadScreenNoisePanner'
	zoomFactor				= 0.5
	relativeEdgeRadius		= 0.45
	componentOriginX		= 0.5
	componentOriginY		= 0.5
}