class RadarInfo extends Core.Object
	config
	native;

enum EColorType
{
	COLOR_UserPref,
	COLOR_Relative,
	COLOR_Team,
	COLOR_Neutral,
	COLOR_Absolute,
};

enum EIconType
{
	ICON_Radar,
	ICON_Viewport
};

struct native MaterialDef
{
	var() config Material	Material;
	var() config MatCoords	Coords;
	var() config Color		DrawColor;
	var() config float		Alpha;

	var() config bool		bFlashing		"Flashing flag, when set the icon will flash on and off";
	var() config float		flashFrequency	"How long the flash should take in seconds";
};

var() config editinline Array<MaterialDef>	radarIcons			"Array of icon materials for the radar, each index is a different state";
var() config editinline Array<MaterialDef>	viewportIcons		"Array of icon materials for the viewport markers, each index is a different state";
var() config editinline MaterialDef		UpIndicator			"Up indicator texture for this radar info marker";
var() config editinline MaterialDef		DownIndicator		"Down indicator texture for this radar info marker";

var() class<Object>			relatedObjectClass	"Class of the object this radar info is related to";
var() localized String		infoLabel			"info label for display next to the marker";
var() Vector				markerOffset		"offset of the on screen marker from the objects pivot";
var() bool					bOccluded			"Whether the object's viewport marker will be occluded";
var() bool					bRespectRange		"Whether the object's viewport marker will only display within range";
var() bool					bRespectZoom		"Whether the object's radar marker will respect the radar zoom";
var() bool					bDisplayViewport	"Whether the object will be marked on the viewport";
var() bool					bDisplayRadar		"Whether the object will be marked on the radar";
var() bool					bDisplayCommandMap	"Whether the object will be marked on the command map";
var() bool					bShowHeightMarker	"Whether to show the relative height of this marker to the player";
var() bool					bNoSizeReduction	"Set to ignore marker size reduction imposed by the radar";
var() bool					bDisplayDistance	"Whether the Distance will be shown on the radar when the object is out of range (only works if bRespectZoom = false)";
var() EColorType			colorType			"Method for rendering the icons";
var() Color					friendlyColor		"Color for friendly icons";
var() Color					enemyColor			"Color for enemy icons";
var() Color					neutralColor		"Color for neutral icons";
var() float					newDuration			"How long the icon will be considered 'new' for";
var() float					deadDuration		"How long the icon will flash after death before being removed";

defaultproperties
{
     UpIndicator=(Material=Texture'HUD.Radar',Coords=(U=176.000000,V=192.000000,UL=16.000000,VL=42.000000),DrawColor=(B=255,G=255,R=255,A=255),Alpha=1.000000)
     DownIndicator=(Material=Texture'HUD.Radar',Coords=(U=192.000000,V=192.000000,UL=16.000000,VL=42.000000),DrawColor=(B=255,G=255,R=255,A=255),Alpha=1.000000)
     relatedObjectClass=Class'Engine.Actor'
     markerOffset=(Z=120.000000)
     bRespectRange=True
     bRespectZoom=True
     bDisplayViewport=True
     bDisplayRadar=True
     bDisplayCommandMap=True
     friendlyColor=(B=20,G=230,R=20,A=255)
     enemyColor=(B=20,G=20,R=230,A=255)
     neutralColor=(B=20,G=200,R=200,A=255)
     newDuration=10.000000
     deadDuration=10.000000
}
