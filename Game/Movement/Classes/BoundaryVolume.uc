// Boundary Volume class

class BoundaryVolume extends Engine.Volume native;

cpptext
{
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();
}

var (BoundaryVolume) bool Active;
var (BoundaryVolume) float DampingScale;
var (BoundaryVolume) float FrictionScale;

var bool LocalActive;

replication
{
	reliable if (ROLE == ROLE_Authority)
		Active;
}

simulated function PostBeginPlay()
{
	LocalActive = Active;
	Super.PostBeginPlay();
	RegisterBoundary(Active);
}

simulated function PostLoadGame()
{
    PostBeginPlay();
}

simulated function PostNetReceive()
{
	if (Active != LocalActive)
	{
		RegisterBoundary(Active);
		bNetNotify = false;
	}
}

simulated function EnableBoundary(bool Enable)
{
	Active = Enable;
	RegisterBoundary(Enable);
}

simulated native function RegisterBoundary(bool Enable);

function Trigger(Actor Other, Pawn EventInstigator)
{
    Active = !Active;
	RegisterBoundary(Active);
}

defaultproperties
{
    Active = true
    DampingScale = 1
    FrictionScale = 1
	bBlockHavok = true

	// net replication (needed for filtering)
	bNetNotify = true
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	NetUpdateFrequency=5

	// optimisation:
	bDisableTouch = true
	bUnlit = true
	bAcceptsProjectors = false

	// display
	RenderMaterial = Material'FX.BoarderShader'
	RenderMaterialWorldSize = (X=500,Y=500,Z=0)

	bReverseHavokTriangleWinding = true
}

