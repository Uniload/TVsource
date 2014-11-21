class TribesWebQueryAdmins extends TribesWebQueryHandler;

struct RowGroup { var array<string>	rows; };

var config string AdminsIndexPage;
var config string UsersHomePage;
var config string UsersAccountPage;
var config string UsersAddPage;
var config string UsersBrowsePage;
var config string UsersEditPage;
var config string UsersGroupsPage;
var config string UsersMGroupsPage;
var config string GroupsAddPage;
var config string GroupsBrowsePage;
var config string GroupsEditPage;

var localized string NoteUserHomePage;
var localized string NoteAccountPage;
var localized string NoteUserAddPage;
var localized string NoteUserEditPage;
var localized string NoteUsersBrowsePage;
var localized string NoteGroupAddPage;
var localized string NoteGroupEditPage;
var localized string NoteGroupsBrowsePage;
var localized string NoteGroupAccessPage;
var localized string NoteMGroupAccessPage;

function bool Query(WebRequest Request, WebResponse Response)
{
	switch (Mid(Request.URI, 1))
	{
	case DefaultPage:		QueryAdminsFrame(Request, Response); return true;
	case AdminsIndexPage:	QueryAdminsMenu(Request, Response); return true;
		
	case UsersHomePage:		if (!owner.MapIsChanging()) QueryUsersHomePage(Request, Response); return true;
	case UsersAccountPage:	if (!owner.MapIsChanging()) QueryUserAccountPage(Request, Response); return true;
	case UsersBrowsePage:	if (!owner.MapIsChanging()) QueryUsersBrowsePage(Request, Response); return true;
	case UsersAddPage:		if (!owner.MapIsChanging()) QueryUsersAddPage(Request, Response); return true;
	case UsersEditPage:		if (!owner.MapIsChanging()) QueryUsersEditPage(Request, Response); return true;
	case UsersGroupsPage:	if (!owner.MapIsChanging()) QueryUsersGroupsPage(Request, Response); return true;
	case UsersMGroupsPage:	if (!owner.MapIsChanging()) QueryUsersMGroupsPage(Request, Response); return true;
	case GroupsBrowsePage:	if (!owner.MapIsChanging()) QueryGroupsBrowsePage(Request, Response); return true;
	case GroupsAddPage:		if (!owner.MapIsChanging()) QueryGroupsAddPage(Request, Response); return true;
	case GroupsEditPage:	if (!owner.MapIsChanging()) QueryGroupsEditPage(Request, Response); return true;
	}	
	return false;
}

function QueryAdminsFrame(WebRequest Request, WebResponse Response)
{
local String Page;
	
	// if no page specified, use the default
	Page = Request.GetVariable("Page", UsersHomePage);

	Response.Subst("IndexURI", 	AdminsIndexPage$"?Page="$Page);
	Response.Subst("MainURI", 	Page);

	owner.ShowPage(Response, DefaultPage);
}

function QueryAdminsMenu(WebRequest Request, WebResponse Response)
{
	Response.Subst("Title", "Users & Groups Management");
	
	Response.Subst("UsersHomeURI", UsersHomePage);
	Response.Subst("UserAccountURI", UsersAccountPage);
	Response.Subst("UsersAddURI", UsersAddPage);
	Response.Subst("GroupsAddURI", GroupsAddPage);
	Response.Subst("UsersBrowseURI", UsersBrowsePage);
	Response.Subst("GroupsBrowseURI", GroupsBrowsePage);
	
	owner.ShowPage(Response, AdminsIndexPage);
}

function QueryUsersHomePage(WebRequest Request, WebResponse Response)
{
	Response.Subst("Section", "Admin Home Page");
	Response.Subst("PageHelp", NoteUserHomePage);
	owner.ShowPage(Response, UsersHomePage);
}

