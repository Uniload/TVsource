class MPTeamScoreDecoration extends Engine.Actor
	placeable;

var() Name				defaultAnim				"The animation that plays on the actor when it is spawned";
var() bool				bLoopAnim				"Animation looping on/off";
var() Name				teamScoreAnim			"The animation that plays on the actor when a team scores.  Loops for decorateTime seconds.";
var() float				decorateTime			"The lenght of time that effects and animations will be played when a team scores.";
var() Name				teamScoreEffectEvent	"An effect event that gets triggered once when a team scores";
var() Name				teamScoreEffectEventLoop "An effect event that loops for decorateTime seconds when a team scores";
var() MaterialSwitch	teamScoreMaterialSwitch	"An optional MaterialSwitch that switches for decorateTime seconds when a team scores";
var() int				teamScoreMaterialSwitchIndex "The MaterialSwitch index to set when switching.  Switches back to 0 after decorateTime seconds";

var bool	bTeamScored;
var bool	bLocalTeamScored;

replication
{
	reliable if (Role == ROLE_Authority)
		bTeamScored;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	playIdleAnimation();

	if (Level.NetMode != NM_Client)
	{
		registerMessage(class'MessageTeamScored', "All");
	}
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	updateDecorationEffects();
}

// onMessage
function onMessage(Message msg)
{
	if (MessageTeamScored(msg) != None)
	{
		bTeamScored = true;

		updateDecorationEffects();
		SetTimer(decorateTime, false);
	}
}

simulated function playIdleAnimation()
{
	if (defaultAnim == '' || !hasAnim(defaultAnim))
		return;

	if (bLoopAnim)
	{
		LoopAnim(defaultAnim);
	}
	else
	{
		PlayAnim(defaultAnim);
	}
}

simulated function updateDecorationEffects()
{
	if (bLocalTeamScored != bTeamScored)
	{
		bLocalTeamScored = bTeamScored;

		if (!bTeamScored)
		{
			if (teamScoreEffectEventLoop != '')
				UnTriggerEffectEvent(teamScoreEffectEventLoop);

			if (teamScoreMaterialSwitch != None)
				teamScoreMaterialSwitch.set(0);

			playIdleAnimation();
		}
		else
		{
			if (teamScoreEffectEventLoop != '')
				TriggerEffectEvent(teamScoreEffectEventLoop);

			if (teamScoreEffectEvent != '')
				TriggerEffectEvent(teamScoreEffectEvent);

			if (teamScoreMaterialSwitch != None)
				teamScoreMaterialSwitch.set(teamScoreMaterialSwitchIndex);

			if (teamScoreAnim != '' && hasAnim(teamScoreAnim))
				LoopAnim(teamScoreAnim);
		}
	}
}

function Timer()
{
	bTeamScored = false;

	updateDecorationEffects();
}

defaultproperties
{
	bCollideActors = true
	bProjTarget = true
	bNetNotify = true

	decorateTime					= 5
	teamScoreEffectEvent			= teamScored 
	teamScoreEffectEventLoop		= teamScoredLoop
	teamScoreMaterialSwitchIndex	= 1

}