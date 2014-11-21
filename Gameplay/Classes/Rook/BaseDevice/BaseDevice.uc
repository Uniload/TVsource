class BaseDevice extends Rook
	native;

var()	editdisplay(displayActorLabel)
		editcombotype(enumBaseInfo)
		BaseInfo			ownerBase					"The BaseInfo that the device belongs to (mandatory). Used to power the device and define team ownership (the 'team' variable is ignored)";
var()	Material			DestroyedDiffuse			"Diffuse material that gets swapped in when object is destroyed";	
var()	float				functionalHealthThreshold	"Percentage of health when the device ceases to function";
var()	float				damagedHealthThreshold		"Percentage of health when the device plays 'damaged' effects";
var()	class<Explosion>	destroyedExplosionClass		"Explosion to trigger when the device is destroyed";
var()	class<MPBaseDeviceMessages>	baseDeviceMessageClass				"Messages used in multiplayer to communicate the state of base devices.  Leave this blank if you don't want messages on this base device.";
var()	class<MPSecondaryMessage>	secondaryBaseDeviceMessageClass		"Secondary messages used in multiplayer to communicate the state of base devices.  Leave this blank if you don't want messages on this base device.";

var()	localized string	localizedName				"The name that will be displayed when viewing this device";

var bool				bInitialization;
var	protected bool		bPowered;				// indicates whether the device has a generator that is supplying power
var	protected bool		m_bSwitchedOn;			// if false, the base device will remain unpowered even if it has a generator
var bool				bWasDeployed;			// set by Deployable when it deploys this object
var bool				bCurrentlyDeploying;	// set while deployable is playing its starting fx, for clients
var bool				bHasOpenAnim;
var Character			deployer;				// who deployed us
var private int			m_ownershipMaterialIdx;	// the index of the material in the mesh that displays the ownership badge
var int					lastUnderAttackTime;	// the last time this base device took damage
var int					lastOfflineTime;		// the last time this base device was destroyed
var int					lastOnlineTime;			// the last time this base device came online as a result of repairs
var Pawn				lastAttacker;			// the last Pawn to damage this base device

var Name				savedAnim;
var bool				bLoopSavedAnim;

var const int OWNERSHIP_MATERIAL_UNDISCOVERED;
var const int OWNERSHIP_MATERIAL_NOT_FOUND;

replication
{
	reliable if (Role == ROLE_Authority)
		bPowered, bWasDeployed, bCurrentlyDeploying;
}

// for saving
simulated function PlayBDAnim( name Sequence )
{
	savedAnim = Sequence;
	bLoopSavedAnim = false;
	PlayAnim(Sequence);
}

simulated function LoopBDAnim( name Sequence )
{
	savedAnim = Sequence;
	bLoopSavedAnim = true;
	LoopAnim(Sequence);
}

function PostLoadGame()
{
	super.PostLoadGame();

	if (!bLoopSavedAnim)
		PlayAnim(savedAnim);
	else
		LoopAnim(savedAnim);
}

// construct
overloaded function construct(optional bool _bWasDeployed, optional Character _deployer, optional TeamInfo team, optional vector loc, optional Rotator rot)
{
	bWasDeployed = _bWasDeployed;
	deployer = _deployer;

	super.construct();

	SetLocation(loc);
	SetRotation(rot);

	if (team != None)
		setTeam(team);
}

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (ownerBase == None && !bWasDeployed)
		LOG("NOTE: BaseDevice "$name$" does not belong to a base");
}

simulated function float GetDamageComponentThresholdRange()
{
	// damage component break threshold based on functionalHealthThreshold
	return (1 - functionalHealthThreshold) * healthMaximum;
}

// classConstruct
function classConstruct()
{
	bGroundNavigationObstruction = true;
}

//
// Client CanBeUsedBy implementation. Checks for functionality of the device.
//
simulated function bool CanBeUsedBy(Character CharacterUser)
{
	return super.CanBeUsedBy(characterUser) && IsFunctional();
}

simulated function string GetHumanReadableName()
{
	local string value;

	value = localizedName;

	if(value == "")
		value = super.GetHumanReadableName();

	if(value == "")
		value = string(class.name);

	return value;
}

simulated event bool isAlive()
{
	return !bDeleteMe && (!bWasDeployed || Health > 0);
}

// isActive
simulated event bool isActive()
{
	return IsInState('Active');
}

// isDamagedAtThreshold
simulated event bool isDamagedAtThreshold()
{
	local float healthPercentage;

	healthPercentage = health / healthMaximum;
	return healthPercentage < damagedHealthThreshold;
}

// isDamaged
simulated event bool isDamaged()
{
	if(isFunctional())
	{
		return isDamagedAtThreshold();
	}
	else
		return false;
}

