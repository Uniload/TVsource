//=============================================================================
// Ambient sound, sits there and emits its sound.  This class is no different 
// than placing any other actor in a level and setting its ambient sound.
//=============================================================================
class AmbientSound extends Keypoint;

// Import the sprite.

defaultproperties
{
     RemoteRole=ROLE_None
     Texture=Texture'Engine_res.S_Ambient'
     bTriggerEffectEventsBeforeGameStarts=True
     bNeedLifetimeEffectEvents=True
}
