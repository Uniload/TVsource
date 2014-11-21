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
	UpIndicator=(Material=Texture'HUD.Radar',Coords=(U=176,V=192,UL=16,VL=42),DrawColor=(R=255,G=255,B=255,A=255),Alpha=1)
	DownIndicator=(Material=Texture'HUD.Radar',Coords=(U=192,V=192,UL=16,VL=42),DrawColor=(R=255,G=255,B=255,A=255),Alpha=1)
	relatedObjectClass = class'Actor'
	infoLabel = ""
	markerOffset = (X=0,Y=0,Z=120)
	bRespectRange = true
	bRespectZoom = true
	bDisplayViewport = true
	bDisplayRadar = true
	bDisplayCommandMap = true
	colorType = COLOR_UserPref
	friendlyColor = (R=20,G=230,B=20,A=255)
	enemyColor = (R=230,G=20,B=20,A=255)
	neutralColor = (R=200,G=200,B=20,A=255)
	newDuration=10
	deadDuration=10
}
