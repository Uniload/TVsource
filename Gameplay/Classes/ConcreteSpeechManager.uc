class ConcreteSpeechManager extends Engine.SpeechManager
	dependsOn(SpeechCategory)
	native;

import enum EChannelID from SpeechCategory;

var() config float SpeechPitch;
var() config float SpeechInnerRadius;
var() config float SpeechOuterRadius;
var() config String AnnouncerType;
var() config float VolumePriorityDisabledLagTime;
var() config float SecondsPerWord;

var transient private SpeechCategoryManager categoryManager;
var transient private Array<SpeechChannel> channels;
var transient private bool bIgnoreCategoryFrequency;

var transient private Array<string> AIVoiceSetPrecache;
var transient private Array<string> VOPrecache;

var transient noexport private const int level_padding;
var transient noexport private const int categoryMap_padding[5];
var transient noexport private const float VolumePriorityDisableTime_padding;


//
// Precaching functions
//
native simulated function PrecacheAIVoiceSet(String VoiceSetPackageName);
native simulated function PrecacheVO(String SpeechTag);

function int GetChannelID(String channelName)
{
	if(channelName ~= "Movement")
		return EChannelID.CHANNEL_Movement;
	else if(channelName ~= "Dynamic")
		return EChannelID.CHANNEL_Dynamic;
	else if(channelName ~= "Scripted")
		return EChannelID.CHANNEL_Scripted;
	else if(channelName ~= "QuickChat")
		return EChannelID.CHANNEL_QuickChat;
	else if(channelName ~= "Announcer")
		return EChannelID.CHANNEL_Announcer;

	return -1;
}

function ToggleChannelLogging(String channelName)
{
	local int channelIndex;

	channelIndex = GetChannelID(channelName);

	if(channelIndex > -1)
		channels[channelIndex].bDebugLogged = ! channels[channelIndex].bDebugLogged;
}

function ToggleChannel(String channelName)
{
	local int channelIndex;

	channelIndex = GetChannelID(channelName);

	if(channelIndex > -1)
		channels[channelIndex].bDisabled = ! channels[channelIndex].bDisabled;
}

function ToggleCategoryFrequency()
{
	bIgnoreCategoryFrequency = ! bIgnoreCategoryFrequency;
}

//
// Disable a channel
//
function DisableChannel(String channelName)
{
	local int channelIndex;

	channelIndex = GetChannelID(channelName);

	if(ChannelIndex > -1)
		channels[ChannelIndex].bDisabled = true;
}

//
// Enable a channel
//
function EnableChannel(String channelName)
{
	local int channelIndex;

	channelIndex = GetChannelID(channelName);

	if(ChannelIndex > -1)
		channels[ChannelIndex].bDisabled = false;
}

defaultproperties
{
     SpeechPitch=1.000000
     SpeechInnerRadius=1.000000
     SpeechOuterRadius=4096.000000
     AnnouncerType="Announcer5"
     VolumePriorityDisabledLagTime=1.000000
     SecondsPerWord=0.700000
}
