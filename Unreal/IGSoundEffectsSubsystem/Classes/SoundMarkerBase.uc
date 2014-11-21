class SoundMarkerBase extends Engine.Actor
    native
    abstract;

var private bool QueuedTillStartup;
var private bool GameStarted;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    RegisterNotifyGameStarted();

}

simulated function OnGameStarted()
{
    GameStarted = true;
    if ( QueuedTillStartup )
    {
        log( "Sound is queued and played in "$Self );
        PlayEffects();
    }
}

simulated event Touch (Actor Other)
{
	Super.Touch (Other);

	if (Other.IsA('Pawn') && Pawn(Other).IsPlayerPawn())
	{
        if ( GameStarted ) 
            PlayEffects();
        else
            QueuedTillStartup = true;
    }
}

simulated function PlayEffects();