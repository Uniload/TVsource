class HUDVehicleManifest extends HUDElement;

var() config HUDMaterial	ManifestSchematic;
var() config HUDMaterial	UnoccupiedIcon;
var() config HUDMaterial	OccupiedIcon;
var() config HUDMaterial	PlayerOccupiedIcon;
var() config Color			OccupiedPositionNumberColor;
var() config Color			PositionNumberColor;

var Array<ClientSideCharacter.HUDPositionData>		PositionData;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	ManifestSchematic.Material = c.vehicleManifestSchematic;
	PositionData = c.VehiclePositionData;
}

function RenderPosition(Canvas c, out HUDMaterial material, ClientSideCharacter.HUDPositionData position, int PositionIndex, Color TextColor)
{
	local int matWidth, matHeight;
	local float textWidth, textHeight;

	matWidth = MaterialWidth(material);
	matHeight = MaterialHeight(material);

	c.SetPos(position.PosX - (matWidth * 0.5), 
			 position.PosY - (matHeight * 0.5));
	RenderHUDMaterial(c, material, matWidth, matHeight);

	if(! position.bNotLabelled)
	{
		c.Font = textFont;
		c.StrLen(position.SwitchHotKey, textWidth, textHeight);
		c.SetPos(position.PosX - (textWidth * 0.5), 
				position.PosY - (textHeight * 0.5));
		c.DrawColor = TextColor;
		c.DrawText(position.SwitchHotKey);
	}
}

function RenderElement(Canvas c)
{
	local int i;

	super.RenderElement(c);

	RenderHUDMaterial(c, ManifestSchematic, Width, Height);

	for(i = 0; i < PositionData.Length; ++i)
	{
		if(PositionData[i].bOccupiedByPlayer)
			RenderPosition(c, PlayerOccupiedIcon, PositionData[i], i + 1, OccupiedPositionNumberColor);
		else if(PositionData[i].bOccupied)
			RenderPosition(c, OccupiedIcon, PositionData[i], i + 1, OccupiedPositionNumberColor);
		else
			RenderPosition(c, UnoccupiedIcon, PositionData[i], i + 1, PositionNumberColor);
	}

	c.SetPos(0, 0);
}

defaultproperties
{
	ManifestSchematic=(Coords=(U=0,V=0,UL=80,VL=80),DrawColor=(R=255,G=255,B=255,A=255),Style=1)
	UnoccupiedIcon=(Material=Texture'HUD.Blips',Coords=(U=0,V=20,UL=12,VL=12),DrawColor=(R=255,G=255,B=255,A=255),Style=1)
	OccupiedIcon=(Material=Texture'HUD.Blips',Coords=(U=20,V=0,UL=12,VL=12),DrawColor=(R=128,G=128,B=128,A=255),Style=1)
	PlayerOccupiedIcon=(Material=Texture'HUD.Blips',Coords=(U=0,V=0,UL=12,VL=12),DrawColor=(R=255,G=255,B=255,A=255),Style=1)
	OccupiedPositionNumberColor=(R=0,G=0,B=0,A=255)
	PositionNumberColor=(R=255,G=255,B=255,A=255)
}