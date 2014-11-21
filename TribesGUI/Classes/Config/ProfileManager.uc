//
// class: ProfileManager
//
// Manages player profiles, adding, deleting, saving, loading etc.
//

class ProfileManager extends Core.Object
	native
	transient;

var private config String			activeProfileName;
var private int						nextProfileNumber;

var private PlayerProfile			defaultProfile;
var private Array<PlayerProfile>	profiles;
var private int						activeProfileIndex;

var private GUIController			controller;

native function LoadProfiles(GUIController gc);
native function bool DeleteProfile(PlayerProfile profile);

function PlayerProfile GetDefaultProfile()
{
	return defaultProfile;
}

//
// Gets the active profile
//
simulated function PlayerProfile GetActiveProfile()
{
	local int i;

	if(activeProfileIndex < profiles.Length && String(profiles[activeProfileIndex].Name) != activeProfileName)
	{
		for(i = 0; i < profiles.Length; ++i)
		{
			if(String(profiles[i].Name) == activeProfileName)
			{
				SetActiveProfile(profiles[i]);
				break;
			}
		}
	}


	return profiles[activeProfileIndex];
}

//
// Sets the active profile. If the profile cannot be
// found in the list of profiles it is added automatically
//
simulated function bool SetActiveProfile(PlayerProfile newActiveProfile)
{
	local int i;

	for(i = 0; i < profiles.Length; ++i)
	{
		if(profiles[i] == newActiveProfile)
		{
			activeProfileName = String(newActiveProfile.Name);
			activeProfileIndex = i;
			SaveConfig();
			return true;
		}
	}

	return false;
}

//
// Gets the number of profiles in the list
//
simulated function int NumProfiles()
{
	return profiles.Length;
}

//
// Gets a profile index by object.
//
simulated function int GetProfileIndex(PlayerProfile profile)
{
	local int i;

	for(i = 0; i < profiles.Length; i++)
		if(profiles[i] == profile)
			return i;

	return -1;
}

//
// HasProfile - returns whether the manager has a profile
//
simulated function bool HasProfile(out String playerName)
{
	local int i;

	for(i = 0; i < profiles.Length; i++)
		if(profiles[i].PlayerName ~= playerName)
		{
			playerName = profiles[i].PlayerName;
			return true;
		}

	return false;
}

//
// Gets a profile index by object.
//
simulated function int GetProfileIndexByPlayerName(String playerName)
{
	local int i;

	for(i = 0; i < profiles.Length; i++)
		if(profiles[i].PlayerName == playerName)
			return i;

	return -1;
}

//
// Gets a profile index by object.
//
simulated function PlayerProfile GetProfileByName(String playerName)
{
	local int i;

	for(i = 0; i < profiles.Length; i++)
		if(profiles[i].PlayerName == playerName)
			return profiles[i];

	return None;
}

//
// Gets a profile by index.
//
simulated function PlayerProfile GetProfile(int index)
{
	if(profiles.Length > index)
		return profiles[index];

	return None;
}

//
// Creates a new profile, adds it to the list and returns it.
//
simulated event PlayerProfile NewActiveProfile(String newProfileName, optional String baseProfileName, optional bool bReadOnly)
{
	local PlayerProfile profile;
	local int i;
	
	for(i = 0; i < profiles.Length; i++)
	{
		if(profiles[i].PlayerName ~= newProfileName)
			return profiles[i];
	}

	profile = new(None, "PlayerProfile"$nextProfileNumber++) class'PlayerProfile';
	profile.LoadProfileData(baseProfileName);
	profile.playerName = newProfileName;
	profile.controller = controller;
	profile.bReadOnly = bReadOnly;
	profile.Store();

	profiles[profiles.Length] = profile;
	SetActiveProfile(profile);

	return profile;
}

simulated function String GetURLOptions(optional string originalURL)
{
	if(GetActiveProfile() != None)
		return GetActiveProfile().GetURLOptions(originalURL);
	else
		return "Name=Player?IsFemale=false";
}

simulated function Store()
{
	local int i;

	SaveConfig();

	for(i = 0; i < profiles.Length; i++)
	{
		profiles[i].Store();
	}
}
