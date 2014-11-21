//
// DynamicObject Class
// 
// - Destroyable object
// - Chunks are large child objects in Karma physics
// - Fragments are small child objects in the new physics system
// - Sounds and effects have been removed pending the new sound and effects system integration
//

class DynamicObject extends Engine.HavokActor 
	native 
	placeable;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var (DynamicObject) float   Mass			"The mass of the object (kg)";
var (DynamicObject) float   Elasticity      "The elasticity [0,1]";
var (DynamicObject) float   friction		"The amount of friction [0,1]";
var (DynamicObject) float   LinearDamping   "Linear Damping [0,1] 0 = no damping";
var (DynamicObject) float   AngularDamping  "Angular Damping [0,1] 0 = no damping";
var (DynamicObject) float	Health			"The amount of health in the object";
var (DynamicObject) bool	Invulnerable	"Object will be invulnerable to weapon attacks";
var (DynamicObject) bool	Blocking	    "Blocks players and collide with other objects";
var (DynamicObject) bool	Stationary		"The object is stationary and cannot move";
var (DynamicObject) bool	Enabled			"Start enabled in physics right away";
var (DynamicObject) bool	Shadows			"Use projected shadows with this object (expensive)";
var (DynamicObject) bool	Volatile		"Object will explode immediately on collision or when hit with a weapon";
var (DynamicObject) bool	Freeze		    "Child objects all freeze immediately on spawning (useful for art testing)";
var (DynamicObject) bool    FadeOut		    "Fadeout object when destroyed (requires material to be setup correctly)";
var (DynamicObject) bool	LimitedLife		"If true, object will only hang around for Lifetime amount of time after spawning";
var (DynamicObject) float	Lifetime		"Object will only appear in the world for this long before fading out";		
var (DynamicObject) bool	Explosion     	"Launch child objects with initial explosion (true/false)";
var (DynamicObject) float   ExplosionForce	"Force applied to child objects when this object is destroyed";

var (DynamicObject) array< class<DynamicObject> > Children		"Child objects spawned when this object is destroyed";

var (DynamicObject) array< class<Explosion> > Explosions        "Explosion objects spawned when this object is destroyed";

var array<ColorModifier> Style;
var bool StyleCreated;

var bool FadingOut;
var float FadeOutAlpha;
var float FadeOutTime;
var float FadeOutLength;

var bool NextVersionPending;
var bool NextVersionCalled;	

// currently can switch of dynamic on minspec machine
enum EScalabilitySetting
{
	DS_NoDynamics,
	DS_Full,
};

overloaded function Construct( actor Owner, optional optional name Tag, 
				               optional vector Location, optional rotator Rotation, optional float Scale)
{
    Label = Tag;
	setNativeActorData(Scale);
	super.construct(Owner, Tag, Location, Rotation);
    Label = Tag;
}

// this is used to set script const data in the Construct call
native final function setNativeActorData(float Scale);

event PreBeginPlay()
{
	// local data -> actor

	bActorShadows = Shadows;
	
	if (!Blocking) 
        SetCollision(false, false, false);

	// force stationary if scalability says so
	if (GetScalabilitySetting() == DS_NoDynamics)
		Stationary = true;

	if (Stationary)
	{
		SetPhysics(PHYS_None);
	}
	else
	{
		// initially inactive (to stop decorations falling off walls etc)
		HavokActivate(Enabled);
	}

	Super.PreBeginPlay();
}

static simulated function PrecacheDynamicObjectRenderData(LevelInfo Level, class<DynamicObject> DynClass)
{
	local int i;

	if (DynClass.default.StaticMesh != None)
	{
		Level.AddPrecacheStaticMesh(DynClass.default.StaticMesh);
//		Log("PRECACHING DYNAMICOBJECT MESH "$DynClass.default.StaticMesh.Name);
	}

	// recurse through children
    for (i=0; i<DynClass.default.Children.Length; i++)
	{
		if (DynClass.default.Children[i] != None)
			PrecacheDynamicObjectRenderData(Level, DynClass.default.Children[i]);
	}
}

simulated function UpdatePrecacheRenderData()
{
	Super.UpdatePrecacheRenderData();
	PrecacheDynamicObjectRenderData(Level, Class);
}

event Tick(float DeltaTime)
{
    if (NextVersionPending)
	{
        NextVersion();
	}
    
	if (FadingOut)
	{
        FadeOutTime += DeltaTime;
        FadeOutAlpha = (1 - FadeOutTime / FadeOutLength) * 255;
        SetAlpha(FadeOutAlpha);
	}

	if (FadeOutAlpha<=0)
	{
        Destroy();
	}

	if (!FadingOut && LimitedLife)
	{
		LifeTime -= DeltaTime;
		if (LifeTime <= 0)
			Remove();
	}
}


function Trigger(Actor Other, Pawn EventInstigator)
{
	Health = 0;
    NextVersion();
}



function StartFadeOut()
{
	// start fade out

	CreateAlphaStyle();
	FadingOut = true;
}


event NextVersion()
{
	if (NextVersionCalled)
		return;

	if (!FadingOut)
	{
		NextVersionCalled = true;

		// trigger event on next version
		triggerEvent(Event, self, None);

		// handle child objects
		if (Children.Length>0)
		{
			// destroy self and spawn children
			SpawnChildren();
		}

		Remove();
	}
}


