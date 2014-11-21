class MPGoal extends MPActor;

var() int		teamGoalScore			"The number of points an attacker scores for his team when a goal is scored";
var() int		individualGoalScore		"The number of points an attacker scores for himself when a goal is scored";
var() Material	goalMaterial			"The material the ball must touch in order to score a goal";

// Effects
var bool bGoalEffect;
var bool bLocalGoalEffect;
var() name goalScoredAnimation			"The name of an animation to play when a goal is scored";
var(EffectEvents) name goalScoredEffectEvent	"The name of an effect event that plays once on the goal when a goal is scored.";
var MPBall ballRef;
var bool bInitialization;

replication
{
	reliable if (Role == ROLE_Authority)
		bGoalEffect;
}

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	updateGoalEffects();
}

simulated function updateGoalEffects()
{
	if (bGoalEffect != bLocalGoalEffect)
	{
		bLocalGoalEffect = bGoalEffect;

		if (!bInitialization)
		{
			if (team() != None)
				TriggerEffectEvent(goalScoredEffectEvent,,,,,,,,team().Class.name);
			else
				TriggerEffectEvent(goalScoredEffectEvent);
			if (hasAnim(goalScoredAnimation))
				PlayAnim(goalScoredAnimation);
		}
	}
	
	bInitialization = false;
}

// Bump
function Touch(Actor Other)
{
	local MPBall ball;
	local TeamInfo t;
    local Vector HitLocation, HitNormal, StartTrace, EndTrace;
	local Actor Check;
    local Material MaterialHit;
	local int i;

	ball = MPBall(Other);
	if (ball == None)
		return;

	// Check for goal by determining the material the ball hit
	StartTrace = Other.Location;
	EndTrace = Location;// + (Normal(Other.Velocity) * 100.0);

	Check = Other.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0), MaterialHit );
	
	//Log("GOAL check ="$Check$", mat = "$MaterialHit$", start = "$StartTrace$", end = "$EndTrace$", vel = "$Other.Velocity);
 
	if (MaterialHit != goalMaterial)
	{
		//Other.HitWall(HitNormal, self);
		// Remove from touching array so that touch is called again
		for (i=0; i<Touching.Length; i++)
		{
			if (Touching[i] == ball)
				Touching.Remove(i, 1);
		}

		return;
	}

	// Hide the ball and wait half a second before returning it
	// This is partly to handle the case where someone scores from point blank range, which
	// can result in state confusion
	ball.bHidden = true;
	ballRef = ball;
	SetTimer(0.5, false);
	bGoalEffect = !bGoalEffect;
	updateGoalEffects();

	if (ball.lastCarrier.team() != team())
	{
		scoreTeam(teamGoalScore, ball.lastCarrier.team());
		scoreIndividual(ball.lastCarrier, individualGoalScore);
		//Level.Game.Broadcast(self, "GOOOOOOOOOOOOOOAAAAL!!!");
		Level.Game.BroadcastLocalized(self, ball.Class.default.CarryableMessageClass, 5, ball.lastCarrier.team());

		if (ball.Class.default.SecondaryMessageClass != None)
			Level.Game.BroadcastLocalized(self, ball.Class.default.SecondaryMessageClass, 5, ball.lastCarrier.playerReplicationInfo);

		dispatchMessage(new class'MessageGoalScored'(label, ball.lastCarrier.label, ball.lastCarrier.getTeamLabel(), ball.label));
	}
	else
	{
		// If someone scores on their own team's goal, all other teams get a point
		ForEach DynamicActors(class'TeamInfo', t)
		{
			if (t != ball.lastCarrier.team())
			{
				dispatchMessage(new class'MessageGoalScored'(label, ball.lastCarrier.label, t.label, ball.label));
				scoreTeam(teamGoalScore, t);
			}
		}
	}
}

function Timer()
{
	ballRef.onGoal(self);
	ballRef.bHidden = false;
	ballRef = None;
}

defaultproperties
{
	DrawType				= DT_StaticMesh
	StaticMesh				= StaticMesh'MPGameObjects.goal'
	bCollideActors			= true
	bCollideWorld			= true
	bBlockActors			= true
	bBlockPlayers			= true
	bMovable				= false
	bNetNotify				= true
	//bUseCylinderCollision	= true

	teamGoalScore			= 1
	individualGoalScore		= 10

	goalMaterial			= Material'MPGameObjects.GoalMouthShader'
	goalScoredEffectEvent	= Scored

	bSkipEncroachment		= true

	bInitialization = true
}