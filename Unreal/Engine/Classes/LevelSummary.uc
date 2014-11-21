//=============================================================================
// LevelSummary contains the summary properties from the LevelInfo actor.
// Designed for fast loading.
//=============================================================================
class LevelSummary extends Core.Object
	native;

//-----------------------------------------------------------------------------
// Properties.

// From LevelInfo.
var() localized string Title;
var()           string Author;
#if !IG_TRIBES3	// michaelj:  Use min/max instead
var() int	IdealPlayerCount;
#endif
var() localized string LevelEnterText;

#if IG_TRIBES3	// michaelj:  Additional information (some integrated from UT2004)
var() Array< class<GameInfo> >	SupportedModes	"List of modes that this map supports.";
var() Array< int >				SupportedModesScoreLimits	"Parallels the SupportedModes array.  Score limit for each game type.  0 to disable.";
var() localized String  Description		"Description of this level.";
var()			Material Screenshot		"A screenshot of this level.";
var()			int		IdealPlayerCountMin		"Recommended minimum number of players for this level.";
var()			int		IdealPlayerCountMax		"Recommended maximum number of players for this level.";
var()			String	ExtraInfo;
var()			bool	HideFromMenus;
#endif

defaultproperties
{
}
