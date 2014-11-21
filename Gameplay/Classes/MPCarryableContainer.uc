class MPCarryableContainer extends MPArea;

enum EContainerObjectiveState
{
	COS_Empty,
	COS_HalfFull,	// I'm an optimist
	COS_Full
};

var() int numCarryables					"The number of carryables this container starts with";
var() int maxCarryables					"The maximum number of carryables this container can hold before becoming full";
var() int carryablesPerTeamPoint		"The number of carryables needed to score a team point";
var() class<MPCarryable> carryableClass	"The class which is stored in this container";
var() bool bAcceptThrownCarryables		"Does this container allow carryables to be thrown into it?";
var() float timeBetweenWithdrawals		"The number of seconds you must wait in between each carryable withdrawal";
var(LocalMessage) class<Engine.Localmessage> ContainerMessageClass "The class used for playing effects and displaying messages";

var() Name deactivatedAnimation			"The animation to play when the container becomes inactive";
var() Name activatedAnimation			"The looping animation to play while the container is active";
var() Name fullAnimation				"The animation to play when the container becomes full";
var() Name depositedAnimation			"The animation to play when the container accepts a deposit";
var() Name withdrawnAnimation			"The animation to play when the container accepts a withdrawal";
var() int fuelMaterialIndex				"The index at which the fuel material resides";
var() int innerFuelMaterialIndex		"The index at which the inner fuel material resides";
var() int numWithdrawnPerSpawn			"The number of carryables to withdraw from the container and give to a player each time the player spawns.";
var() float	nearlyEmptyWithdrawScale	"When the container is less than 25% full, time between withdrawals will be scaled by this amount";
var() float	nearlyFullWithdrawScale		"When the container is more than 75% full, time between withdrawals will be scaled by this amount";
var() float	halfFullWithdrawScale		"When the container is between 25% and 75% full, time between withdrawals will be scaled by this amount";

var(EffectEvents) Name	deactivatedEffectEvent	"The name of an effect event that plays once when the container becomes inactive";
var(EffectEvents) Name	activatedEffectEvent	"The name of an effect event that plays once when the container becomes active";
var(EffectEvents) Name	fullEffectEvent			"The name of an effect event that plays once when the container becomes full";
var(EffectEvents) Name	depositedEffectEvent	"The name of an effect event that plays once when the container accepts a deposit";
var(EffectEvents) Name	withdrawnEffectEvent	"The name of an effect event that plays once when the container accepts a withdrawal";
var(EffectEvents) Name	activeEffectEvent		"The name of an effect event that loops while the container is active";

var(Stats) class<Stat>	depositStat					"The stat awarded for depositing each carryable in this container.";

var Shader fuelShader;
var ControllableTexturePanner fuelTexPanner;
var Shader innerFuelShader;
var ControllableTexturePanner innerFuelTexPanner;

var Array<MPCarryable> storedCarryables;

var bool bFull;
var float lastWithdrawAnnouncementTime;
var() int	timeBetweenWithdrawAnnouncements;

// Effect bools
var bool			bFullEffect;
var bool			bLocalFullEffect;
var bool			bDepositEffect;
var bool			bLocalDepositEffect;
var bool			bWithdrawEffect;
var bool			bLocalWithdrawEffect;
var bool			bInactiveEffect;
var bool			bLocalInactiveEffect;

replication
{
	reliable if (Role == ROLE_Authority)
		numCarryables, maxCarryables, bFullEffect, bDepositEffect, bWithdrawEffect, bInactiveEffect;
}

// PostBeginPlay
simulated function PostBeginPlay()
{
	local int numStart;

	Super.PostBeginPlay();

	if (Level.NetMode != NM_Client)
	{
		// Handle the case where carryables were added in the editor.  AddNewCarryables() increases
		// the value of numCarryables, so set it properly afterward
		numStart = numCarryables;
		numCarryables = 0;
		addNewCarryables(numStart);
		numCarryables = numStart;
	
		areaTrigger.setTriggerFrequency(0.2);
	}

	buildControllableSkin();
	evaluatePercentageContents(0);
}

