class x2MPFlag extends Gameplay.MPFlag;

var bool bReturning;

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_Client)
	{
		bReturning = false;
	}
	Super.PostBeginPlay();
}

function returnToHome(optional bool bSignificant)
{
	bReturning = true;

	super.returnToHome(bSignificant);
}

/*
singular function Touch(Actor Other)
{
	if(bReturning)
		return;
	super.Touch(Other);
}
*/

function bool attemptPickup(Character c, optional bool ignoreLastCarrierCheck){
	if(bReturning)
		return false;
	super.attemptPickup(c, ignoreLastCarrierCheck);
}

function bool validCarrier(Character c, optional bool ignoreLastCarrierCheck){
	if(bReturning)
		return false;
	super.validCarrier(c, ignoreLastCarrierCheck);
}

// Home state
state Home
{
	function returnToHome(optional bool bSignificant)
	{
		// Already home
	}

	function CheckTouching()
	{
		local Character c;

		if(bReturning)
			return;

		ForEach TouchingActors(class'Character',c)
		{
			if ( ValidCarrier(c) )
			{
				setCarrier(c);
				pickup(c);
				return;
			}
		}
	}

	function BeginState()
	{
		bWasDropped = false;

		SetRelativeLocation(Vect(0,0,0));
	    SetRelativeRotation(Rot(0,0,0));
		unifiedSetVelocity(Vect(0,0,0));
		unifiedSetAngularVelocity(Rot(0,0,0));

		SetBase(None);

		SetPhysics(default.Physics);
		bHome = true;

		// If a homeContainer is specified, use its location instead and send to Locked
		if (homeContainer != None)
		{
			//Log("homeContainer for "$self$" detected as "$homeContainer$"; adding and sending to Locked");
			homeContainer.addCarryable(self);
			unifiedSetPosition(homeContainer.Location);
			GotoState('Locked');
			return;
		}

		unifiedSetPosition(homeLocation);
		unifiedSetRotation(homeRotation);
		//Enable('Touch');

		bHomeEffect = true;
		updateCarryableEffects();
		bInitialized = true;
		bReturning = false;
	}

	function EndState()
	{
		bHome = false;
		bHomeEffect = false;
		updateCarryableEffects();

		if (existenceTimer != None)
			existenceTimer.StartTimer(existenceTime);
	}

SignificantReturn:
	if (CarryableMessageClass != None)
		Level.Game.BroadcastLocalized(self, CarryableMessageClass, 2, team());

Begin:
	// After setting to its home location, see if anyone is touching it
	CheckTouching();
}

defaultproperties
{
     returnStat=Class'StatClasses.flagReturnStat'
     captureStat=Class'StatClasses.flagCaptureStat'
     returnTime=30.000000
     hudIcon=Texture'HUD.MPTabs'
     hudIconCoords=(U=102.000000,V=216.000000)
     meshWhileCarried=SkeletalMesh'MPGameObjects.Flag'
     bCanBeGrappledInField=False
     CarryableMessageClass=Class'AnnouncerClasses.MPFlagMessages'
     pickupStat=Class'StatClasses.flagPickupStat'
     carrierKillStat=Class'StatClasses.StatFlagCarrierKill'
     returnedHomeEffectEvent="None"
     carriedObjectClass=None
     localizedName="Flag"
     primaryFriendlyObjectiveDesc="Defend your team's flag"
     primaryEnemyObjectiveDesc="Get the enemy flag"
     primaryNeutralObjectiveDesc="Get the flag"
     defendStat=Class'StatClasses.StatFlagDefend'
     attackStat=Class'StatClasses.StatFlagAttack'
     defendRadius=1500
     attackRadius=1500
     idleAnim="Idle"
     radarInfoClass=Class'hudClasses.RadarInfoFlag'
     DrawType=DT_Mesh
     StaticMesh=None
     Mesh=SkeletalMesh'MPGameObjects.Flag'
     Skins(1)=Shader'MPGameObjects.FlagNeutralShader'
     CollisionRadius=70.000000
     CollisionHeight=120.000000
}
