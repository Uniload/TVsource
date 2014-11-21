class TribesImageServer extends UWeb.ImageServer;

event Query(WebRequest Request, WebResponse Response)
{
local string AdminRealm;

	AdminRealm = class'TribesServerAdmin'.default.AdminRealm;

// TODO: auth!

	// Check authentication:
/*	User = Level.Game.AccessControl.AdminManager.WebLogin(Request.UserName, Request.Password);
	if ( User == None)
	{
		Response.FailAuthentication(AdminRealm);
		return;
	}
	*/
	Super.Query(Request, Response);
//	Level.Game.AccessControl.AdminManager.WebLogout(User);
}

defaultproperties
{
}
