
class SpeechCategory extends Core.Object
	native
	config(SpeechCategories)
	PerObjectConfig;

//
// These are declared out in order of increasing 
// priority, so the dynamic speech is of a lower priority
// than the QuickChat, etc.
//
enum EChannelID
{
	CHANNEL_Movement,
	CHANNEL_Dynamic,
	CHANNEL_QuickChat,
	CHANNEL_Announcer,
	CHANNEL_Scripted,
	MAX_CHANNELS
};

cpptext
{

	void BuildTagFileMap();
	void PoolByKey(const FString &base, TArray<FString*> &speechPool, const FString &KeyString, const FString &KeyString2 = FString(TEXT("")));
	FString PoolAndSelect(ACharacter *speaker, AActor* Instigator, AActor* Other, FString extraKey);

private:

	TMultiMap<FName, FString*> speechPoolMapping;
}

var config Name			eventName;
var config float		priority;
var config float		frequency;
var config EChannelID	channelID;
var config bool			exclusive;
var config float		lingerDuration;

var config bool		bHasSquadCondition;

struct native SpeechPoolMap
{
	var Name	Tag;
	var String	File;
};

// Array of mappings from speechEvents to files
var config Array<SpeechPoolMap>	poolMap;

// match up the native class size to the script one (TMultiMap is 20 bytes)
var transient noexport private const int speechPoolMapping_SizePadding[5];

defaultproperties
{
	eventName="Event"
	priority=1
	channelID=CHANNEL_Dynamic
	exclusive=false
	frequency=0.3
	bHasSquadCondition=true
	lingerDuration=0.0
}