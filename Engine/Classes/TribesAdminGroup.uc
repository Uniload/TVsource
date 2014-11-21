class TribesAdminGroup extends TribesAdminBase;

var string GroupName;
var string Privileges;
var byte   GameSecLevel;

// List of Users and Managers for quick display
var TribesAdminUserList	Users;
var TribesAdminUserList	Managers;

var bool			bMasterAdmin;

function Init(string sGroupName, string sPrivileges, byte nGameSecLevel)
{
	Users = new(None) class'TribesAdminUserList';
	Managers = new(None) class'TribesAdminUserList';

	GroupName = sGroupName;
	Privileges = sPrivileges;
	GameSecLevel = nGameSecLevel;
	if (GroupName == "Admin")
		bMasterAdmin = true;
}

function SetPrivs(string privs)
{
local int i;

	Privileges = privs;
	for (i=0; i<Users.Count(); i++)
		Users.Get(i).RedoMergedPrivs();
}

static function bool ValidName(string uname)
{
local int i;

	if (Len(uname)<5)
		return false;

	Log("Checking each characters");
	for (i=0; i<Len(uname); i++)
		if (Instr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJMLMNOPQRSTUVWXYZ0123456789!%^*(){}[]<>.,", Mid(uname,i,1)) == -1)
			return false;
	
	return true;
}

function UnlinkUsers()
{
local int i;

	for (i=0; i<Users.Count(); i++)
		Users.Get(i).RemoveGroup(self);
		
	for (i=0; i<Managers.Count(); i++)
		Managers.Get(i).RemoveManagedGroup(self);
}

function RemoveUser(TribesAdminUser User)
{
	if (User != None)
	{
		if (Users.Contains(User))
			Users.Remove(User);

		if (Managers.Contains(User))
			Managers.Remove(User);
	}
}

/*
function AddUser(TribesAdminUser User)			{ Users.Add(User); }
function RemoveUser(TribesAdminUser User)		{ Users.Remove(User); }
function AddManager(TribesAdminUser Manager)		{ Managers.Add(Manager); }
function RemoveManager(TribesAdminUser Manager)	{ Managers.Remove(Manager); } 

function bool HasUser(TribesAdminUser User)			{ return Users.Contains(User); }
function bool HasManager(TribesAdminUser Manager)	{ return Users.Contains(Manager); }

function TribesAdminUser FindUserByName(string UserName)		{ return Users.FindByName(UserName); }
function TribesAdminUser FindManagerByName(string UserName)	{ return Managers.FindByName(UserName); } 
 */
function bool HasPrivilege(string priv)
{
	return bMasterAdmin || (InStr("|"$Privileges$"|", "|"$priv$"|") != -1) || Instr("|"$Left(Privileges,1)$"|", "|"$priv$"|") != -1;
}

defaultproperties
{
}
