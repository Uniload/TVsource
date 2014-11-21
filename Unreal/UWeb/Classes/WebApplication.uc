class WebApplication extends Core.Object;
	
// Set by the webserver
var LevelInfo Level;
var WebServer WebServer;
var string Path;

function Init();
function Cleanup();
#if IG_TRIBES3_ADMIN   // glenn: admin support
function bool PreQuery(WebRequest Request, WebResponse Response) { return true; }
function Query(WebRequest Request, WebResponse Response);
function PostQuery(WebRequest Request, WebResponse Response);
#else
function Query(WebRequest Request, WebResponse Response);
#endif
