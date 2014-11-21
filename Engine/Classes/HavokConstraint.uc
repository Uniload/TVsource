// Havok base class for Constraints.
// Some constraints use only a sub set of the given data.
// The constraint is between hkAttachedActorA and option hkAttachedActorB.
// You can also specify option sub parts of the actors by name. The subparts
// are only taken into account if the Mesh of the attached actor is skeletal 
// and the Physics of the attached Actor is PHYS_HavokSkeletal. In that way
// you can constrain ragdolls together, or to other rigid bodies or the world.


class HavokConstraint extends HavokActor
#if IG_SWAT
    hidecategories(Havok,LightColor,Lighting,Movement,Force,Display,Collision)
#endif
    abstract
	placeable
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var transient const int hkConstraintPtr;
var transient const bool hkInitCalled; 

// Actors joined effected by this constraint (could be NULL for 'World')
var(HavokConstraint) edfindable Actor hkAttachedActorA; // may be a sub system, like a skeletal mesh. If so, the subpoart name will be used.
// usually a bone name
var(HavokConstraint) name hkAttachedSubPartA "If hkAttachedActorA is a skeletal pawn and PHYS_HavokSkeletal, this option specifies the bone of the skeleton to which the constraint should attach"; 
var(HavokConstraint) edfindable Actor hkAttachedActorB; // may be a sub system, like a skeletal mesh. If so, the subpoart name will be used.
// usually a bone name
var(HavokConstraint) name hkAttachedSubPartB "If hkAttachedActorB is a skeletal pawn and PHYS_HavokSkeletal, this option specifies the bone of the skeleton to which the constraint should attach"; 

// Disable collision between joined objects. Will attempt to make a system group for them (fast filter) and will fall back to pairwise (slow) if there
// are too many system groups used (>32K) 
var(HavokConstraint) bool bDisableCollisions "If true, collisions between hkAttachedActorA and hkAttachedActorB will be disabled";

// Breakable constraints

// 0 == doesn't break
var(HavokConstraint) float fMaxForceToBreak "Maximum force required to break the constraint (i.e., un-attached the two actors from each other), in Newtons. If 0, the constraint will never break";

// Varing stength constraints

// 0 = no special (malleable) tau (strength)
var(HavokConstraint) float fSpecificStrength "Large impulses or forces can stretch all constraints; the speed of recovery is determined by the constraint's strength (or 'tau' value). Higher values mean that the constraint recovers more quickly. Values can range from 0 to 1"; 
// 0 = no special (malleable) damping.
var(HavokConstraint) float fSpecificDamping "The damping value governs how quickly the oscillation of a constraint settles down. Low values create springy behavior, while high values will reduce any oscillations very quickly with the size of the oscillations getting much smaller each time. Values can range from 0 to 1"; 

var(HavokConstraint) enum EAutoComputeConstraint
{
	HKC_DontAutoCompute, // Just use the Local values as specified.
	HKC_AutoComputeBothFromC, // This is most common in the editor. Compute both A and B local values from the transform for this Constraint Actor. Handy for initializing "as placed" in the editor.
	HKC_AutoComputeAFromC,    // Make the basis in A match the world basis of Constraint Actor (C)
	HKC_AutoComputeBFromC,    // Make the basis in B match the world basis of Constraint Actor (C). This is most common for orientation constraint on A to world (B), based on orientation of the constraint C. So set the B bassis to that of C and constrain.
	HKC_AutoComputeAFromB,    // Compute the local values for A from the values given for B
	HKC_AutoComputeBFromA     // Compute the local values for B from the values given for A
} AutoComputeLocals;

// Constraint position/orientation, as defined in each body's local reference frame
// Local to actor (or the actor subpart space if name given, ie: bone name), and are in Unreal space.
// May be Autocomputed from one another, or from the constraint actor itself.

// BodyA frame
var(HavokConstraint) vector LocalPosA;  // Local pivot point in A
var(HavokConstraint) vector LocalAxisA;  // Primary constraint axis in A
var(HavokConstraint) vector LocalPerpAxisA; // Secondary (perpendicular to Primary) axis for A

// BodyB frame
var(HavokConstraint) vector LocalPosB;  // Local pivot point in B
var(HavokConstraint) vector LocalAxisB; // Primary constraint axis in B
var(HavokConstraint) vector LocalPerpAxisB; // Secondary (perpendicular to Primary) axis for B

// Call this function when you change a parameter such as the attached bodies 
// recreates the constraint from scratch.
native function RecreateConstraint();

// Call this function when you change an updatable parameter (limits, positions, etc)
native function UpdateConstraintDetails();

// Called automatically when you update a constraint, but you can use it whenever you see fit.
native function ActivateAttachedBodies();

// Called automatically when you update a constraint, but you can use it whenever you see fit.
// It computes the Local* values based on the AutoComputeLocals enum.
native function ComputeLocalValues();

cpptext
{
#ifdef UNREAL_HAVOK
  
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();
	virtual void HavokScriptMoveUpdate(FLOAT dt);

	virtual void Spawned(); // override the default (rigidbody) one in HavokActor

	virtual void PostEditChange(); // this wil auto recreate the constraint if not in Editor
	virtual void PostEditMove();

	virtual void RecreateConstraint(); // call this if you change of the constraint data and the attached body names and change tto/from 0 for damping and strength values (requires extra constraint layer to be changed)
    virtual void UpdateConstraintDetails(); // call this if you just change of the updateable constraint data (limits, positions etc, not the attached bodies though)
	virtual void ActivateAttachedBodies(); // called automatically when you update the constraint, but you can use it anytime.
	virtual void AutoComputeLocalValues(); // compute the Local Axis based on some set other axis (either from the other Actor or from this constraint actor itself). Called automatically on create and update.
	
	virtual void PrivateSetupExtraData(); // internal call
	virtual void PrivateUpdateExtraData(); // internal call
	virtual void* GetRigidBodyPtrA(); // internal call
	virtual void* GetRigidBodyPtrB(); // internal call
	virtual void* GetBaseConstraint(); // internal call

	virtual void CheckForErrors(); // used for checking that this constraint is valid during map build
	virtual void RenderEditorSelected(FLevelSceneNode* SceneNode,FRenderInterface* RI, FDynamicActor* FDA);
	virtual UBOOL CheckOwnerUpdated();

#endif

}


defaultproperties
{
     bDisableCollisions=True
     AutoComputeLocals=HKC_AutoComputeBothFromC
     LocalAxisA=(X=1.000000)
     LocalPerpAxisA=(Y=1.000000)
     LocalAxisB=(X=1.000000)
     LocalPerpAxisB=(Y=1.000000)
     DrawType=DT_Sprite
     bHidden=True
     bNoDelete=False
     Texture=Texture'Engine_res.Havok.S_HkConstraint'
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockKarma=False
     bBlockHavok=False
}