function addNewCarryables(int numToAdd)
{
	local int i;
	local MPCarryable c;

	for (i=0; i<numToAdd; i++)
	{
		//Log("POST adding, i="$i$", numToAdd="$numToAdd);
		c = spawn(carryableClass,,,Location);
		if (c == None)
		{
			Log("Container error:  could not spawn carryable of class "$carryableClass);
			continue;
		}
		c.GotoState('Locked');
		c.homeLocation = Location;
		addCarryable(c);
	}
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	// Update panner whenever the territory comes into relevancy
	calcFuelPannerScale();
}

simulated function buildControllableSkin()
{
	// Build a controllable texture panner for the fuel shader
	fuelShader = Shader(ShallowCopyMaterial(GetMaterial(fuelMaterialIndex), self));

	if (fuelShader != None)
	{
		fuelTexPanner = new class'ControllableTexturePanner';
		fuelTexPanner.PanDirection = Vector(TexPanner(fuelShader.SelfIllumination).PanDirection);
		fuelTexPanner.Material = TexPanner(fuelShader.SelfIllumination).Material;

		fuelShader.Diffuse = fuelTexPanner;
		fuelShader.SelfIllumination = fuelTexPanner;
		fuelShader.SelfIlluminationMask = fuelTexPanner;
	}

	Skins[fuelMaterialIndex] = fuelShader;

	// Build a controllable texture panner for the inner fuel shader
	//innerFuelShader = Shader(ShallowCopyMaterial(GetMaterial(innerFuelMaterialIndex), self));

	if (innerFuelShader != None)
	{
		innerFuelTexPanner = new class'ControllableTexturePanner';
		innerFuelTexPanner.PanDirection = Vector(TexPanner(Combiner(innerFuelShader.SelfIllumination).Material2).PanDirection);
		innerFuelTexPanner.Material = TexPanner(Combiner(innerFuelShader.SelfIllumination).Material2).Material;

		innerFuelShader.Diffuse = innerFuelTexPanner;
		innerFuelShader.SelfIllumination = innerFuelTexPanner;
		innerFuelShader.SelfIlluminationMask = innerFuelTexPanner;
	}

	Skins[innerFuelMaterialIndex] = innerFuelShader;
	calcFuelPannerScale();
}

simulated function calcFuelPannerScale()
{
	fuelTexPanner.Scale = 0.5 + float(numCarryables) / float(maxCarryables) / 2.0;
	//innerFuelTexPanner.Scale = 0.5 + float(numCarryables) / float(maxCarryables) / 2.0;
	//Log(self$" set panner scale to "$fuelTexPanner.Scale);
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	updateContainerEffects();
}

simulated function updateContainerEffects()
{
	if (bFullEffect != bLocalFullEffect)
	{
		bLocalFullEffect = bFullEffect;
		if (bFullEffect)
		{
			TriggerEffectEvent(fullEffectEvent);
			//Log(self$" trying to play "$fullAnimation);
			if (hasAnim(fullAnimation))
			{
				// Disable bWorldGeometry so that effect attachments in the Full animation work properly
				if (bWorldGeometry)
					bWorldGeometry = false;
				PlayAnim(fullAnimation);
			}
		}
		else
		{
			UnTriggerEffectEvent(fullEffectEvent);
		}
	}

	if (bInactiveEffect != bLocalInactiveEffect)
	{
		bLocalInactiveEffect = bInactiveEffect;

		if (bInactiveEffect)
		{
			TriggerEffectEvent(deactivatedEffectEvent);
			Log(self$" playing "$deactivatedAnimation);
			if (hasAnim(deactivatedAnimation))
				PlayAnim(deactivatedAnimation);
		}
		else
		{
			if (hasAnim(activatedAnimation))
				PlayAnim(activatedAnimation);
		}
	}

	if (bWithdrawEffect != bLocalWithdrawEffect)
	{
		bLocalWithdrawEffect = bWithdrawEffect;
		TriggerEffectEvent(withdrawnEffectEvent);
		if (hasAnim(withdrawnAnimation))
			PlayAnim(withdrawnAnimation);

		// Update the panner
		calcFuelPannerScale();
	}

	if (bDepositEffect != bLocalDepositEffect)
	{
		bLocalDepositEffect = bDepositEffect;
		TriggerEffectEvent(depositedEffectEvent);
		if (hasAnim(depositedAnimation))
			PlayAnim(depositedAnimation);

		// Update the panner
		calcFuelPannerScale();
	}
}

