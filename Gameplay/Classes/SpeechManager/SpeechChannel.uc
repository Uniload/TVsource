class SpeechChannel extends Core.Object
	native;

enum ESubtitleType
{
	SUBTITLE_None,
	SUBTITLE_Cutscene,
	SUBTITLE_Announcer
};

var int						id;				///< ID of the channel
var config int				maxSounds;		///< Maximum number of sounds for this channel
var config int				priority;		///< priority of this channel
var config bool				bStreamed;		///< streamed files
var config bool				bLifo;			///< Last sound requested will always be played immediately
var Array<SpeakerRecord>	speechList;		///< list of currently playing sounds in the channel
var ConcreteSpeechManager	speechManager;	///< Speech manager which this Channel belongs to
var float					SpeechVolume;	///< Volume settings for this channel

var bool					bDebugLogged;	///< whether the channel logs debug messages
var bool					bDisabled;		///< whether the channel is disabled

CPPTEXT
{
	///
	/// Plays speech in the channel
	///
	FLOAT PlaySpeech(FSpeakerRef speaker, FString speechName, FString packageName, FString basePath = TEXT(""), ESubtitleType subtitleType = SUBTITLE_None, USpeechCategory* category = NULL, UBOOL bPositional = true);

	///
	/// Finds a speaker record, if it exists, within the list of currently active
	/// speech objects. Returns the located record or NULL if one is not found
	///
	USpeakerRecord* FindSpeakerRecord(FSpeakerRef speaker);

	///
	/// Cancels a currently playing speaker record.
	///
	void CancelSpeech(USpeakerRecord *record, UBOOL killSound = 1);

	///
	/// Cancels all currently playing speech in the channel.
	///
	void CancelAllSpeech();

	///
	/// Updates the channel
	///
	void Tick(FLOAT dt);
}

defaultproperties
{
	SpeechVolume=1.0
	maxSounds=5
	bStreamed=true
	bLifo=false
}