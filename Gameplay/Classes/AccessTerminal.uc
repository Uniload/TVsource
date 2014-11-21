class AccessTerminal extends Engine.StaticMeshActor
	placeable;

var() Array<Material>	usedMaterials;
var() float				useableObjectCollisionHeight;
var() float				useableObjectCollisionRadius;
var() string			customPromptID	"Localisation ID for prompt loaded from [Prompt] seciton of mission .int";

var bool used;
var AccessTerminalUseableObject atuo;

function PostBeginPlay()
{
	atuo = Spawn(class'AccessTerminalUseableObject', self,, Location, Rotation);

	atuo.SetCollisionSize(useableObjectCollisionRadius, useableObjectCollisionHeight);

	// rowan: setup custom prompt text
	if (Len(customPromptID) != 0)
		atuo.prompt = static.Localize("Prompts", customPromptID, "Localisation\\GUI\\Prompts");
}

function useTerminal()
{
	used = true;

	Skins = usedMaterials;
}

function resetTerminal()
{
	used = false;

	Skins.Length = 0;
}

defaultproperties
{
     usedMaterials(1)=Shader'BaseObjects.UniversalControlScreenAShader'
     useableObjectCollisionHeight=80.000000
     useableObjectCollisionRadius=150.000000
     bNeedPostRenderCallback=True
     StaticMesh=StaticMesh'BaseObjects.UniversalControl'
     bStatic=False
}