// isDisabled
//
// Returns true when the device health falls below 
// its functional threshold
simulated event bool isDisabled()
{
	local float healthPercentage;

	// check health
	healthPercentage = health / healthMaximum;
	if(healthPercentage < functionalHealthThreshold)
		return true;

	return false;
}

simulated function bool isFunctional()
{
	if(isDisabled())
		return false;

	// check power
	if(! isPowered())
		return false;

	return true;
}

// enumBaseInfo
function enumBaseInfo(Engine.LevelInfo l, Array<BaseInfo> a)
{
	local BaseInfo b;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		a[a.length] = b;
	}
}

function dispatchDeathMessage(Controller Killer)
{
	local Rook killerRook;

	if (Killer != None && Killer.Pawn != None)
	{
		killerRook = Rook(Killer.Pawn);
		if (killerRook != None)
			dispatchMessage(new class'MessageDeath'(killerRook.getKillerLabel(), label, Killer.Pawn.playerReplicationInfo, None));
		else
			dispatchMessage(new class'MessageDeath'(Killer.Pawn.label, label, Killer.Pawn.playerReplicationInfo, None));
	}
	else
		dispatchMessage(new class'MessageDeath'(self.label, label, None, None));

}

// Died
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    TriggerEffectEvent('Died');

	dispatchDeathMessage(Killer);

	squadCleanupOnDeath( Killer.Pawn, damageType, HitLocation );
}

function unifiedAddImpulseAtPosition(Vector impulse, Vector position)
{
	// base devices aren't knocked around
}

function float getTeamDamagePercentage()
{
	// Team damage on deployables can never be restricted (this would prevent people from correcting
	// mistakingly deployed deployables)
	if (bWasDeployed)
		return 0.0;

	// The BaseDevice's teamDamagePercentage setting overrides anything stored in the GameInfo if
	// it's anything other than -1%
	if (self.teamDamagePercentage != -1.0)
		return self.teamDamagePercentage;

	return GameInfo(Level.Game).baseDeviceTeamDamagePercentage;
}


function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	local bool bWasActive;
	local ModeInfo mode;
	local int positiveDamageAmount;

	if(! bCanBeDamaged)
		return;

	bWasActive = !isDisabled();

	if (Health > 0)
	{
		// clear momentum
		Momentum = Vect(0, 0, 0);

		if (baseDeviceMessageClass != None && Level.TimeSeconds - lastUnderAttackTime > baseDeviceMessageClass.default.timeBetweenUnderAttackMessages)
		{
			lastUnderAttackTime = Level.TimeSeconds;
			Level.Game.BroadcastLocalized(self, baseDeviceMessageClass, 0, team());
		}

		lastAttacker = EventInstigator;
		Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);

		// Only report damage that brought health to 0
		positiveDamageAmount = Damage;
		if (Health < 0)
			positiveDamageAmount += Health;

		mode = ModeInfo(Level.Game);
		if (mode != None && Rook(EventInstigator).team() != team())
		{
			mode.OnBaseDeviceDamage(EventInstigator, self, DamageType, positiveDamageAmount);
		}

		if (bWasActive && isDisabled())
		{
			dispatchDeathMessage(EventInstigator.Controller);
		}
	}

	if (Health < 0)
		Health = 0;
}

simulated function bool isOpenedAnimPlaying(Name animName)
{
	return animName == 'Open';
}

simulated latent function latentBeginActive()
{
	local name animName;
	local float animFrame;
	local float animAlpha;

	GetAnimParams(0, animName, animFrame, animAlpha);

	if (!bWasDeployed)
	{
		if (!bInitialization)
		{
			if (!isOpenedAnimPlaying(animName))
			{
				PlayBDAnim('Opening');
				FinishAnim();
			}
		}

		LoopBDAnim('Open');
	}
	else
	{
		if (Level.NetMode != NM_Client)
			bCurrentlyDeploying = true;

		if (bCurrentlyDeploying)
		{
    		TriggerEffectEvent('DeployStart');
    		TriggerEffectEvent('DeployLoop');

			PlayBDAnim('Deploy');
			FinishAnim();

    		UnTriggerEffectEvent('DeployLoop');
    		TriggerEffectEvent('DeployStop');
		}

		LoopBDAnim('Deployed');
		
		Sleep(0);
		
		bCurrentlyDeploying = false;
	}

	bInitialization = false;
}

simulated latent function latentExecuteActive()
{
}

simulated latent function latentExecuteInitialization()
{
	if(isDisabled())
	{
		GotoState('Destructed');
	}
	else if(!isPowered() && !bWasDeployed)
	{
		GotoState('UnPowered');
	}
	else if(isDamaged())
	{
		GotoState('Damaged');
	}
	else
	{
		GotoState('Active');
	}
}

