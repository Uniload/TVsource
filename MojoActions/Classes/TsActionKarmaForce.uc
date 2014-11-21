class TsActionKarmaForce extends TsAction;

var(Action) vector relativeLocation;
var(Action) vector momentum;

function bool OnStart()
{
	//local Engine.KActor karmaActor;
	//local Vector centerOfMass;

	//// get karma actor
	//karmaActor = Engine.KActor(actor);
	//if (karmaActor == None)
	//{
	//	Log("Failed to get Karma actor.");
	//	return true;
	//}

	//// get karma center of mass
	//karmaActor.KGetCOMPosition(centerOfMass);

	//// apply impulse force
	//karmaActor.KAddImpulse(momentum, relativeLocation + centerOfMass);

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Karma Force"
	Track			="State"
	Help			="Applies an impulse force to a Karma Actor."
}