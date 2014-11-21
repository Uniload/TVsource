class Mirror extends Actor
    HideCategories(Advanced, Mirrors, Events, Force, Karma, Havok, LightColor, Lighting, Movement, Object, Sound)
    placeable
    native;

cpptext 
{
	virtual void CheckForErrors();
    virtual void PostEditAdd(GroupFactory& Grouper);
	virtual void PostEditChange();
	virtual void PostEditLoad();
}

var private nocopy MirrorCamera MyCamera; // The MirrorCamera must be spawned by PostEditAdd() when the Mirror is placed
var() int MirrorSkinIndex "This is the Skin array index that the mirror texture will override.";

function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    assertWithDescription( MyCamera != None, "Error: MyCamera is none for "$Self$".  This is either an old instance of the mirror, or someone deleted the MirrorCamera that was auto-created when this Mirror was placed has been deleted. Please delete this Mirror, and place a new one." );  

    if (Skins.Length == 0)
        Skins.Length = MirrorSkinIndex;

    Skins[MirrorSkinIndex] = MyCamera.MirrorMaterial;
}

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'Editor_res.TexPropCube'
    DrawScale=0.15
    bIsMirror=true
    bEdShouldSnap=True
    bStatic=True
    bStaticLighting=false
    bShadowCast=True
    bCollideActors=True
    bBlockActors=True
    bBlockPlayers=True
    bBlockKarma=True
    bWorldGeometry=True
    CollisionHeight=+000001.000000
    CollisionRadius=+000001.000000
    bAcceptsProjectors=True
}
