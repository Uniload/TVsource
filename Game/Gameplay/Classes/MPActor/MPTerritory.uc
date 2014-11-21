class MPTerritory extends MPArea implements IRepairClient;

var() int			teamConquerScore			"The number of points a team receives for conquering.  If bReconquerable is false, this amount is subtracted if a team loses the territory.";
var() int			conquerTime					"The amount of uninterrupted time it takes to conquer the territory";
var() float			individualConquerBonusScale "Each additional friend conquering a territory scales the conquering speed by this amount (1 has no effect)";
var() int			minimumConquerers			"The mininum number of people needed in order to start conquering this territory";
var() float			conquerInterval				"The frequency with which the territory considers who is conquering it";
var() bool			bConquerOnce				"When true, the territory can only be conquered once";
var bool			bReconquerable				"Can the Territory be conquered again for points after it has already been conquered?";
var bool			bReconquerNeedsPlayers		"If bReconquerable is true, does reconquering require players to be in the Territory?  If false, a team will reconquer their territory even when none of their players are in it.";
var() editdisplay(displayActorLabel)
	  editcombotype(enumBaseInfo)
	  BaseInfo		ownerBase					"An optional BaseInfo to which this Territory is attached.  Capturing the Territory also captures this base.";
var() class<Engine.LocalMessage> TerritoryMessageClass;

var TeamInfo		conqueringTeam;
var TeamInfo		ownerTeam;
var TeamInfo		previousOwnerTeam;
var float			currentConqueringTime;

var bool			bConquering;
var bool			bLocalConquering;
var bool			bContesting;
var bool			bLocalContesting;
var bool			bIdle;
var bool			bLocalIdle;
var bool			bConquered;
var bool			bLocalConquered;
var bool			bDelayPermanentConquer;

var (Skins) Material conqueringSkin;
var (Skins) Material contestedSkin;
var (Skins) Material idleSkin;
var (Skins) int titleSkinIndex;

var (EffectEvents) Name conqueringEffectEvent			"The name of an effect event that loops on the territory when conquering";
var (EffectEvents) Name startedConqueringEffectEvent	"The name of an effect event that plays once on the territory when conquering";
var (EffectEvents) Name contestingEffectEvent			"The name of an effect event that loops on the territory when contesting";
var (EffectEvents) Name startedContestingEffectEvent	"The name of an effect event that plays once on the territory when contesting";
var (EffectEvents) Name idleEffectEvent					"The name of an effect event that loops on the territory when conquering";
var (EffectEvents) Name conqueredEffectEvent			"The name of an effect event that plays once on the territory when conquered";

var RepairRadius rr;
var() Name socketTarget								"The name of the socket to use when attaching the tendril effect to a target actor";

// Stats
var(Stats)	class<Stat>	conquerStat				"Stat awarded when a player conquers a territory";

replication
{
	reliable if (Role == ROLE_Authority)
		bConquering, bContesting, bIdle, bConquered, conquerTime, currentConqueringTime;
}

function OnConquered()
{
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode != NM_Client)
		areaTrigger.setTriggerFrequency(conquerInterval);

	rr = new class'RepairRadius'(self, , Location);
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();
	updateEffects();
}

simulated function destroyed()
{
	super.destroyed();
	cleanup();
}

function cleanup()
{
	Super.cleanup();

	if (rr != None)
		rr.destroy();
}

