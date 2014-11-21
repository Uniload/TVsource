class TribesAdminUser extends TribesAdminBase;

var string				UserName;
var string				Password;
var string				Privileges;
var string				MergedPrivs;	// Set on load or any Groups change
var TribesAdminGroupList		Groups;
var TribesAdminGroupList		ManagedGroups;

// Post Load information
var bool				bMasterAdmin;

function Init(string uname, string Pass, string privs)
{
	Groups = new(None) class'TribesAdminGroupList';
	ManagedGroups = new(None) class'TribesAdminGroupList';

	UserName = uname;
	Password = Pass;
	Privileges = privs;
	MergedPrivs = privs;
}

function AddGroup(TribesAdminGroup Group)
{
	if (Group != None)
	{
		if (!Groups.Contains(Group))
			Groups.Add(Group);

		if (!Group.Users.Contains(self))
			Group.Users.Add(self);

		if (Group.bMasterAdmin)
			bMasterAdmin = true;
		else
			MergePrivs(Group.Privileges);
	}
}

function RemoveGroup(TribesAdminGroup Group)
{
	if (Group != None && Groups.Contains(Group))
	{
		Group.Users.Remove(self);
		Groups.Remove(Group);

		RedoMergedPrivs();
	}
}

function AddManagedGroup(TribesAdminGroup Group)
{
	if (Group != None)
	{
		if (!ManagedGroups.Contains(Group))
			ManagedGroups.Add(Group);
			
		if (!Group.Managers.Contains(self))
			Group.Managers.Add(self);
	}
}

function RemoveManagedGroup(TribesAdminGroup Group)
{
	if (Group != None && ManagedGroups.Contains(Group))
	{
		Group.Managers.Remove(self);
		ManagedGroups.Remove(Group);
	}
}

function AddGroupsByName(TribesAdminGroupList lGroups, array<string> aGroupNames)
{
local int i;

	for (i = 0; i<aGroupNames.Length; i++)
		AddGroup(lGroups.FindByName(aGroupNames[i]));
}

function AddManagedGroupsByName(TribesAdminGroupList lGroups, array<string> aGroupNames)
{
local int i;

	for (i=0; i<aGroupNames.Length; i++)
		AddManagedGroup(lGroups.FindByName(aGroupNames[i]));
}

function bool HasPrivilege(string Priv)
{
	return (bMasterAdmin || Instr("|"$MergedPrivs$"|", "|"$priv$"|") != -1 || Instr("|"$MergedPrivs$"|", "|"$Left(priv,1)$"|") != -1);
}

function RedoMergedPrivs()
{
local int i;

	bMasterAdmin = false;
	for (i = 0; i<Groups.Count(); i++)
		if (Groups.Get(i).bMasterAdmin)
		{
			bMasterAdmin = true;
			break;
		}

	if (bMasterAdmin)
		MergedPrivs = "";
	else
	{
		MergedPrivs = Privileges;

		// Merge Privileges from all Groups
		for (i=0; i<Groups.Count(); i++)
			MergePrivs(Groups.Get(i).Privileges);
	}
}

private function MergePrivs(string newprivs)
{
local string priv;
local int pos;

	while (newprivs != "")
	{
		pos = instr(newprivs, "|");
		if (pos == -1)
		{
		  priv = newprivs;
		  newprivs = "";
		}
		else
		{
		  priv = Left(newprivs, pos);
		  newprivs = Mid(newprivs, pos+1);
		}
		pos = Instr("|"$MergedPrivs$"|", "|"$priv$"|");
		if (pos == -1)
		{
		  if (MergedPrivs == "")
			  MergedPrivs = priv;
		  else
			  MergedPrivs = MergedPrivs$"|"$priv;
		}
	}
}

function bool CanManageGroup(TribesAdminGroup Group)
{
	return bMasterAdmin || ManagedGroups.Contains(Group);
}

function bool CanManageUser(TribesAdminUser User)
{
local int i;

	if (bMasterAdmin)
		return true;
		
	for (i=0; i<ManagedGroups.Count(); i++)
	{
		if (ManagedGroups.Get(i).Users.Contains(User))
			return true;
	}
	return false;
}

static function bool ValidPass(string upass)
{
local int i;

	if (Len(upass)<6)
		return false;

	for (i=0; i<Len(upass); i++)
		if (Instr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJMLMNOPQRSTUVWXYZ0123456789!%^*(){}[]<>.,", Mid(upass,i,1)) == -1)
			return false;
	
	return true;
}

static function bool ValidName(string uname)
{
local int i;

	if (Len(uname) < 1)
		return false;

	for (i=0; i<Len(uname); i++)
		if (Instr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJMLMNOPQRSTUVWXYZ0123456789!%^*(){}[]<>.,", Mid(uname,i,1)) == -1)
			return false;
	
	return true;
}

// Game Security Level relies only on Groups, not on ManagedGroups.
// Or it would allow to create a Group with a higher sec than what i have.
function int MaxSecLevel()
{
local int i, m;

	if (bMasterAdmin)
		return 255;

	m = 0;
	for (i=0; i<Groups.Count(); i++)
		if (Groups.Get(i).GameSecLevel > m)
			m = Groups.Get(i).GameSecLevel;
			
	return m;
}

function TribesAdminGroup GetGroup(string Groupname)
{
	return Groups.FindByName(Groupname);
}

function TribesAdminGroup GetManagedGroup(string Groupname)
{
	return ManagedGroups.FindByName(Groupname);	
}

function TribesAdminUserList GetManagedUsers(TribesAdminGroupList uAllGroups)
{
local TribesAdminUserList	retList, uList;
local TribesAdminGroupList	uGroups;
local int i, j;

	retList = new(None) class'TribesAdminUserList';

	if (bMasterAdmin)
		uGroups = uAllGroups;
	else
		uGroups = ManagedGroups;

	for (i = 0; i<uGroups.Count(); i++)
	{
		uList = uGroups.Get(i).Users;
		for (j = 0; j<uList.Count(); j++)
			retList.Add(uList.Get(j));
	}
	return retList;
}

function UnlinkGroups()
{
local int i;

	for (i=0; i<Groups.Count(); i++)
		Groups.Get(i).RemoveUser(self);
		
	for (i=0; i<ManagedGroups.Count(); i++)
		ManagedGroups.Get(i).RemoveUser(self);
}

defaultproperties
{
}
