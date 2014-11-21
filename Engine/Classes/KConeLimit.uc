//=============================================================================
// The Cone Limit joint class.
//=============================================================================

class KConeLimit extends KConstraint
    native
    placeable;

//cpptext
//{
//#ifdef WITH_KARMA
//    virtual void KUpdateConstraintParams();
//#endif
//}
//
//var(KarmaConstraint) float KHalfAngle; // ( 65535 = 360 deg )
//var(KarmaConstraint) float KStiffness;
//var(KarmaConstraint) float KDamping;
//
////native final function KSetHalfAngle(float HalfAngle);
////native final function KSetStiffness(float Stiffness);
////native final function KSetDamping(float Damping);
//
//
//defaultproperties
//{
//    KHalfAngle=8200 // about 45 deg
//    KStiffness=50
//
//    Texture=Texture'Engine_res.S_KConeLimit'
//    bDirectional=True
//}

defaultproperties
{
}
