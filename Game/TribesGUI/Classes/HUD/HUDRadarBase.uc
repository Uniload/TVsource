class HUDRadarBase extends HUDContainer
	native;

import enum EIconType from Gameplay.RadarInfo;
import enum EColorType from Gameplay.RadarInfo;

var() config float	relativeEdgeRadius				"";
var() config bool	bClipMarkers					"whether to clip markers at the zoom level";
var() config float	defaultFlashFrequency			"default frequency to flash icons at";
var() config float	SmallMarkerZoomThreshold		"zoom level after which the markers will becom dots";

var ClientSideCharacter currentData;
var float				zoomFactor;
var Rotator				mapRotation;
var Vector				mapCenter;
var float				mapExtent;
var float				componentOriginX;
var float				componentOriginY;
var MatCoords			LastRenderedMarkerCoords;

// native function to render a single radar marker (for optimisation reasons)
native function Vector CalcMarkerPosition(Vector position);
// native function to render a single radar marker (for optimisation reasons)
native function RenderRadarMarker(Canvas c, Vector position, int objectHeight, class<RadarInfo> objectRadarInfo, int state, bool isFriendly, Color TeamColor, EColorType PrefColorType, optional String InfoLabel, optional bool bFlashing, optional Material materialOverride);
// Creates a HUDMaterial instance from a state.
static native function HUDMaterial GetHUDMaterial(class<RadarInfo> radarInfo, int state, bool isFriendly, EIconType iconType, Color TeamColor, EColorType PrefColorType, optional bool bForceFlash);

native function RenderEnemies(Canvas c);
native function RenderAllies(Canvas c);
native function RenderObjectives(Canvas c);

CPPTEXT
{
	FHUDMaterial GetHUDMaterial(UClass *radarInfoClass, INT state, UBOOL isFriendly, EIconType iconType, FColor TeamColor, EColorType PrefColorType, UBOOL bForceFlash);
	void RenderRadarMarker(UCanvas *canvas, FVector position, INT objectHeight, UClass *objectRadarInfo, INT state, UBOOL isFriendly, FColor TeamColor, EColorType PrefColorType, FString InfoLabel, UBOOL bFlashing, UMaterial *materialOverride);
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);
}

event bool ShouldRender(class<RadarInfo> radarInfoClass)
{
	if(radarInfoClass != None)
		return true;

	return false;
}

defaultproperties
{
	bClipMarkers = true
	defaultFlashFrequency = 0.7
	SmallMarkerZoomThreshold=0.7
}