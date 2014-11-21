// the ragdoll class extends a pawn derived class to add support for ragdoll physics on death.

class Ragdoll extends Rook
	native;

var(Ragdoll) float ragdollLifeSpan;			// Maximum time the ragdoll will be around.

var(Ragdoll) class<HavokSkeletalSystem>	HavokParamsClass;

var bool bPlayedDeath;

var (Ragdoll) float jetpackDuration;        // amount of time to apply the jets for on death
var (Ragdoll) float jetpackLinearForce;     // amount of jetpack force to apply to jetpack bone with linear only
var (Ragdoll) float jetpackTwirlyForce;     // amount of jetpack force to apply to jetpack bone with rotational component

var (Ragdoll) float ragdollScale;           // scale factor between ragdoll mass and actual mass. eg. 10 means that actual mass is 10x ragdoll mass (ragdoll 10 -> actually 100kilos)

var (Ragdoll) float ragdollMaximumImpulse;  // any impulse above this amount is clamped. stops retarded ragdolls from oversized explosions from the designers =/

var (Ragdoll) bool disableJetpackDeath;     // flag to disable jetpack death

var (Ragdoll) float ragdollDeathLift;       // ragdoll lift on death impulse

var bool jetpack;                           // true if jetpack is applying force
var float jetpackTime;                      // time spend applying jetpack force to ragdoll so far
var bool ragdollTouchedGround;              // true if the ragdoll has hit ground (go into twirly mode)
var int ragdollTickCount;                   // tick count since ragdoll started

var vector TearOffLocation;					// set on server to replicate a location change at the instant of death
var bool bTearOffLocationValid;

var vector ragdollInheritedVelocity;        // stored velocity for initial ragdoll velocity inheritance

enum MovementState
{
	MovementState_Stand,
	MovementState_Walk,
	MovementState_Run,
	MovementState_Sprint,
	MovementState_Ski,
	MovementState_Slide,
	MovementState_Stop,
	MovementState_Airborne,
	MovementState_AirControl,
	MovementState_Thrust,
	MovementState_Swim,
	MovementState_Float,
	MovementState_Skim,
	MovementState_ZeroGravity,
	MovementState_Elevator,
};

var MovementState movement;                 // current movement state



replication
{
	// infrequently changing variables
	reliable if (ROLE == ROLE_Authority)
		HavokParamsClass;

	reliable if (bTearOff && bNetDirty && (Role==ROLE_Authority))
		TearOffLocation, bTearOffLocationValid;
}


simulated function Tick(float DeltaTime)
{
    local vector jetpackForce;
    local rotator jetpackRotation;
    local coords jetpackCoords;
    
	super.Tick(DeltaTime);

	if (Level.NetMode == NM_DedicatedServer)
		return;
		
    // assume dead if bTearOff
    
    if (bTearOff)
    {
        if ( !bPlayedDeath )
            PlayDying(HitDamageType, TakeHitLocation);
    }
    
    // cool thrust on ragdoll

    if (bPlayedDeath && jetpack)
    {
        // start thrust effect on second tick into ragdoll (after physics change stops effects)

        ragdollTickCount++;

        if (ragdollTickCount==2)        
            StartLoopingEffect("MovementThrust");

        // apply ragdoll thrust forces

        jetpackTime += deltaTime;

        if (jetpackTime<jetpackDuration)
        {
            // apply linear jetpack force
        
            if (havokSkeletalRotationSpeed<500 && vsize(velocity)<2000)
            {
                jetpackRotation = GetBoneRotation('Bip01 Spine');
            
                jetpackForce = (jetpackLinearForce / ragdollScale) * vector(jetpackRotation);
            
                HavokImpartLinearForceAll(jetpackForce);
            }

            // apply twirly jetpack force if collided last update

            if (havokSkeletalRotationSpeed<50 || vsize(velocity)<500)
            {        
                jetpackCoords = GetBoneCoords('JetpackBone');
                jetpackRotation = GetBoneRotation('JetpackBone');

                if (jetpackCoords.origin==jetpackCoords.origin)
                    HavokImpartForce((-jetpackTwirlyForce / ragdollScale) * vector(jetpackRotation), jetpackCoords.origin);
            }
        }
        else
        {
	        StopLoopingEffect("MovementThrust");
	        
	        jetpack = false;
	    }
	}
}

// Notes about how this replicates to clients:
// - The server will get PlayDying called and go into ragdoll here. This function sets bTearOff to true
// - bTearOff is replicated to clients, who in their Tick function detect it set to true and call PlayDying locally
// - Dedicated servers need to just keep the player hanging around without it going into ragdoll

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{	
	if (bPlayedDeath)
		return;
	
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	HitDamageType = DamageType;     // these are replicated
    TakeHitLocation = HitLoc;

    GotoState('Dying');

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (StartHavokRagdoll())
			return;
	}
		
	SetPhysics(PHYS_None);
}

