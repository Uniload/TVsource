///////////////////////////////////////////////////////////////////////////////
//
// Explosion
//

class Explosion extends Engine.Actor placeable;

// Physics & Force properties
var (Explosion) float RadialForce				"Force of explosion out radially from center";
var (Explosion) float LiftForce					"Force of explosion applied directly upwards";
var (Explosion) float ChaoticForce				"Chaotic force of explosion (random direction) *NOT CURRENTLY IMPLEMENTED*";
var (Explosion) float StartRadialVelocity		"Starting Radial velocity of explosion outwards";
var (Explosion) float RadialAcceleration		"Radial acceleration of explosion outwards";
var (Explosion) float RadialAccelerationChange	"Change in acceleration over time";
var (Explosion) bool AllowDownforce				"Whether to allow down forces on the explosion";
var (Explosion) bool AllowForceRepeat			"Whether to allow the force to be applied repeatedly to objects which remain in the explosion radius";

// Falloff properties
var (Explosion) float StartRadius				"What radius the explosion starts at (immediate area of effect)";
var (Explosion) float EndRadius					"The end radius of the explosion";
var (Explosion) float FalloffStartRadius		"At what radius the falloff begins";
var (Explosion) float LingerTime				"How long the explosion 'lingers' for after it reaches it's max radius";

// Damage properties
var (Explosion) float				MaxDamage			"The maximum amount of damage to apply to an affected object (changes with falloff)";
var (Explosion) class<DamageType>	DamageTypeClass		"The damage type infliced on victims of the explosion";

// FX properties
var (Explosion) float ShakeTime					"Duration of camera shake";
var (Explosion) float ShakeMagnitude			"Magnitude of camera shake";
var (Explosion) float ShakeRadius				"Radius to be added to the explosion area of effect";
var (Explosion) Name Effect						"Effect for explosion";

// Unaffected classes
var (Explosion) Array<Name>	UnaffectedActorTypes	"Array of class names which are unaffected by the explosion";

// Debug Properties
var (Explosion) bool DestroyOnFinish			"Whether to destroy the explosion when it has exploded";
var (Explosion) bool ShowVisualisation			"Show the debug explosion visualisation";

var float			Radius;				// current radius of explosion
var float			RadialVelocity;		// current velocity of explosion
var float			LingerCounter;		// how long we have been lingering for
var Array<Actor>	Affected;			// array of already affected actors
var Pawn			StoredEventInstigator;

var ExplosionVisualisation vis;	// debug vis object

function PostBeginPlay()
{
	super.PostBeginPlay();
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	StoredEventInstigator = EventInstigator;
	GotoState('Exploding');
}

function DoExplosion()
{
}

