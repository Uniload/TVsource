//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Sequence / Mesh editor object to expose/shuttle only selected editable 
//  

class SequEditProps extends Engine.MeshObject
	hidecategories(Object)
	native;	

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const int WBrowserAnimationPtr;

var(SequenceProperties) float	Rate;
var(SequenceProperties) float	Compression;
var(SequenceProperties) float	Velocity;
var(SequenceProperties) EAnimCompressMethod ReCompressionMethod;
var(SequenceProperties) name	SequenceName;
var(Groups) array<name>			Groups;

cpptext
{
	void PostEditChange();

}


defaultproperties
{
     Compression=1.000000
}
