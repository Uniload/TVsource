//=====================================================================
// AI_EnemySensor
// Keeps tracks of this pawn's enemies
// Value (int): number of enemies visible
//=====================================================================

class AI_EnemySensor extends AI_Sensor implements IVisionNotification, Engine.IInterestedTeamChanged;

//=====================================================================
// Constants

const MAX_GREETING_ANIMATION_DISTANCE = 1000.0f;
const MAX_ALLYKILLED_DIST = 3000.0f;

//=====================================================================
// Variables

var array<Pawn> enemies;						// the enemies this AI is currently worrying about
var Rook lastSeen;								// last rook spotted (cleared if a pawn is lost)
var Rook lastLost;								// last rook lost (cleared if a pawn is spotted)
var Rook player;								// points to the player character if s/he is an enemy and visible (None otherwise)
												// If several players are present, the first one spotted is stored until it dies/vanishes; then it can be replaced 

//=====================================================================
// Functions

//---------------------------------------------------------------------
// convenience function to set all the variables (and the sensor value itself)

function setValue( Rook aLastSeen, Rook aLastLost )
{
	lastSeen = aLastSeen;
	lastLost = aLastLost;
	setIntegerValue( enemies.length );
}

//---------------------------------------------------------------------
// Initialize set the sensor's parameters
// (only used to ensure that a message is sent when sensor is first started up)

function setParameters()
{
	setValue( None, None );
}

//---------------------------------------------------------------------
// vision callbacks

function OnViewerSawPawn(Pawn Viewer, Pawn Seen)
{
	local int i;
	local Rook rookViewer, rookSeen;

	//log( "OnViewerSawPawn called on" @ sensorAction.resource.localRook().name @ "for" @ Seen.name ); 

	rookViewer = Rook(Viewer);
	rookSeen = Rook(Seen);

	// debug only
	if ( Viewer == None || AI_Controller(Viewer.Controller) == None )
	{
		if ( Viewer == None )
			log( "AI WARNING: Viewer is None in" @ name @ "(" @ sensorAction.resource.name @ sensorAction.resource.localRook() @ ")" );
		else
			log( "AI WARNING:" @ Viewer.name @ "has a" @ Viewer.Controller @ "instead of an AI_Controller" );
		return;
	}

	if ( !rookViewer.isFriendly( rookSeen ) )
	{
		for ( i = 0; i < enemies.length; i++ )
			if ( enemies[i] == Seen )
				return;

		if ( rookViewer.getAlertnessLevel() == ALERTNESS_Neutral &&
			rookViewer.IsA( 'Character' ) &&
			rookViewer.vision.isLocallyVisible( Seen ))
		{
			Character(rookViewer).playAnimation( "AI_spotEnemy" );	// todo: move this to a separate action so I can turn and stuff
		}

		if ( player == None && rookSeen.Controller != None && rookSeen.Controller.bIsPlayer )
			player = rookSeen;

		AI_Controller(Viewer.controller).setAlertnessLevel( ALERTNESS_Alert );

		enemies[enemies.length] = Seen;
		//log( "==> Adding" @ Seen.name @ "to enemySensor of" @ sensorAction.resource.localRook().name @ "(length:" @ enemies.length $ ")" ); 
		setValue( rookSeen, None );
	}
	else if ( rookViewer.getAlertnessLevel() == ALERTNESS_Neutral && 
				VDistSquared( Viewer.Location, Seen.Location ) < MAX_GREETING_ANIMATION_DISTANCE * MAX_GREETING_ANIMATION_DISTANCE &&
				rookViewer.IsA( 'Character' ) &&
				rookViewer.vision.isLocallyVisible( Seen ))
	{
		if ( Viewer.logTyrion )
			log( "Animation:" @ Viewer.name @ "spotted friendly" @ Seen.name );
		Character(rookViewer).playAnimation( "AI_spotFriendly" );
	}
}

