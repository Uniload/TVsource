// Havok actor that imparts forces on the underlying body (s) when shot etc
// It also initializes the Actor fields to reasonable defaults for a 
// rigid body constructed from a StaticMesh.

class HavokActor extends Actor
	native
	placeable;

cpptext
{
#ifdef UNREAL_HAVOK
	virtual void Spawned();
#endif
}

var (Havok)	bool bAcceptsShotImpulse "If true, an impulse will be imparted to this object when it takes damage. The impulse will be scaled by the hkHitImpulseScale in the instigating DamageType";

 
// Default behaviour when shot is to apply an impulse and kick the KActor.
#if IG_SHARED    //tcohen: hooked, used by effects system and reactive world objects
function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional float projectileFactor)
#else
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
#endif
{
	local vector impulse;
	if( bAcceptsShotImpulse && damageType.default.hkHitImpulseScale > 0 )
	{
		if(VSize(momentum) < 0.001)
			return;
		
		impulse = Normal(momentum) * damageType.default.hkHitImpulseScale;
		HavokImpartImpulse(impulse, hitlocation);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	HavokActivate();
}


defaultproperties
{
	Texture=Texture'Engine_res.Havok.S_HkActor'
	bAcceptsShotImpulse=true
	DrawType=DT_StaticMesh
	Physics=PHYS_Havok
	bEdShouldSnap=True
	bStatic=False
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=False
    bProjTarget=True
	bBlockActors=True
	bBlockNonZeroExtentTraces=True
	bBlockZeroExtentTraces=True
	bBlockPlayers=True
	bWorldGeometry=False
	bBlockKarma=True
	bBlockHavok=True
	bAcceptsProjectors=True
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bNoDelete=true
	RemoteRole=ROLE_None
}

