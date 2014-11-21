// such as
class compGrapplerRope extends Gameplay.GrapplerRope;

var() Material ropeGlowMaterial;

simulated function Material GetOverlayMaterial(int Index)
{
	log("rope texuter overlay: " $ ropeGlowMaterial);
     return ropeGlowMaterial;
}

defaultproperties
{
     ropeGlowMaterial=Shader'FX.ScreenShader'
}
