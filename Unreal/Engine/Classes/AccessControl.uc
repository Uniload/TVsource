//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to 
// login in the PreLogin() function, and also controls whether or not a player 
// can enter as a spectator or a game administrator.
//
//=============================================================================
class AccessControl extends Info;

#if IG_TRIBES3_ADMIN   // glenn: admin support

struct AdminPlayer
{
	var TribesAdminUser	User;
	var PlayerReplicationInfo PRI;
};

#if IG_TRIBES3 // dbeswick: for savegames
var transient TribesAdminUserList		Users;
var transient TribesAdminGroupList		Groups;
#else
var TribesAdminUserList		Users;
var TribesAdminGroupList		Groups;
#endif
var protected array<AdminPlayer>	LoggedAdmins;
var config array< class<TribesPrivilegeBase> >	PrivClasses;
var array<TribesPrivilegeBase>		PrivManagers;
var string AllPrivs;

var globalconfig array<string>   IPPolicies;
var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var localized string          SessionBanned;
var localized string		  KickedMsg;
var class<AdminBase>		  AdminClass;

var config string KickToMenu;		// The name of the menu to kick this player too

var bool bReplyToGUI;
var bool bDontAddDefaultAdmin;

var private string AdminName;
var private string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		    // Password to enter game.
#if IG_TRIBES3	// michaelj:  Integrated UT2004 admin login
var globalconfig float          LoginDelaySeconds;  // Delay between login attempts
#endif

var transient Array<string> SessionIPPolicies; // sjs
// MC: Have a GameAccess class eventually ?

event PreBeginPlay()
{
local TribesAdminUser  NewUser;

	Super.PreBeginPlay();

    // gam ---
    assert( Users == None );
	Users = new(None) class'TribesAdminUserList';
    assert( Groups == None );
	Groups = new(None) class'TribesAdminGroupList';
	// --- gam

	if (!bDontAddDefaultAdmin)
	{
		Groups.Add(Groups.CreateGroup("Admin", "", 255));
		NewUser = Users.Create("Admin", "Admin", "");
		NewUser.AddGroup(Groups.FindByName("Admin"));
		Users.Add(NewUser);
		AdminName = "Admin";
	}
	InitPrivs();
}

function SaveAdmins()
{
	AdminPassword = Users.Get(0).Password;
}

function InitPrivs();

function bool AdminLogin( PlayerController P, string Username, string Password)
{
	if (ValidLogin(Username, Password))
	{
		P.PlayerReplicationInfo.bAdmin = true;
		return true;
	}
	return false;
}

function bool AdminPromote( PlayerController Promoter, PlayerController P )
{
	return false;
}

function AdminPromoted( PlayerController Promoter, PlayerController P, bool bSuccess )
{
}

function bool AdminLogout( PlayerController P )
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		return true;
	}
	return false;
}

function AdminEntered( PlayerController P, string Username)
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as Administrator.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}

function AdminExited( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged out.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.");
}

function bool IsAdmin(PlayerController P)
{
	return P.PlayerReplicationInfo.bAdmin;
}

function SetAdminFromURL(string N, string P)
{
local TribesAdminUser NewUser;
local TribesAdminGroup NewGroup;

	Log("SetAdminFromURL called");
	NewGroup = Groups.CreateGroup("URL::Admin", "", 255);
	NewGroup.bMasterAdmin = true;
	Groups.Add(NewGroup);
	NewUser = Users.Create(N, P, "");
	NewUser.AddGroup(NewGroup);
	Users.Add(NewUser);
	AdminName = N;
	SetAdminPassword(P);
}

function bool SetAdminPassword(string P)
{
	AdminPassword = P;
	return true;
}

function SetGamePassword(string P)
{
	GamePassword = P;
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

function TribesAdminUser GetAdmin( PlayerController PC)
{
	return None;
}

function string GetAdminName( PlayerController PC)
{
	return AdminName;
}

function Kick( string S ) 
{
	local Controller C, NextC;

    for ( C=Level.ControllerList; C!=None; C=NextC )
    {
		NextC = C.NextController;
        if ( C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.PlayerName~=S )
        {
            if (PlayerController(C) != None)
				KickPlayer(PlayerController(C));
			else if ( C.PlayerReplicationInfo.bBot )
            {
				if (C.Pawn != None)
					C.Pawn.Destroy();
				if (C != None)
					C.Destroy();
            }
            break;
        }
    }
}

function SessionKickBan( string S ) // sjs
{
	local PlayerController P;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			BanPlayer(P, true);
		}
}

