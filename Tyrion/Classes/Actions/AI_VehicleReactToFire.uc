//=====================================================================
// AI_VehicleReactToFire
//
// Note: This action will only be activated if the shooter isn't visible;
//       and if the shooter is friendly, will only be activated when hit
//=====================================================================

class AI_VehicleReactToFire extends AI_VehicleAction
	editinlinenew
	dependsOn(AI_ReactToFireSensor);

import enum TriggerCategories from AI_ReactToFireSensor;

//=====================================================================
// Variables

var(Parameters) float nearHitDistance "Max distance to react to near hit";
var(Parameters) float allyShotDistance "Max distance to react to an ally getting shot";

var Rook ai;						// vehicle or turret
var BaseAICharacter controllingAI;	// vehicle/turret occupant
var Rook enemy;
var TriggerCategories trigger;	// what triggered ReactToFire?
var bool bFriendly;				// was shooter a friendly?
var bool bVisible;				// is shooter visible?

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	ai = rook();

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") started." );

	// This bit of code assumes that the reactToFire action is started by the reactToFire sensor
	// (and consequently, that the sensor has meaningful values when this action runs). 
	// todo: Think of a way to formalize this dependency? The action could declare its interest in a value even though it doesn't require callbacks?)
	enemy = Rook(vehicleResource().vehicleSensorAction.reactToFireSensor.attacker);	// knowing who fired the shot is a bit a cheat, but the AI does have to spot the enemy before reacting

	if ( enemy == None )
	{
		log( "AI WARNING:" @ name $ ":" @ ai.name @ "has no enemy to react to" );
	}
	else if ( class'Pawn'.static.checkDead( enemy ) )
	{
		;	// enemy is dead
	}
	else
	{
		trigger = vehicleResource().vehicleSensorAction.reactToFireSensor.triggerCategory;
		bFriendly = ai.isFriendly( enemy );
		controllingAI = BaseAICharacter(ai.getControllingCharacter());

		if ( bFriendly )
		{
			//log( ai.name $ ": Stop shooting at me," @ enemy.name $ "! You dumbass!" );
			if ( controllingAI.scaleByWeaponRefireRate( enemy.firingMotor().getWeapon() ) )
				ai.level.speechManager.PlayDynamicSpeech( controllingAI, 'AllyHurtWeapon' );
		}
		else if ( class'Pawn'.static.checkAlive( enemy ) )
		{
			bVisible = ai.vision.isVisible( enemy );

			switch ( trigger )
			{
			case RTF_PAIN:
			case RTF_NEAR_MISS:
			case RTF_COMBAT_SOUND:
				ai.level.speechManager.PlayDynamicSpeech( controllingAI, 'SuspiciousCombat' );
				break;
			case RTF_MOVEMENT_SOUND:
				ai.level.speechManager.PlayDynamicSpeech( controllingAI, 'SuspiciousHear' );
				break;
			}

			// turn to enemy
			if ( !bVisible )
			{
				ai.firingMotor().setViewRotation( Rotator(enemy.Location - ai.Location) );
			}
		}
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleReactToFireGoal'
}