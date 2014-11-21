//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native;

//------------------------------------------------------------------------------
// Structs for reporting server state data

struct native export KeyValuePair
{
	var() string Key;
	var() string Value;
};

struct native export PlayerResponseLine
{
	var() int PlayerNum;
	var() int PlayerID;
	var() string PlayerName;
	var() int Ping;
	var() int Score;
	var() int StatsID;
	var() array<KeyValuePair> PlayerInfo;

};

struct native export ServerResponseLine
{
	var() int ServerID;
	var() string IP;
	var() int Port;
	var() int QueryPort;
	var() string ServerName;
	var() string MapName;
	var() string GameType;
	var() int CurrentPlayers;
	var() int MaxPlayers;
	var() int Ping;
	
	var() array<KeyValuePair> ServerInfo;
	var() array<PlayerResponseLine> PlayerInfo;
};

#if IG_TRIBES3_ADMIN   // glenn: admin support

static function FillPlayInfo(PlayInfo PlayInfo)
{
	PlayInfo.AddClass(default.Class);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	return true;
}

#endif


defaultproperties
{
	RemoteRole=ROLE_None
	NetUpdateFrequency=10
     bHidden=True
	 bOnlyDirtyReplication=true
	 bSkipActorPropertyReplication=true
}
