class SpeechManager extends Core.Object
	abstract
	native;


//
// PlayDynamicSpeech 
//
native function float PlayDynamicSpeech(Pawn speaker, Name event, optional Actor Instigator, optional Actor Other, optional String extraKey);

//
// PlayQuickChatSpeech 
//
native function float PlayQuickChatSpeech(PlayerReplicationInfo speaker, String VoiceSetPackageName, Name event, optional Pawn cSpeaker);

//
// PlayScriptedSpeech 
//
native function float PlayScriptedSpeech(Pawn speaker, Name event, bool bPositional);

//
// PlayAnnouncerSpeech
//
native function float PlayAnnouncerSpeech(Name event, optional Actor Instigator, optional Actor Other, optional String VoiceSetPackageName);

//
// PlayMovementSpeech
//
native function float PlayMovementSpeech(Pawn Speaker, Name event);

//
// CancelSpeech
//
native function float CancelSpeech(Pawn speaker);

//
// Disable a channel
//
function DisableChannel(String channelName);

//
// Enable a channel
//
function EnableChannel(String channelName);

//
// Precaching functions
//
simulated function PrecacheAIVoiceSet(String VoiceSetPackageName);
simulated function PrecacheVO(String SpeechTag);

defaultproperties
{
}
