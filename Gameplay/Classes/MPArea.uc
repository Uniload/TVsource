class MPArea extends MPActor implements IMPAreaTriggerable;

var() editinline class<MPAreaTrigger> areaTriggerClass		"An MPAreaTrigger that defines an area";
var MPAreaTrigger	areaTrigger;
var() Vector areaOffset										"The spawned area will be offset by this amount from the actor's pivot";

// PostBeginPlay
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode != NM_Client)
	{
		// Create trigger here
		areaTrigger = spawn(areaTriggerClass, self,,location+areaOffset);
		areaTrigger.listener = self;
	}
}

function cleanup()
{
	Super.cleanup();

	// Force destruction of the areaTrigger so that territories are properly
	// filtered on map load
	if (areaTrigger != None)
		areaTrigger.Destroy();
}

function OnAreaEntered(Character c)
{
	c.ReceiveLocalizedMessage( class'MPAreaMessages', 1 );
}

function OnAreaExited(Character c)
{
	c.ReceiveLocalizedMessage( class'MPAreaMessages', 2 );
}

function OnAreaEnteredByActor(Actor a)
{
}

function OnAreaExitedByActor(Actor a)
{
}

function OnAreaTick()
{
	// Do nothing
}

defaultproperties
{
     areaTriggerClass=Class'MPAreaTrigger'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor_res.TexPropCube'
     bMovable=False
     CollisionRadius=200.000000
     CollisionHeight=200.000000
}
