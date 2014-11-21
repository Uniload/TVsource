class TribesAdminGroupList extends TribesAdminBase;

var private array<TribesAdminGroup>	Groups;

function int Count()	{ return Groups.Length; }

function TribesAdminGroup CreateGroup(string GroupName, string Privileges, byte GameSecLevel)
{
local TribesAdminGroup NewGroup;

	NewGroup = FindByName(GroupName);
	if (NewGroup == None)
	{
		NewGroup = new(None) class'TribesAdminGroup';
		if (NewGroup != None)
		{
//			Log("Group"@GroupName@" was created");
			NewGroup.Init(GroupName, Privileges, GameSecLevel);
		}
		return NewGroup;
	}
	return None;
}

function Add(TribesAdminGroup Group)
{
	if (Group != None && !Contains(Group))
	{
		Groups.Length = Groups.Length + 1;
		Groups[Groups.Length - 1] = Group;
	}
}

function Remove(TribesAdminGroup Group)
{
local int i;

	if (Group != None)
	{
		for (i = 0; i<Groups.Length; i++)
			if (Groups[i] == Group)
			{
				Groups.Remove(i, 1);
				return;
			}
	}
}

function TribesAdminGroup Get(int index)
{
	if (index<0 || index >= Groups.Length)
		return None;
		
	return Groups[index];
}

function TribesAdminGroup FindByName(string GroupName)
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i].GroupName == GroupName)
			return Groups[i];
			
	return None;
}

function bool Contains(TribesAdminGroup Group)
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i] == Group)
			return true;
			
	return false;
}

function TribesAdminGroup FindMasterGroup()
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i].GameSecLevel == 255)
			return Groups[i];

	return None;
}

function Clear()
{
	Groups.Remove(0, Groups.Length);
}

defaultproperties
{
}
