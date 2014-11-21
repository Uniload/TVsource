class MPCapturePoint extends MPActor;

var() int						teamCaptureScore			"The number of points an attacker scores for his team when the carryable is captured";
var() editcombotype(enumCapturables) 
	  Name						homeCapturableLabel			"Label of a carryable of the capture point's team that must be in a home state in order for the team to score on capture";
var() Vector					homeCapturableOffset		"How much the carryable is offset from the capture point";

var() class<MPCapturable>		capturableClass;
var(LocalMessage) class<Engine.Localmessage> CapturePointMessageClass "The class used for playing effects and displaying messages";

var MPCapturable				homeCapturable;
var Array<MPCapturable>			enemyCapturables;

var float lastCaptureAttemptTime;

// Stats

// PostBeginPlay
simulated function PostBeginPlay()
{
	local MPCapturable a;

	Super.PostBeginPlay();

	if (Level.NetMode != NM_Client)
	{
		if (homeCapturableLabel != '')
		{
			homeCapturable = MPCapturable(findByLabel(class'MPCapturable', homeCapturableLabel));
			if (homeCapturable == None)
			{
				LOG(Label$": could not find the specified home capturable");
			}
			else
			{
				// Ensure the homeCapturable is precisely positioned on the stand
				setHomeCapturableLocation();

				// Cross-reference it
				homeCapturable.homeCapturePoint = self;
			}
		}
		else
			Log("Warning:  capture point "$self$" doesn't have a homeCapturable");

		ForEach DynamicActors(class'MPCapturable', a)
		{
			// A capturable is considered "enemy" to the capture point if it's on a different team,
			// or if the capturable is neutral, or if the capture point is neutral
			if (a != None && (a.team() != team() || a.team() == None || team() == None))
			{
				enemyCapturables[enemyCapturables.Length] = a;
			}
		}
	}
}

function setHomeCapturableLocation()
{
	homeCapturable.homeLocation = Location + homeCapturableOffset;
	homeCapturable.returnToHome();
}

// Bump
function touch(Actor Other)
{
	local int i;
	local MPCapturable c;

	// an actor bumped into us - check all the enemy capturables to see if that actor is holding one of them
	for (i = 0; i < enemyCapturables.Length; i++)
	{
		c = enemyCapturables[i];

		if (!c.IsInState('Held'))
		{
			continue;
		}

		// Can only capture if carrier is on the capture point's team or if the capture point is neutral
		if (c.carrier == Other && ((c.carrier.team() == team()) || (team() == None)))
		{
			// can only capture when home capturable is returned
			if (homeCapturable != None && !homeCapturable.bHome)
			{
				if (Level.TimeSeconds - lastCaptureAttemptTime > 2)
				{
					lastCaptureAttemptTime = Level.TimeSeconds;
					c.carrier.ReceiveLocalizedMessage( CapturePointMessageClass, 1 );
				}
				continue;
			}

			if (CapturePointMessageClass != None)
				Level.Game.BroadcastLocalized(self, CapturePointMessageClass, 0, c.carrier.team(), c.team());

			if (SecondaryMessageClass != None)
				Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 3, c.carrier.playerReplicationInfo);

			scoreCapture(c.carrier);
			c.onCapture(c.carrier);
		}
	}
}

// scoreCapture
function scoreCapture(Character instigator)
{
	// If this stand has a team, score according to that team
	if (team() != None)
		scoreTeam(teamCaptureScore);
	// Otherwise, score according to the carrier's team
	else
		scoreTeam(teamCaptureScore, instigator.team());
}

function onHomeCapturableReturned()
{
	local Character c;

	// Check for anyone standing at the capture point when the home capturable returns
	ForEach TouchingActors(class'Character', c)
	{
		Touch(c);
	}
}

// enumCapturables
function enumCapturables(Engine.LevelInfo l, out Array<Name> a)
{
	local MPCapturable f;

	ForEach DynamicActors(class'MPCapturable', f)
	{
		if (f.isA(capturableClass.Name) && f.team() == team())
			a[a.Length] = f.Label;
	}
}


defaultproperties
{
	DrawType				= DT_StaticMesh
	StaticMesh				= StaticMesh'Editor_res.TexPropCube'
	bCollideActors			= true
	bCollideWorld			= true
//	bBlockActors			= true
	bMovable				= false
	bNeedLifetimeEffectEvents	= true
	bProjTarget				= false


	CollisionRadius			= 200
	CollisionHeight			= 200

	teamCaptureScore		= 1
	homeCapturableOffset	= (X=0,Y=0,Z=125)

	capturableClass			= class'MPCapturable'
	CapturePointMessageClass = class'MPCapturePointMessages'
}