///////////////////////////////////////////////////////////////////////////////
// Catapult
//
// Applies an impulse to certain objects when they touch it - Characters, time delayed
// projectiles, and inventory items.
//
class Catapult extends BaseDevice dependsOn(Character);

var(Catapult) float		throwForce				"How much force is imparted to an actor that uses the catapult?";
var(Catapult) float		actorInfluence			"How much does the linear velocity of the actor influence the throw direction?";
var(Catapult) float		catapultInfluence		"How much does the catapult's orientation influence the throw direction?";
var(Catapult) bool		bDirectional			"Does the catapult only throw in a forward direction (x axis)?";
var(Catapult) float		verticalInfluence		"(Directional only) What is the vertical influence of catapult? (0.0 = horizontal, 1.0 = vertical)";
var(Catapult) bool		bIgnoreActorVelocity	"Set to ignore the actor velocity when it hits the catapult (ie: force the actor in the direction the catapult throws)";
var(Catapult) bool		bReflective				"Does the catapult reflect the actor velocity in to the velocity out? (Setting this to true results in all other variables being ignored)";

replication
{
	reliable if(Role == ROLE_Authority)
		throwForce, actorInfluence, catapultInfluence, bDirectional, 
		verticalInfluence, bIgnoreActorVelocity, bReflective;
}

simulated function Touch(actor Other)
{
	// arc projectiles handle catapult touching from their end
	if (Other.IsA('ArcProjectile'))
		return;

	TouchProcessing(Other);
}

simulated function TouchProcessing(actor Other)
{
    local float actorMass;               // mass of actor in kilos
    local Vector actorVelocity;          // incoming actor velocity

    local Vector desiredVelocity;        // desired outgoing actor velocity (minus throw impulse)
    local Vector desiredDirection;       // desired outgoing direction vector (zero if ignoring incoming velocity)

	local Vector throwImpulse, throwDirection;
	local Vector catapultForward, catapultRight, catapultUp;

	if(! isFunctional() || isAnimating())
		return;

	if(Other.Role != ROLE_AutonomousProxy && Other.Role != ROLE_Authority && !Other.IsA('ArcProjectile'))
		return;

	//
	// Check that we have a throwable actor
	//
	if(! (Other.IsA('Character') || 
		  Other.IsA('KActor') || 
		  Other.IsA('ArcProjectile')))
				return;

	//
	// Get the zAxis of the catapult for the throw Impulse direction
	//
	GetAxes(Rotation, catapultForward, catapultRight, catapultUp);

    actorVelocity = other.unifiedGetVelocity();

	if(! bReflective)
	{
		//
		// Get the adjusted actor velocity (remove components facing towards 
		// the catapult throw direction) and store a normalized version.
		//
		if(bIgnoreActorVelocity)
		{
			desiredVelocity = vect(0,0,0);
			desiredDirection = vect(0,0,0);
		}
		else
		{
		    // remove velocity component into catapult (inelastic collision)
		
			desiredVelocity = actorVelocity - (actorVelocity dot catapultUp) * catapultUp;
			desiredDirection = Normal(actorVelocity);
		}

		if(bDirectional)
		{
			//
			// If this is a directional catapult we want to restrict the throw 
			// direction to the plane of the catapult. 
			//
			// note: throw will always be in the direction of the forward axis.
			//
			throwDirection = (catapultUp * verticalInfluence) + (catapultForward * (1.0 - verticalInfluence));
		}
		else
		{
			//
			// Use a throw direction calculated from the catapult influence and the
			// actor influence (inelastic collision response outgoing direction)
			//
			throwDirection = Normal((catapultUp * catapultInfluence) + 
									(desiredDirection * actorInfluence));
		}
	}
	else
	{
		//
		// A collision with a reflective catapult should result in the outgoing 
		// velocity of the player to be an opposite reflection of the incoming
		// velocity, around the plane of the catapult base. This should be perfectly elestic. 
		//
		
		desiredVelocity = MirrorVectorByNormal(actorVelocity, catapultUp);

		throwDirection = Normal(desiredVelocity);
	}

	// calc the throw impulse
	throwImpulse = throwForce * throwDirection;

	// extra step to even out the impulse so that all objects  
	// behave the same way when they touch a catapult (may filter
	// this step by class later if required).
    actorMass = other.unifiedGetMass();
	throwImpulse = (throwImpulse * actorMass) / 100;

    if (Character(other)!=None)
        Character(other).blockMovementDamage = true;

    other.unifiedAddImpulse(throwImpulse + (desiredVelocity - actorVelocity) * actorMass);

	PlayBDAnim('Fire');
	
	TriggerEffectEvent('CatapaultTriggered', Other, None, Location, Rotation);
}

defaultproperties
{
	Mesh = SkeletalMesh'BaseObjects.Catapult'
	DrawType = Mesh

	RemoteRole=ROLE_DumbProxy

	bBlockActors = false
	bBlockPlayers = false

	bReplicateAnimations = true;

	bBlockKarma = false
	bBlockHavok	= false

	bIgnoreActorVelocity = false;

	throwForce = 400000.0
	actorInfluence = 0.0		// default to no actor influence
	catapultInfluence = 1.0		// full catapult influence

	bDirectional = false;		// default to a non-directional catapult
	verticalInfluence = 0.5;	// default to 45 degrees

	bReflective = false;

	bWorldGeometry = false
}