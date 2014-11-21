//
// class: HUDMarkerDisplay
//
// Element to paint markers on the screen over enemies & allies, & to
// mark out where objectives are, etc.
//
class HUDMarkerDisplay extends HUDRadarBase;

var ClientSideCharacter currentData;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	bVisible = true;

	currentData = c;
}

function RenderElement(Canvas c)
{
	local int i;
	local Class<RadarInfo> radarInfoClass;
	local HUDMaterial material;
	//local ObjectiveInfo.ClientObjectiveActorInfo nextActorInfo;

	super.RenderElement(c);

	for(i = 0; i < currentData.markers.Length; i++)
	{
		radarInfoClass = currentData.markers[i].Type;

		if( radarInfoClass != None && radarInfoClass.default.bDisplayViewport &&
			currentData.markers[i].ScreenX > 0 && currentData.markers[i].ScreenX < Width &&
			currentData.markers[i].ScreenY > 0 && currentData.markers[i].ScreenY < Height)
		{
			if(currentData.markers[i].Team != None)
				material = GetHUDMaterial(radarInfoClass, currentData.markers[i].State, currentData.markers[i].Friendly, ICON_Viewport, currentData.markers[i].Team.default.TeamColor, currentData.UserPrefColorType);
			else
				material = GetHUDMaterial(radarInfoClass, currentData.markers[i].State, currentData.markers[i].Friendly, ICON_Viewport, currentData.ownTeamColor, currentData.UserPrefColorType);
			c.SetPos(currentData.markers[i].ScreenX - (material.Coords.UL / 2), 
				currentData.markers[i].ScreenY - material.Coords.UL);
			if(material.bFading)
				material.fadeProgress = FClamp((TimeSeconds % material.fadeDuration) / material.fadeDuration, 0.f, 1.f);
			RenderHUDMaterial(c, material, material.Coords.UL, material.Coords.VL);
		}
	}
}

defaultproperties
{
//	enemyMarkerMaterial = (material=Texture'HUD.Tags',style=1,drawColor=(R=255,G=0,B=0,A=255),Coords=(U=0,V=24,UL=11,VL=8))
//	allyMarkerMaterial = (material=Texture'HUD.Tags',style=1,drawColor=(R=0,G=255,B=0,A=255),Coords=(U=12,V=24,UL=11,VL=8))
//	objectiveMarkerMaterial = (material=Texture'HUD.Tags',style=1,drawColor=(R=0,G=0,B=255,A=255),Coords=(U=12,V=24,UL=11,VL=8))
}