// Awkward effects handling
simulated function updateEffects()
{
	if (bConquering != bLocalConquering)
	{
		bLocalConquering = bConquering;
		if (bConquering)
		{
			SetSkin(conqueringSkin);
			TriggerEffectEvent(conqueringEffectEvent);
			TriggerEffectEvent(startedConqueringEffectEvent);

			// Start animation going down from whatever position it's already in

			AnimBlendParams(1, 1);
			//Log("Playing down animation at rate "$ (GetAnimLength('Down') / conquerTime));
			PlayAnim('Down', GetAnimLength('Down') / conquerTime,,1);

			if (currentConqueringTime > 0)
			{
				//Log("Continuing at frame "$100 * currentConqueringTime / conquerTime);
				SetAnimFrame(100 * currentConqueringTime / conquerTime,1,1);
			}
		}
		else
		{
			// Reset it
			AnimBlendParams(1, 1);
			//Log("Playing up animation");
			//PlayAnim('Up',,, 1);
			SetSkin(idleSkin);
			UnTriggerEffectEvent(conqueringEffectEvent);
			//AnimBlendParams(1, 1);
			if (currentConqueringTime > 0 && currentConqueringTime < conquerTime)
			{
				//Log("Pausing animation at "$100 * currentConqueringTime / conquerTime);
				FreezeAnimAt(100 * currentConqueringTime / conquerTime, 1);
			}
		}
	}

	if (bContesting != bLocalContesting)
	{
		bLocalContesting = bContesting;
		if (bContesting)
		{
			SetSkin(contestedSkin);
			UnTriggerEffectEvent(conqueringEffectEvent);
			TriggerEffectEvent(contestingEffectEvent);
			TriggerEffectEvent(startedContestingEffectEvent);;
		}
		else
		{
			UnTriggerEffectEvent(contestingEffectEvent);
			if (!bConquering)
				SetSkin(idleSkin);
		}
	}

	if (bConquered != bLocalConquered)
	{
		if (!bReconquerable)
			SetSkin(idleSkin);
		bLocalConquered = bConquered;
		TriggerEffectEvent(conqueredEffectEvent);

		// Quickly send the animation to the top
		AnimBlendParams(1, 1);
		PlayAnim('Up',,, 1);
	}

	if (bIdle != bLocalIdle)
	{
		bLocalIdle = bIdle;
		if (bIdle)
		{
			SetSkin(idleSkin);
			UnTriggerEffectEvent(conqueringEffectEvent);
			TriggerEffectEvent(idleEffectEvent);
		}
	}
}

function OnAreaEntered(Character c)
{
	//c.ReceiveLocalizedMessage( class'MPTerritoryMessages', 1 );
}

function OnAreaExited(Character c)
{
	//c.ReceiveLocalizedMessage( class'MPTerritoryMessages', 2 );
}

function OnAreaTick()
{
	// Do nothing
}

function setTeam(TeamInfo t)
{
	previousOwnerTeam = ownerTeam;
	ownerTeam = t;
	Super.setTeam(t);

	if (previousOwnerTeam != ownerTeam && ownerBase != None)
		ownerBase.team = t;
}

function bool shouldInteractWith(Character c)
{
	return !c.bDontInteractWithTerritories;
}

auto state Ownerless
{
	function BeginState()
	{
		//Log(self$" entered Ownerless state");
		ownerTeam = None;
		SetSkin(IdleSkin);
		determineInitialState();

		bIdle = true;
		updateEffects();
	}

	function EndState()
	{
		bIdle = false;
		updateEffects();
	}

	function OnAreaEntered(Character c)
	{
		if (!shouldInteractWith(c))
			return;

		Global.OnAreaEntered(c);

		//Log("Character entered, numPlayers = "$areaTrigger.numPlayers());

		// If minimum number of conquerers is satisfied, start conquering
		if (areaTrigger.numPlayers(c.team()) >= minimumConquerers)
		{
			//Log(self$" to Conquering from Ownerless in OnAreaEntered()");
			GotoState('Conquering');
		}
	}


	function determineInitialState()
	{
		local TeamInfo t;
		t = areaTrigger.onlyRemainingTeam();

		// If there isn't a single remaining team and there are players inside, then it's contested
		if (t == None && areaTrigger.numPlayers() > 0)
		{
			//Log(self$" to Contested from Ownerless in determineInitialState()");
			GotoState('Contested');
			return;
		}

		// If there's only one team, start conquering if applicable
		else if (t != None && (t != team() || (t == team() && bReconquerable)))
		{
			//Log(self$" to Conquering from Ownerless in determineInitialState()");
			GotoState('Conquering');
			return;
		}

		// Check to see if the team has been set in the editor; if it has been, 
		// start in the conquered state
		else if (team() != None)
		{
			// Check for bConquerOnce, and if set, effectively delay it
			if (bConquerOnce)
				bDelayPermanentConquer = true;
			setTeam(team());
			//Log(self$" to Conquered from Ownerless in determineInitialState()");
			GotoState('Conquered');
			return;
		}

		// Otherwise, remain Ownerless
		//Log(self$" remaining ownerless");
	}
}

