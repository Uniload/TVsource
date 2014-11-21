class SpawnPointRadarInfo extends Gameplay.RadarInfo;

defaultproperties
{
	relatedObjectClass = class'Gameplay.SpawnArray'
	radarIcons(0)=(Material=texture'HUD.Radar',Coords=(U=96,V=160,UL=32,VL=32),DrawColor=(R=255,G=128,B=0,A=255),alpha=1)
	radarIcons(1)=(Material=texture'HUD.Radar',Coords=(U=64,V=160,UL=32,VL=32),DrawColor=(R=0,G=0,B=255,A=255),alpha=1)
	infoLabel = "You Are Here"
	markerOffset = (X=0,Y=0,Z=120)
	bRespectRange = true
	bDisplayRadar = false
	bDisplayCommandMap = true
	colorType = COLOR_Absolute
}