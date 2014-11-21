//=====================================================================
// AI_CivilianReactToFire
//=====================================================================

class AI_CivilianReactToFire extends AI_CharacterAction
	editinlinenew
	dependsOn(AI_ReactToFireSensor);

import enum TriggerCategories from AI_ReactToFireSensor;

//=====================================================================
// Variables

var(Parameters)	float panicChance "chance of panicking when being shot at";
var(Parameters) float nearHitDistance "Max distance to react to near hit";
var(Parameters) float allyShotDistance "Max distance to react to an ally getting shot";

var Pawn enemy;
var TriggerCategories trigger;	// what triggered ReactToFire?

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;
}

//=====================================================================
// State code

state Running
{
Begin:
	// This bit of code assumes that the reactToFire action is started by the reactToFire sensor
	// (and consequently, that the sensor has meaningful values when this action runs). 
	// todo: Think of a way to formalize this dependency? The action could declare its interest in a value even though it doesn't require callbacks?)
	enemy = characterResource().commonSenseSensorAction.reactToFireSensor.attacker;	// knowing who fired the shot is a bit a cheat, but the AI does have to spot the enemy before reacting
	trigger = characterResource().commonSenseSensorAction.reactToFireSensor.triggerCategory;

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") started." @ enemy @ trigger );

	if ( trigger != RTF_MOVEMENT_SOUND && class'Pawn'.static.checkAlive( enemy ) )
	{
		waitForGoal( (new class'AI_TurnGoal'( movementResource(), 99, Rotator(enemy.Location - pawn.Location) )).postGoal( self ), true );
	}

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_ReactToFireGoal'
}