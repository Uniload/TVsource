class CutsceneCharacter extends Character;

function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (weapon != None)
	{
		weapon.Destroy();
		weapon = None;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

defaultproperties
{
	Physics = PHYS_None
	bCollideActors = false
	bCollideWorld = false
	bBlockActors = false
	bBlockPlayers = false
	bPhysicsAnimUpdate = false
	bUseRootMotionBound = true
	bStasis = false
	MaxLights = 8
	BumpmapLODScale = 0
	ShadowLightDistance = 500

    LandMovementState = ""
}
