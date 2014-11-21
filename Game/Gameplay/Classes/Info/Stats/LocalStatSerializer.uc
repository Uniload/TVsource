class LocalStatSerializer extends StatSerializer;

var string	filenamePrefix;
var FileLog localLog;

// Serializes stats to disk

function serializeSnapshot()
{
}

function Logf(string LogString)
{
	//Log("Logging:  "$LogString);
	if (localLog!=None)
		localLog.Logf(LogString);
} 

function serializeStat(TribesReplicationInfo TRI, StatData sd)
{
	local String output;

	if (TRI == None)
	{
		Log("Error:  null TRI received in serializeStat()");
		return;
	}

	output = string(TRI.playerStatIndex);
	output = output @ "O="$string(TRI.offenseScore)@"D="$string(TRI.defenseScore)@"S="$string(TRI.styleScore);
	Logf(output);
}

function onMapStart()
{
	Super.initialize();

	localLog = spawn(class 'FileLog');
	if (localLog!=None)
	{
		localLog.OpenLog("LocalStats");
		Log("Output game stats to: LOCALSTATS.TXT");
	}
	else
	{
		Log("Could not spawn local stats log");
		Destroy();
	}
}

function onMapEnd()
{
	Log("Local stat serializer shutting down");
	Super.shutdown();
	if (localLog!=None) 
		localLog.Destroy();
}

defaultproperties
{
	filenamePrefix			= "stats"
}