class Pack extends Equipment implements IEffectObserver;

var float progressedRechargingTime;
var (Pack) float rechargeTimeSeconds					"The number of seconds it takes for this pack to recharge after it has been activated";

var float progressedActivatingTime;
var (Pack) float rampUpTimeSeconds						"The number of seconds it takes for this pack's active effect to kick in";

var float progressedActiveTime;
var (Pack) float durationSeconds						"The duration of this pack's active effect";

var float alpha;

var (Pack) StaticMesh thirdPersonMesh;

var Character heldBy;
var Character localHeldBy;

var (EffectEvents) name activatingEffectName			"The name of an effect event that loops on the pack when activating";
var (EffectEvents) name activeEffectName				"The name of an effect event that loops on the pack while active";
var (EffectEvents) name chargedEffectName				"The name of an effect event that loops on the pack when activating";
var (EffectEvents) name deactivatingEffectName			"The name of an effect event that plays once on the pack when deactivated";
var (EffectEvents) name activeEffectStartedName			"The name of an effect event that plays once on the pack when active";
var (EffectEvents) name activatingEffectStartedName		"The name of an effect event that plays once on the pack when activation has started";
var (EffectEvents) name passiveEffectName				"The name of an effect event that loops on the pack while its worn";

var (Pack) float deactivatingDuration					"The number of seconds it takes for this pack to deactivate";
var float deactivatingProgressedTime;
var bool deactivating;

var bool packActivatedTrigger;
var bool localPackActivatedTrigger;

var bool packSetChargedTrigger;
var bool localPackSetChargedTrigger;

var bool bLocalActive;

var (Pack) bool cannnotBeUsedWhileTouchingInventoryStation;

var float rechargingAlpha;

replication
{
	reliable if (Role == ROLE_Authority)
		heldBy, packActivatedTrigger, packSetChargedTrigger, bLocalActive;
}

function pickup(Character newOwner)
{
	SetTimer(0.0, false);
	setMovementReplication(false);
	newOwner.addPack(self);
	equipmentGone();
}

protected function requestEquipmentDrop()
{
	if (isInNoDropRangeOfInventoryStation())
		return;

	if (Character(Owner) != None)
		Character(Owner).pack = None;

	playEffect('CharacterRemovePack');
	
	Super.requestEquipmentDrop();
}

function bool canPickup(Character potentialOwner)
{
	return potentialOwner.pack.class != class && potentialOwner.armorClass.static.isPackAllowed(class);
}

function bool needPrompt(Character potentialOwner)
{
	return potentialOwner.pack != None;
}

function doSwitch(Character newOwner)
{
	if (newOwner.pack != None)
		newOwner.pack.drop();

	Super.doSwitch(newOwner);
}

function TravelPreAccept()
{
	Character(Owner).addPack(self);
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	// check if held state has changed
	if (localHeldBy != heldBy)
	{
		if (localHeldBy != None)
		{
			removePassiveEffect(localHeldBy);
		}

		localHeldBy = heldBy;

		if (localHeldBy != None)
		{
			applyPassiveEffect(localHeldBy);
		}
	}

	// check for activation
	if (localPackActivatedTrigger != packActivatedTrigger)
	{
		// server side pack is activated so despite the fact we may not be charged force activation
		GotoState('Activating');
		localPackActivatedTrigger = packActivatedTrigger;
	}

	// check for forced charging
	if (localPackSetChargedTrigger != packSetChargedTrigger)
	{
		GotoState('Charged');
		localPackSetChargedTrigger = packSetChargedTrigger;
	}
}

function startHeldByCharacter(Character holder)
{
	heldBy = holder;

	playEffect(passiveEffectName);
	applyPassiveEffect(holder);

	holder.createThirdPersonMesh(class);

	bHeld = true;
	bDropped = false;

	SetPhysics(PHYS_None);
	SetDrawType(DT_None);
	bCollideWorld = false;
	SetCollision(false, false, false);
}

function endHeldByCharacter(Character holder)
{
	holder.destroyThirdPersonMesh();

	finishActiveEffect();
	removePassiveEffect(holder);

	heldBy = None;

	SetDrawType(DT_StaticMesh);
}

function setCharged()
{
	if (IsInState('Charged'))
		return;

	GotoState('Charged');

	// inform clients
	if (Level.NetMode != NM_Client)
		packSetChargedTrigger = !packSetChargedTrigger;	
}

simulated function applyPassiveEffect(Character characterOwner);

simulated function removePassiveEffect(Character characterOwner);

