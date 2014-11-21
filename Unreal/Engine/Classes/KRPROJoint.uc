//=============================================================================
// The Relative Position Relative Orientation joint class. Added by Alex.
//=============================================================================

class KRPROJoint extends KConstraint
	native
	placeable;

//// negative value implies infinity
//var float xLinearStrength;
//var float yLinearStrength;
//var float zLinearStrength;
//
//// negative value implies infinity
//var float xAngularStrength;
//var float yAngularStrength;
//var float zAngularStrength;
//
//cpptext
//{
//#ifdef WITH_KARMA
//    virtual void KUpdateConstraintParams();
//#endif
//}
//
//defaultproperties
//{
//	Texture=Texture'Engine_res.S_KBSJoint'
//
//	bNoDelete=false
//
//	xLinearStrength=-1
//	yLinearStrength=-1
//	zLinearStrength=-1
//
//	xAngularStrength=-1
//	yAngularStrength=-1
//	zAngularStrength=-1
//}