function evaluatePercentageContents(int numAdded)
{
	local int numStartedWith;
	local float percentageStartedWith;
	local float percentageLeft;

	evaluateObjectiveState();

	if (ContainerMessageClass == None || numAdded == 0)
		return;

	numStartedWith = numCarryables - numAdded;
	percentageStartedWith = float(numStartedWith) / float(maxCarryables);
	percentageLeft = float(numCarryables) / float(maxCarryables);

	// Announce a change if the number of carryables passes the 25%, 50% or 75% mark

	// Decreases
	if (percentageLeft <= 0.25 && 0.25 < percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 3, team());
	else if (percentageLeft <= 0.5 && 0.5 < percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 2, team());
	else if (percentageLeft <= 0.75 && 0.75 < percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 1, team());

	// Increases
	else if (percentageLeft >= 0.75 && 0.75 > percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 1, team());
	else if (percentageLeft >= 0.5 && 0.5 > percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 2, team());
	else if (percentageLeft >= 0.25 && 0.25 > percentageStartedWith)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 3, team());

	// Empty
	else if (numCarryables == 0)
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 4, team());
}

function evaluateObjectiveState()
{
	local float percentageLeft;

	percentageLeft = float(numCarryables) / float(maxCarryables);

	setObjectiveTally(numCarryables, maxCarryables);

	// Set objective icon state
	if (percentageLeft <= 0.25)
	{
		setObjectiveState(0);
		timeBetweenWithdrawals = default.timeBetweenWithdrawals * nearlyEmptyWithdrawScale;
	}
	else if (percentageLeft <= 0.75)
	{
		setObjectiveState(1);
		timeBetweenWithdrawals = default.timeBetweenWithdrawals * halfFullWithdrawScale;
	}
	else
	{
		setObjectiveState(2);
		timeBetweenWithdrawals = default.timeBetweenWithdrawals * nearlyFullWithdrawScale;
	}
}

function cleanup()
{
	local int i, numToRemove;
	local MPCarryable c;

	// Store in NumToRemove since numCarryables gets altered by removeCarryable()
	numToRemove = storedCarryables.Length;
	for (i=0; i<numToRemove; i++)
	{
		c = removeCarryable();
		c.destroy();
	}

	super.cleanup();
}

function registerStats(StatTracker tracker)
{
	Super.registerStats(tracker);

	tracker.registerStat(depositStat);
}


function addCarryable(MPCarryable c)
{
	storedCarryables.Length = storedCarryables.Length + 1;
	storedCarryables[storedCarryables.Length-1] = c;
	numCarryables++;
	//Log("Carryable stored "$c$", "$storedCarryables[numCarryables-1]$", len = "$storedCarryables.Length$", numCarryables = "$numCarryables);

	// If adding a carryable caused the number of carriers to increase beyond a scoring
	// threshold, increase the number of team points
	if(numCarryables % carryablesPerTeamPoint == 0 && team() != None)
		scoreTeam(1);

	//dispatchMessage(new class'MessageContainerDeposit'(label, c.lastCarrier.label, c.lastCarrier.getTeamLabel(), 1));
	//c.clearCarrier();
	c.homeContainer = self;
	c.SetCollision(false);
	c.bHidden = true;
	c.GotoState('Locked');
	//if (c.lastCarrier != None && c.lastCarrier.team() == team())
	//{	
	//	c.lastCarrier.ClientMessage("You threw a carryable into the container!");
	//	scoreIndividual(c.lastCarrier, 1);
	//}

	if (team() != None)
		team().bNoMoreCarryables = !allowSpawn();
}

function addMetaCarryable(MPMetaCarryable meta)
{
	local int i;

	// Just empty the metacarryable and put all contents into the container, even if this causes
	// the container to overflow (ideally the overflow would break into denominations)
	for (i=0; i<meta.carryables.Length; i++)
	{
		addCarryable(meta.carryables[i]);

		if (meta.carryables[i].lastCarrier != None && meta.carryables[i].lastCarrier.team() == team())
			awardStat(depositStat, meta.carryables[i].lastCarrier);
	}
	meta.destroy();
}