function Explode()
{
    local int i;

	local Explosion ExplosionObject;

	local String SocketName;
	local Vector SocketPosition;
	local Rotator SocketRotation;
	local Vector SocketScale;

    for (i=0; i<Explosions.length; i++)
    {
        GetExplosionSocketName(i, SocketName);

        if (getSocket(SocketName, SocketPosition, SocketRotation, SocketScale))
    		ExplosionObject = spawn(Explosions[i], , , SocketPosition, SocketRotation);
        else
		    ExplosionObject = spawn(Explosions[i], , , unifiedGetCOMPosition(), Rotation);

		ExplosionObject.Trigger(self, None);
    }
}

function Remove()
{
    TriggerEffectEvent('Destroyed');

	Explode();

	if (FadeOut)
		StartFadeOut();
	else
		Destroy();
}

function SpawnChildren()
{
    local int i;

    for (i=0; i<Children.Length; i++)
        SpawnChild(i);
}


function SpawnChild(int Index)
{
	local DynamicObject Child;

	local String SocketName;
	local Vector SocketPosition;
	local Rotator SocketRotation;
	local Vector SocketScale;

	local String ChildName;
    
	local Vector Impulse;
	
	if (Children[Index] == None)
		return;

    GetChildSocketName(Index, SocketName);
    
	if (GetScalabilitySetting() == DS_NoDynamics && !Children[Index].default.Stationary)
		return;
	
    ChildName = Label$"_"$Index;

    if (getSocket(SocketName, SocketPosition, SocketRotation, SocketScale))
        Child = new(Outer) Children[Index](Self, Name(ChildName), SocketPosition, SocketRotation, DrawScale * SocketScale.X);
    else
        Child = new(Outer) Children[Index](Self, Name(ChildName), Location, Rotation, DrawScale);

	Child.bClientHavokPhysics = bClientHavokPhysics;

	if (Child.Stationary || Freeze)
	{
	    Child.setPhysics(PHYS_None);
	}
	else if (Explosion)
	{
	    Impulse = Child.unifiedGetComPosition() - unifiedGetComPosition();
	    
	    if (Impulse==vect(0,0,0))
	        impulse = VRand();
		
		Impulse += vect(0,0,0.5);
		
		Impulse = Normal(Impulse);
		
		Impulse *= (FRand()*0.25 + 1.0) * ExplosionForce;

		Child.HavokImpartImpulse(Impulse, Child.unifiedGetCOMPosition() + VRand()*5);
	}
}

// scalability queries of main level config
native function EScalabilitySetting GetScalabilitySetting();

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(Killer != None && Killer.Pawn != None)
		dispatchMessage(new class'MessageDestroyed'(Killer.Pawn.label, label));
	else
		dispatchMessage(new class'MessageDestroyed'(label, label));
}

// rowan: had to override this, as we set bSkipEncroachment as an optimisation, but still want to take damage form projectiles (base class returns !bSkipEncroachment)
simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	return bProjTarget;
}

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	local Controller Killer;
	Killer = None;
	if (EventInstigator != None)
		Killer = EventInstigator.Controller;

	if (!Stationary) 
	    HavokImpartImpulse(Momentum, HitLocation);

	if (Invulnerable)
		return;

    if (Volatile)
    {
        NextVersion();

		// post destroyed message
		Died(Killer, damageType, HitLocation);
    }
    else if (Health>0)
	{
		Health -= Damage;

		if (Health<=0) 
		{
			NextVersion();

			// post destroyed message
			Died(Killer, damageType, HitLocation);
		}
	}
}


function CreateAlphaStyle()
{
	local int i;

	if (Skins.Length==0) 
        LoadSkinsFromMaterials();

	if (!StyleCreated)
	{
		for(i=0; i<Skins.Length; i++)
		{
			if (Skins[i] == none)
				break;

			if (!StyleCreated)
				Style[i] = new(none) class'ColorModifier'();

			Style[i].Material = Skins[i];
			Style[i].Color.A = 255;

			Skins[i] = Style[i];
		}

		StyleCreated = true;
	}
}


function SetAlpha(byte Amount)
{
	local int i;

	if (StyleCreated)
	{
		for (i=0; i<Style.Length; i++)
		{
			Style[i].Color.A = Amount;
		}
	}
}    


function unifiedAddImpulse(Vector impulse)
{
	if (!Stationary)
        super.unifiedAddImpulse(impulse);
}


function unifiedAddImpulseAtPosition(Vector impulse, Vector position)
{
	if (!Stationary)
		super.unifiedAddImpulseAtPosition(impulse, position);
}


function unifiedAddForce(Vector force)
{
	if (!Stationary)
		super.unifiedAddForce(force);
}


function unifiedAddForceAtPosition(Vector force, Vector position)
{
	if (!Stationary)
		super.unifiedAddForceAtPosition(force, position);
}


function unifiedAddTorque(Vector torque)
{
	if (!Stationary)
		super.unifiedAddTorque(torque);
}


native function LoadSkinsFromMaterials();
native function Initialize(float Scale, StaticMesh Mesh);
native function GetChildSocketName(int Index, out String Name);
native function GetExplosionSocketName(int Index, out String Name);

cpptext
{
	virtual void initialiseHavokDataObject();	
	virtual void HavokPreSyncCallback(const FVector& deltaPos);

}


defaultproperties
{
     Mass=50.000000
     Elasticity=0.300000
     friction=0.800000
     AngularDamping=0.050000
     Health=100.000000
     Blocking=True
     Shadows=True
     Explosion=True
     ExplosionForce=10000.000000
     FadeOutAlpha=255.000000
     FadeOutLength=0.500000
     StaticMesh=StaticMesh'PhysicsObjects.Cube'
     bActorShadows=True
     bNoDelete=False
     bAcceptsProjectors=False
     bNeedLifetimeEffectEvents=True
}