function OnViewerLostPawn(Pawn Viewer, Pawn Seen)
{
	local int i;

	if ( player == Seen )
		player = None;

	// for now: forget about opponents that can't be seen
	for( i = 0; i < enemies.length; i++ )
		if ( enemies[i] == Seen )
		{
			enemies.remove( i, 1 );	// removes element - shifts the rest
			//log( "<== Removing" @ Seen.name @ "from enemySensor of" @ sensorAction.resource.localRook().name @ "(length:" @ enemies.length $ ")" ); 
			setValue( None, Rook(Seen) );
			break;
		}

	// send AllyKilled message?
	if ( class'Pawn'.static.checkDead( Seen ) &&
		VDistSquared( Viewer.Location, Seen.Location ) <= MAX_ALLYKILLED_DIST * MAX_ALLYKILLED_DIST &&
		Rook(Viewer).isFriendly( Rook(Seen) ) &&
		!Viewer.IsA( 'AICivilian' ))
	{
		Viewer.level.speechManager.PlayDynamicSpeech( Viewer, 'AllyKilled', None, Vehicle(Seen) );
	}
}

//---------------------------------------------------------------------
// called whenever a rook changes team

function onTeamChanged( Pawn changedPawn )
{
	local Rook changedRook;
	local Rook me;

	me = sensorAction.resource.localRook();
	changedRook = Rook(changedPawn);

	//log( "onTeamChanged called on" @ me.name @ "because" @ changedPawn.name @ "changed team" );

	if ( changedRook == me )
	{
		initEnemiesList( me );
		setValue( None, None );		// send sensor message
	}
	else if ( me.isFriendly( changedRook ) )
		OnViewerLostPawn( me, changedRook );
	else if ( me.vision != None && me.vision.isVisible( changedRook ) )
		OnViewerSawPawn( me, changedRook );
}

//---------------------------------------------------------------------
// initialize enemies list

private function initEnemiesList( Rook me )
{
	local int i;
	local Rook squadMember;

	enemies.length = 0;		// clear enemies list
	player = None;

	if ( me.squad() == None )
		initEnemiesListFromMember( me, me );
	else
	{
		for ( i = 0; i < me.squad().pawns.length; ++i )
		{
			squadMember = Rook(me.squad().pawns[i]);
			if ( class'Pawn'.static.checkAlive( squadMember ) )
				initEnemiesListFromMember( me, squadMember );
		}
	}
}

private function initEnemiesListFromMember( Rook me, Rook squadMember )
{
	local int i;
	local int outi;
	local Rook seenRook;
	local array<Rook> enemyList;

	enemyList = squadMember.vision.getEnemyList();

	for ( i = 0; i < enemyList.length; ++i )
	{
		seenRook = enemyList[i];
		//log( "initEnemies:" @ me.name @ seenRook.name );
		if ( !isInEnemiesList( outi, seenRook ) )
		{
			if ( player == None && seenRook.Controller != None && seenRook.Controller.bIsPlayer )
				player = seenRook;
			enemies[enemies.length] = seenRook;
		}
	}
}

//---------------------------------------------------------------------
// is 'rook' in the enemies list? If yes, return index (index is undefined otherwise)

private function bool isInEnemiesList( out int i, Rook rook )
{
	for( i = 0; i < enemies.length; i++ )
		if ( enemies[i] == rook )
			return true;
	
	i = -1;
	return false;
}

//---------------------------------------------------------------------
// perform sensor-specific startup initializations when sensor is activated

function begin()
{
	local Rook rook;

	rook = sensorAction.resource.localRook();
	//log( "EnemySensor started on" @ sensorAction.resource.name @ sensorAction.resource.localRook().name );

	initEnemiesList( rook );
	rook.RegisterVisionNotification( self );
	rook.level.registerNotifyTeamChanged( self );
}

//---------------------------------------------------------------------
// perform sensor-specific cleanup when sensor is deactivated

function cleanup()
{
	local Rook rook;

	rook = sensorAction.resource.localRook();

	if ( rook == None )
	{
		log( "AI ERROR:" @ name @ "has no attached rook; can't unregister vision notification" );
	}
	else
	{
		//log( name @ rook.name @ "UNREGISTERING VISION" );
		rook.UnregisterVisionNotification( self );
		rook.level.unRegisterNotifyTeamChanged( self );
	}
}

//=====================================================================

defaultproperties
{
	bNotifyIfResourceInactive = true	// vision based sensors have to pass through pawn lost messages when vision shuts down
}