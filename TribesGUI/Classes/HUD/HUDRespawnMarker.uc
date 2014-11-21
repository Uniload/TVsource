class HUDRespawnMarker extends HUDNumericTextureLabel;

var() config HUDMaterial SelectedIcon;
var() config Color SelectedTextColor;
var() config HUDMaterial UnselectedIcon;
var() config Color UnselectedTextColor;
var() config HUDMaterial WatchedIcon;
var() config Color WatchedTextColor;

var HUDRespawnMap RespawnMap;
var int RespawnIndex;
var bool bSelected;
var bool bWatched;

function OnMouseEntered(HUDElement Sender)
{
	bWatched = true;
}

function OnMouseExited(HUDElement Sender)
{
	bWatched = false;
}

function OnMouseClicked(HUDElement Sender)
{
	if(TribesRespawnHUDScript(BaseScript).bShowingRespawnMap)
		respawnMap.SelectSpawnPoint(self);
}

function UpdateData(ClientSideCharacter c)
{
	if(bSelected)
	{
		backgroundTexture = SelectedIcon;
		textColor = SelectedTextColor;
	}
	else if(bWatched)
	{
		backgroundTexture = WatchedIcon;
		textColor = WatchedTextColor;
	}
	else
	{
		backgroundTexture = UnselectedIcon;
		textColor = UnselectedTextColor;
	}
}

function RenderElement(Canvas c)
{	
	if(bSelected)
	{
		RenderHUDMaterial(c, SelectedIcon, Width, Height);
		textColor = SelectedTextColor;
	}
	else if(bWatched)
	{
		RenderHUDMaterial(c, WatchedIcon, Width, Height);
		textColor = WatchedTextColor;
	}
	else
	{
		RenderHUDMaterial(c, UnselectedIcon, Width, Height);
		textColor = UnselectedTextColor;
	}

	super.RenderElement(c);
}

defaultproperties
{
	UnselectedIcon=(Material=texture'HUD.Radar',style=1,Coords=(U=64,V=160,UL=32,VL=32),DrawColor=(R=128,G=128,B=128,A=255))
	WatchedIcon=(Material=texture'HUD.Radar',style=1,Coords=(U=64,V=160,UL=32,VL=32),DrawColor=(R=255,G=255,B=255,A=255))
	SelectedIcon=(Material=texture'HUD.Radar',style=1,Coords=(U=96,V=160,UL=32,VL=32),DrawColor=(R=255,G=255,B=255,A=255))

	WatchedTextColor=(R=255,G=255,B=255,A=255)
	UnselectedTextColor=(R=128,G=128,B=128,A=255)
	SelectedTextColor=(R=0,G=0,B=0,A=255)

	RespawnIndex = -2
	bCenterText = true
}