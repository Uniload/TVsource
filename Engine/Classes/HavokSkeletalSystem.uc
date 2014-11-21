// Havok physical system, imported from a HKE file (from modellers such as Max or Maya) 
// and associated with the skeletal mesh by name. This is most commonly used for
// ragdolls and rigidbody based deformable meshes.

class HavokSkeletalSystem extends HavokObject
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const transient int RigidBodySystemNumber;  //the system number (group for rbs in the level) for this body. Set internally. Do not change.
var const transient int RigidBodyRootBoneIndex; //the the index into the skel mesh of the physics root bone. Set internally. Do not change.
var const transient int RigidBodyLastBoneIndex; //the the index into the skel mesh of the physics root bone. Set internally. Do not change.
var const transient int CachedLastRigidBodyRootBoneIndex; // When we quit, this stores the root node so that we can bake it bake into the actor rot if we want.

// Intrusion driven updates will create a phantom double the size of the AABB of the system and only update its physical
// bodies from keyframes. 
var() bool useIntrusionDrivenUpdates "If false, the Havok representation of this skeleton's bones will be updated every frame to match the on-screen bone location. If true, they will only be updated when another Havok object enters a volume rougly twice the size of this actor's bounding volume. This is a performance optimization; in most cases you should leave it at the default setting.\r\n\r\nNOTE: This is automatically set to true at runtime for keyframed (animated) skeletal meshes.";  

// normally null, but used by keyframed skeletal meshes if intrusion updates are used.
var const transient int hkPhantom; 

// HKE to use for this skeletal actor.
var() string SkeletonPhysicsFile "File from which to load the Havok ragdoll skeleton (e.g., \"myRagdoll.hke\"). File path is relative to \"<ProjectRoot>\Content\HavokData\"."; 

#if IG_SHARED // new vars
// ckline: hkActive: is the body to start moving?
var()   bool	hkActive        "If true, the object will behave like a ragdoll as soon as the level starts (e.g., it will fall to the ground, etc). If false, it will be inactive until it is activated (i.e., it will not become a ragdoll until collides with it, etc.)";
var()	float	hkJointFriction	"Global control of ragdoll joint friction";
#endif

#if IG_TRIBES3	// rowan: work around for tearoff impulses being huge on ragdolls
var() float TearOffImpulseScale;
#endif

cpptext
{
#ifdef UNREAL_HAVOK
	void PostEditChange();
#endif

}


defaultproperties
{
     hkActive=True
     TearOffImpulseScale=1.000000
}
