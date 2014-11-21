class TsActionLoopAnim extends TsAction;

var(Action) MojoAnimation BaseAnim;
var(Action) float BlendInTime;
var(Action) float AnimRate;
var(Action) int PlayChannel;
var(Action) float duration;

var transient float elapsed_time;

function bool OnStart()
{
	local MeshAnimation mesh_anim;

	if ( (BaseAnim.name == 'None') || (BaseAnim.name == ''))
		return false;

	// load a new animation set if specified
	if (BaseAnim.animation_set != '')
	{
		mesh_anim = MeshAnimation(DynamicLoadObject(string(Actor.Mesh.Outer.Name) $ "." $ string(BaseAnim.animation_set), class'MeshAnimation', true));
		if (mesh_anim == None)
			return false;

		Actor.LinkSkelAnim(mesh_anim);
	}

	if (!Actor.HasAnim(BaseAnim.name))
	{
		Log("bad animation name");
		return false;
	}

	// disable channel notify when using the movement channel (or else the Actor will 
	// interrupt the looping when next notify is sent)
	if (PlayChannel == 0)
		Actor.EnableChannelNotify(PlayChannel, 0);

	Actor.LoopAnim(BaseAnim.name,AnimRate,BlendInTime, PlayChannel);
	elapsed_time = 0;

	return true;
}

function bool OnTick(float delta)
{
	elapsed_time += delta;
	return elapsed_time < duration;
}

function OnFinish()
{
	if (PlayChannel == 0)
		Actor.EnableChannelNotify(PlayChannel, 1);
}

event bool SetDuration(float _duration)
{
	duration = _duration;
	return true;
}

event float GetDuration()
{
	return Duration;
}

defaultproperties
{
	DName			="Loop Animation"
	Track			="Animation"
	Help			="Loop a particular skeletal animation for a given duration"
    UsesDuration	=true
	
	BlendInTime		=0.200000
	AnimRate		=1.000000
	duration		=5.0f;
}