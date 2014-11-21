class StatSerializer extends Engine.Info
	abstract;

var() int	currentLogLevel;
var() int	serializationFrequency;
var() bool	bSerializeOnMapEnd;

function serializeSnapshot()
{
	// Serializes all current statData in every TRI, filtered by logLevel
}

function serializeStat(TribesReplicationInfo TRI, StatData sd)
{
}

function bool shouldSerialize(Stat s)
{
	return s.logLevel <= currentLogLevel;
}

function setLogLevel(int i)
{
	currentLogLevel = i;
}

function onClientConnect(TribesReplicationInfo TRI)
{
}

function onClientDisconnect(TribesReplicationInfo TRI)
{
}

function onMapStart()
{
}

function onMapEnd()
{
}

function initialize()
{
	SetTimer(serializationFrequency, true);
}

function shutdown()
{
	SetTimer(0, false);
}

function Timer()
{
	serializeSnapshot();
}

function registerStat(Stat s)
{
}

defaultproperties
{
     currentLogLevel=2
}