state Exploding
{
	function BeginState()
	{
		TriggerEffectEvent(Effect);

		Radius = StartRadius;
		RadialVelocity = StartRadialVelocity;
		LingerCounter = 0;
		if(Affected.Length > 0)
			Affected.Remove(0, Affected.Length);	// Clear the Affected Array

		// Init Debug visualisation
		if(vis == None && ShowVisualisation)
		{
			vis = spawn(class'ExplosionVisualisation', , , Location, Rot(0, 0, 0));
			vis.owner = self;
			vis.unifiedSetPosition(Location);
			vis.SetPhysics(PHYS_None);
		}
	}

	function Tick(float Delta)
	{
		local Vector Impulse;
		local Vector HitLocation;
		local Vector Direction;
		local Vector CenterOfMass;
		local Vector Offset;
		local Actor Object;
		local Controller C;
		local Pawn P;
		local float FalloffPercent;
		local float HitLocationRadius;
		local bool DontAffect;
		local int i;

		DontAffect = false;

		// Integrate values
		RadialAcceleration += RadialAccelerationChange * Delta;
		RadialVelocity += RadialAcceleration * Delta;
		Radius += RadialVelocity * Delta;

		// cap the Radius
		if(Radius > EndRadius)
			Radius = EndRadius;

		// Update debug visualisation
		if(ShowVisualisation)
		{
			vis.bHidden = false;
			vis.UpdateVis();
		}

		// find all objects in radius
		foreach VisibleCollidingActors(class'Actor', Object, Radius, Location, true, true, self, true)
		{
			if(IsAffected(Object))
			{
				// search the affected objects to ensure we arent 
				// applying explosive effects more than once
				for(i = 0; i < Affected.Length; i++)
				{
					if(Affected[i] == Object)
					{
						DontAffect = true;
						break;
					}
				}

				Affected.Length = Affected.Length + 1;
				Affected[Affected.Length - 1] = Object;

				// calculate the force to be applied
				CenterOfMass = Object.unifiedGetNaturalCOMPosition();

				Offset = VRand() * 5;
				HitLocation = Offset + CenterOfMass;

				// calc the falloff percentage based on the hit location
				FalloffPercent = 1.0;
				HitLocationRadius = VSize(HitLocation - Location);
				if(Radius > FalloffStartRadius)
					FalloffPercent = fClamp(1.0 - (HitLocationRadius - FalloffStartRadius) / (EndRadius - FalloffStartRadius), 0.0, 1.0);

				Direction = Normal(HitLocation - Location);
				Impulse += RadialForce * Direction;

				Impulse.Z += LiftForce;

				// restrict the downforce if configured so
				if(! AllowDownforce && Impulse.Z < 0)
					Impulse.Z = 0;
					
			    // respect character knockback scale
			    if (Character(object)!=None && object.Physics==PHYS_Movement)
			        Impulse *= Character(object).movementKnockbackScale;

				// apply impulse - respecing the AllowForceRepeat & DontAffect flags
				if(AllowForceRepeat)
					Object.unifiedAddImpulseAtPosition(Impulse * FalloffPercent, HitLocation);
				else if(! DontAffect)
					Object.unifiedAddImpulseAtPosition(Impulse * FalloffPercent, HitLocation);

				if(! DontAffect)
				{
					// apply damage if not in hurt radius family or parent of hurt radius family
					if (Object.getHurtRadiusParent() == None || Object.getHurtRadiusParent() == Object)
						Object.TakeDamage(MaxDamage * FalloffPercent, StoredEventInstigator, HitLocation, vect(0,0,0), DamageTypeClass);

					// shake camera view
					P = Pawn(Object);
					if (P!=None && P.Controller!=None)
					{
						for ( C=Level.ControllerList; C!=None; C=C.NextController )
							if ( (PlayerController(C) != None) && (VSize(Location - PlayerController(C).ViewTarget.Location) < ShakeRadius) )
								P.Controller.ShakeView(ShakeTime, 10 * ShakeMagnitude, ShakeMagnitude * vect(0.0,0.0,1.00000), 12000, ShakeMagnitude * vect(10,10,10), 1 + 0.1f * ShakeMagnitude);
					}
				}

				DontAffect = false;
			}
		}

		if(Radius >= EndRadius)
		{
			if(LingerCounter >= LingerTime)
			{
				// hide debug visualisation
				if(ShowVisualisation)
					vis.bHidden = true;
				GotoState('None');
				if(DestroyOnFinish)
				{
					if (vis != None)
						vis.Destroy();

					Destroy();
				}
			}
			else
			{
				LingerCounter += Delta;
			}
		}
	}
}

// returns whether the given object will be affected
// by the explosion
function bool IsAffected(Actor Object)
{
	local int i;

	// dont affect the explosion object - it's just wrong
	if(Object == self || Object == vis)
		return false;

	for(i = 0; i < UnaffectedActorTypes.Length; i++)
	{
		if(Object.IsA(UnaffectedActorTypes[i]))
		{
			return false;
		}
	}

	// only affect authorities
	if (Object.Role != ROLE_Authority)
		return false;

	return true;
}

defaultproperties
{
    DrawType = DT_None

	Physics = PHYS_None
	bCollideWorld = false
	bCollideActors = false
	bBlockActors = false
	bBlockPlayers = false

	RadialForce = 105000
	LiftForce = 105000
	ChaoticForce = 0
	StartRadialVelocity = 10
	RadialAcceleration = 10000
	RadialAccelerationChange = 0
	AllowDownforce = false
	AllowForceRepeat = false;

	StartRadius = 50
	EndRadius = 900
	FalloffStartRadius = 450
	LingerTime = 0.0

	MaxDamage = 10
	DamageTypeClass = class'ExplosionDamageType'

	ShakeMagnitude = 25
	ShakeTime = 15
	ShakeRadius = 1000

	DestroyOnFinish = true
	ShowVisualisation = false
	
    UnaffectedActorTypes(0) = "Projectile"
    
    Effect = "Exploded";

	RemoteRole = ROLE_None
}