function KickBan( string S ) 
{
	local PlayerController P;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			BanPlayer(P);
			return;
		}
}

function bool KickPlayer(PlayerController C)
{
	// Do not kick logged admins
	if (C != None && !IsAdmin(C) && NetConnection(C.Player)!=None )
    {	    
		if (C.Pawn != None)
		{
			C.Pawn.Died( None, class'DamageType', C.Pawn.Location );	
			C.Pawn.Destroy();
		}
		if (C != None)
			C.Destroy();
		return true;
    }
    else
    {
        log("cannot kick player: controller="$c$", admin="$IsAdmin(C)$", connection="$NetConnection(C.Player));
    }
    
	return false;
}

function bool BanPlayer(PlayerController C, optional bool bSession)
{
local string IP;

    log("ban player: "$c$" session="$bSession);

	if (IsAdmin(C))
		return false;

	IP = C.GetPlayerNetworkAddress();
	
	
	if( CheckIPPolicy(IP) )
	{
		IP = Left(IP, InStr(IP, ":"));
		if (bSession)
		{
			Log("Adding Session IP Ban for: "$IP);
            SessionIPPolicies[SessionIPPolicies.Length] = "DENY,"$IP;
		}
		else
		{
			Log("Adding IP Ban for: "$IP);
			IPPolicies[IPPolicies.Length] = "DENY,"$IP;
			SaveConfig();
		}
		KickPlayer(C);
		return true;
	}
	return false;
}

function bool KickBanPlayer(PlayerController P)
{
local string IP;

	if (!IsAdmin(P))
	{
		IP = P.GetPlayerNetworkAddress();
		if( CheckIPPolicy(IP) )
		{
			IP = Left(IP, InStr(IP, ":"));
			Log("Adding IP Ban for: "$IP);
			IPPolicies[IPPolicies.Length] = "DENY,"$IP;
			SaveConfig();
		}
		P.Destroy();
		return true;
	}
	return false;
}

function bool CheckOptionsAdmin( string Options)
{
local string InAdminName, InPassword;

	InPassword = Level.Game.ParseOption( Options, "Password" );
	InAdminName= Level.Game.ParseOption( Options, "AdminName" );
	return ValidLogin(InAdminName, InPassword);
}

function bool ValidLogin(string UserName, string Password)
{
	return (AdminPassword != "" && Password==AdminPassword);
}

function TribesAdminUser GetLoggedAdmin(PlayerController P)
{
	return Users.Get(0);
}

function TribesAdminUser GetUser(string uname)
{
	return None;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode,
	bool bSpectator
)
{
	// Do any name or password or name validation here.
	local string InPassword;
	local bool   bAdmin;

	Error="";
#if IG_TRIBES3	// michaelj:  Fixed admin/join "Password" option clash
	InPassword = Level.Game.ParseOption( Options, "JoinPassword" );
#else
	InPassword = Level.Game.ParseOption( Options, "Password" );
#endif
	bAdmin = CheckOptionsAdmin(Options);

	if( (Level.NetMode != NM_Standalone) && !bAdmin && Level.Game.AtCapacity(bSpectator) )
	{
		// TODO: Check Login to make room for Master Admins if not enuff specs.
		Error=Level.Game.GameMessageClass.Default.MaxedOutMessage;
	}
	else if	( GamePassword!="" && caps(InPassword)!=caps(GamePassword) && !bAdmin )
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	if(!CheckIPPolicy(Address))
		Error = IPBanned;
}


function bool CheckIPPolicy(string Address, optional bool bSilent)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<IPPolicies.Length; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress && !bSilent)
		Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
		
    // check session polices
    if( bAcceptAddress )
    {
        for(i=0; i<SessionIPPolicies.Length && SessionIPPolicies[i] != ""; i++ )
        {
            j = InStr(SessionIPPolicies[i], ",");
		    if(j==-1)
			    continue;
		    Policy = Left(SessionIPPolicies[i], j);
		    Mask = Mid(SessionIPPolicies[i], j+1);
		    if(Policy ~= "ACCEPT") 
			    bAcceptPolicy = True;
		    else if(Policy ~= "DENY") 
			    bAcceptPolicy = False;
		    else
			    continue;

		    j = InStr(Mask, "*");
		    if(j != -1)
		    {
			    if(Left(Mask, j) == Left(Address, j))
			    {
				    bAcceptAddress = bAcceptPolicy;
				    LastMatchingPolicy = i;
			    }
		    }
		    else
		    {
			    if(Mask == Address)
			    {
				    bAcceptAddress = bAcceptPolicy;
				    LastMatchingPolicy = i;
			    }
		    }
        }
        if(!bAcceptAddress && !bSilent)
		    Log("Denied connection for "$Address$" with Session IP policy "$IPPolicies[LastMatchingPolicy]);
    } 	
	return bAcceptAddress;
}