function MPCarryable removeCarryable()
{
	local MPCarryable removedCarryable;

	// Just remove the last coin
	removedCarryable = storedCarryables[storedCarryables.Length-1];
	storedCarryables.Length = storedCarryables.Length - 1;
	numCarryables--;

	// If removing a carryable caused the number of carriers to decrease beyond a scoring
	// threshold, decrease the number of team points
	if((numCarryables + 1) % carryablesPerTeamPoint == 0 && team() != None && team().score > 0)
		scoreTeam(-1);

	removedCarryable.SetCollision(true);

	//Log("Container removing "$removedCarryable);
	return removedCarryable;
}

function int deposit(Character c)
{
	local int i, numAdded;

	// Friendly touch:  deposit coins

	// Don't deposit the player's permanent carryables and don't deposit beyond this container's maximum
	for (i=c.numPermanentCarryables; i<c.carryables.Length && numCarryables < maxCarryables; i++)
	{
		addCarryable(c.carryables[i]);
		//Log("Deposited "$c.carryables[i]);
		numAdded++;
	}

	awardStat(depositStat, c, None, numAdded);
	//c.ClientMessage("You deposited "$numAdded$" carryables!");
	dispatchMessage(new class'MessageContainerDeposit'(label, c.label, getTeamLabel(), numAdded));

	// If all carryables were deposited by the character, cleanup the character completely
	if (c.numPermanentCarryables == 0 && numAdded == c.numCarryables)
	{
		//Log(c$" deposited ALL carryables = "$numAdded);
		c.clearCarryables();
	}
	// Otherwise, only remove the carryables that were deposited
	else
	{
		c.carryables.Length = c.carryables.Length - numAdded;
		c.numCarryables = c.carryables.Length;

		// Reset denomination attachment
		c.carryableReference.attachDenomination();
		//Log(c$" deposited SOME carryables = "$numAdded$", c.numCarryables = "$c.numCarryables$", len = "$c.carryables.Length$", ref = "$c.carryableReference);
	}

	bDepositEffect = !bDepositEffect;
	updateContainerEffects();
	evaluateContents();

	//Log(self$" successfully deposited "$numAdded);
	return numAdded;
}

function withdraw(Character c)
{
	local MPCarryable removedCarryable;

	// Enemy touch:  steal coins
	if (storedCarryables.Length <= 0)
	{
		//Log("Can't withdraw due to lack of carryables");
		return;
	}

	if (c.carryableReference != None && !c.carryableReference.canCombineWith(carryableClass))
	{
		//Log("Can't withdraw due to existing carryableReference = "$c.carryableReference$" and class "$carryableClass);
		return;
	}

	removedCarryable = removeCarryable();
	//Log(self$" attempting withdrawal of "$removedCarryable);

	removedCarryable.attemptPickup(c);

	bWithdrawEffect = !bWithdrawEffect;
	updateContainerEffects();

	// Neutral containers become inactive when empty
	if (team() == None && storedCarryables.Length == 0)
		GotoState('Inactive');
	else
	{
		evaluatePercentageContents(-1);
	}

	if (team() != None)
		team().bNoMoreCarryables = !allowSpawn();
}

function bool allowSpawn()
{
	if (numWithdrawnPerSpawn > 0)
		return numCarryables >= numWithdrawnPerSpawn;

	return true;
}

function evaluateContents()
{
	if (storedCarryables.Length >= maxCarryables && team() != None)
	{
		GotoState('Full');
	}
	else
	{
		evaluatePercentageContents(1);
	}
}

function onAreaEntered(Character c)
{
	// Do nothing by default
}

function onAreaExited(Character c)
{
	// Do nothing by default
}

function onAreaTick()
{
}

function reset()
{
	local int i;

	// Used in single player to reset the container
	for(i=0; i<storedCarryables.Length; i++)
	{
		if (storedCarryables[i] != None)
			storedCarryables[i].destroy();
	}
	storedCarryables.Length = 0;
	numCarryables = 0;
	GotoState('Active');
}

