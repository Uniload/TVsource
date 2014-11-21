class ChrisPawn extends Engine.Pawn;

var Name WepAttachBone;	// Name of the bone to attach the weapon to

simulated event PostBeginPlay()
{
	local Weapon Gun;

//	Gun = Spawn( class'UDNContent.Zapper' );
	if( Gun != None )
	{
		Gun.GiveTo(self);
		if ( Gun != None )
		Gun.PickupFunction(self);
		Gun.GiveAmmo(self);
	}
}


function Fire( optional float F )
{
	local Engine.Actor C;
	local vector startVel;
	startVel.Y = 500;
	ForEach AllActors(class 'Engine.Actor', C)
	{
	// 
		if( (C.Physics != PHYS_HavokSkeletal) && 
		     (C.HavokData!=None) &&
		     (C.HavokData.IsA('HavokSkeletalSystem')) )
		{
			C.SetPhysics( PHYS_HavokSkeletal );	// to ragdoll
			
			C.HavokSetLinearVelocityAll( startVel );
		}
		else if( C.Physics == PHYS_HavokSkeletal ) // kill havok.
			C.SetPhysics( PHYS_None );		// from ragdoll
	}

	Super.Fire(F);
}


function name GetWeaponBoneFor(Inventory I)
{
	return WepAttachBone;
}

simulated function PlayWaiting()
{
	PlayAnim('idleknukles');
}

defaultproperties
{
	Mesh=SkeletalMesh'UDN_CharModels_K.GenericMale'
	MovementAnims(0)="frun"
	MovementAnims(1)="brun"
	MovementAnims(2)="lrun"
	MovementAnims(3)="rrun"
	bPhysicsAnimUpdate=true
	bHavokCharacterCollisions=false
	bBlockHavok=false;	
	bCollideActors=false;
	
//	WepAttachBone="Bip02 L Arm"
}