// Stubs in preparation of multi-admin system
function bool CanPerform(PlayerController P, string Action)
{
	// Filter out any Admin Users/Group/commands
	if (!AllowPriv(Action))
		return false;

	// Standard Admin actions only performed by Admin
	return P.PlayerReplicationInfo.bAdmin;
}

function bool AllowPriv(string priv)
{
	if (Left(priv, 1) ~= "A" || Left(priv, 1) ~= "G")
		return false;

	return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	i=0;
	PlayInfo.AddSetting("Server",  "GamePassword", "Game Password", 240,  85, "Text", "16");
}

defaultproperties
{
	WrongPassword="The password you entered is incorrect."
	NeedPassword="You need to enter a password to join this game."
	IPBanned="Your IP address has been banned on this server."
    SessionBanned="Your IP address has been banned from the current game session."
	IPPolicies(0)="ACCEPT,*"
	AdminClass=class'Engine.Admin'
	KickedMsg="You have been forcably removed from the game."	
	//InvalidOptions="The options you specified are invalid"
	LoginDelaySeconds=1
}

#else

// old code for access control: superceded by TribesAdmin from UT

var globalconfig string     IPPolicies[50];
var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
#if IG_SHARED // ckline: Unprog security bugfid: https://udn.epicgames.com/lists/showpost.php?list=unprog&id=35587
var	localized string          InvalidOptions;
#endif
var class<Admin> AdminClass;

var private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		    // Password to enter game.

var bool bDontAddDefaultAdmin;


function SetAdminPassword(string P)
{
	AdminPassword = P;
}

function SetGamePassword(string P)
{
	GamePassword = P;
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

function Kick( string S ) 
{
	local PlayerController P;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			P.Destroy();
			return;
		}
}

function KickBan( string S ) 
{
	local PlayerController P;
	local string IP;
	local int j;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) )
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
					if( IPPolicies[j] == "" )
						break;
				if(j < 50)
					IPPolicies[j] = "DENY,"$IP;
				SaveConfig();
			}
			P.Destroy();
			return;
		}
}

function bool AdminLogin( PlayerController P, string Password )
{
	if (AdminPassword == "")
		return false;

	if (Password == AdminPassword)
	{
		Log("Administrator logged in.");
		Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName$"logged in as a server administrator." );
		return true;
	}
	return false;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode,
	bool bSpectator
)

{
	// Do any name or password or name validation here.
	local string InPassword;

#if IG_SHARED // ckline: Unprog security bugfid: https://udn.epicgames.com/lists/showpost.php?list=unprog&id=35587
    // Restrict players with '%' symbols in their options
    if (InStr(Options, "%") >= 0)
    {
		Error = InvalidOptions;
        return;
    }
#endif
    
	Error="";
	InPassword = Level.Game.ParseOption( Options, "Password" );

	if( (Level.NetMode != NM_Standalone) && Level.Game.AtCapacity(bSpectator) )
	{
		Error=Level.Game.GameMessageClass.Default.MaxedOutMessage;
	}
	else if
	(	GamePassword!=""
	&&	caps(InPassword)!=caps(GamePassword)
	&&	(AdminPassword=="" || caps(InPassword)!=caps(AdminPassword)) )
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	if(!CheckIPPolicy(Address))
		Error = IPBanned;


}


function bool CheckIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<50 && IPPolicies[i] != ""; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else
		if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
		
	return bAcceptAddress;
}

// note: commented out to stop warning about redundant data
// ucc parser for defaultproperties does not respect #if/#else/#endif !

//defaultproperties
//{
//	WrongPassword="The password you entered is incorrect."
//	NeedPassword="You need to enter a password to join this game."
//	IPBanned="Your IP address has been banned on this server."
//	IPPolicies(0)="ACCEPT,*"
//	AdminClass=class'Engine.Admin'
//#if IG_SHARED // ckline: Unprog security bugfid: https://udn.epicgames.com/lists/showpost.php?list=unprog&id=35587
//	InvalidOptions="The options you specified are invalid"
//#endif
//}

#endif
