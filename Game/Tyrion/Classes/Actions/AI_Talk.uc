//=====================================================================
// AI_Talk
//=====================================================================

class AI_Talk extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name lipsyncAnimName "Name of the lipsync animation to play";
var(Parameters) Name subtitleTag "The localization tag for the subtitle text of the dialogue";
var(Parameters) Name targetName "The pawn to talk to";
var(Parameters) Rotator facing "Where the AI turns to before talking if targetName is none";
var(Parameters) bool bNeedsToTurn "If true the targetName and facing values will be used";
var(Parameters) bool bPositional "Whether the sound is to be positional or 2D";
var(Parameters) bool bWaitForSpeech "Whether the action should wait till the sound has finished playing before continuing";

var(InternalParameters) editconst Pawn target;

// totally internal
var float speechDuration;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Make sure the speech stops

function cleanup()
{
	super.cleanup();

	if(! achievingGoal.wasAchieved())
		character().Level.speechManager.CancelSpeech(character());
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") is starting to talk." );
	
	// block all the character's resources
	if ( target == None && targetName != 'None')
	{
		target = Pawn(pawn.findByLabel( class'Engine.Pawn', targetName ));

		if ( target == None )
		{
			log( "AI WARNING:" @ name @ "can't find specified pawn" );
			fail( ACT_INVALID_PARAMETERS, true );
		}
	}

	if ( target != None )
		facing = Rotator(target.Location - pawn.Location);

	if ( bNeedsToTurn && resource.requiredResourcesAvailable( achievingGoal.priority, 0, 0 ) )
	{
		waitForGoal( (new class'AI_TurnGoal'( movementResource(), achievingGoal.priority, facing )).postGoal( self ), true );
	}

	useResources( class'AI_Resource'.const.RU_HEAD );
	speechDuration = pawn.Level.speechManager.PlayScriptedSpeech( pawn, lipsyncAnimName, bPositional );

	if ( bWaitForSpeech )
		sleep( speechDuration );

	// catch this here just in case
	while ( class'Pawn'.static.checkAlive( pawn ) && pawn.IsPlayingLIPSincAnim() )
		yield();

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped." );
	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_TalkGoal'
}