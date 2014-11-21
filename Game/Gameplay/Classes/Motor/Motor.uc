// Motor
// Motor objects expose an interface that enables players or AIs to move 
// and perform actions in the world.
//
// An object's Motor should expose the most atomic set of actions that can be used to 
// control that object.
// 
// The functions of a motor should also constrain input to valid values, i.e. the user
// should not be able to jet without a jetpack.
 
class Motor extends Engine.Actor
	native;

defaultproperties
{
	bHidden		= true
	DrawType	= DT_None
	RemoteRole	= ROLE_None
}