class SingleplayerGameInfo extends GameInfo
	config;

struct DifficultyData
{
	var() config float aiLeadAbilityMultiplier;
	var() config float aiHealthMultiplier;
	var() config float playerHealthMultiplier;
};

var() config DifficultyData difficultyMods[3];
var() config string deathMenuClass;

var() config bool bShowSubtitles;

var() private bool allowRespawn;

var() private int maxDroppedEquipment;
var private Array<Actor> droppedEquipment;

var bool bDifficultySet;
var bool bAllowReturnToGameWhenDead;

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local Rook TestRook;

	// Try to match up to existing unoccupied player in level, for savegames.
	ForEach DynamicActors(class'Rook', TestRook )
	{
		if ((TestRook!=None) &&
			TestRook.Controller != None &&
			!TestRook.Controller.bDeleteMe &&
			(PlayerController(TestRook.Controller)!=None) &&
			(PlayerController(TestRook.Controller).Player==None) &&
			(TestRook.Health > 0))
		{
			//NewPlayer.Destroy();
			TestRook.SetRotation(TestRook.Controller.Rotation);
			TestRook.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
			TestRook.PlayWaiting();

			// Restore the HUD
			PlayerCharacterController(TestRook.Controller).clientTribesSetHUD(PlayerCharacterController(TestRook.Controller).currentHUDClass);

			return PlayerController(TestRook.Controller);
		}
	}

	return super.Login(Portal, Options, Error);
}
// setTeamObject
function setTeamObject(Rook r)
{
	local SinglePlayerStart s;
	s = SinglePlayerStart(r.LastStartSpot);

	if (s == None && s.team == None)
	{
		return;
	}

	r.setTeam(s.team);

	LOG("Singleplayer is on team "$r.team().label);
}

// tribesRatePlayerStart
function float tribesRatePlayerStart(PlayerStart P, TeamInfo Team, Controller Player)
{
	local PlayerCharacterController c;

	if (Player != None)
		c = PlayerCharacterController(Player);

	//Log("rating SPPlayer start "$P$" using team "$team$" and c's spawnbase "$c.spawnBase);
	//if (SinglePlayerStart(P) == None)
	//	return 0;
	//else
	//	return 1;

	if (SinglePlayerStart(P) == None) // || SinglePlayerStart(P).team != Team)
		return 0;

	// spawn only within the desired base, if specified
	if (c != None && allowRespawn && c.spawnBase != None)
	{
		if (P.baseInfo != None && P.baseInfo == c.spawnBase)
			return Rand(65535);
		else
			return 0;
	}

	return Rand(65535);
}

function setAllowRespawn(bool allow)
{
	allowRespawn = allow;
	bRestartLevel = !allowRespawn;
}

// tryRespawn
function bool tryRespawn(PlayerCharacterController c)
{
	if (allowRespawn)
	{
		// Destroy character's ragdoll
		if (Character(c.ViewTarget) != None && Character(c.ViewTarget).bTearOff)
			c.ViewTarget.Destroy();

		RestartPlayer(c);
		return true;
	}

	return false;
}

function showDeathScreen(PlayerCharacterController c)
{
	c.OpenMenu(deathMenuClass);
}

function setCampaignDifficulty(int newDifficulty)
{
	local Actor a;
	local Character c;
	local bool bFoundSPCharacter;
	local int i;

	LOG("Setting difficulty to "$newDifficulty);

	bDifficultySet = true;
    difficulty = newDifficulty;
	i = difficulty;

	ForEach DynamicActors(class'Actor', a)
	{
		// filter objects according to difficulty
		if (difficulty < a.minDifficulty || difficulty > a.maxDifficulty)
		{
			a.Destroy();
			continue;
		}

		// apply multipliers to AIs
		if (BaseAICharacter(a) != None)
		{
			modifyAI(BaseAICharacter(a));
		}
		else if (SingleplayerCharacter(a) != None)
		{
			bFoundSPCharacter = true;
			modifyPlayer(SingleplayerCharacter(a));
		}
	}

	// if we didn't happen to find a SPCharacter object, fall back to controller's pawn
	if (!bFoundSPCharacter)
	{
		c = Character(Level.GetLocalPlayerController().Pawn);
		modifyPlayer(SingleplayerCharacter(c));
	}
}

// RestartPlayer
function RestartPlayer( Controller aPlayer )	
{
	Super.RestartPlayer(aPlayer);

	// Notify the playerStart so it can notify its baseInfo and spawnArray
	PlayerStart(aPlayer.startSpot).onPlayerSpawned(aPlayer);

	setTeamObject( Rook(aPlayer.Pawn) );
}

function Name playerPawnDestroyedState()
{
	if (allowRespawn)
		return 'PlayerRespawn';
	else
		return 'Dead';
}

// initialTeamObject
function TeamInfo initialTeamObject(PlayerController pc)
{
	return None;
}

