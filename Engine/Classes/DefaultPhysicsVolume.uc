//=============================================================================
// DefaultPhysicsVolume:  the default physics volume for areas of the level with 
// no physics volume specified
//=============================================================================
class DefaultPhysicsVolume extends PhysicsVolume
	native
	notplaceable;

function Destroyed()
{
	Log(self$" destroyed!");
	assert(false);
}

defaultproperties
{
     bStatic=False
     bNoDelete=False
}