// States
auto simulated state Initialization
{
	simulated function BeginState()
	{
		bInitialization = true;
	}

Begin:
	latentExecuteInitialization();
}

// State Active
simulated state Active
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		CheckChangeState();
	}

	simulated function CheckChangeState()
	{
		// check if we need to go to Destructed or unpowered states
		if(!isPowered() && !bWasDeployed)
			GotoState('UnPowered');
		else if(isDisabled())
			GotoState('Destructed', 'Degenerating');
		else if(isDamaged())
			GotoState('Damaged', 'Degenerating');
	}

	simulated function BeginState()
	{
		activatepersonalShield();

		if (!bInitialization)
    		TriggerEffectEvent('ActiveStart');

    	TriggerEffectEvent('ActiveLoop');
	}

	simulated function EndState()
	{
		UnTriggerEffectEvent('ActiveLoop');
		TriggerEffectEvent('ActiveStop');
	}	

Begin:
	latentBeginActive();
	Goto('ExecuteActive');

Regenerating:
	if (Level.NetMode != NM_Client)
	{
		if (baseDeviceMessageClass != None )
		{
			if (Level.TimeSeconds - lastOnlineTime > baseDeviceMessageClass.default.timeBetweenOnlineMessages)
			{
				lastOnlineTime = Level.TimeSeconds;
				Level.Game.BroadcastLocalized(self, baseDeviceMessageClass, 2, team());
			}
		}
	}

RegeneratingWithoutAnnouncement:
	if (Level.NetMode != NM_Client)
	{
		if (ModeInfo(Level.Game) != None)
		{
			if (repairers.Length > 0)
				ModeInfo(Level.Game).OnBaseDeviceOnline(self, repairers[0]);
			else
				ModeInfo(Level.Game).OnBaseDeviceOnline(self);
		}
	}

ExecuteActive:
	latentExecuteActive();
}

//
// Plays the effects for when the Device becomes damaged
//
simulated function PlayDamagedEnteredEffects()
{
	if (!bInitialization)
	    TriggerEffectEvent('DamagedStart');
	TriggerEffectEvent('DamagedLoop');
}

//
// Plays the effects for when the Device becomes undamaged (degenerating or not)
//
simulated function PlayDamagedExitedEffects()
{
	UnTriggerEffectEvent('DamagedLoop');
	TriggerEffectEvent('DamagedStop');
}

//
// Plays the effects for when the Device becomes damaged when degenerating
//
simulated function PlayDamagedDegeneratingEffects()
{
	TriggerEffectEvent('Damaged');
}

// State Damaged, just like active, except an effect plays
simulated state Damaged extends Active
{
	simulated function CheckChangeState()
	{
		// check if we need to go to Destructed or unpowered states
		if(!isDamagedAtThreshold())
			GotoState('Active', 'RegeneratingWithoutAnnouncement');
		else if(!isPowered() && !bWasDeployed)
			GotoState('UnPowered');
		else if(isDisabled())
		{
			GotoState('Destructed', 'Degenerating');
		}
	}

	simulated function BeginState()
	{
		PlayDamagedEnteredEffects();
	}

	simulated function EndState()
	{
		PlayDamagedExitedEffects();
	}	

Begin:
	latentBeginActive();
	Goto('ExecuteActive');

Degenerating:
	PlayDamagedDegeneratingEffects();

ExecuteActive:
	latentExecuteActive();
}

// State Unpowered
simulated state Unpowered
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if(Health <= 0)
		{
			GotoState('Destructed');
			return;
		}

		if(isDisabled())
			GotoState('Destructed');

		if (isPowered())
		{
			if(isDamaged())
				GotoState('Damaged');
			else if(Health >= healthMaximum)
				GotoState('Active');
		}
	}

	simulated function BeginState()
	{
		if (!bInitialization)
		    TriggerEffectEvent('UnpoweredStart');
	    TriggerEffectEvent('UnpoweredLoop');

		if(Mesh != None)
		{
			if (!bInitialization)
			{
				if(HasAnim('PowerLost'))
					PlayBDAnim('PowerLost');
				else
					StopAnimating();
			}
			else
			{
				PlayBDAnim('PowerLost');
				SetAnimFrame(1000.0);
			}
		}
		
		deactivatepersonalShield();

		dispatchMessage(new class'MessageBaseDevicePowerOff'(Label));

		bInitialization = false;
	}
	
	simulated function EndState()
	{
	    UnTriggerEffectEvent('UnpoweredLoop');
	    TriggerEffectEvent('UnpoweredStop');

		dispatchMessage(new class'MessageBaseDevicePowerOn'(Label));
	}
}