function addDroppedEquipment(Equipment e)
{
	local int i;

	for (i = 0; i < droppedEquipment.length; ++i)
		if (droppedEquipment[i] == e)
			return;

	droppedEquipment[droppedEquipment.Length] = e;

	if (droppedEquipment.Length > maxDroppedEquipment)
	{
		for (i = 0; i < droppedEquipment.length; ++i)
			if (Equipment(droppedEquipment[i]).canExpire())
				droppedEquipment[i].Destroy();
	}
}

function removeDroppedEquipment(Equipment e)
{
	local int i;

	for (i = 0; i < droppedEquipment.length; ++i)
		if (droppedEquipment[i] == e)
			break;

	if (i != droppedEquipment.length)
		droppedEquipment.Remove(i, 1);
}

// skin changes are not allowed in singleplayer games
function bool allowSkinChanges()
{
	return false;
}

// manual respawn is not allow in singleplayer games
function bool allowManualRespawn()
{
	return false;
}

function bool ReturnToGameAllowed()
{
	local PlayerController pc;

	pc = Level.GetLocalPlayerController();

	return !TribesGUIControllerBase(pc.Player.GUIController).GuiConfig.bMissionFailed;
}

event bool SaveAllowed()
{
	local PlayerCharacterController pc;

	pc = PlayerCharacterController(Level.GetLocalPlayerController());

	if (pc == None || pc.isInCutscene())
		return false;

	return (pc.Pawn != None && pc.Pawn.Health > 0) && !TribesGUIControllerBase(pc.Player.GUIController).GuiConfig.bMissionFailed;
}

// when ?restart is specified in a url, this function determines the map used for restart. 
// if it returns "" then the current URL is used by the engine.
event string GetRestartMap()
{
	local TribesGUIControllerBase gc;

	gc = TribesGUIControllerBase(Level.GetLocalPlayerController().Player.GUIController);
	if (gc != None && gc.GuiConfig.CurrentCampaign != None)
		return gc.GuiConfig.CurrentCampaign.missions[gc.GuiConfig.CurrentCampaign.progressIdx].mapName;
}

function float modifyHealthKitRate(Rook who, float rate)
{
	if (SingleplayerCharacter(who) != None)
	{
		return rate * difficultyMods[difficulty].playerHealthMultiplier;
	}

	return rate;
}

function float modifyRepairRate(Rook who, float rate)
{
	local BaseAICharacter ai;
	local Vehicle v;

	if (SingleplayerCharacter(who) != None)
	{
		return rate * difficultyMods[difficulty].playerHealthMultiplier;
	}
	
	ai = BaseAICharacter(who);
	if (ai != None)
	{
		return rate * FMax(ai.healthModifier, difficultyMods[difficulty].aiHealthMultiplier);
	}

	v = Vehicle(who);
	if (v != None)
	{
		return rate * v.healthModifier;
	}

	return rate;
}

static function bool showChatWindow()
{
	return default.bShowSubtitles;
}

function modifyAI(BaseAICharacter c)
{
	if (!bDifficultySet)
		return;

	if (c.bApplyHealthFilter)
	{
		c.healthMaximum *= difficultyMods[difficulty].aiHealthMultiplier;
		c.health = c.healthMaximum;
	}

	if (c.shotLeadAbility.Min < 1.0)
		c.shotLeadAbility.Min *= difficultyMods[difficulty].aiLeadAbilityMultiplier;
	else
		c.shotLeadAbility.Min *= 1.0 + difficultyMods[difficulty].aiLeadAbilityMultiplier;
	
	if (c.shotLeadAbility.Max < 1.0)
		c.shotLeadAbility.Max *= difficultyMods[difficulty].aiLeadAbilityMultiplier;
	else
		c.shotLeadAbility.Max *= 1.0 + difficultyMods[difficulty].aiLeadAbilityMultiplier;
}

function modifyPlayer(SingleplayerCharacter c)
{
	if (!bDifficultySet || c == None)
		return;

	if (c.bApplyHealthFilter)
	{
		c.healthMaximum *= difficultyMods[difficulty].playerHealthMultiplier;
		c.health = c.healthMaximum;
	}
}


defaultproperties
{
	playerTeamDamagePercentage		= 0.0
	CheatClass		= class'TribesCheatManager'
    bRestartLevel	= false
	maxDroppedEquipment = 24

	difficultyMods[0] = (aiLeadAbilityMultiplier=1.5,aiHealthMultiplier=0.5,playerHealthMultiplier=1.5)
	difficultyMods[1] = (aiLeadAbilityMultiplier=1,aiHealthMultiplier=1,playerHealthMultiplier=1)
	difficultyMods[2] = (aiLeadAbilityMultiplier=0.5,aiHealthMultiplier=1.5,playerHealthMultiplier=0.5)

	deathMenuClass = "TribesGUI.TribesSPEscapeMenu"
}
