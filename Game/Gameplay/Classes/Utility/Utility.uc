// Utility class with useful stuff!

class Utility extends Core.Object;// config(Utility);

struct LevelData
{
    var /*config*/ string name;                     // level name "MP-Fort"
    var /*config*/ string title;                    // level title (can be untitled)
    var /*config*/ int checksum;                    // level checksum (used to detect level changes)
    var /*config*/ array<string> gameTypes;         // supported game types in this level ["CTF", "Fuel", "DeathMatch"]
};

var /*config*/ array<LevelData> levels;             // cached list of data for levels

struct GameData
{
    var /*config*/ string name;                     // name of game type "CTF"
    var /*config*/ string className;                // name of game info class "GameClasses.ModeCTF"
};

var /*config*/ array<GameData> gameTypes;           // cached list of game types supported in list of levels

struct LevelsForGameType
{
    var string gameType;                            // game type name "CTF"
    var array<LevelData> levels;                    // list of level names that support this game type
};

var /*config*/ array<LevelsForGameType> gameTypeLevels;

var bool initialized;                   // temporary: so we only scan levels once to extract the required data (slow)


static function load()
{
    // load cached level data
    
    ResetConfig();
}

static function smartRefresh()
{
    // refresh cached data only if we need to
    
    if (!default.initialized)
    {
        refresh();
        default.initialized = true;
    }
}

static function refresh()
{
    // scan levels and extract important information
                       
    local int i, j, k, index;
    local bool match;
    local string gameType;
    local string gameClass;
    local array<string> files;
    local array<LevelSummary> data;
    
    scanLevels(files, data);

    default.levels.length = files.length;

    for (i=0; i<files.length; i++)
    {
        default.levels[i].name = files[i];
        default.levels[i].title = data[i].title;
        default.levels[i].checksum = 0;                 // todo: store checksum in level summary!
        
		for (j=0; j<data[i].SupportedModes.length; j++)
		{
			if (data[i].supportedModes[j]!=None)
			{
			    // add game type to the list of supported game types for this level if it is unique (duplicates in source array)
			
			    gameType = data[i].supportedModes[j].default.acronym;
			    gameClass = string(data[i].supportedModes[j]);
			    
			    match = false;
			    
			    for (k=0; k<default.levels[i].gameTypes.length; k++)
			    {
					if (default.levels[i].gameTypes[k] == gameType)
					{
				        match = true;
						break;
					}
			    }
			    
			    if (!match)
				{
                    default.levels[i].gameTypes[default.levels[i].gameTypes.length] = gameType;
				}

                // and if this is a new game type then add it to the global list

                match = false;

                for (k=0; k<default.gameTypes.length; k++)
                {
                    if (gameType==default.gameTypes[k].name)
                    {
                        match = true;
                        break;
                    }
                }
                
                if (!match)
                {
                    index = default.gameTypes.length;
                    default.gameTypes.length = index + 1;
                    default.gameTypes[index].name = gameType;
                    default.gameTypes[index].className = gameClass;
                }
            }
		}
    }

    // generate the list of levels for each game type
    
    default.gameTypeLevels.length = default.gameTypes.length;
    
    for (i=0; i<default.gameTypes.length; i++)
    {
        default.gameTypeLevels[i].gameType = default.gameTypes[i].name;
        
        // find set of levels that support this game type
        
        for (j=0; j<default.levels.length; j++)
        {
            for (k=0; k<default.levels[j].gameTypes.length; k++)
            {
                gameType = default.levels[j].gameTypes[k];
                
                if (gameType==default.gameTypes[i].name)
                {
                    // level supports this game type
                    default.gameTypeLevels[i].levels[default.gameTypeLevels[i].levels.length] = default.levels[j];
                }
            }    
        }
    }
}

static function save()
{
    // save cached level data
    
    StaticSaveConfig();
}

static function getGameTypeList(out array<GameData> gameTypeNames)
{
    gameTypeNames = default.gameTypes;
}

static function getLevelList(out array<string> levelNames, optional bool bPreferTitles)
{
    local int i;
    
    for (i=0; i<default.levels.length; i++)
	{
		if (bPreferTitles && default.levels[i].title != "Untitled")
			levelNames[i] = default.levels[i].title;
		else
	        levelNames[i] = default.levels[i].name;
	}
}

static function getLevelListForGameType(string gameType, out array<string> levels, optional bool bPreferTitles)
{
    local int i, j;
	local array<string> levelList;
	local string mapTitle, mapFilename;
	
	if (gameType=="")
	    getLevelList(levels, bPreferTitles);

    for (i=0; i<default.gameTypeLevels.length; i++)
    {
        if (gameType==default.gameTypeLevels[i].gameType)
        {
			for (j=0; j<default.gameTypeLevels[i].levels.Length; j++)
			{
				mapTitle = default.gameTypeLevels[i].levels[j].title;
				mapFilename = default.gameTypeLevels[i].levels[j].name;

				if (bPreferTitles && mapTitle != "Untitled")
					levelList[levelList.Length] = mapTitle;
				else
					levelList[levelList.Length] = mapFilename;
			}
			levels = levelList;
            break;
        }
    }
}

static function string getGameTypeFromGameClassName(string gameClass)
{
    local int i;

    for (i=0; i<default.gameTypes.length; i++)
    {
        if (gameClass==default.gameTypes[i].className)
            return default.gameTypes[i].name;
    }
}

static function getMutatorList(Engine.LevelInfo level, out array<string> mutators)
{
    local string nextMutator;
    local string nextDescription;

	level.GetNextIntDesc("Engine.Mutator", 0, nextMutator, nextDescription);     // todo: Gameplay.Mutator

	mutators.length = 0;
	
	while (nextMutator!="")
	{	
		mutators[mutators.Length] = nextMutator;

		level.GetNextIntDesc("Engine.Mutator", mutators.length, nextMutator, nextDescription);
	}
	
	// TODO: mutator list is not correct
}

// internal functions

private static function scanLevels(out array<String> files, out array<LevelSummary> levels)
{
	local int i;
	local LevelSummary level;
	local string firstlevel, nextlevel, testlevel, loadlevel;

	// get list of level filenames matching MP-*
	
	firstlevel = class'Actor'.static.GetMapName("MP-", "", 0);
	nextlevel = firstlevel;

	while (!(firstlevel ~= testlevel))
	{
		if (Right(nextlevel, 4) ~= ".tvm")
			loadlevel = Left(nextlevel, Len(nextlevel) - 4);
		else
			loadlevel = nextlevel;

		nextlevel = class'Actor'.static.GetMapName("MP-", nextlevel, 1);
		testlevel = nextlevel;

		if (loadlevel != "")
			files[files.length] = loadlevel;
	}

	// Now load the actual LevelSummaries (potentially slow)
	
	for (i=0; i<files.length; i++)
	{
		level = LevelSummary(DynamicLoadObject(files[i]$".LevelSummary", class'LevelSummary'));

		if (level==None)
			continue;

		levels[levels.length] = level;
	}

    assert(files.length==levels.length);
}
            