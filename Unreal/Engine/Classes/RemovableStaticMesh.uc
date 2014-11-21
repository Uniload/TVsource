// RemovableStaticMesh
// A static mesh actor that can be removed from the level during gameplay. A static mesh with bStatic = false
class RemovableStaticMesh extends StaticMeshActor;

function PostBeginPlay()
{
	RepSkin = Skins[0];
}

defaultproperties
{
	bStatic = false
	bNetInitialRotation = true
	bAlwaysRelevant = true
}