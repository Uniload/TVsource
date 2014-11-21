class InventoryStationPlatform extends Engine.Actor
	native;

cpptext
{
	virtual UMaterial* GetSkin( INT Index );

	virtual void PostRenderCallback(UBOOL InMainScene);
}

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

defaultProperties
{
	Mesh			= SkeletalMesh'BaseObjects.InventoryStationBase'
	DrawType		= DT_Mesh

	bLockLocation	= true

	bNetInitialRotation	= true
	bAlwaysRelevant = true
	bReplicateMovement = false
	bAcceptsProjectors = false
	bNeedPostRenderCallback = true

	bCollideActors = true
	bBlockPlayers = true
	bBlockActors = true

	RemoteRole = ROLE_SimulatedProxy

	bProjTarget = true
}