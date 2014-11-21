class HUDRespawnMap extends HUDCommandMap;

var int positionIndices[20];
var Array<HUDRespawnMarker> SpawnPosLabels;
var int MouseX;
var int MouseY;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	RefreshSpawnPositions();
}

function SelectSpawnPointByIndex(int PosIndex)
{
	local int i;

	for(i = 0; i < SpawnPosLabels.Length; ++i)
		SpawnPosLabels[i].bSelected = (SpawnPosLabels[i].RespawnIndex == positionIndices[PosIndex]);
}

function SelectSpawnPoint(HUDRespawnMarker marker)
{
	local int i;

	for(i = 0; i < SpawnPosLabels.Length; ++i)
	{
		if(SpawnPosLabels[i] != None)
			SpawnPosLabels[i].bSelected = (SpawnPosLabels[i] == marker);
	}

	TribesRespawnHUDScript(RootHUDScript()).ActionHandler.SelectRespawnBase(marker.RespawnIndex);
}

function RefreshSpawnPositions()
{
	local int i, currentIndex;
	local Vector detectedPos;

	for(i = 0; i < currentData.class.const.MAX_SPAWN_AREAS; i++)
		positionIndices[i] = -2;

	for(i = 0; i < currentData.class.const.MAX_SPAWN_AREAS; i++)
	{
		if(currentData.GetSpawnArea(i).bValid)
		{
			positionIndices[currentIndex] = i;

			detectedPos.X = currentData.GetSpawnArea(i).SpawnPointLocation.X;
			detectedPos.Y = currentData.GetSpawnArea(i).SpawnPointLocation.Y;

			detectedPos = CalcMarkerPosition(detectedPos);
			
			if(currentIndex >= SpawnPosLabels.Length)
			{
				SpawnPosLabels.Length = currentIndex;
				SpawnPosLabels[currentIndex] = HUDRespawnMarker(AddClonedElement("TribesGUI.HUDRespawnMarker", "SpawnPositionMarker"));
				SpawnPosLabels[currentIndex].respawnMap = self;
				RootHUDScript().RegisterMouseEventReceptor(SpawnPosLabels[currentIndex]);
			}

			SpawnPosLabels[currentIndex].RespawnIndex = i;
			SpawnPosLabels[currentIndex].bVisible = true;
			SpawnPosLabels[currentIndex].SetDataString(""$(currentIndex + 1));
			SpawnPosLabels[currentIndex].PosX = int(detectedPos.X) - 16;
			SpawnPosLabels[currentIndex].PosY = int(detectedPos.Y) - 16;
			SpawnPosLabels[currentIndex].Width = 32;
			SpawnPosLabels[currentIndex].Height = 32;

			currentIndex++;
		}
		else if(i < SpawnPosLabels.Length && SpawnPosLabels[i] != None)
		{
			SpawnPosLabels[i].RespawnIndex = -2;
			SpawnPosLabels[i].bVisible = false;
		}
	}
}

defaultproperties
{

}