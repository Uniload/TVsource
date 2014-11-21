//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
	abstract
	placeable
	native;

defaultproperties
{
     bStatic=True
     bHidden=True
     Texture=Texture'Engine_res.S_Keypoint'
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
