class TexCoordSource extends TexModifier
	native
	editinlinenew
	collapsecategories;

var() int	SourceChannel;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
	void PostEditChange();

}


defaultproperties
{
     TexCoordSource=TCS_Stream0
     MaterialType=MT_TexCoordSource
}
