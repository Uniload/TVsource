class TribesAdminUserList extends TribesAdminBase;

var private array<TribesAdminUser>	Users;

// Returns the number of Users in the list
function int Count()		{ return Users.Length; }

/////////////////////////////////////////////////
// CreateUser : Creates a new user 

function TribesAdminUser Create(string UserName, string Password, string Privileges)
{
local TribesAdminUser NewUser;

	NewUser = new(None) class'TribesAdminUser';
	if (NewUser != None)
		NewUser.Init(UserName, Password, Privileges);

	return NewUser;
}

function Add(TribesAdminUser NewUser)
{
	if (NewUser != None && !Contains(NewUser))
	{
		Users.Length = Users.Length + 1;
		Users[Users.Length - 1] = NewUser;
	}
}

function TribesAdminUser Get(int i)
{
	return Users[i];
}

function Remove(TribesAdminUser User)
{
local int i;

	if (User != None)
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i] == User)
			{
				Users.Remove(i, 1);
				return;
			}
	}
}

function Clear()
{
	Users.Length = 0;
}

function bool Contains(TribesAdminUser User)
{
local int i;

	if (User != None)
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i] == User)
				return true;
	}
	return false;
}

function TribesAdminUser FindByName(string UserName)
{
local int i;

	if (UserName != "")
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i].UserName == UserName)
				return Users[i];
	}
	return None;
}

defaultproperties
{

}
