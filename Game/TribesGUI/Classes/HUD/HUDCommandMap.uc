class HUDCommandMap extends HUDRadarBase;

var() config HUDMaterial mapMaterial;

var ControllableTexMatrix playerTexture;
var int mapWidth;
var int mapHeight;

function InitElement()
{
	super.InitElement();

	playerTexture = new class'ControllableTexMatrix';
	playerTexture.Material = class'PlayerRadarInfo'.default.radarIcons[0].Material;
	playerTexture.scale = 1.0;
}

event DoLayout(Canvas c)
{
	if(ParentElement != None)
	{
		Width = Min(ParentElement.Width, ParentElement.Height);
		Height = Width;
	}

	super.DoLayout(c);

	mapWidth = Min(Width, Height);
	mapHeight = mapWidth;
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	mapMaterial.Material = c.RadarUnderlayMaterial;

	currentData = c;
	mapCenter = c.mapOrigin;
	mapExtent = c.mapExtent;

	playerTexture.rotation = -(Normalize(c.charRotation).yaw + 16384) / 65536.0;
}

function RenderElement(Canvas c)
{
	local int oldOrgX, oldOrgY, oldWidth, oldHeight;

	super.RenderElement(c);

	oldOrgX = c.OrgX;
	oldOrgY = c.OrgY;
	oldWidth = width;
	oldHeight = height;

	c.OrgX += (width - mapWidth) * 0.5;
	c.OrgY += (height - mapHeight) * 0.5;

	width = mapWidth;
	height = mapHeight;

	// render the map underlay
	if(mapMaterial.Material != None)
	{
//		RenderHUDMaterial(c, mapMaterial, mapWidth, mapHeight);
		SetColor(c, mapMaterial.DrawColor);
		c.DrawTileClipped(mapMaterial.Material, mapWidth, mapHeight);
		c.CurX = 0;
		c.CurY = 0;
	}

	RenderRadarMarker(c, currentData.charLocation, 0, class'TribesGUI.PlayerRadarInfo', 0, true, currentData.ownTeamColor, currentData.UserPrefColorType, , false, playerTexture);

	RenderPointsOfInterest(c);

	RenderAllies(c);

	RenderEnemies(c);

	RenderObjectives(c);

	c.OrgX = oldOrgX;
	c.OrgY = oldOrgY;
	width = oldWidth;
	height = oldHeight;
}

function RenderPointsOfInterest(Canvas c)
{
	local int i;

	for(i = 0; i < currentData.POIData.Length; ++i)
		RenderRadarMarker(c, currentData.POIData[i].Location, 0, currentData.POIData[i].radarInfoClass, 0, true, currentData.ownTeamColor, currentData.UserPrefColorType, currentData.POIData[i].LabelText);
}

function bool ShouldRender(class<RadarInfo> radarInfoClass)
{
	if(super.ShouldRender(radarInfoClass) && radarInfoClass.default.bDisplayCommandMap)
		return true;

	return false;
}

defaultproperties
{
	zoomFactor					= 1.0
	SmallMarkerZoomThreshold	= 1.1
	relativeEdgeRadius			= 1.0;
	componentOriginX			= 0.5
	componentOriginY			= 0.5
	bClipMarkers				= false
}