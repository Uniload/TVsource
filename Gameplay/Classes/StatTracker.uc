class StatTracker extends Engine.Info
	config;

var() globalconfig int globalLogLevel;

var Array< Stat > stats;
var() globalconfig Array< StatSerializer > statSerializers;

var int currentStatID;

function initialize()
{
	local int i;
	local TribesReplicationInfo TRI;
	
	// Clear all statData entries
	ForEach DynamicActors(class'TribesReplicationInfo', TRI)
	{
		for (i=0; i<stats.Length; i++)
		{
			TRI.statDataList[i] = None;
		}
	}

	// Clear all stats
	stats.Remove(0, stats.Length);

	// Read active serializers from ini file
	// TEMP:  For now, just manually add a serializer
	//statSerializers[statSerializers.Length] = new class'LocalStatSerializer';
	statSerializers[statSerializers.Length] = new class'GameSpyStatSerializer';

	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].initialize();
	}

	// Register to receive messages
	registerMessage(class'MessageLevelStart', "All");
	registerMessage(class'MessageGameEnd', "All");
	registerMessage(class'MessageClientConnected', "All");
	registerMessage(class'MessageClientDisconnected', "All");
}

function registerStat(Class<Stat> s)
{
	local int i;

	// Don't register the stat if it has already been registered
	if (statRegistered(s))
		return;

	// Don't register default Stats
	if (s == None)
		return;

	if (s.default.logLevel > globalLogLevel)
		return;

	// Register the stat
	stats[stats.Length] = new s();

	// Give serializers an opportunity to register the stat
	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].registerStat(stats[stats.Length - 1]);
	}
	//Log("STATS:  StatTracker registered "$s);
}

function bool statRegistered(Class<Stat> s)
{
	local int i;

	for (i=0; i<stats.Length; i++)
	{
		if (stats[i].Class == s)
			return true;
	}

	return false;
}

function awardStat(Controller C, Class<Stat> s, optional Controller Target, optional int value)
{
	local StatData sd;
	local int i;
	local TribesReplicationInfo TRI;
	local PlayerController PC;

	//Log("STATTRACKER:  awarding "$s$" to "$C);

	if (C == None)
	{
		//Log("STATTRACKER warning:  Stat was awarded to None controller");
		return;
	}

	PC = PlayerController(C);

	if (PC == None)
		return;

	if (s == None)
	{
		//Log("STATTRACKER warning:  A None stat was awarded to "$C);
		return;
	}

	if (s.default.logLevel > globalLogLevel)
		return;

	// Increase amount by 1 if no value was supplied
	if (value <= 0)
	{
		value = 1;
	}

	// Send personal message if applicable
	if (s.default.personalMessage != "" && s.default.personalMessageClass != None)
	{
		if (target != None)
			PC.ReceiveLocalizedMessage(s.default.personalMessageClass, 0, s, target.playerReplicationInfo,, string(value));
		else
			PC.ReceiveLocalizedMessage(s.default.personalMessageClass, 0, s,,, string(value));
	}

	// Send target message if applicable
	//if (Target != None && s.default.targetMessage != "" && s.default.targetMessageClass != None)
	//	PlayerController(Target).ReceiveLocalizedMessage(s.default.targetMessageClass, 0, s, C);

	TRI = TribesReplicationInfo(PC.PlayerReplicationInfo);

	if (TRI == None)
		return;

	sd = TRI.getStatData(s);

	if (sd == None)
	{
		Log("STATTRACKER warning:  An unregistered stat was awarded ("$s$")");
		return;
	}

	sd.amount = sd.amount + value;

	// Set a timestamp
	// This ensures that all serializers will report the stat being awarded
	// at the same time.  It also allows this to be used to display times if
	// necessary, for example MPCheckpoints might want to somehow display the
	// finishing time of a race (not sure how yet).
	sd.lastAwardTimestamp = Level.TimeSeconds;

	// Also award offense, defense and style points
	TRI.offenseScore += sd.statClass.default.offensePointsPerStat * value;
	TRI.defenseScore += sd.statClass.default.defensePointsPerStat * value;
	TRI.styleScore += sd.statClass.default.stylePointsPerStat * value;

	// Calculate total score here for now; eventually this can be
	// performed when the score is displayed
	TRI.Score += sd.statClass.default.offensePointsPerStat * value;
	TRI.Score += sd.statClass.default.defensePointsPerStat * value;
	TRI.Score += sd.statClass.default.stylePointsPerStat * value;

	//Log("TRACKER awarded "$s);

	// Notify StatSerializers
	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].serializeStat(TRI, sd);
	}
}

function incrementStatAttempt(Character c, Class<Stat> s)
{
	if (c.tribesReplicationInfo == None)
		return;

	// Increment the denominator
}

function setStat(Controller c, class<Stat> s, int value)
{
	local TribesReplicationInfo TRI;

	TRI = TribesReplicationInfo(C.PlayerReplicationInfo);

	if (TRI == None)
		return;

	TRI.getStatData(s).amount = value;
}

function addStatSerializer(StatSerializer newSerializer)
{
	statSerializers[statSerializers.Length] = newSerializer;
}

function onMessage(Message msg)
{
	local int i;

	// Receive game messages here and notify serializers accordingly
	if (MessageGameEnd(msg) != none)
	{
		for (i=0; i<statSerializers.Length; i++)
		{
			statSerializers[i].onMapEnd();
		}
	}
	else if (MessageLevelStart(msg) != None)
	{
		for (i=0; i<statSerializers.Length; i++)
		{
			statSerializers[i].onMapStart();
		}
	}
	else if (MessageClientConnected(msg) != None)
	{
		onClientConnect(tribesReplicationInfo(MessageClientConnected(msg).client.playerReplicationInfo));
	}
	else if (MessageClientDisconnected(msg) != None)
	{
		onClientDisconnect(tribesReplicationinfo(MessageClientDisconnected(msg).client.playerReplicationInfo));
	}
}

function onClientConnect(TribesReplicationInfo TRI)
{
	local int i;

	// Serialize if applicable
	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].onClientConnect(TRI);
	}
}

function onClientDisconnect(TribesReplicationInfo TRI)
{
	local int i;

	// Serialize if applicable
	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].onClientDisconnect(TRI);
	}
}

function onMapStart()
{
	local int i;

	// Serialize if applicable
	for (i=0; i<statSerializers.Length; i++)
	{
		statSerializers[i].onMapStart();
	}
}

function onMapEnd()
{
	local int i;

	for (i=0; i<statSerializers.Length; i++)
	{
		// Serialize if applicable
		if (statSerializers[i].bSerializeOnMapEnd)
			statSerializers[i].serializeSnapshot();

		statSerializers[i].onMapEnd();
	}
}

function int createStatID()
{
	return currentStatID++;
}

defaultproperties
{
     globalLogLevel=5
}
