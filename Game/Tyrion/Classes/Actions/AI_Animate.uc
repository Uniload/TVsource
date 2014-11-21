//=====================================================================
// AI_Animate
//=====================================================================

class AI_Animate extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name animName "Name of the animation to play";
var(Parameters) int numIterations "The number of times the animation should loop, 0 means until the goal is unposted";
var(Parameters) Name targetName "The pawn to turn towards before animating";
var(Parameters) Rotator facing "Where the AI turns to before animating if targetName is none";
var(Parameters) bool bNeedsToTurn "If true the targetName and facing values will be used";
var(Parameters) bool bFreezeMovement "If true the target will not move while playing the animation";

var(InternalParameters) editconst Actor target;

var int i;
var Character c;
var bool didAnimate;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Make sure the animation stops

function cleanup()
{
	super.cleanup();

	if ( wasTicked() && didAnimate )
	{
		c = Character(pawn);

		if (c != None)
		{
			c.StopAnimation();
			c.movementFrozen = false;
		}
		else
			pawn.StopAnimating();
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") is starting to animate." );
	
	if ( !pawn.HasAnim( animName ) )
	{
		log( "AI_WARNING:" @ name $ "(" @ pawn.name @ ") does not have an animation named" @ animName );

		fail( ACT_GENERAL_FAILURE, true );
	}

	if ( target == None && targetName != 'None')
	{
		target = pawn.findStaticByLabel( class'Engine.Actor', targetName );

		if ( target == None )
		{
			log( "AI WARNING:" @ name @ "(" @ pawn.name @ ") can't find specified actor" );
			fail( ACT_INVALID_PARAMETERS, true );
		}
	}

	if ( target != None )
		facing = Rotator(target.Location - pawn.Location);

	if ( bNeedsToTurn && resource.requiredResourcesAvailable( achievingGoal.priority, 0, 0 ) )
	{
		waitForGoal( (new class'AI_TurnGoal'( movementResource(), achievingGoal.priority, facing )).postGoal( self ), true );
	}

	c = Character(pawn);

	if ( numIterations > 0 )
	{
		for ( i = 0; i < numIterations; ++i )
		{
			if (class'Pawn'.static.checkDead(pawn))
				break;

			if (c != None)
			{
				c.movementFrozen = bFreezeMovement;
				c.playAnimation( String(animName) );
				didAnimate = true;
				while( c.isPlayingAnimation() )
				{
					yield();
				}
			}
			else
			{
				pawn.PlayAnim( animName );
				didAnimate = true;
				pawn.FinishAnim();
			}
		}
	}
	else
	{
		if (c != None)
		{
			c.movementFrozen = bFreezeMovement;
			c.LoopAnimation( String(animName) );
			didAnimate = true;

			while ( true )
			{
				if ( !c.isLoopingAnimation() )
					c.LoopAnimation( String(animName) );
				
				yield();
			}
		}
		else
		{
			pawn.LoopAnim( animName );
			didAnimate = true;

			while ( true )
			{
				if ( !pawn.IsAnimating() ) 
					pawn.LoopAnim( animName );
				
				yield();
			}
		}
	}

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	resourceUsage = 0
	satisfiesGoal = class'AI_AnimateGoal'
}