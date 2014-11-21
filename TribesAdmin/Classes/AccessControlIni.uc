class AccessControlIni extends Engine.AccessControl;

#if IG_TRIBES3 // dbeswick: for savegames
var transient GameConfigSet	ConfigSet;
#else
var GameConfigSet	ConfigSet;
#endif
var AdminBase		CSEditor;

event Destroyed()
{
	if (CSEditor != None)
	{
		ConfigSet.EndEdit(false);
		AdminIni(CSEditor).ConfigSet = None;
		CSEditor = None;
	}
    Super.Destroyed();
}

function InitPrivs()
{
local int i, cnt;
local TribesPrivilegeBase	privileges;

	cnt = 0;
	for (i = 0; i<PrivClasses.Length; i++)
	{
		privileges = new PrivClasses[i];
		if (privileges != None)
		{
			PrivManagers.Length = cnt+1;
			PrivManagers[cnt] = privileges;
			cnt++;
			if (privileges.LoadMsg != "")
				Log(privileges.LoadMsg);

			// Prepare an AllPrivs string
			if (AllPrivs == "")
				AllPrivs = privileges.MainPrivs$"|"$privileges.SubPrivs;
			else
				AllPrivs = AllPrivs$"|"$privileges.MainPrivs$"|"$privileges.SubPrivs;
		}
		else
			Log("Invalid Privilege Class:"@PrivClasses[i]);
	}
}

event PreBeginPlay()
{
	Users=new(None) class'Engine.TribesAdminUserList';
	Groups=new(None) class'Engine.TribesAdminGroupList';

	class'TribesAdminConfigIni'.static.Load(Users, Groups, bDontAddDefaultAdmin);
	ConfigSet = new(None) class'GameConfigSet';
	ConfigSet.Level = Level;
	Super(Info).PreBeginPlay();
	InitPrivs();
}

function SaveAdmins()
{
	class'TribesAdminConfigIni'.static.Save(Users, Groups);
}

function bool AdminLogin( PlayerController P, string Username, string Password )
{
local Engine.TribesAdminUser	User;
local int index;

	if (P == None)
		return false;

	User = GetLoggedAdmin(P);

	if (User == None)
	{
	 	User = Users.FindByName(UserName);
		if (User != None)
		{
			// Check Password
			if (User.Password == Password)
			{
				index = LoggedAdmins.Length;
				LoggedAdmins.Length = index + 1;
				LoggedAdmins[index].User = User;
				LoggedAdmins[index].PRI = P.PlayerReplicationInfo;
				P.PlayerReplicationInfo.bAdmin = User.bMasterAdmin || User.HasPrivilege("Kp") || User.HasPrivilege("Bp");
				if (P.AdminManager == None)
					P.MakeAdmin();
				P.AdminManager.bAdmin = P.PlayerReplicationInfo.bAdmin;
			}
			else
				User = None;
		}
	}
	return (User != None);
}

function bool AdminPromote( PlayerController Promoter, PlayerController P )
{
	return Promoter != None && Promoter.AdminManager != None;
}

function bool AdminLogout( PlayerController P )
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
		{
			P.PlayerReplicationInfo.bAdmin = false;
			LoggedAdmins.Remove(i, 1);
			return true;
		}
	return false;
}

function SetAdminFromURL(string N, string P)
{
local Engine.TribesAdminGroup Group;
local Engine.TribesAdminUser User;

	// Check that there is not a User by that name already
	// TODO: This check should happen MUCH earlier, like at GUI level.
	if (Users.FindByName(N) != None)
	{
		Log("User"@N@"already in user list, please choose another name");
		return;
	}

	// Find an Admin Group .. and if none, add one called URL::Admin (cant be created manually)
	Group = Groups.FindByName("URL::Admin");
	if (Group == None)
	{
		Group = Groups.CreateGroup("URL::Admin", "", 255);
		Groups.Add(Group);
	}
	if (Group != None)
	{
		Group.bMasterAdmin = true;
		Group.GameSecLevel = 255;

		// Then create a user to add to that group
		User = Users.Create(N, P, "");
		User.AddGroup(Group);
		Users.Add(User);
	}
}

function bool ValidLogin(string UserName, string Password)
{
local Engine.TribesAdminUser  User;

	User = Users.FindByName(UserName);
	return User != None && User.Password == Password;
}

function bool IsAdmin(PlayerController P)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return true;

	return false;
}

function bool IsLogged(Engine.TribesAdminUser User)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].User == User)
			return true;

	return false;
}
// Each admin can change his own password
function bool SetAdminPassword(string P)
{
	// There is no single Admin Password
	// Todo : Find the master admin password and change it ?
	return false;
}

function bool AllowPriv(string priv)
{
	return true;
}

function SetGamePassword(string P)
{
	// TODO: Check privs b4 calling super
	Super.SetGamePassword(P);
}

function string GetAdminName(PlayerController PC)
{
local Engine.TribesAdminUser User;

	User = GetLoggedAdmin(PC);
	if (User != None)
	{
		return User.UserName;
	}
	return "Unknown";
}

function AdminEntered( PlayerController P, string Username)
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as"@Username$".");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}


function AdminPromoted( PlayerController Promoter, PlayerController P, bool bSuccess )
{
	if (bSuccess)
	{
		Log(P.PlayerReplicationInfo.PlayerName@"was promoted to administrator.");
		Level.Game.Broadcast( Promoter, P.PlayerReplicationInfo.PlayerName@"was promoted to a server administrator." );
	}
	else
	{
		Log("Could not promote"@P.PlayerReplicationInfo.PlayerName@"to server administrator.");
		Level.Game.BroadcastHandler.BroadcastText( Promoter.PlayerReplicationInfo, Promoter, "Could not promote"@P.PlayerReplicationInfo.PlayerName@"to server administrator." );
	}
}

// Verify if an admin action can be performed by a player
function bool CanPerform(PlayerController P, string Action)
{
local int i;

	for (i=0; i<LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return LoggedAdmins[i].User.HasPrivilege(Action);

	return false;
}

function bool ReportLoggedAdminsTo(PlayerController P)
{
    return false;
}

function bool LockConfigSet(out GameConfigSet GCS, AdminBase Admin)
{
	if (CSEditor == None)
	{
		CSEditor = Admin;
		GCS = ConfigSet;
		return true;
	}
	return false;
}

function bool ReleaseConfigSet(out GameConfigSet GCS, AdminBase Admin)
{
	if (CSEditor == Admin && GCS == ConfigSet)
	{
		CSEditor = None;
		GCS = None;
		return true;
	}
	return false;
}

/////////////////////////////////////////////////////////////////////
// Local Functions Area
//
//

function Engine.TribesAdminUser GetLoggedAdmin(PlayerController P)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return LoggedAdmins[i].User;

	return None;
}

function Engine.TribesAdminUser GetUser(string uname)
{
	return Users.FindByName(uname);
}

defaultproperties
{
	AdminClass=class'TribesAdmin.AdminIni'
	PrivClasses(0)=class'TribesAdmin.TribesKickPrivs'
	PrivClasses(1)=class'TribesAdmin.TribesGamePrivs'
	PrivClasses(2)=class'TribesAdmin.TribesUserGroupPrivs'
	PrivClasses(3)=class'TribesAdmin.TribesExtraPrivs'
}
