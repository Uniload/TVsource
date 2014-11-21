//
// class: PlayerProfile
//
// Models data for multiplayer profile settings. Handles interfaces for saving, 
// loading and deleting MP profiles.  An MP profile includes: name, sex, voice set, 
// skin, equipment loadouts, and possibly GameSpy login information.
//
class PlayerProfile extends Core.Object
	native
	transient
	EditInlineNew
	dependsOn(CustomPlayerLoadout);

struct native LoadoutSlot
{
	var() config String			loadoutName;
	var() config String			combatRoleClassName;
	var() config String			packClassName;
	var() config String			grenadeClassName;
	var() config Array<String>	weaponClassNameList;
	var() config bool			occupied;
	var() config Array<CustomPlayerLoadout.SkinPreferenceMapping>	skinPreferences;
};

struct native AutoLoginInfo
{
	var() config string IP;
	var() config string Port;
	var() config string Username;
	var() config string Password;
	var() config bool   bAutologin;
};

var(Profile) config bool bStoreLogins;
var(Profile) config array<AutoLoginInfo> LoginHistory;

struct native ServerFavorite
{
	var() config string IP;
	var() config string Port;
};

var(Profile) config array<ServerFavorite> serverFavorites;

var(Profile) config String	playerName	"Name of the Player";
var(Profile) config bool	bIsFemale	"Whether the player is female";
var(Profile) config String	voiceSet	"Voice set the player uses";
var(Profile) config String	skinName	"Player skin";

var(Profile) config Array<LoadoutSlot>	loadoutSlots;
var(Profile) config LoadoutSlot			activeLoadoutSlot;
var(Profile) config Array<String>		buddyList;

var(Profile) config bool	bReadOnly;
var(Profile) config bool	bShownMPHelp;

var(Profile) config bool	bUseStatTracking;
var(Profile) config bool	bSaveStatTrackingPassword;
var(Profile) config string	statTrackingNick;
var(Profile) config string	statTrackingEmail;
var(Profile) config string	statTrackingPassword;
var			 config int		statTrackingID; // 0 if none / not resolved

var(Profile) config bool	bUseTeamAffiliation;
var(Profile) config bool	bSaveTeamPassword;
var			 config int		affiliatedTeamId;
var(Profile) config string	affiliatedTeamTag;
var(Profile) config string	affiliatedTeamName;
var(Profile) config string	affiliatedTeamPassword;

var(Profile) config string	ownedTeamTag;
var(Profile) config string	ownedTeamName;

var private Array<CustomPlayerLoadout>	loadouts;
var private CustomPlayerLoadout			activeLoadout;

var GUIController	controller;
var private String	configFilePath;

cpptext
{

	// loads the profile data
	void LoadProfileData(UGUIController* gc);

}

native function LoadProfileData(String profileName);

simulated function Store()
{
	local int i;

	if (bReadOnly)
		return;

	if (!bSaveStatTrackingPassword)
		statTrackingPassword = "";

	if (!bSaveTeamPassword)
		affiliatedTeamPassword = "";

	if(configFilePath == "")
		configFilePath = "Profiles\\"$Name;

	for(i = 0; i < loadouts.Length; ++i)
		SlotFromLoadout(loadouts[i], loadoutSlots[i]);
	if(activeLoadout != None)
		SlotFromLoadout(activeLoadout, activeLoadoutSlot);

	SaveConfig( , configFilePath);
}

simulated function CustomPlayerLoadout GetLoadoutAutoCreate(int slot)
{
	local CustomPlayerLoadout loadout;
	local string newName;

	if(loadouts.Length <= slot || loadouts[slot] == None)
	{
		newName = self.Name$"Loadout"$slot;
		loadout = new(None, newName) class'CustomPlayerLoadout';
		AddLoadout(loadout, slot);
	}
	else
	{
		loadout = loadouts[slot];
	}

	return loadout;
}


