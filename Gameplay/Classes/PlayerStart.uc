//=============================================================================
// Player start location.
//=============================================================================
class PlayerStart extends Engine.PlayerStart
	placeable;

var()	editdisplay(displayActorLabel)
		editcombotype(enumTeamInfo)
		TeamInfo team					"PlayerStart's team";

var()	float invincibleDelay			"The amount of time the player will be invincible for after spawning";

// Observer-specific flags
var()	bool bObserverStart					"When true, this start point is used for observers (and only observers)";
var()	bool bLockObserverLocation			"If bObserverStart is true and this flag is set, observers who spawn here will be able to rotate but not move (NOT YET IMPLEMENTED)";

var() editcombotype(enumBaseInfo)
		editdisplay(displayActorLabel)
		BaseInfo			baseInfo			"Specifies the BaseInfo object that this playerstart belongs to. Overrides the 'team' member and can be 'None'.";

var() bool bDisallowEquipmentDropOnDeath;

// defaultPawnClassName
// return the default pawn class for the start point
function string defaultPawnClassName()
{
	return "";
}


function onPlayerSpawned(Controller aPlayer)
{
	local Character c;

	c = Character(aPlayer.Pawn);

	if (c == None)
		return;

	c.bDisallowEquipmentDropOnDeath = bDisallowEquipmentDropOnDeath;

	if (MultiplayerGameInfo(Level.Game) != None && !MultiplayerGameInfo(Level.Game).IsInState('GamePhase'))
		return;

	// Withdraw carryables if applicable
	if (baseInfo != None)
	{
		if (baseInfo.spawnArray != None)
			baseInfo.spawnArray.PlayerSpawned();

		if (baseInfo.container != None)
		{
			c.numPermanentCarryables = baseInfo.container.numWithdrawnPerSpawn;
			baseInfo.container.onPlayerSpawned(c);
		}
		else
			c.numPermanentCarryables = 0;
	}
}

function bool canRespawn()
{
	if (baseInfo != None && baseInfo.container != None)
		return baseInfo.container.allowSpawn();

	return true;
}

// enumTeamInfo
// List all team info objects in the editor
function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

// displayActorLabel
// Display an actor reference's label in the editor
function string displayActorLabel(Actor t)
{
	return string(t.label);
}

function enumBaseInfo(Engine.LevelInfo l, Array<BaseInfo> a)
{
	local BaseInfo b;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		a[a.length] = b;
	}
}

defaultproperties
{
     invincibleDelay=5.000000
}