function onPlayerSpawned(Character c)
{
	local int i;

	//Log("Withdrawing permanent carryables:  "$c.numPermanentCarryables);
	if (storedCarryables.Length < c.numPermanentCarryables)
	{
		Log("Not enough carryables left for spawn withdrawal.");
		return;
	}

	for (i=0; i<c.numPermanentCarryables; i++)
	{
		//Log(self$" automatically withdrawing for spawn");
		withdraw(c);
	}
}

// The container accepts deposits and withdrawals
 auto simulated state Active
{
	simulated function BeginState()
	{
		TriggerEffectEvent(activatedEffectEvent);
		if (hasAnim(activatedAnimation))
			LoopAnim(activatedAnimation);
	}

	function onAreaEntered(Character c)
	{
		if (c.team() == team())
		{
			if (c.carryableReference != None && c.numCarryables > c.numPermanentCarryables && c.carryableReference.canCombineWith(carryableClass))
			{
				// Deposit all the character's carryables
				if (SecondaryMessageClass != None)
				{
					Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 1, c.tribesReplicationInfo,,,string(c.numDroppableCarryables()));
				}

				deposit(c);
			}
		}
		else if (numCarryables > 0 && !c.bDontAllowCarryablePickups && Vehicle(c.getMount()) == None && (c.carryableReference == None || c.numCarryables < c.carryableReference.maxCarried))
		{
			// Announce withdrawal as soon as the player enters
			if (Level.TimeSeconds - lastWithdrawAnnouncementTime > timeBetweenWithdrawAnnouncements)
			{
				lastWithdrawAnnouncementTime = Level.TimeSeconds;
				if (team() == None)
					Level.Game.BroadcastLocalized(self, ContainerMessageClass, 5, c.team());
				else
					Level.Game.BroadcastLocalized(self, ContainerMessageClass, 6, c.team());
			}
		}
	}

	function onAreaExited(Character c)
	{
		local int carryableCount;

		carryableCount = c.numDroppableCarryables();
		if (c.team() != team() && carryableCount > 1 && SecondaryMessageClass != None && carryableCount != c.lastCarryableNumber)
		{
			c.lastCarryableNumber = carryableCount;
			Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 0, c.tribesReplicationInfo,,,string(carryableCount));
		}
	}

	function onAreaTick()
	{
		local Character c;
		//local MPCarryable carryable;
		//local MPMetaCarryable meta;
		//local bool bAdded;

		// See if there are any characters withdrawing, or friendly players carrying fuel
		ForEach areaTrigger.TouchingActors(class'Character', c)
		{
			if (c.team() != team() && storedCarryables.Length > 0 && !c.bDontAllowCarryablePickups && Vehicle(c.getMount()) == None)
			{
				// Give all players who have been in here long enough a carryable
				if (areaTrigger.enoughTimeElapsedSinceMarkerTime(c, timeBetweenWithdrawals, true) && c.numDroppableCarryables() < carryableClass.default.maxCarried)
				{
					// Withdraw a carryable
					//Log(self $" allowed carryable withdrawal");
					withdraw(c);

					if (Level.TimeSeconds - lastWithdrawAnnouncementTime > timeBetweenWithdrawAnnouncements)
					{
						lastWithdrawAnnouncementTime = Level.TimeSeconds;
						if (team() == None)
							Level.Game.BroadcastLocalized(self, ContainerMessageClass, 5, c.team());
						else
							Level.Game.BroadcastLocalized(self, ContainerMessageClass, 6, c.team());
					}
				}
			}

			// Automatically deposit if friendly
			if (c.team() == team() && c.carryableReference != None && c.numCarryables > c.numPermanentCarryables && c.carryableReference.canCombineWith(carryableClass))
			{
				if (SecondaryMessageClass != None)
				{
					Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 1, c.tribesReplicationInfo,,,string(c.numDroppableCarryables()));
				}

				deposit(c);
			}
		}

		// Eat any carryables inside the area
		//ForEach areaTrigger.TouchingActors(class'MPCarryable', carryable)
		//{
		//	meta = MPMetaCarryable(carryable);
		//	if (!carryable.bHidden && meta == None && carryable.canCombineWith(carryableClass) )
		//	{
		//		Log(self$" eating "$carryable);
		//		addCarryable(carryable);
		//		bAdded = true;
		//	}
		//	else if (meta != None && carryable.canCombineWith(carryableClass))
		//	{
		//		Log(self$" eating meta "$meta);
		//		addMetaCarryable(meta);
		//		bAdded = true;
		//	}

		//	if (bAdded)
		//		evaluateContents();
		//}		
	}

	simulated function Tick(float Delta)
	{
		super.Tick(Delta);

		// Occasionally update the panner
		calcFuelPannerScale();
	}

	//function OnAreaEnteredByActor(Actor a)
	//{
	//	local MPCarryable thrownCarryable;
	//	local MPMetaCarryable meta;

	//	// Allow carryables to be thrown into the container, if applicable
	//	thrownCarryable = MPCarryable(a);

	//	if (thrownCarryable != None && !thrownCarryable.bHidden && thrownCarryable.canCombineWith(carryableClass) && bAcceptThrownCarryables)
	//	{
	//		// If it's a metacarryable, empty it
	//		// Assume it was THROWN since characters can't actually deposit metacarryables directly
	//		meta = MPMetaCarryable(thrownCarryable);
	//		if (meta != None)
	//		{
	//			addMetaCarryable(meta);
	//		}
	//		else
	//		{
	//			// It's not a metacarryable; just add it
	//			addCarryable(thrownCarryable);
	//			if (thrownCarryable.lastCarrier != None && thrownCarryable.lastCarrier.team() == team())
	//				awardStat(depositStat, thrownCarryable.lastCarrier);
	//		}
	//		evaluateContents();
	//	}
	//}
}

