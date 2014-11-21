class PlayerRadarInfo extends Gameplay.RadarInfo;

defaultproperties
{
	relatedObjectClass = class'PlayerCharacterController'
	radarIcons(0)=(Material=texture'HUD.PlayerMarker',alpha=1)
	markerOffset = (X=0,Y=0,Z=120)
	bRespectRange = true
	bDisplayRadar = false
	bDisplayCommandMap = true
	colorType = COLOR_Neutral
	neutralColor = (R=255,G=255,B=255,A=255)
}