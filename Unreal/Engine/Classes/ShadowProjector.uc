//
//	ShadowProjector
//

class ShadowProjector extends Projector
	native;

var() Actor					ShadowActor;
var() vector				LightDirection;
var() float					LightDistance;
var() bool					RootMotion;
var() bool					bBlobShadow;
var() bool					bShadowActive;
var ShadowBitmapMaterial	ShadowTexture;

#if IG_DYNAMIC_SHADOW_DETAIL
var() int					Resolution;
native final function UpdateDetailSetting();
#endif

//
//	PostBeginPlay
//

event PostBeginPlay()
{
	Super(Actor).PostBeginPlay();
}

//
//	Destroyed
//

event Destroyed()
{
	if(ShadowTexture != None)
	{
		ShadowTexture.ShadowActor = None;
		
		if(!ShadowTexture.Invalid)
			Level.ObjectPool.FreeObject(ShadowTexture);

		ShadowTexture = None;
		ProjTexture = None;
	}

	Super.Destroyed();
}

//
//	InitShadow
//

function InitShadow()
{
	// initialise with blob texture. we will switch to actual projector first time we are renderer
	ProjTexture = class'ShadowBitmapMaterial'.default.BlobShadow;
	AttachProjector();
}

function CreateShadowBitmap()
{
	local Plane		BoundingSphere;

	if(ShadowActor != None && ShadowTexture == None)
	{
		BoundingSphere = ShadowActor.GetRenderBoundingSphere();
		FOV = Atan(BoundingSphere.W * 2 + 160, LightDistance) * 180 / Pi;

		ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'ShadowBitmapMaterial'));
//		log("ALLOCATING SHADOW FOR "$ShadowActor);

		ProjTexture = ShadowTexture;

		if(ShadowTexture != None)
		{
#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: variable resolution
			ShadowTexture.SetResolution(Resolution);
#endif
			SetDrawScale(LightDistance * Tan(0.5 * FOV * Pi / 180) / (0.5 * ShadowTexture.USize));

			ShadowTexture.Invalid = False;
			ShadowTexture.bBlobShadow = bBlobShadow;
			ShadowTexture.ShadowActor = ShadowActor;
			ShadowTexture.LightDirection = Normal(LightDirection);
			ShadowTexture.LightDistance = LightDistance;
			ShadowTexture.LightFOV = FOV;
            ShadowTexture.CullDistance = CullDistance; 

			Enable('Tick');
		}
		else
			Log(Name$".InitShadow: Failed to allocate texture");
	}
	else
		Log(Name$".InitShadow: No actor");
}

//
//	UpdateShadow
//

native final function UpdateShadow();

//
//	Tick
//

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if (ShadowTexture != None)
		UpdateShadow();
}

simulated event PreRenderCallback()
{
	// on demand initialisation
	if (ShadowTexture == None && !bBlobShadow)
		CreateShadowBitmap();

	// update root motion position now
	if (ShadowTexture != None)
		SetLocation(ShadowTexture.GetShadowLocation());
	SetRotation(Rotator(Normal(-LightDirection)));

	// must call this after setting location/rotation
	UpdateMatrix();	

#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: handle dynamic detail changes
	UpdateDetailSetting();
#endif
}

#if IG_SHARED // ckline: selectively prevent actors from receiving ShadowProjector shadows
simulated event Touch( Actor Other )
{
	if(Other==None || !Other.bAcceptsShadowProjectors)
		return;

    Super.Touch(Other);
}
#endif

//
//	Default properties
//

defaultproperties
{
	bShadowActive=True
	bProjectActor=False
	bProjectOnParallelBSP=True
	bProjectOnAlpha=True
	bClipBSP=True
	bGradient=True
	bStatic=False
	bOwnerNoSee=True
	bBlobShadow=False
	RemoteRole=ROLE_None
    CullDistance=4800.0
    bDynamicAttach=True
    bCollideActors=False
	bCollideWorld=False

#if IG_DYNAMIC_SHADOW_DETAIL	// rowan: variable resolution
	Resolution = 128
#endif
#if IG_TRIBES3	// rowan: we never use this...small speedup
	bProjectParticles=False
#endif
}