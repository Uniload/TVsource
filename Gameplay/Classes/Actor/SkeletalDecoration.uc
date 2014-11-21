class SkeletalDecoration extends Engine.Actor
	placeable;

var() Name defaultAnim		"The animation that plays on the skeletal actor when it is spawned";
var() bool bLoopAnim		"Animation looping on/off";
var bool bAnimPlayed;
var Name playedAnim;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (defaultAnim == '')
		return;

	if (bLoopAnim)
	{
		LoopAnim(defaultAnim);
	}
	else
	{
		PlayAnim(defaultAnim);
	}

	bAnimPlayed = true;
}

simulated function PostLoadGame()
{
	if (!bAnimPlayed)
		return;

	if (bLoopAnim)
	{
		LoopAnim(defaultAnim);
	}
	else
	{
		if (playedAnim != '')
			PlayAnim(playedAnim);
		else
			PlayAnim(defaultAnim);

		SetAnimFrame(1.0);
	}

}

simulated function PlayScriptedAnim(name AnimToPlay)
{
	playedAnim = animToPlay;
	PlayAnim(AnimToPlay);
	bAnimPlayed = true;
}

defaultproperties
{
	Mesh		= SkeletalMesh'Editor_res.SkeletalDecoration'
	DrawType	= DT_Mesh

	defaultAnim	= Activate
	bLoopAnim	= true
	
	bCollideActors = true
	bProjTarget = true
}