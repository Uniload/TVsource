// Boundary Volume class

class BoundaryVolume extends Engine.Volume native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

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

cpptext
{
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();

}


defaultproperties
{
     Active=True
     DampingScale=1.000000
     FrictionScale=1.000000
     bReverseHavokTriangleWinding=True
     RenderMaterial=Shader'FX.BoarderShader'
     RenderMaterialWorldSize=(X=500.000000,Y=500.000000)
     bDisableTouch=True
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=5.000000
     bUnlit=True
     bBlockHavok=True
     bNetNotify=True
}