// The Territory has only one team in it, but more players are needed
state AwaitingTeammates
{
	function BeginState()
	{
		//Log(self$" entered AwaitingTeammates state");
	}

	function OnAreaEntered(Character c)
	{
		if (!shouldInteractWith(c))
			return;

		Global.OnAreaEntered(c);

		// If an enemy entered, the territory becomes contested
		if (c.team() != conqueringTeam)
		{
			//Log(self$" to Contested from AwaitingTeammates");
			GotoState('Contested');
			return;
		}

		// Check to see if there are now enough friendlies
		if (areaTrigger.numPlayers(conqueringTeam) >= minimumConquerers)
		{
			//Log(self$" to Conquering from AwaitingTeammates");
			GotoState('Conquering');
		}
	}
}

// The Territory is in the process of being conquered
state Conquering
{
	function BeginState()
	{
		conqueringTeam = areaTrigger.onlyRemainingTeam();
		//Log("Conquering state entered with conqueringTeam = "$conqueringTeam);
		
		if (conqueringTeam == None)
		{
			// I believe this happens if the player started conquering an empty territory
		}

		// Check to see if there are enough players to conquer it
		if (areaTrigger.numPlayers(conqueringTeam) < minimumConquerers)
		{
			//Log(self$" to AwaitingTeammates from Conquering");
			GotoState('AwaitingTeammates');
			return;
		}

		Level.Game.BroadcastLocalized(self, TerritoryMessageClass, 2, conqueringTeam);
		dispatchMessage(new class'MessageTerritoryConquering'(label));


		bConquering = true;
		updateEffects();
	}

	function EndState()
	{
		bConquering = false;
		updateEffects();
	}

	function allocatePoints()
	{
		// Award points
		Level.Game.BroadcastLocalized(self, TerritoryMessageClass, 0, conqueringTeam);
		scoreTeam(teamConquerScore, conqueringTeam);
		
		// If the territory isn't reconquerable, remove points from the conquered team
		if (!bReconquerable && previousOwnerTeam != None && previousOwnerTeam != ownerTeam)
			scoreTeam(-teamConquerScore, previousOwnerTeam);
	
		// Somehow divvy up stats among conquerers here
	}

	function OnAreaTick()
	{
		local int i;
		local float conquerBonusScale;

		// Manually calculate individualConquerBonusScale ^ areaTrigger.numPlayers(conqueringTeam)
		// The ^ operator doesn't seem to accept floats
		conquerBonusScale = individualConquerBonusScale;
		for (i=1; i<areaTrigger.numPlayers(conqueringTeam); i++)
			conquerBonusScale *= conquerBonusScale;

		// Increase conquering time
		currentConqueringTime += conquerInterval * conquerBonusScale;
		//Log("TERRITORY:  currentConqueringTime = "$currentConqueringTime$", bonusScale = "$conquerBonusScale);

		// If enough time has elapsed to conquer it
		if (currentConqueringTime >= conquerTime)
		{
			// The Territory was conquered
			setTeam(conqueringTeam);
			allocatePoints();
			dispatchMessage(new class'MessageTerritoryConquered'(label, ownerTeam.Label));
			OnConquered();
		
			//Log(self$" to Conquered from Conquering in onAreaTick()");
			GotoState('Conquered');
		}
	}

	function OnAreaEntered(Character c)
	{
		if (!shouldInteractWith(c))
			return;

		Global.OnAreaEntered(c);

		// If an enemy entered, the territory becomes contested
		if (c.team() != conqueringTeam)
		{
			//Log(self$" to Contested from Conquering in OnAreaEntered()");
			GotoState('Contested');
		}
	}

	function OnAreaExited(Character c)
	{
		if (!shouldInteractWith(c))
			return;

		Global.OnAreaExited(c);

		//Log(self$" had character exit "$c$" with numPlayers left = "$areaTrigger.numPlayers());
		// Is the exiting player the last player?
		if (areaTrigger.numPlayers() == 0)
		{
			if (ownerTeam == None)
			{
				//Log(self$"  to Ownerless from Conquering in OnAreaExited()");
				currentConqueringTime = 0;
				GotoState('Ownerless');
				return;
			}
			else
			{
				// Just return to the conquered state; whoever owned it still owns it
				//Log(self$" to Conquered from Conquering in OnAreaExited()");
				currentConqueringTime = 0;
				bDelayPermanentConquer = true;
				GotoState('Conquered');
				return;
			}
		}

		// There's at least 1 player left.  Was the exiting player needed in order to keep conquering?
		if ( areaTrigger.numPlayers(conqueringTeam) < minimumConquerers )
		{
			//Log(self$" to AwaitingTeammates from Conquering in OnAreaExited()");
			GotoState('AwaitingTeammates');
		}
	}
}