//
// State Disabled
// Currently not used
//
simulated state Disabled
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		// return to active state if we are now functional
		// or unpowered if we are no longer disabled, but still unpowered
		if(isFunctional())
			GotoState('Active', 'Regenerating');
		else if(! isDisabled() && ! isPowered())
			GotoState('Unpowered');
	}

	simulated function BeginState()
	{
	    TriggerEffectEvent('DisabledStart');
		TriggerEffectEvent('DisabledLoop');

		deactivatepersonalShield();

		dispatchMessage(new class'MessageBaseDeviceDisabled'(Label));
	}

	simulated function EndState()
	{
		UnTriggerEffectEvent('DisabledLoop');
		TriggerEffectEvent('DisabledStop');
		dispatchMessage(new class'MessageBaseDeviceEnabled'(Label));
	}	

// Specifically call this state tag when we are
// entering the state due to degeneration of the 
// devices health, to avoid destruction effects
// when health is increasing
Degenerating:
	TriggerEffectEvent('Disabled');
}

// State Destructed - cant use destroyed
simulated state Destructed
{
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (!isDisabled())
		{
			if(isPowered())
			{
				if(isDisabled())
					GotoState('Disabled');
				else
					GotoState('Active', 'Regenerating');
			}
			else
			{
				GotoState('Unpowered');
			}
		}
	}

	simulated function BeginState()
	{
		if (!bWasDeployed)
		{
			// only play these effects if we weren't deployed
			if (!bInitialization)
			{
				TriggerEffectEvent('DestructedStart');
			}
			TriggerEffectEvent('DestructedLoop');

			bInitialization = false;

			if (Level.NetMode != NM_Client)
				Health = 0;

			deactivatepersonalShield();
			StopAnimating();
		}
	}

	simulated function EndState()
	{
		if (!bWasDeployed)
		{
			// only play these effects if we weren't deployed
			UnTriggerEffectEvent('DestructedLoop');
			TriggerEffectEvent('DestructedStop');
		}
	}

// Specifically call this state tag when we are
// entering the state due to degeneration of the 
// devices health, to avoid destruction effects
// when health is increasing
Degenerating:
	// spawn the explosion and trigger it
	if(destroyedExplosionClass != None)
		spawn(destroyedExplosionClass, , , Location, Rotation).Trigger(self, None);

	if (Level.NetMode != NM_Client)
	{
		if (baseDeviceMessageClass != None && Level.TimeSeconds - lastOfflineTime > baseDeviceMessageClass.default.timeBetweenOfflineMessages)
		{
			lastOfflineTime = Level.TimeSeconds;
			Level.Game.BroadcastLocalized(self, baseDeviceMessageClass, 1, team());
		}

		if (secondaryBaseDeviceMessageClass != None && lastAttacker != None)
			Level.Game.BroadcastLocalized(self, secondaryBaseDeviceMessageClass, 0, lastAttacker.playerReplicationInfo);

		if (ModeInfo(Level.Game) != None)
			ModeInfo(Level.Game).OnBaseDeviceOffline(self, lastAttacker);
	}

Begin:
	// if we were deployed, we get vapourised
	if (bWasDeployed)
	{
		bHidden = true;
		Health = 0;
		TriggerEffectEvent('Destroyed');
		Sleep(0.5);
		Destroy();
	}
}

simulated function onTeamChange()
{
	super.onTeamChange();

	if (!bInitialization)
		TriggerEffectEvent('TeamChanged');
}

simulated event bool isPowered()
{
	return bPowered && m_bSwitchedOn;
}

function setHasPower(bool b)
{
	bPowered = b;
}

function setSwitchedOn(bool b)
{
	m_bSwitchedOn = b;
}

defaultproperties
{
	bStasis							= false
	bNoDelete						= false
	bUseCompressedPosition			= false
	Mesh							= SkeletalMesh'Editor_res.SkeletalDecoration'
	DrawType						= DT_Mesh
	bEdShouldSnap					= true
	bBlockKarma						= true
	bBlockHavok						= true
	bMovable						= false
	functionalHealthThreshold		= 0.5
	damagedHealthThreshold			= 0.75
	teamDamagePercentage			= -1.0

	bCanBeSensed						= false

	bPowered						= true

	m_bSwitchedOn					= true

	m_ownershipMaterialIdx			= -1
	OWNERSHIP_MATERIAL_UNDISCOVERED = -1
	OWNERSHIP_MATERIAL_NOT_FOUND	= -2

	bNeedPostRenderCallback = true	// required for DoIdentify to work
}
