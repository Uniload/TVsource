class TsActionSetCollision extends TsAction;

var(Action) bool collide_with_actors;

function bool OnStart()
{
	Actor.SetCollision(collide_with_actors, collide_with_actors, collide_with_actors);
	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Set Collision"
	Track			="State"
	Help			="Adjust the collision properties of an actor"

	collide_with_actors=false
}