state Contested
{
	function BeginState()
	{
		//Log(self$" entered contested state");
		Level.Game.BroadcastLocalized(self, TerritoryMessageClass, 1, ownerTeam);
		//areaTrigger.debugOutput();
		dispatchMessage(new class'MessageTerritoryContested'(label));
		bContesting = true;
		bIdle = false;
		updateEffects();
	}

	function EndState()
	{
		bContesting = false;
		updateEffects();
	}

	function OnAreaExited(Character c)
	{
		local TeamInfo onlyRemainingTeam;

		if (!shouldInteractWith(c))
			return;

		Global.OnAreaExited(c);

		onlyRemainingTeam = areaTrigger.onlyRemainingTeam();

		if (onlyRemainingTeam == None)
		{
			// There's more than one remaining team
			// Check to make sure there are still people in the territory; if there aren't,
			// something has gone wrong
			if (areaTrigger.numPlayers() == 0)
			{
				Log("Territory error:  Area emptied while in contested state");
			}
			//Log(self$" continues to be contested despite the departure of "$c);
			return;
		}

		// There's only one remaining team
		// If the remaining team is a new team, or if there's already a team conquering, continue
		// conquering; otherwise, just stay conquered
		if (onlyRemainingTeam != None && (onlyRemainingTeam != ownerTeam)) // || conqueringTeam != None))
		{
			//Log(self$" to Conquering from Contested in OnAreaExited()");
			//Log("ort = "$onlyRemainingTeam$", owner = "$ownerTeam$", conquer = "$conqueringTeam);
			GotoState('Conquering');
		}
		else
		{
			//Log(self$" to Conquered from Contested in OnAreaExited() due to exit of "$c);
			bDelayPermanentConquer = true;
			GotoState('Conquered');
		}
	}
}

// The Territory has been conquered but is not reconquerable, i.e. you can't
// keep scoring points by maintaining possession of it
state Conquered
{
	function BeginState()
	{
		currentConqueringTime = 0;
		//Log(self$" entered conquered state due to team "$conqueringTeam);
		conqueringTeam = None;

		// Manage any lattice that might be present
		expandLattice(ownerTeam);
		if (previousOwnerTeam != None)
			contractLattice(previousOwnerTeam);

		// Allow base to be spawned at
		//if (ownerTeam != None && ownerBase != None)
		//	ownerTeam.addBase(ownerBase);

		// Update effects
		bConquered = !bConquered;
		updateEffects();

		// If it's only conquerable once, send it to a locked state
		if (bConquerOnce)
		{
			if (bDelayPermanentConquer)
			{
				bDelayPermanentConquer = false;
				return;
			}
			//Log(self$" to PermanentlyConquered from Conquered");
			GotoState('PermanentlyConquered');
			return;
		}

		// If it's reconquerable, keep on conquering
		//if (bReconquerable)
		//{
			//Log(self$" to Conquering from Conquered due to bReconquerable");
		//	GotoState('Conquering');
		//}
	}
	function OnAreaEntered(Character c)
	{
		if (!shouldInteractWith(c))
			return;

		Global.OnAreaEntered(c);

		// If an enemy entered, the territory becomes conquering or contested
		if (c.team() != team())
		{
			// Conquering if this player's team is the only one left or if this is the first player
			// to enter the territory
			if (c.team() == areaTrigger.onlyRemainingTeam(c))
			{
				//Log(self$" to Conquering from Conquered in OnAreaEntered() with team = "$team());
				GotoState('Conquering');
			}
			else
			{
				//Log(self$" to Contested from Conquered in OnAreaEntered() due to "$c$" and ort = "$areaTrigger.onlyRemainingTeam());
				GotoState('Contested');
			}
		}
	}

	function EndState()
	{
		// Don't allow this base to be considered a spawn area
		//if (ownerTeam != None && ownerBase != None)
		//	ownerTeam.removeBase(ownerBase);
	}

	// Don't show repair tendrils when conquered
	function bool canRepair()
	{
		return false;
	}
}