simulated function startActiveEffect(Character characterOwner);

simulated function finishActiveEffect();

// Occurs at start of Activating state.
simulated function startApplyPartialActiveEffect();

// Occurs during Activating state. Alpha is guaranteed to start at 0 and end at 1.
simulated function applyPartialActiveEffect(float alpha, Character characterOwner);

simulated function activate();

simulated function tick(float deltaSeconds)
{
	Super.tick(deltaSeconds);

	// stop deactivating visual effect if necesssary
	if (deactivating)
	{
		deactivatingProgressedTime += deltaSeconds;
		if (deactivatingProgressedTime >= deactivatingDuration)
		{
			stopEffect(deactivatingEffectName);
			deactivating = false;
		}
	}

	// move pack to location of character to ensure relevancy
	if (heldBy != None)
	{
		Move(heldBy.Location - Location);
	}

	if (Level.NetMode == NM_Client)
	{
		if (bLocalActive)
			GotoState('Active');
	}
}

simulated function playEffect(Name effectEvent)
{
	if (heldBy != None)
	{
		heldBy.TriggerEffectEvent(Name(Class.Name$effectEvent));
		if (heldBy.leftPack != None)
		{
			heldBy.leftPack.TriggerEffectEvent(effectEvent,,,,,,,self,'Pack');
			heldBy.leftPack.TriggerEffectEvent(name(string(effectEvent)$"left"),,,,,,,self,'Pack');
		}

		if (heldBy.rightPack != None)
		{
			heldBy.rightPack.TriggerEffectEvent(effectEvent,,,,,,,self,'Pack');
			heldBy.rightPack.TriggerEffectEvent(name(string(effectEvent)$"right"),,,,,,,self,'Pack');
		}

		effectTriggered(effectEvent);
	}
}

simulated function OnEffectStarted(Actor inStartedEffect)
{
}

simulated function OnEffectStopped(Actor e, bool b)
{
}

simulated function OnEffectInitialized(Actor inInitializedEffect)
{
}

simulated function stopEffect(Name effectEvent)
{
	if (heldBy != None)
	{
		heldBy.UnTriggerEffectEvent(Name(Class.Name$effectEvent));
		if (heldBy.leftPack != None)
			heldBy.leftPack.UnTriggerEffectEvent(effectEvent);

		if (heldBy.rightPack != None)
			heldBy.rightPack.UnTriggerEffectEvent(effectEvent);

		effectUntriggered(effectEvent);
	}
}

function effectTriggered(Name effectEvent)
{
	if (heldBy != None)
	{
		if (effectEvent == activatingEffectName)
			heldBy.bActivatingEffect = !heldBy.bActivatingEffect;

		else if (effectEvent == activeEffectName)
			heldBy.bActiveEffect = !heldBy.bActiveEffect;

		else if (effectEvent == deactivatingEffectName)
			heldBy.bDeactivatingEffect = !heldBy.bDeactivatingEffect;

		else if (effectEvent == activatingEffectStartedName)
			heldBy.bActivatingEffectStarted = !heldBy.bActivatingEffectStarted;

		else if (effectEvent == activeEffectStartedName)
			heldBy.bActiveEffectStarted = !heldBy.bActiveEffectStarted;
	}
}

function effectUntriggered(Name effectEvent)
{
	if (heldBy != None)
	{
		if (effectEvent == activatingEffectName)
			heldBy.bUnactivatingEffect = !heldBy.bUnactivatingEffect;

		else if (effectEvent == activeEffectName)
			heldBy.bUnactiveEffect = !heldBy.bUnactiveEffect;

		else if (effectEvent == deactivatingEffectName)
			heldBy.bUndeactivatingEffect = !heldBy.bUndeactivatingEffect;

		else if (effectEvent == activatingEffectStartedName)
			heldBy.bUnactivatingEffectStarted = !heldBy.bUnactivatingEffectStarted;

		else if (effectEvent == activeEffectStartedName)
			heldBy.bUnactiveEffectStarted = !heldBy.bUnactiveEffectStarted;
	}
}

// this function can be used to overlay a material onto the owning character
simulated event Material GetOverlayMaterialForOwner(int Index)
{
	return None;
}

// called when a pack is taken from an equipment spawn point
function onTakenFromSpawnPoint()
{
	Super.onTakenFromSpawnPoint();
	setCharged();
}

