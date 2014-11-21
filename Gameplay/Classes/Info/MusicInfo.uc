class MusicInfo extends Engine.MusicManagerBase
	placeable
	native;

var() string IntroMusic;
var() string ExplorationMusic;
var() string CombatMusic;
var() string TensionMusic;

enum EMusicType
{
	MS_NoMusic,
	MS_ExplorationMusic,
	MS_IntroMusic,
	MS_CombatMusic,
	MS_TensionMusic,
};

struct native DynamicMusicOptions
{
	var() float FadeInTime;
	var() float FadeOutTime;
	var() float MinLifetime;
};

// ug hacky. seeing as we only have 2 dynamic music types, dont bother generalisin this into an array or anythin
var() DynamicMusicOptions	CombatMusicOptions;
var() DynamicMusicOptions	TensionMusicOptions;
var() float					IntroMusicFadeOutTime;

// state
var EMusicType			CurrentMusicType;
var float				CurrentSongTimer;		// if non zero, countdown to when we should start fading out the current song
var float				CurrentSongFadeTime;	// time to fade out the current song over (when CurrentSongTimer has elapsed)
var bool				TriggeredIntroMusic;	// just to make sure we onyl do it once

// transient (within sound system)
var transient float		CurrentMusicLength;
var transient int		CurrentSongHandle;

simulated function Tick(float Delta)
{
	// restart music from savegame (music type is set, but we dont have a valid handle)
	if (CurrentMusicType != MS_NoMusic && !PlayingMusic())
		RestartSavegameMusic();

	// start intro/level music
	if (CurrentMusicType == MS_NoMusic)
	{
		if (Len(IntroMusic) != 0 && !TriggeredIntroMusic)
			TriggerIntroMusic();
		
		// if intro music not started (not specified, play failed or already triggered), start normal level music
		if (!PlayingMusic())
			StartMusicType(MS_ExplorationMusic, 0);
	}

	// handle fade out of current music
	if (ShouldProcessFadeOut())
	{
		CurrentSongTimer -= Delta;
		// song timer expired, transition to explotation music
		if (CurrentSongTimer <= 0)
			StartMusicType(MS_ExplorationMusic, CurrentSongFadeTime);
	}
}

simulated function TriggerIntroMusic()
{
	StartMusicType(MS_IntroMusic, 0);

	CurrentSongFadeTime = IntroMusicFadeOutTime;
	CurrentSongTimer = CurrentMusicLength - IntroMusicFadeOutTime;
	
	TriggeredIntroMusic = true;
}

simulated function TriggerDynamicMusic(EDynamicMusicType Type)
{
	switch(Type)
	{
	case MT_Combat:
		ProcessDynamicMusic(MS_CombatMusic, CombatMusic, CombatMusicOptions.FadeInTime, 
				CombatMusicOptions.FadeOutTime, CombatMusicOptions.MinLifeTime);
		break;
		
	case MT_Tension:
		// NOTE: tension should not override combat music
		if (CurrentMusicType != MS_CombatMusic)
			ProcessDynamicMusic(MS_TensionMusic, TensionMusic, TensionMusicOptions.FadeInTime, 
					TensionMusicOptions.FadeOutTime, TensionMusicOptions.MinLifeTime);
		break;
	}
}

simulated function TriggerScriptMusic(string MusicName, float FadeTime)
{
	// TBD: do we need this anymore???
}

// NOTE: MusicName is only passed in so that this funciton can validate whether to even try playing music (incase none is specified)
simulated function ProcessDynamicMusic(EMusicType MusicType, string MusicName, float FadeInTime, float FadeOutTime, float MinLifeTime)
{
	if (CurrentMusicType != MusicType && Len(MusicName) != 0)
	{
		StartMusicType(MusicType, FadeInTime);
		CurrentSongFadeTime = FadeOutTime;
	}
		
	// restart music timer if succsefully playing
	if (CurrentMusicType == MusicType)
		CurrentSongTimer = MinLifeTime;
}

simulated function bool ShouldProcessFadeOut()
{
	return PlayingMusic() && ( CurrentMusicType == MS_IntroMusic || CurrentMusicType == MS_CombatMusic || CurrentMusicType == MS_TensionMusic);
}

simulated function bool PlayingMusic()
{
	return CurrentSongHandle != 0;
}

simulated function RestartSavegameMusic()
{
	// dont re-play intro music when loading a saved game
	if (CurrentMusicType == MS_IntroMusic)
		CurrentMusicType = MS_ExplorationMusic;

	StartMusicType(CurrentMusicType, 0);	
}

simulated function StartMusicType(EMusicType Music, float FadeTime)
{
	switch (Music)
	{
	case MS_ExplorationMusic:	StartMusic(ExplorationMusic, FadeTime); break;
	case MS_IntroMusic:			StartMusic(IntroMusic, FadeTime); break;
	case MS_CombatMusic:		StartMusic(CombatMusic, FadeTime); break;
	case MS_TensionMusic:		StartMusic(TensionMusic, FadeTime); break;
	};

	if (PlayingMusic())
		CurrentMusicType = Music;
	else
		CurrentMusicType = MS_NoMusic;
}

simulated function StartMusic(string MusicName, float FadeTime)
{
	// stop old music
	StopCurrentMusic(FadeTime);

	// startup new music
	CurrentSongHandle = PlayMusic(MusicName, FadeTime);
	if (CurrentSongHandle != 0)
	{
		CurrentMusicLength = GetMusicDuration(MusicName);
	}
	else
	{
		CurrentMusicLength = 0;
	}

//	log("Start Music on "$MusicName$"     Length = "$CurrentMusicLength$"  FadeTime = "$FadeTime);
}

// NOTE!: this function will only work if the music is playing in the sound system
native function float GetMusicDuration(string MusicName);

simulated function StopCurrentMusic(float FadeTime)
{
	if (CurrentSongHandle != 0)
	{
		StopMusic(CurrentSongHandle, FadeTime);
	}

	CurrentSongHandle = 0;
	CurrentMusicType = MS_NoMusic;
}

defaultproperties
{
	CurrentMusicType	= MS_NoMusic
	CurrentSongHandle	= 0
	CurrentSongTimer	= 0
	TriggeredIntroMusic = 0
}