simulated function bool StartHavokRagdoll()
{
	local HavokSkeletalSystem HavokSkeletal;
	local Vector RagdollVelocity;
	local vector lift;

	if (HavokParamsClass == None)
		return false;
	HavokSkeletal = new HavokParamsClass;

	HavokData = HavokSkeletal;

	// inherit velocity and add extra upwards kick
	
	velocity = ragdollInheritedVelocity;         // work around zeroed velocity bug in MP
	
	if (velocity==velocity)
	{
	    RagdollVelocity = Velocity;
    }
    else
    {
        // NaN in velocity
        RagdollVelocity = vect(0,0,0);
    }

	// apply tear off location
	if (bTearOffLocationValid && TearOffLocation == TearOffLocation)
		SetLocation(TearOffLocation);

	// ragdoll physics are a client side visual effect
	bClientHavokPhysics = true;
	bEnableHavokBackstep = true;	// help with tunnelling probs

	// disable collision cylinder proxy when in ragdoll

	bHavokCharacterCollisions = false;

	StopAnimating(true);
	SetPhysics(PHYS_HavokSkeletal);

	HavokSetLinearVelocityAll(RagdollVelocity);
	
	//log("ragdoll velocity = "$ragdollVelocity);
	//log("tear off = "$tearOffMomentum);
	
	if (tearOffMomentum!=tearOffMomentum)       // NaN
	    tearOffMomentum = vect(0,0,0);
	
    if (vsize(tearOffMomentum)<1) 
    {
        //log("no tear off momentum: pushing forward to fall on face");
    
        tearOffMomentum = (vect(5000,0,0) >> rotation);
    }

	unifiedAddImpulse(HavokSkeletal.TearOffImpulseScale * TearOffMomentum);

    velocity = unifiedGetVelocity();

    //log("lift velocity: "$velocity.z);
    
    if (velocity.Z > -10 && vsize(TearOffMomentum) > 5000)
    {
        lift.x = 0;
        lift.y = 0;
        lift.z = ragdollDeathLift * rand(10000) / 10000.0;
        
        unifiedAddImpulse(lift);
        
        //log("ragdoll lift applied: "$lift.z);
    }

	// check for jetpack ragdoll

	if (!disableJetpackDeath && (movement==MovementState_Thrust || movement==MovementState_ZeroGravity))
	{
		jetpack = true;
		jetpackTime = 0;

        // randomize jetpack duration

        jetpackDuration = jetpackDuration*0.25 + jetpackDuration*0.75*rand(1000)/1000.0;	

        //log("jetpack death: duration="$jetpackDuration);
	}

	return true;
}

State Dying
{
	function PostLoadGame()
	{
		Destroy();
	}

    simulated function PostTakeDamage( float Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional float projectileFactor)
    {		
        //log("ragdoll take damage: "$damage);
    
        ragdollTouchedGround = true;
 	    unifiedAddImpulse(Momentum);
    }

    simulated function BeginState()
	{
		local Character character;

		Super.BeginState();

		character = Character(self);

		// Minimum life time of 4 seconds for client local ragdolls to guarantee it is not culled due to replication inefficiencies.
		// Pre-matrure ragdoll cull causes the the controller spectating the death to go to 0, 0, 0.

		if (Level.NetMode == NM_Client && character != None && character.bIsLocalCharacter)
			SetTimer(4.0, false);
		else
			SetTimer(1.0, false);
 	}

    simulated function Timer()
	{
		ragdollLifespan -= 1.0;

	    if (Level.NetMode==NM_DedicatedServer)
	    {
		    Destroy();
		}
		else if (ragdollLifespan > 0)
		{
			SetTimer(1.0, false);
		}
		else
		{
		    if (!PlayerCanSeeMe())
            {
                // destroy ragdoll if not seen

                Destroy();        
            }
		    else
            {
                // set timer and check again later
            
			    SetTimer(1.0, false);
            }
        }
	}
}


// override unified physics methods to take ragdoll mass scale into account

simulated function unifiedAddImpulse(Vector impulse)
{
    if (vsize(impulse)>ragdollMaximumImpulse)
        impulse = normal(impulse) * ragdollMaximumImpulse;

    super.unifiedAddImpulse(impulse/ragdollScale);
}

simulated function unifiedAddImpulseAtPosition(Vector impulse, Vector position)
{
    if (vsize(impulse)>ragdollMaximumImpulse)
        impulse = normal(impulse) * ragdollMaximumImpulse;

    super.unifiedAddImpulseAtPosition(impulse/ragdollScale, position);
}

simulated function unifiedAddForce(Vector force)
{
    super.unifiedAddForce(force/ragdollScale);
}

simulated function unifiedAddForceAtPosition(Vector force, Vector position)
{
    super.unifiedAddForceAtPosition(force/ragdollScale, position);
}

defaultproperties
{
     ragdollLifeSpan=10.000000
     jetpackDuration=4.000000
     jetpackLinearForce=20000.000000
     jetpackTwirlyForce=250000.000000
     ragdollScale=20.000000
     ragdollMaximumImpulse=200000.000000
     ragdollDeathLift=50000.000000
}
