//=============================================================================
// The Havok Cone Limit class
// By using a seperate constraint on top a normal instead of a single constraint
// that has a limit in it (eg LimitedHingeConstraint) you are wasting CPU cycles!
//=============================================================================

class HavokConeLimitConstraint extends HavokConstraint
    native
    placeable;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(HavokConstraint) float hkHalfAngle; // ( 65535 = 360 deg )

// Internal index references. Do not alter.
 var const transient int basisAIndex;
 var const transient int basisBIndex;
 var const transient int coneIndex;
//

cpptext
{
#ifdef UNREAL_HAVOK
	virtual bool HavokInitActor();
	virtual void UpdateConstraintDetails();
#endif

}


defaultproperties
{
     hkHalfAngle=8200.000000
     AutoComputeLocals=HKC_AutoComputeBFromC
     Texture=Texture'Engine_res.Havok.S_HkConeLimitConstraint'
     bDirectional=True
}
