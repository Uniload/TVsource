class InventoryStationPlatform extends Engine.Actor
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var InventoryStation ownerInventoryStation;

function PostBeginPlay()
{
	super.PostBeginPlay();

	// Base is set to the owner inventory station in UnrealEd so simply grab from Base value
	ownerInventoryStation = InventoryStation(Base);
	if (ownerInventoryStation == None)
		warn(self @ "is not based on an inventory station");
}

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	// forward to owner inventory station
	if (ownerInventoryStation != None)
		ownerInventoryStation.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

simulated function Actor getHurtRadiusParent()
{
	return ownerInventoryStation;
}

cpptext
{
	virtual UMaterial* GetSkin( INT Index );

	virtual void PostRenderCallback(UBOOL InMainScene);

}


defaultproperties
{
     bNeedPostRenderCallback=True
     DrawType=DT_Mesh
     bAlwaysRelevant=True
     bReplicateMovement=False
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'BaseObjects.InventoryStationBase'
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bLockLocation=True
}
