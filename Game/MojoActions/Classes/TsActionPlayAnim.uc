class TsActionPlayAnim extends TsAction;

var(Action) MojoAnimation BaseAnim;
var(Action) float BlendInTime;
// var(Action) float BlendOutTime;
var(Action) float AnimRate;
var(Action) int Iterations;
var(Action) int PlayChannel;
var(Action) bool DisablePhysics;

var transient int currItrtn;
var transient Actor.EPhysics org_physics;

function bool OnStart()
{
	local MeshAnimation mesh_anim;

	if ( (BaseAnim.name == 'None') || (BaseAnim.name == '') || (Iterations == 0) )
		return false;

	// load a new animation set if specified
	if (BaseAnim.animation_set != '')
	{
		mesh_anim = MeshAnimation(DynamicLoadObject(string(Actor.Mesh.Outer.Name) $ "." $ string(BaseAnim.animation_set), class'MeshAnimation', true));
		if (mesh_anim == None)
		{
			Log("ActionPlayAnim: Couldn't load animation set "$BaseAnim.animation_set);
			return false;
		}

		Actor.LinkSkelAnim(mesh_anim);
	}

	if (!Actor.HasAnim(BaseAnim.name))
	{
		Log("bad animation name");
		return false;
	}

	currItrtn = 0;

	if (DisablePhysics)
	{
		org_physics = Actor.Physics;
		Actor.SetPhysics(PHYS_None);
	}

	Actor.PlayAnim(BaseAnim.name,AnimRate,BlendInTime, PlayChannel);

	return true;
}

function bool OnTick(float delta)
{
	local name currAnim;
	local float dummyFloat;
	local bool still_animating;
	
	still_animating = Actor.IsAnimating(PlayChannel);
	// even if we are still animating on play channel , we may have switched to a different anim. ie we are no 
	// longer playing our desired anim
	if (still_animating)
	{
		Actor.GetAnimParams(PlayChannel, currAnim, dummyFloat, dummyFloat);
		still_animating = (currAnim == BaseAnim.name);
	}

	// if not animating, end, or loop again
	if (!still_animating)
	{
		currItrtn++;
		if (currItrtn >= Iterations)
		{
			return false;
		}
		else
		{
			Actor.PlayAnim(BaseAnim.name,AnimRate,BlendInTime, PlayChannel);
		}
	}

	return true;
}

function OnFinish()
{
	if (DisablePhysics)
		Actor.SetPhysics(org_physics);
}

defaultproperties
{
	DName			="Play Animation"
	Track			="Animation"
	Help			="Run a particular skeletal animation"
    BlendInTime		=0.000000
 //   BlendOutTime	=0.200000
	AnimRate		=1.000000
	Iterations		=1
}