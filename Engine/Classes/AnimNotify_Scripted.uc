class AnimNotify_Scripted extends AnimNotify
	native
	abstract;

event Notify( Actor Owner );

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
	// AnimNotify interface.
	virtual void Notify( UMeshInstance *Instance, AActor *Owner );

}


defaultproperties
{
}
