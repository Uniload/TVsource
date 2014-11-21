class TsActionSnapTo extends TsAction
	native;

var(Action) MojoKeyframe target;
var(Action) bool reset_animation;

function bool OnStart()
{
	Actor.setLocation(target.position);
	Actor.setRotation(target.rotation);

	// disable phsyics, or else the actor may try to phys move out of their snap position
	Actor.SetPhysics(PHYS_None);

	if (reset_animation)
		Actor.StopAnimating();

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName				="Snap Object"
	Track				="Position"
	Help				="Snap an object to a particular position"
	ModifiesLocation = true

	reset_animation = false
}