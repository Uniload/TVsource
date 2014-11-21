// ====================================================================
//  Class:  Engine.AdminBase
//  Parent: Core.Object
//
//  <Enter a description here>
// ====================================================================

class AdminBase extends Core.Object Within PlayerController
	abstract native;

var bool bAdmin;

function Created();     // glenn: hack must be called after construction
function DoLogin( string UserName, string Password );
function DoLogout();

defaultproperties
{
}
