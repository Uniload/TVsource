class MusicManagerBase extends Info
	abstract
	native;

enum EDynamicMusicType
{
	MT_None,
	MT_Combat,
	MT_Tension,
};

simulated function PostBeginPlay()
{
	// register ourselves with the levelinfo
	Level.MusicMgr = self;
}

simulated function TriggerIntroMusic();
simulated function TriggerDynamicMusic(EDynamicMusicType Type);
simulated function TriggerScriptMusic(string MusicName, float FadeTime);