simulated private function AddLoadout(out CustomPlayerLoadout loadout, int slot)
{
	if(loadouts.Length <= slot)
		loadouts.Length = slot + 1;
	loadouts[slot] = loadout;

	if(loadoutSlots.Length <= slot)
		loadoutSlots.Length = slot + 1;

//	if(loadoutSlots[slot].occupied == true)
//	{
		// occupied slot, load the loadout from the slot
		LoadoutFromSlot(loadoutSlots[slot], loadout);
//	}	
}

simulated function CustomPlayerLoadout GetActiveLoadout()
{
	if(activeLoadout == None && activeLoadoutSlot.occupied == true)
	{
		// the active loadout slot is occupied:
		activeLoadout = new class'CustomPlayerLoadout';
		LoadoutFromSlot(activeLoadoutSlot, activeLoadout);
	}

	return activeLoadout;
}

simulated function SetActiveLoadout(CustomPlayerLoadout loadout)
{
	if(activeLoadout == loadout)
		return;

	if(activeLoadout != None)
	{
		activeLoadout = None;
	}

	activeLoadout = loadout;
	SlotFromLoadout(activeLoadout, activeLoadoutSlot);
}

simulated function CustomPlayerLoadout GetLoadout(int slotIndex)
{
	local CustomPlayerLoadout loadout;

	if((slotIndex >= loadouts.Length || loadouts[slotIndex] == None) &&
		(slotIndex < loadoutSlots.Length/* && loadoutSlots[slotIndex].occupied == true*/))
	{
		// if we auto create here, we know we will get a valid loadout, 
		// because the slot is occupied
		loadout = GetLoadoutAutoCreate(slotIndex);
	}
	else if(slotIndex < loadouts.Length)
		loadout = loadouts[slotIndex];

	return loadout;
}

simulated function String GetURLOptions(optional string originalURL)
{
	local string AdminURL, CurrentIP, CurrentPort;
	local int i;

	Div(originalURL, ":", CurrentIP, CurrentPort);

	i = FindCredentials(CurrentIP, CurrentPort);
	if (i != -1 && LoginHistory[i].bAutoLogin)
	{
		AdminURL = "?AdminName="$LoginHistory[i].UserName$"?Password="$LoginHistory[i].Password;
		Log("SET ADMIN URL to "$AdminURL);
	}

	// originalURL contains the server IP address and port
	return "Name=" $EncodeForURL(PlayerName)
			$"?IsFemale=" $bIsFemale 
			$"?VoiceSet=" $voiceSet
			$AdminURL;
}

simulated function SlotFromLoadout(CustomPlayerLoadout loadout, out LoadoutSlot newSlot)
{
	local int i;

	if(loadout == None)
	{
		// no loadout == unoccupied slot
		newSlot.occupied = false;
		return;
	}

	newSlot.occupied = true;
	newSlot.loadoutName = loadout.loadoutName;
	newSlot.skinPreferences = loadout.skinPreferences;
	if(newSlot.loadoutName == "")
		newSlot.loadoutName = "Loadout";
	if(loadout.combatRoleClass != None)
		newSlot.combatRoleClassName = String(loadout.combatRoleClass.Outer.Name)$"."$String(loadout.combatRoleClass.Name);
	else
		log("Warning: CombatRoleClass was none for loadout "$loadout);
	if(loadout.packClass != None)
		newSlot.packClassName = String(loadout.packClass.Outer.Name)$"."$String(loadout.packClass.Name);
	if(loadout.grenades.grenadeClass != None)
		newSlot.grenadeClassName = String(loadout.grenades.grenadeClass.Outer.Name)$"."$String(loadout.grenades.grenadeClass.Name);
	newSlot.weaponClassNameList.Length = loadout.weaponList.Length;
	for(i = 0; i < loadout.weaponList.Length; ++i)
	{
		if(loadout.weaponList[i].weaponClass != None)
			newSlot.weaponClassNameList[i] = String(loadout.weaponList[i].weaponClass.Outer.Name)$"."$String(loadout.weaponList[i].weaponClass.Name);
	}
}