// The container, for whatever reason, doesn't accept deposits or withdrawals
state Inactive
{
	// Handle cases where a sytem adds a carryable back in (for example when a dropped
	// carryable returns here after the depot has become inactive)
	function addCarryable(MPCarryable c)
	{
		GotoState('Active');

		Global.addCarryable(c);
	}

	function BeginState()
	{
		bInactiveEffect = true;
		updateContainerEffects();
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 7, team());
		dispatchMessage(new class'MessageContainerEmpty'(label, getTeamLabel()));
	}

	function EndState()
	{
		bInactiveEffect = false;
		updateContainerEffects();
	}
}

// The container is full and will no longer accept deposits or withdrawals
state Full extends Inactive
{
	function BeginState()
	{
		local int i;

		bFullEffect = true;
		bFull = true;
		updateContainerEffects();
		Level.Game.BroadcastLocalized(self, ContainerMessageClass, 0, team());
		dispatchMessage(new class'MessageContainerFull'(label, getTeamLabel()));

		// Destroy all the fuel that was in it
		for (i=0; i<storedCarryables.Length; i++)
		{
			if (storedCarryables[i] != None)
				storedCarryables[i].destroy();
		}
		storedCarryables.Length = 0;
	}

	function EndState()
	{
		bWorldGeometry = default.bWorldGeometry;
		bFullEffect = false;
		bFull = false;
		updateContainerEffects();

		Super.EndState();
	}

	// Don't allow deposits or withdrawals in this state
	function int deposit(Character c)
	{
		return 0;
	}

	function withdraw(Character c)
	{
	}
}

// Don't allow deposits or withdrawals
state Paused
{
}

defaultproperties
{
     maxCarryables=10
     carryablesPerTeamPoint=10
     carryableClass=Class'MPCarryable'
     bAcceptThrownCarryables=True
     timeBetweenWithdrawals=2.000000
     ContainerMessageClass=Class'MPContainerMessages'
     fuelMaterialIndex=2
     nearlyEmptyWithdrawScale=1.500000
     nearlyFullWithdrawScale=0.500000
     halfFullWithdrawScale=1.000000
     deactivatedEffectEvent="Deactivated"
     activatedEffectEvent="Activated"
     fullEffectEvent="full"
     depositedEffectEvent="Deposited"
     withdrawnEffectEvent="Withdrawn"
     activeEffectEvent="Active"
     timeBetweenWithdrawAnnouncements=10
     bAlwaysRelevant=True
     NetUpdateFrequency=4.000000
     bBlockPlayers=False
     bNetNotify=True
}