// The pack is regenerating its charge. Indicated through animation and sound.
simulated state Recharging
{
	simulated function beginState()
	{
		progressedRechargingTime = 0;
	}

	simulated function tick(float deltaSeconds)
	{
		Global.Tick(deltaSeconds);

		progressedRechargingTime += deltaSeconds;

		rechargingAlpha = progressedRechargingTime / rechargeTimeSeconds;

		if (progressedRechargingTime >= rechargeTimeSeconds)
		{
			rechargingAlpha = 1.0;
			GotoState('Charged');
		}
	}

Begin:

}

function bool isInRangeOfInventoryStation()
{
	local UseableObject testObject;
	local Character characterOwner;

	characterOwner = Character(Owner);

	if (characterOwner == None)
		return false;

	foreach characterOwner.touchingActors(class'UseableObject', testObject)
	{
		if (testObject == None)
			continue;
		if (testObject.getCorrespondingInventoryStation() != None)
			return true;
	}

	return false;
}

// The pack is fully charged and ready to be activated.
simulated state Charged
{
	simulated function BeginState()
	{
		if (heldBy != None && heldBy.Controller == Level.GetLocalPlayerController())
		{
			heldBy.TriggerEffectEvent(Name(Class.Name$chargedEffectName));
		}

		rechargingAlpha = 1.0;
	}

	simulated function activate()
	{
		// if we have no controller, we're probably driving or manning a turret and shouldn't be allowed to use our pack.
		if (Character(Owner) == None || Character(Owner).Controller == None)
			return;

		// some packs cannot be used while touching an inventory station - handle that here
		if (Level.NetMode != NM_Client && cannnotBeUsedWhileTouchingInventoryStation && isInRangeOfInventoryStation())
			return;

		GotoState('Activating');

		// inform clients
		if (Level.NetMode != NM_Client && !IsInState('Active'))
			packActivatedTrigger = !packActivatedTrigger;
	}


Begin:

}

// The pack is active and using up its charge. Indicated through animation and sound.
simulated state Activating
{
	simulated function beginState()
	{
		rechargingAlpha = 0;

		progressedActivatingTime = 0;

		startApplyPartialActiveEffect();

		playEffect(activatingEffectStartedName);
		playEffect(activatingEffectName);
	}

	simulated function tick(float deltaSeconds)
	{
		Global.Tick(deltaSeconds);

		// calculate alpha
		alpha = progressedActivatingTime / rampUpTimeSeconds;
		alpha = fclamp(alpha, 0, 1);

		applyPartialActiveEffect(alpha, heldBy);

		progressedActivatingTime += deltaSeconds;
		if (progressedActivatingTime >= rampUpTimeSeconds)
			GotoState('Active');
	}

	simulated function endState()
	{
		stopEffect(activatingEffectName);
	}

Begin:

}

// The pack is active and using up its charge. Indicated through animation and sound.
simulated state Active
{
	simulated function beginState()
	{
		progressedActiveTime = 0;

		startActiveEffect(character(owner));

		playEffect(activeEffectStartedName);
		playEffect(activeEffectName);

		if (Level.NetMode != NM_Client)
			bLocalActive = true;
	}

	simulated function tick(float deltaSeconds)
	{
		Global.Tick(deltaSeconds);

		progressedActiveTime += deltaSeconds;

		// if we have no controller, we're probably driving or manning a turret and shouldn't be allowed to use our pack.
		if (Level.NetMode != NM_Client)
		{
			if (Character(Owner) == None || Character(Owner).Controller == None)
			{
				GotoState('Recharging');
				return;
			}

			if (progressedActiveTime >= durationSeconds)
				GotoState('Recharging');
		}
		else
		{
			if (!bLocalActive)
			{
				GotoState('Recharging');
				return;
			}
		}
	}

	simulated function endState()
	{
		finishActiveEffect();

		stopEffect(activeEffectName);

		// ... deactivation
		deactivating = true;
		deactivatingProgressedTime = 0;

		playEffect(deactivatingEffectName);

		if (Level.NetMode != NM_Client)
			bLocalActive = false;
	}

Begin:

}

defaultproperties
{
     rechargeTimeSeconds=2.000000
     rampUpTimeSeconds=2.000000
     durationSeconds=2.000000
     activatingEffectName="Activating"
     activeEffectName="Active"
     chargedEffectName="Charged"
     deactivatingEffectName="deactivating"
     activeEffectStartedName="ActiveStarted"
     activatingEffectStartedName="ActivatingStarted"
     passiveEffectName="Passive"
     deactivatingDuration=1.000000
     bCanDrop=True
     Prompt="Press '%1' to swap your '%4' for a '%3'"
     heldStartState="Recharging"
     DrawType=DT_StaticMesh
}