// The Territory has been conquered and can never be conquered again
state PermanentlyConquered
{
	function BeginState()
	{
		//Log(self$" has been permanently conquered");
		bIdle = true;
		updateEffects();
	}

	function OnAreaEntered(Character c)
	{
		// Do nothing
	}

	function OnAreaExited(Character c)
	{
		// Do nothing
	}

	// Don't show repair tendrils when permanently conquered
	function bool canRepair()
	{
		return false;
	}
}

function enumBaseInfo(Engine.LevelInfo l, Array<BaseInfo> a)
{
	local BaseInfo b;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		a[a.length] = b;
	}
}

simulated function setSkin(Material skin)
{
	skins[titleSkinIndex] = skin;
}

// Tendrils
// IRepairClient
simulated function bool canRepair(Rook r)
{
	// Only connect to living Characters
	if (Character(r) == None || !r.isAlive())
		return false;

	return true;
}

simulated function float getRepairRadius()
{
	return areaTriggerClass.default.CollisionRadius;
}

simulated function beginRepair(Rook r)
{
}

simulated function endRepair(Rook r)
{

}

simulated function Pawn getFXOriginActor()
{
	return self;
}

simulated function Vector getFXTendrilOrigin(Vector targetPos)
{
	return Location;
}

simulated function Vector getFXTendrilTarget(Actor target)
{
	local coords socketCoords;

	// Make sure this is a character
	if (socketTarget != '' && Character(target) != None)
	{
		socketCoords = target.getBoneCoords(socketTarget, true);

		if (socketCoords.Origin != Vect(0, 0, 0))
			return socketCoords.Origin;
	}

	// Otherwise just return location
	return target.unifiedGetPosition();
}

simulated function bool canStartFXTendril()
{
	return true;
}

simulated function onTendrilCreate(RepairTendril t)
{
	local Character c;
	local BeamEmitter beam;
	local Color col;

	c = Character(t.target);
	if (c != None)
	{
		if (c.team() != None)
		{
			col = c.team().territoryTendrilColor;

			beam = t.getBeamEmitter();
			if (beam != None)
			{
				beam.UseColorScale = true;
				beam.ColorScale.Length = 2;
				beam.ColorScale[0].RelativeTime = 0;
				beam.ColorScale[0].Color = col;
				beam.ColorScale[1].RelativeTime = 1;
				beam.ColorScale[1].Color = col;
			}
		}
	}
}

// End IRepairClient

defaultproperties
{
	DrawType				= DT_StaticMesh
	StaticMesh				= StaticMesh'Editor_res.TexPropCube'
	bCollideActors			= true
	bCollideWorld			= true
//	bBlockActors			= true
	bMovable				= false
	NetUpdateFrequency		= 2
	bNetNotify				= true
	bAlwaysRelevant			= true

	CollisionRadius			= 200
	CollisionHeight			= 200

	teamConquerScore		= 1
	conquerTime				= 10
	conquerInterval			= 1
	individualConquerBonusScale = 1
	minimumConquerers		= 1
	bReconquerable			= false
	bReconquerNeedsPlayers	= false
	bConquerOnce			= false
	TerritoryMessageClass	= class'MPTerritoryMessages'

	conqueringEffectEvent			= Conquering
	startedConqueringEffectEvent	= StartedConquering
	contestingEffectEvent			= Contesting
	startedContestingEffectEvent	= StartedContesting
	idleEffectEvent					= Idle
	conqueredEffectEvent			= Conquered
	idleAnim				= Idle

	contestedSkin			= Material'BaseObjects.CS_ContestedShader'
	conqueringSkin			= Material'BaseObjects.CS_CapturedShader'
	idleSkin				= Material'BaseObjects.CS_Dormant'
	titleSkinIndex			= 1
	socketTarget			= "capture"
}