class MapList extends Gameplay.MapList;


function string GetNextMap()
{
	local int startIdx;
	local LevelSummary l;
	local int i;
	local bool bSupported;
	local string CurrentMap;

	CurrentMap = GetURLMap();
	if (Maps.Length <= 1)
		return CurrentMap;

	if ( CurrentMap != "" )
	{
		for ( i=0; i<Maps.Length; i++ )
		{
			if ( CurrentMap ~= Maps[i] )
			{
				MapNum = i;
				break;
			}
		}
	}

	startIdx = MapNum;

	do
	{
		MapNum++;
		if ( MapNum > Maps.Length - 1 )
			MapNum = 0;
		if ( Maps[MapNum] == "" )
			MapNum = 0;

		l = LevelSummary(DynamicLoadObject(Maps[MapNum]$".LevelSummary", class'LevelSummary'));
		
		if (l == None)
		{
			LOG("GetNextMap: no level summary for level "$Maps[MapNum]$", unable to determine game type support");
		}
		else
		{
			for (i = 0; i < l.SupportedModes.Length; i++)
			{
				if (ClassIsChildOf(l.SupportedModes[i], class'GameClasses.ModeCTF'))
				{
					bSupported = true;
					break;
				}
			}
		}

		if (!bSupported)
			LOG("GetNextMap: current game type "$Level.Game.class.name$" not supported by map "$Maps[MapNum]$", skipping");
	}
	until (bSupported || MapNum == startIdx);

	SaveConfig();
	return Maps[MapNum];
}

defaultproperties
{
     Maps(0)="MP-Arid"
     Maps(1)="MP-Cavern"
     Maps(2)="MP-Detritus"
     Maps(3)="MP-Emerald"
     Maps(4)="MP-Fort"
     Maps(5)="MP-GarudaGorge"
     Maps(6)="MP-Highlands"
     Maps(7)="MP-Isle"
     Maps(8)="MP-Junk"
     Maps(9)="MP-Royalty"
     Maps(10)="MP-Spiridian"
     Maps(11)="MP-SurfaceTension"
     Maps(12)="MP-Tropics"
     Maps(13)="MP-Utopia"
     Maps(14)="MP-Winterlake"
}
