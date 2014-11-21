class SpeakerRecord extends Core.Object
	native;

// this encapsulates the reference to the speaking character, which 
// we use to avoid the same character speaking two lines at once.
struct native SpeakerRef
{
	var Character				character;
	var PlayerReplicationInfo	PRI;
	var bool					bAnnouncer;
};

var SpeakerRef			speaker;
var SpeechCategory		category;
var Sound				speechSound;
var String				speechName;
var INT					channelID;
var INT					soundID;
var INT					priority;
var INT					flags;
var FLOAT				duration;
var FLOAT				currentDuration;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{

	inline UBOOL operator==(USpeakerRecord other)
	{ 
		if( (speaker.bAnnouncer && other.speaker.bAnnouncer) ||									// both announcer
			((speaker.PRI != NULL) && (speaker.PRI == other.speaker.PRI)) ||					// same PRI
			((speaker.Character != NULL) && (speaker.Character == other.speaker.Character)) )	// same character
				return true;

		return false;
	}

	inline UBOOL operator!=(USpeakerRecord other)
	{ 
		if((speaker.bAnnouncer && other.speaker.bAnnouncer) ||									// both announcer
			((speaker.PRI != NULL) && (speaker.PRI == other.speaker.PRI)) ||					// same PRI
			((speaker.Character != NULL) && (speaker.Character == other.speaker.Character)) )	// same character
				return false;

		return true;
	}

}


defaultproperties
{
     channelID=-1
     soundID=-1
     duration=3.000000
}