function QueryUserAccountPage(WebRequest Request, WebResponse Response)
{
local string upass;

	Response.Subst("NameValue", owner.HtmlEncode(owner.CurAdmin.UserName));
	if (Request.GetVariable("edit", "") != "")
	{
		// Can only change his password
		upass = Request.GetVariable("Password", owner.CurAdmin.Password);
		if (!owner.CurAdmin.ValidPass(upass))
			owner.StatusError(Response, "New password is too short!");
		else if (upass != owner.CurAdmin.Password)
		{
			owner.CurAdmin.Password = upass;
			owner.Level.Game.AccessControl.SaveAdmins();
		}
	}

	Response.Subst("PassValue", owner.CurAdmin.Password);
	Response.Subst("PrivTable", GetPrivsTable(owner.CurAdmin.Privileges, true));
	Response.Subst("GroupLinks", "");
	Response.Subst("SubmitValue", "Accept");
	Response.Subst("PostAction", UsersAccountPage);
	Response.Subst("PageHelp", NoteAccountPage);
	owner.ShowPage(Response, UsersAccountPage);
}

function QueryUsersBrowsePage(WebRequest Request, WebResponse Response)
{
local TribesAdminUser User;

	if (owner.CanPerform("Al|Aa|Ae|Ag|Am"))
	{
		// Delete an Admin
		if (Request.GetVariable("delete") != "")
		{
			// Delete specified Admin Group	
			User = owner.Level.Game.AccessControl.Users.FindByName(Request.GetVariable("delete"));
			if (User != None)
			{
				if (owner.CurAdmin.CanManageUser(User))
				{
					owner.StatusOk(Response, "User '"$owner.HtmlEncode(User.UserName)$"' was removed!");
					// Remove User
					User.UnlinkGroups();
					owner.Level.Game.AccessControl.Users.Remove(User);
					owner.Level.Game.AccessControl.SaveAdmins();
				}
				else
					owner.StatusError(Response, "Your privileges prevent you from delete this group");
			}
			else
				owner.StatusError(Response, "Invalid group name specified");
		}
		// Show the list
		Response.Subst("BrowseList", GetUsersForBrowse(Response));

		Response.Subst("Section", "Browse Available Users");
		Response.Subst("PageHelp", NoteUsersBrowsePage);
		owner.ShowPage(Response, UsersBrowsePage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryUsersAddPage(WebRequest Request, WebResponse Response)
{
local TribesAdminUser User;
local TribesAdminGroup Group;
local TribesAdminGroupList Groups;
local string uname, upass, uprivs, ugrp, ErrMsg;

	if (owner.CanPerform("Aa"))
	{
		if (owner.CurAdmin.bMasterAdmin)
			Groups = owner.Level.Game.AccessControl.Groups;
		else
			Groups = owner.CurAdmin.ManagedGroups;
			 
		if (Request.GetVariable("addnew") != "")
		{
			// Humm .. AddNew
			uname = Request.GetVariable("Username");
			upass = Request.GetVariable("Password");
			uprivs = FixPrivs(Request, "");
			ugrp = Request.GetVariable("Usergroup");
			Group = Groups.FindByName(ugrp);
			
			if (!owner.CurAdmin.ValidName(uname))
				ErrMsg = "User name contains invalid characters!";
			else if (owner.Level.Game.AccessControl.Users.FindByName(uname) != None)
				ErrMsg = "User name already used!";
			else if (!owner.CurAdmin.ValidPass(upass))
				ErrMsg = "Password contains invalid characters!";
			else if (ugrp == "")
				ErrMsg = "You must select a group!";
			else if (Group == None)
				ErrMsg = "The Group you selected does not exist!";
		
			Response.Subst("NameValue", owner.HtmlEncode(uname));
			Response.Subst("PassValue", upass);
			Response.Subst("PrivTable", GetPrivsTable(uprivs));

			if (ErrMsg == "")
			{
				// All settings are fine, create the new Group.
				User = owner.Level.Game.AccessControl.Users.Create(uname, upass, uprivs);
				if (User != None)
				{
					User.AddGroup(Group);
					owner.Level.Game.AccessControl.Users.Add(User);
					owner.Level.Game.AccessControl.SaveAdmins();
				}
				else
				{
					// Only re-add the DDL if there was a problem.
					ErrMsg = "Exceptional error creating the new group";
				}
			}
			
			if (ErrMsg != "")
				owner.StatusError(Response, ErrMsg);
		}
		else
			Response.Subst("PrivTable", GetPrivsTable(""));
		
		if (User != None)
		{
			Response.Subst("PostAction", UsersEditPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", "Modify Admin");
			Response.Subst("Section", "Modify an Administrator");
			Response.Subst("PageHelp", NoteUserEditPage);
			owner.ShowPage(Response, UsersEditPage);
		}
		else
		{
			Response.Subst("Groups", GetGroupOptions(Groups, ugrp));
			Response.Subst("PostAction", UsersAddPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", "Add Admin");
			Response.Subst("Section", "Add a New Administrator");
			Response.Subst("PageHelp", NoteUserAddPage);
			owner.ShowPage(Response, UsersAddPage);
		}
	}
	else
		owner.AccessDenied(Response);
}

function QueryUsersEditPage(WebRequest Request, WebResponse Response)
{
local TribesAdminUser User;
local string uname, upass, privs, ErrMsg;

	if (owner.CanPerform("Aa|Ae"))
	{
		ErrMsg = "";
		
		Response.Subst("Section", "Modify an Administrator");

		User = owner.Level.Game.AccessControl.GetUser(Request.GetVariable("edit"));
		if (User != None)
		{
			if (owner.CurAdmin.CanManageUser(User))
			{
				// Operations
				if (Request.GetVariable("mod") != "")
				{
					// Validate the changes and modify the user information
					uname = Request.GetVariable("Username");
					upass = Request.GetVariable("Password");
					privs = FixPrivs(Request, User.Privileges);
					if (uname != User.UserName)
					{
						if (User.ValidName(uname))
						{
							if (owner.Level.Game.AccessControl.GetUser(uname) == None)
								User.UserName = uname;
							else
								ErrMsg = "New name already exists";
						}
						else
							ErrMsg = "New name is invalid";
					}
					
					if (ErrMsg == "" && !(upass == User.Password))
					{
						if (User.ValidPass(upass))
							User.Password = upass;
						else
							ErrMsg = "New password is invalid";
					}
					
					if (ErrMsg == "" && privs != User.Privileges)
					{
						User.Privileges = privs;
						User.RedoMergedPrivs();
					}
					if (ErrMsg == "")
						owner.Level.Game.AccessControl.SaveAdmins();
				}
				
				if (ErrMsg != "")
					owner.StatusError(Response, ErrMsg);
			
				Response.Subst("NameValue", owner.HtmlEncode(User.UserName));
				Response.Subst("PassValue", owner.HtmlEncode(User.Password));
				Response.Subst("PrivTable", GetPrivsTable(User.Privileges));
				Response.Subst("PostAction", UsersEditPage);
				Response.Subst("SubmitName", "mod");
				Response.Subst("SubmitValue", "Modify Admin");
				Response.Subst("PageHelp", NoteUserEditPage);
				owner.ShowPage(Response, UsersEditPage);
			}
			else
				owner.ShowMessage(Response, "No Privileges", "You do not have the privileges to modify this admin");
		}
		else
			owner.ShowMessage(Response, "Unknown Admin", "The admin you have selected does not exist!");
	}
	else
		owner.AccessDenied(Response);
}

function QueryUsersGroupsPage(WebRequest Request, WebResponse Response)
{
local TribesAdminUser		User;
local TribesAdminGroupList	Groups;
local TribesAdminGroup		Group;
local StringArray	  GrpNames;
local string GroupRows, GrpName, Str;
local int i;
local bool bModify, bChecked;

	if (owner.CanPerform("Ag"))
	{
		User = owner.Level.Game.AccessControl.Users.FindByName(Request.GetVariable("edit"));
		if (User != None)
		{
			if (owner.CurAdmin.CanManageUser(User))
			{
				if (owner.CurAdmin.bMasterAdmin)
					Groups = owner.Level.Game.AccessControl.Groups;
				else
					Groups = owner.CurAdmin.ManagedGroups;
				
				// Work with a table of checkboxes now
				GroupRows = "";
				bModify = (Request.GetVariable("submit") != "");

				// Make a sorted list of Groups
				GrpNames = new(None)class'SortedStringArray';
				for (i=0; i<Groups.Count(); i++)
					GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

				for (i=0; i<GrpNames.Count(); i++)
				{
					GrpName = GrpNames.GetItem(i);
					Group = Groups.FindByName(GrpName);
					bChecked = Request.GetVariable(GrpName) != "";

					if (bModify)
					{
						if (User.Groups.Contains(Group))
						{
							if (!bChecked)	// Remove the user from the group
								User.RemoveGroup(Group);
						}
						else
						{
							if (bChecked)
								User.AddGroup(Group);
						}
					}
					Response.Subst("GroupName", GrpName);

					Str = "";
					if (User.Groups.Contains(Group))
						Str = " checked";
					Response.Subst("Checked", Str);
					GroupRows = GroupRows$owner.WebInclude("users_groups_row");
				}

				if (bModify)
					owner.Level.Game.AccessControl.SaveAdmins();

				// Now just build up the page as a table with checkboxes
				Response.Subst("NameValue", owner.HtmlEncode(User.UserName));
				Response.Subst("GroupRows", GroupRows);
				Response.Subst("PostAction", UsersGroupsPage);
				Response.Subst("Section", "Manage Groups For "$owner.HtmlEncode(User.UserName));
				Response.Subst("PageHelp", NoteGroupAccessPage);
				owner.ShowPage(Response, UsersGroupsPage);
			}
			else
				owner.ShowMessage(Response, "No Privileges", "You do not have the privileges to modify this admin");
		}
		else
			owner.ShowMessage(Response, "Unknown Admin", "The admin you have selected does not exist!");
	}
	else
		owner.AccessDenied(Response);
}

function QueryUsersMGroupsPage(WebRequest Request, WebResponse Response)
{
local TribesAdminUser		User;
local TribesAdminGroupList	Groups;
local TribesAdminGroup		Group;
local StringArray	  GrpNames;
local string GroupRows, GrpName, Str;
local int i;
local bool bModify, bChecked;

	if (owner.CanPerform("Am"))
	{

		User = owner.Level.Game.AccessControl.Users.FindByName(Request.GetVariable("edit"));
		if (User != None)
		{
			if (owner.CurAdmin.CanManageUser(User))
			{
				if (owner.CurAdmin.bMasterAdmin)
					Groups = owner.Level.Game.AccessControl.Groups;
				else
					Groups = owner.CurAdmin.ManagedGroups;
				
				// Work with a table of checkboxes now
				GroupRows = "";
				bModify = (Request.GetVariable("submit") != "");

				// Make a sorted list of Groups
				GrpNames = new(None)class'SortedStringArray';
				for (i=0; i<Groups.Count(); i++)
					GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

				for (i=0; i<GrpNames.Count(); i++)
				{
					GrpName = GrpNames.GetItem(i);
					Group = Groups.FindByName(GrpName);
					bChecked = Request.GetVariable(GrpName) != "";

					if (bModify)
					{
						if (User.Groups.Contains(Group))
						{
							if (!bChecked)	// Remove the user from the group
								User.RemoveGroup(Group);
						}
						else
						{
							if (bChecked)
								User.AddGroup(Group);
						}
					}
					Response.Subst("GroupName", GrpName);

					Str = "";
					if (User.Groups.Contains(Group))
						Str = " checked";
					Response.Subst("Checked", Str);
					GroupRows = GroupRows$owner.WebInclude("users_groups_row");
				}

				if (bModify)
					owner.Level.Game.AccessControl.SaveAdmins();

				// Now just build up the page as a table with checkboxes
				Response.Subst("Managed", "Managed ");
				Response.Subst("NameValue", owner.HtmlEncode(User.UserName));
				Response.Subst("GroupRows", GroupRows);
				Response.Subst("PostAction", UsersMGroupsPage);
				Response.Subst("Section", "Manage Groups For "$owner.HtmlEncode(User.UserName));
				Response.Subst("PageHelp", NoteMGroupAccessPage);
				owner.ShowPage(Response, UsersGroupsPage);
			}
			else
				owner.ShowMessage(Response, "No Privileges", "You do not have the privileges to modify this admin");
		}
		else
			owner.ShowMessage(Response, "Unknown Admin", "The admin you have selected does not exist!");
	}
	else
		owner.AccessDenied(Response);
}

function QueryGroupsBrowsePage(WebRequest Request, WebResponse Response)
{
local TribesAdminGroup Group;

	if (owner.CanPerform("Gl|Ge"))
	{
		Response.Subst("Section", "Browse Available Groups");
		if (Request.GetVariable("delete") != "")
		{
			// Delete specified Admin Group	
			Group = owner.Level.Game.AccessControl.Groups.FindByName(Request.GetVariable("delete"));
			if (Group != None)
			{
				if (owner.CurAdmin.CanManageGroup(Group))
				{
					owner.StatusOk(Response, "Group '"$owner.HtmlEncode(Group.GroupName)$"' was removed!");
					Group.UnlinkUsers();
					owner.Level.Game.AccessControl.Groups.Remove(Group);
					owner.Level.Game.AccessControl.SaveAdmins();
				}
				else
					owner.StatusError(Response, "Your privileges prevent you from delete this group");
			}
			else
				owner.StatusError(Response, "Invalid group name specified");
		}
		Response.Subst("BrowseList", GetGroupsForBrowse(Response));
		Response.Subst("PageHelp", NoteGroupsBrowsePage);
		owner.ShowPage(Response, GroupsBrowsePage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryGroupsAddPage(WebRequest Request, WebResponse Response)
{
local TribesAdminGroup Group;
local string gname, gprivs, ErrMsg;
local int gsec;

	if (owner.CanPerform("Ga"))
	{
		if (Request.GetVariable("addnew") != "")
		{
			// Humm .. AddNew
			gname = Request.GetVariable("GroupName");
			gprivs = FixPrivs(Request, "");
			gsec = int(Request.GetVariable("GameSec"));
			
			if (!class'TribesAdminGroup'.static.ValidName(gname))
				ErrMsg = "Group name contains invalid characters";
			else if (owner.Level.Game.AccessControl.Groups.FindByName(gname) != None)
				ErrMsg = "Group name already used!";
			else if (gsec < 0)
				ErrMsg = "Negative security level is invalid";
			else if (gsec > owner.CurAdmin.MaxSecLevel())
				ErrMsg = "You cannot assign a security level higher than yours";
		
			Response.Subst("NameValue", owner.HtmlEncode(gname));
			Response.Subst("PrivTable", GetPrivsTable(gprivs));
			Response.Subst("GameSecValue", string(gsec));

			if (ErrMsg == "")
			{
				// All settings are fine, create the new Group.
				Group = owner.Level.Game.AccessControl.Groups.CreateGroup(gname, gprivs, byte(gsec));
				if (Group != None)
				{
					owner.CurAdmin.AddManagedGroup(Group);
					owner.Level.Game.AccessControl.Groups.Add(Group);
					owner.Level.Game.AccessControl.SaveAdmins();
				}
				else
					ErrMsg = "Exceptional error creating the new group";
			}
			
			if (ErrMsg != "")
				owner.StatusError(Response, ErrMsg);
		}
		else
			Response.Subst("PrivTable", GetPrivsTable(""));
		
		if (Group != None)
		{
			Response.Subst("PostAction", GroupsEditPage);
			Response.Subst("SubmitName", "mod");
			Response.Subst("SubmitValue", "Modify Group");
			Response.Subst("PageHelp", NoteGroupEditPage);
			Response.Subst("Section", "Modify an Administration Group");
		}
		else
		{
			Response.Subst("PostAction", GroupsAddPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", "Add Group");
			Response.Subst("Section", "Add New Administration Group");
			Response.Subst("PageHelp", NoteGroupAddPage);
		}
		owner.ShowPage(Response, GroupsEditPage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryGroupsEditPage(WebRequest Request, WebResponse Response)
{
local TribesAdminGroup Group;
local string ErrMsg, gname, gprivs;
local int gsec;

	if (owner.CanPerform("Gm"))
	{
		Response.Subst("Section", "Modify an Administration Group");

		Group = owner.Level.Game.AccessControl.Groups.FindByName(Request.GetVariable("edit"));
		if (Group != None)		// Do not let admins fake the system.
		{
			if (owner.CurAdmin.CanManageGroup(Group))
			{
				if (Request.GetVariable("mod") != "")
				{
					// Save the changes
					gname = Request.GetVariable("GroupName");
					gprivs = FixPrivs(Request, Group.Privileges);
					gsec = Clamp(int(Request.GetVariable("GameSec")), 0, 255);
					if (gname != Group.GroupName)
					{
						if (Group.ValidName(gname))
						{
							if (owner.Level.Game.AccessControl.Groups.FindByName(gname) == None)
								Group.GroupName = gname;
							else
								ErrMsg = "Group name already used!";
						}
						else
							ErrMsg = "Invalid characters in new group name";
					}

					if (ErrMsg == "")
					{
						if (gprivs != Group.Privileges)
							Group.SetPrivs(gprivs);

						Group.GameSecLevel = gsec;
						owner.Level.Game.AccessControl.SaveAdmins();
					}
				}
			
				if (ErrMsg != "")
					owner.StatusError(Response, ErrMsg);
			
				Response.Subst("NameValue", owner.HtmlEncode(Group.GroupName));
				Response.Subst("PrivTable", GetPrivsTable(Group.Privileges));
				Response.Subst("GameSecValue", string(Group.GameSecLevel));
				Response.Subst("PostAction", GroupsEditPage);
				Response.Subst("SubmitName", "mod");
				Response.Subst("SubmitValue", "Modify Group");
				Response.Subst("PageHelp", NoteGroupEditPage);
				owner.ShowPage(Response, GroupsEditPage);
			}
			else
				owner.ShowMessage(Response, "No Privileges", "You do not have the privileges to modify this group");
		}
		else
			owner.ShowMessage(Response, "Unknown Group", "The group you selected does not exist!");
	}
	else
		owner.AccessDenied(Response);
}

// Must not forget to show only the Users from groups that the admin can manage
function string GetUsersForBrowse(WebResponse Response)
{
local ObjectArray	Users;
local TribesAdminUser	User;
local string OutStr;
local int i;
local bool CanDelete;

	CanDelete = owner.CanPerform("Aa");
	Users = ManagedUsers();

	// Now, just make the users list a bunch of Rows
	if (Users.Count() == 0)
		return "<tr><td>** There are no admins to list **</td></tr>";


	OutStr = "<tr><td>Name</td><td>Privileges</td>";
	if (CanDelete)
		OutStr = OutStr$"<td>&nbsp;</td>";
	OutStr = OutStr$"</tr>";

	for (i = 0; i<Users.Count(); i++)
	{
		User = TribesAdminUser(Users.GetItem(i));
		
		Response.Subst("Username", owner.Hyperlink(UsersEditPage$"?edit="$owner.HtmlEncode(User.UserName), owner.HtmlEncode(User.UserName), owner.CanPerform("Ae|Aa")));
		Response.Subst("Privileges", User.Privileges);
		Response.Subst("Groups", "");
		Response.Subst("Managed", "");
		Response.Subst("Delete", "");
		// Build 1 Group Row
		if (owner.CanPerform("Ag"))
			Response.Subst("Groups", owner.Hyperlink(UsersGroupsPage$"?edit="$owner.HtmlEncode(User.UserName),"Groups", true));
		if (owner.CanPerform("Am"))
			Response.Subst("Managed", owner.Hyperlink(UsersMGroupsPage$"?edit="$owner.HtmlEncode(User.UserName),"Managed Groups", true));
		if (CanDelete)
			Response.Subst("Delete", owner.Hyperlink(UsersBrowsePage$"?delete="$owner.HtmlEncode(User.UserName), "Delete", true));

		OutStr = OutStr$Response.LoadParsedUHTM(owner.Path$"/users_row.inc");
	}
	return OutStr;
}

// Must not forget to show only the Groups that the admin can add users to
function string GetGroupsForBrowse(WebResponse Response)
{
local TribesAdminGroup	Group;
local TribesAdminGroupList Groups;
local string OutStr;
local int i;
local bool CanDelete, CanEdit;

	CanDelete = owner.CanPerform("Gd");
	CanEdit = owner.CanPerform("Ge");

	if (owner.CurAdmin.bMasterAdmin)
		Groups = owner.Level.Game.AccessControl.Groups;
	else
		Groups = owner.CurAdmin.ManagedGroups;

	if (Groups.Count() == 0)
		return "<tr><td>** There are no groups to list **</td></tr>";

	OutStr = "<tr><td>Name</td><td>Privileges</td><td>Game Sec Lvl</td>"$owner.StringIf(CanDelete,"<td>&nbsp;</td>","")$"</tr>";
	for (i=0; i<Groups.Count(); i++)
	{
		Group = Groups.Get(i);
		// Build 1 Group Row
		Response.Subst("Groupname", owner.Hyperlink(GroupsEditPage$"?edit="$owner.HtmlEncode(Group.GroupName),owner.HtmlEncode(Group.GroupName),true));
		Response.Subst("Privileges", Group.Privileges);
		Response.Subst("Gamesec", string(Group.GameSecLevel));
		Response.Subst("Delete", "");
		if (CanDelete)
		  Response.Subst("Delete", owner.Hyperlink(GroupsBrowsePage$"?delete="$owner.HtmlEncode(Group.GroupName), "Delete", true));

        OutStr = OutStr$Response.LoadParsedUHTM(owner.Path$"/groups_row.inc");
	}
	return OutStr;
}

function string GetPrivsHeader(string privs, string text, bool cond, string tag)
{
local string headfile;

	headfile="/privs_header.inc";
	if (cond)
		headfile="/privs_header_chk.inc";

	owner.Resp.Subst("Tag", tag);
	owner.Resp.Subst("Checked", owner.StringIf(Instr("|"$privs$"|", "|"$tag$"|") != -1, " checked", ""));
	owner.Resp.Subst("Text", text);

	return owner.Resp.LoadParsedUHTM(owner.Path$headfile);
}

function string GetPrivsItem(string privs, string text, bool cond, string tag, optional bool bReadOnly)
{
	if (!cond)
		return "";
	
	owner.Resp.Subst("Tag", tag);
	owner.Resp.Subst("Text", text);
	owner.Resp.Subst("Checked", owner.StringIf(Instr("|"$privs$"|", "|"$tag$"|") != -1, " checked", ""));

	if (bReadOnly)
		return owner.Resp.LoadParsedUHTM(owner.Path$"/privs_element_ro.inc");

	return owner.Resp.LoadParsedUHTM(owner.Path$"/privs_element.inc");
}

function ObjectArray ManagedUsers()
{
local ObjectArray Users;
local int i, j;
local TribesAdminGroup Group;
local TribesAdminUser User;
local TribesAdminGroupList Groups;

	Users = New(None) class'SortedObjectArray';	
	
	if (owner.CurAdmin.bMasterAdmin)
		Groups = owner.Level.Game.AccessControl.Groups;
	else
		Groups = owner.CurAdmin.ManagedGroups;
	
	for (i=0; i<Groups.Count(); i++)
	{
		Group = Groups.Get(i);
		for (j=0; j<Group.Users.Count(); j++)
		{
			User = Group.Users.Get(j);
			if (Users.FindTagId(User.UserName) < 0)
				Users.Add(User, User.UserName);
		}
	}
	return Users;
}

function string MakePrivsTable(TribesPrivilegeBase PM, string privs, bool bNoEdit)
{
local int pi, colcnt, maxcols;
local string mprivs, sprivs, mpriv, priv, OutStr;
local bool   bCan, bCanPriv, bCanEdit;

	mprivs=PM.MainPrivs;
	OutStr = "";
	pi = 0;
	maxcols=3;
	while (mprivs != "")
	{
		// Step 1: Check for a main priv type if the Manager can process anything
		mpriv = owner.NextPriv(mprivs);
		bCan = owner.CanPerform(mpriv);
		// If cant manage the whole group, check individually
		if (!bCan)
		{
			sprivs=PM.SubPrivs;
			while (!bCan && sprivs != "")
			{
				priv = owner.NextPriv(sprivs);
				if (Left(priv,1) == mpriv)
					bCan = owner.CanPerform(priv);
			}
		}

		// If we could manage anything, lets make checkboxes for them
		bCanEdit = false;
		if (!bNoEdit)
			bCanEdit = owner.CanPerform(mpriv);

		if (bCan)
			OutStr = OutStr$GetPrivsHeader(privs, PM.Tags[pi], bCanEdit, mpriv)$"<table><tr>";
			
		pi++;
		
		sprivs = PM.SubPrivs;
		colcnt = 0;

		while (sprivs != "")
		{
			priv = owner.NextPriv(sprivs);
			bCanPriv = owner.CanPerform(priv);

			if (bNoEdit)
				bCanEdit = false;
			else
				bCanEdit = bCanPriv;

			if (Left(priv,1) == mpriv)
			{
				if (bCan && bCanPriv)
				{
					colcnt++;
					if (colcnt > maxcols)
					{
						colcnt -= maxcols;
						OutStr = OutStr$"</tr><tr>";
					}

					OutStr = OutStr$GetPrivsItem(privs, PM.Tags[pi], true, priv, !bCanEdit);
				}

				pi++;
			}
		}
		if (bCan)
			OutStr = OutStr$"</tr></table>";
	}
	return OutStr;
}

function string GetPrivsTable(string privs, optional bool bNoEdit)
{
local string str;
local int i;

	// Start by getting all rows for known privilege groups
	str = "";
	for (i=0; i<owner.Level.Game.AccessControl.PrivManagers.Length; i++)
		str = str$MakePrivsTable(owner.Level.Game.AccessControl.PrivManagers[i], privs, bNoEdit);

	if (str == "")
		str = "You cannot assign privileges";
	return str;
}

function string FixPrivs(WebRequest Request, string oldprivs)
{
local string privs, myprivs, priv;

	if (owner.CurAdmin.bMasterAdmin)
		myprivs = owner.Level.Game.AccessControl.AllPrivs;
	else
		myprivs = owner.CurAdmin.MergedPrivs;

	// Before starting, remove privs i can manage
	privs = "";
	while (oldprivs != "")
	{
		priv = owner.NextPriv(oldprivs);
		if (Instr("|"$myprivs$"|", "|"$priv$"|") == -1)
		{
			if (privs == "")
				privs = priv;
			else
				privs = privs$"|"$priv;
		}
	}		
	
	while (myprivs != "")
	{
		priv = owner.NextPriv(myprivs);
		if (Request.GetVariable(priv) != "")
		{
			if (privs == "")
				privs = priv;
			else
				privs = privs$"|"$priv;
		}
	}
	return privs;
}

function string GetGroupOptions(TribesAdminGroupList Groups, string grpsel)
{
local int i;
local string OutStr, GrpName;
local StringArray	  GrpNames;

	if (Groups.Count() == 0)
		return "<option value=\"\">*** None ***</option>";

	// Step 1: Sort the groups
	GrpNames = new(None) class'SortedStringArray';
	for (i=0; i<Groups.Count(); i++)
		GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

	if (GrpNames.Count() == 0)
		return "<option value=\"\">*** None ***</option>";
		
	// Step 2: Build the group list
	OutStr = "";
	for (i=0; i<GrpNames.Count(); i++)
	{
		GrpName = GrpNames.GetItem(i);
		OutStr = OutStr$"<option value='"$GrpName$"'";
		if (GrpName == grpsel)
			OutStr = OutStr$" selected";
		OutStr = OutStr$">"$owner.HtmlEncode(GrpName)$"</option>";
	}
	return OutStr;
}

defaultproperties
{
	Title="Admins & Groups"
	DefaultPage="adminsframe"
	AdminsIndexPage="admins_menu"
	UsersHomePage="admins_home"
	UsersAccountPage="admins_account"
	UsersAddPage="users_add"
	UsersBrowsePage="users_browse"
	UsersEditPage="users_edit"
	UsersGroupsPage="users_groups"
	UsersMGroupsPage="users_mgroups"
	GroupsAddPage="groups_add"
	GroupsBrowsePage="groups_browse"
	GroupsEditPage="groups_edit"

	NoteUserHomePage="Welcome to Admins &amp; Groups Management"
	NoteAccountPage="Here you can change your password if required. You can also see which privileges were assigned to you by your manager."
	NoteUserAddPage="As an Admin of this server you can add new Admins and give them privileges. Make sure that the password assigned to the new Admin is not easy to hack."
	NoteUserEditPage="As an Admin of this server you can modify informations and privileges for another Admin that you can Manage."
	NoteUsersBrowsePage="Here you can see other Admins that you can manage and modify their privilege and groups assignment."
	NoteGroupAddPage="You can create new groups which will have a common set of privileges. Groups are used to give the same privileges to multiple Admins."
	NoteGroupEditPage="You can modify which privileges were assigned to this group. Note that you can only change privileges that you have yourself."
	NoteGroupsBrowsePage="Here you can see all the groups that you can manage, click on a group name to modify it."
	NoteGroupAccessPage="Here you can decide in which groups the selected admin will be part of. This will decide which base privileges this admin will have."
	NoteMGroupAccessPage="Here you can decide which groups this admin will be able to manage. He will be able to assign other admins to this group."
}