simulated function LoadoutFromSlot(LoadoutSlot slot, out CustomPlayerLoadout loadout)
{
	local int i;

	loadout.loadoutName = slot.loadoutName;
	loadout.skinPreferences = slot.skinPreferences;
	if(loadout.loadoutName == "")
		loadout.loadoutName = "Loadout";
	loadout.combatRoleClass = Class<CombatRole>(DynamicLoadObject(slot.combatRoleClassName, class'class'));
	if(slot.packClassName != "")
		loadout.packClass = Class<Pack>(DynamicLoadObject(slot.packClassName, class'class'));
	if(slot.grenadeClassName != "")
		loadout.grenades.grenadeClass = Class<HandGrenade>(DynamicLoadObject(slot.grenadeClassName, class'class'));
	loadout.weaponList.Length = slot.weaponClassNameList.Length;
	for(i = 0; i < slot.weaponClassNameList.Length; ++i)
	{
		if(slot.weaponClassNameList[i] != "")
			loadout.weaponList[i].weaponClass = Class<Weapon>(DynamicLoadObject(slot.weaponClassNameList[i], class'class'));
	}
}

// returns true if user input is required to complete the stat-tracking login
function bool needStatTrackingUserInput()
{
	return statTrackingNick == "" || statTrackingEmail == "" || statTrackingPassword == "";
}

// returns true if user input is required to complete the team affiliation login
function bool needTeamAffiliationUserInput()
{
	return bUseTeamAffiliation && (affiliatedTeamTag == "" || affiliatedTeamPassword == "");
}

// Autologin for admins
function int FindCredentials( coerce string IP, coerce string Port )
{
	local int i;

	Log("Finding admin credentials for "$IP$":"$Port);
	for ( i = 0; i < LoginHistory.Length; i++ )
		if ( LoginHistory[i].IP == IP && LoginHistory[i].Port == Port )
		{
			Log("FOUND ADMIN credentials at index "$i);
			return i;
		}

	Log("Couldn't find ADMIN CREDENTIALS");
	return -1;
}

function SaveCredentials(string Username, string Password, string IP, string Port, bool bAutoLogin)
{
	local AutoLoginInfo NewInfo;
	local int i;

	if ( !bStoreLogins || IP == "" || Port == "" )
		return;

	Log("Saving credentials, "$IP@Port@Username@Password);

	NewInfo.UserName = Username;
	NewInfo.Password = Password;
	if ( NewInfo.Password == "" )
		return;

	NewInfo.IP = IP;
	NewInfo.Port = Port;
	NewInfo.bAutoLogin = bAutoLogin;

	i = FindCredentials(NewInfo.IP, NewInfo.Port);
	if ( i == -1 )
	{
		i = LoginHistory.Length;
		LoginHistory.Length = LoginHistory.Length + 1;
	}


	LoginHistory[i] = NewInfo;
	Store();
}

function toggleServerFavorite(string IP, string Port)
{
	local int i;

	// If it already exists, get rid of it (toggle it off)
	for (i=0; i<serverFavorites.Length; i++)
	{
		if (serverFavorites[i].IP == IP && serverFavorites[i].Port == Port)
		{
			serverFavorites.Remove(i, 1);
			return;
		}
	}

	// Otherwise, it's a new favorite, so add it
	serverFavorites.Length = serverFavorites.Length + 1;
	serverFavorites[serverFavorites.Length - 1].IP = IP;
	serverFavorites[serverFavorites.Length - 1].Port = Port;
	Store();
}

function bool hasServerFavorite(string IP, string Port)
{
	local int i;

	// If it already exists, get rid of it (toggle it off)
	for (i=0; i<serverFavorites.Length; i++)
	{
		if (serverFavorites[i].IP == IP && serverFavorites[i].Port == Port)
		{
			return true;
		}
	}

	return false;
}

defaultproperties
{
	playerName	= "Player"
	bIsFemale	= false
	bUseStatTracking = false
	bSaveStatTrackingPassword = true
}
