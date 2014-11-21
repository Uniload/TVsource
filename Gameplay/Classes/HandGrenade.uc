class HandGrenade extends TimeChargeUpWeapon;

var() StaticMesh droppedMesh;

function TravelPreAccept()
{
	Character(Owner).addGrenades(self);
}

simulated function extractFirstPersonMeshData()
{
	// Hand grenade weapon doesn't have a mesh so do nothing
}

simulated function Tick(float DeltaTime)
{
	if (rookMotor == None)
	{
		initialiseRookMotor();
	}
}

function initialiseVelocity(Projectile p, Vector InitialVelocity)
{
	super.initialiseVelocity(p, InitialVelocity * (charge * chargeScale + 1.0));
}

simulated state Held
{
	simulated function BeginState()
	{
		super.BeginState();
		GotoState('Idle');
	}
}

function bool canPickup(Character potentialOwner)
{
	if (potentialOwner.armorClass == None)
		return false;

	return potentialOwner.armorClass.static.maxGrenades() > 0 &&
		   potentialOwner.armorClass.static.getHandGrenadeClass() == class;
}

function bool needPrompt(Character potentialOwner)
{
	// Never switch grenades so don't prompt
	return false;
}

function pickup(Character newOwner)
{
	if (newOwner.altWeapon == None)
	{
		SetTimer(0.0, false);
		setMovementReplication(false);
		newOwner.addGrenades(self);
		rookOwner = newOwner;
		rookMotor = newOwner.motor;
		equipmentGone();
	}
	else if (newOwner.altWeapon.class == class)
	{
		ammoCount = newOwner.altWeapon.increaseAmmo(ammoCount);

		if (ammoCount <= 0)
		{
			equipmentGone();
			Destroy();
		}
	}
}

function int getMaxAmmo()
{
	return Character(rookOwner).armorClass.static.maxGrenades();
}

simulated function setDroppedMesh()
{
	SetDrawType(DT_StaticMesh);
	SetStaticMesh(droppedMesh);
}

defaultproperties
{
     droppedMesh=StaticMesh'weapons.HandgrenadeDropped'
     maxCharge=3.000000
     chargeScale=0.300000
     bShowChargeOnHUD=True
     ammoCount=5
     roundsPerSecond=1.000000
     projectileClass=Class'HandGrenadeProjectile'
     projectileVelocity=800.000000
     projectileInheritedVelFactor=1.000000
     aimClass=Class'AimArcWeapons'
     animPrefix="HandGrenade"
     equipped=True
     animClass=Class'CharacterEquippableAnimator'
}
