class MirrorCamera extends GenericExternalCamera
    native;

var() private float MirrorOffset "How much the camera is allowed to move in relation to the player's view rotation.  Larger numbers look more realistic, but can clip into geometry";
var() private Shader    ReferenceShader "If set, allows extra effects to be applied to the Mirror scripted texture.  A copy of the reference shader will be made, and the Diffuse material of the new shader will be set to this mirror's scripted texture.";

var private const transient ScriptedTexture   MirrorTexture;      // Scripted Texture we render into
var private const transient TexScaler         MirrorScaler;       // TexScales that "mirrors" the scripted texture
var transient const Material                  MirrorMaterial;     // Material wrapper for any fancy effects, must wrap the mirror panner in some way

native function Initialize();

native static function ScriptedTexture CreateNewScriptedTexture(string InName);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

event PostBeginPlay()
{
    Super.PostBeginPlay(); // Will call our Initialize function, which doesn't settimer...
    SetTimer(1.0 / UpdateRate,true); // So we set it here.
}

simulated event Destroyed()
{
    if (MirrorTexture != None)
    {
        // prevent GC failure due to hanging actor refs
        MirrorTexture.Client = None;
    }

	Super.Destroyed();
}

simulated function Rotator GetViewRotation()
{
    return Rotation;
}

simulated function Vector GetViewLocation()
{
    local Vector X, Y, Z;
    local Vector EyeLocation, ToPlayer;
    local Actor ViewActor; // unused
    local Rotator EyeRotation; // unused

    Level.GetLocalPlayerController().PlayerCalcView(ViewActor, EyeLocation, EyeRotation);
    ToPlayer = EyeLocation - Location; 
    GetAxes(Rotator(ToPlayer), X, Y, Z);

    // Translate the location along the player's forward vector, capped by MirrorOffset....
    return Location + X * -Min(VSize(ToPlayer)/5.0f, MirrorOffset);
}

cpptext
{
    UScriptedTexture* CreateScriptedTexture( const TCHAR* BaseName );

}


defaultproperties
{
     MirrorOffset=20.000000
     FOV=85
     DrawScale=0.500000
}
