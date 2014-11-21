//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Preferences tab for the animation browser...
//  
 
class SkelPrefsEditProps extends Engine.MeshObject
	native
	hidecategories(Object)	
	collapsecategories;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const int WBrowserAnimationPtr;

var(Interface) int         RootZero;
var(Interface) float       AnimSlomo;

cpptext
{
	void PostEditChange();

}


defaultproperties
{
     AnimSlomo=1.000000
}
