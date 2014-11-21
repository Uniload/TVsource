class AnimNotify_Sound extends AnimNotify
	native;

var() sound Sound;
var() float Volume;
var() int Radius;

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
     Volume=1.000000
}
