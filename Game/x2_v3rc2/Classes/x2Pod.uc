class x2Pod extends VehicleClasses.VehiclePod;

var () float Energy;
var () float EnergyMax;
var () float EnergyRegenPerSec;


	
/*function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation,  Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	local class<ProjectileDamageType> pdt;
	local int positionI;
	local Controller killer;
	local Rook killerRook;
	local ModeInfo mode;
	local Rook instigatedRook;

	instigatedRook = Rook(instigatedBy);

	// catch case we have been torn off and this is called
	if (Level.NetMode == NM_Client)
		return;

	// disable invincibility if attacked by our own team
	if (instigatedRook != None && instigatedRook.team() == team())
		bInvincible = false;

	// do nothing if in god mode or invincible
	if (InGodMode() || bInvincible)
		return;

	pdt = class<ProjectileDamageType>(damageType);

	if (pdt != None)
		Damage *= pdt.default.vehicleDamageModifier;
	
	//shield code
	if(Energy >= Damage)
	{
		Energy -= Damage;//subtract damage from energy
		Health += Damage;//undo damage taken
	}
	else
	{
		Health += Energy;//Since energy < damage, just heal what we can
		Energy = 0;//we used all our shields
		
	}

	// avoid damage healing the car
	if (Damage < 0)
		return;

	// vehicle is dead
	if ((Health - Damage) <= 0)
	{
		aboutToDie();

		// have all occupants leave
		for (positionI = 0; positionI < positions.length; ++positionI)
		{
			if (positions[positionI].occupant != None)
				driverLeave(true, positionI);
		}

		// Notify mode for stat-tracking purposes
		mode = ModeInfo(Level.Game);
		if (mode != None)
		{
			mode.OnVehicleDestroyed(instigatedBy, self, damageType);
		}

		// Remove dead vehicle's from other AI's VisionNotifier's
		// (maybe to be consistent with Pawn's postTakeDamage function we should call Died() here)
		Level.Game.NotifyKilled(instigatedBy.Controller, Controller, self);

		// emit death message
		if (instigatedBy != None)
			killer = instigatedBy.GetKillerController();
		if (killer!= None && Killer.Pawn != None)
		{
			killerRook = Rook(Killer.Pawn);
			if (killerRook != None)
				dispatchMessage(new class'MessageDeath'(killerRook.getKillerLabel(), label, killer.Pawn.PlayerReplicationInfo, None));
			else
				dispatchMessage(new class'MessageDeath'(killer.Pawn.label, label, killer.Pawn.PlayerReplicationInfo, None));
		}
		else
			dispatchMessage(new class'MessageDeath'(self.label, label, None, None));

		TriggerEffectEvent('VehicleDestroyed');
	}

	Super.PostTakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType, projectileFactor);
}

function tick(float deltaSeconds)
{
	if(Energy < EnergyMax)
		Energy += EnergyRegenPerSec * deltaSeconds;
	else
		Energy = EnergyMax;


	super.tick(deltaSeconds);

}*/
							

//This is where compmod decides what class can pilot each vehicle. Not clean...but there is no nice way to edit the armorclasses allowed vehicles						
// Returns true if the armour of the specified character can occupy the specified position. 
simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}
	//else if (position == VP_DRIVER)
	//	return canArmourBeDriver(character.armorClass);
	//else
	//	return canArmourBePassenger(character.armorClass);
	if(character.ArmorClass == class'EquipmentClasses.ArmorHeavy')
		return false;
	else
		return true;
	
}

function bool aimAdjustViewRotation()
{
	return true;
}

simulated event updateCameraRotation(float deltaSeconds)
{
	local float maxRotationDelta;
	local rotator requiredRotationDelta;
	local rotator actualrotationDelta;
	local rotator rotationNormal;
	local rotator currentCameraRotationNormal;

	rotationNormal = rotation;
	if (rotationNormal.Pitch > 16384)
		rotationNormal.Yaw += 32768;
	rotationNormal = Normalize(rotationNormal);
	if (rotationNormal.Yaw < 0)
		rotationNormal.Yaw += 65536;
	if (rotationNormal.Pitch < 0)
		rotationNormal.Pitch += 65536;

	currentCameraRotationNormal = Normalize(currentCameraRotation);
	if (currentCameraRotationNormal.Yaw < 0)
		currentCameraRotationNormal.Yaw += 65536;
	if (currentCameraRotationNormal.Pitch < 0)
		currentCameraRotationNormal.Pitch += 65536;

	maxRotationDelta = deltaSeconds * 70000;

	requiredRotationDelta = rotationNormal - currentCameraRotationNormal;

	if (requiredRotationDelta.Pitch > 32768)
		requiredRotationDelta.Pitch -= 65536;
	else if (requiredRotationDelta.Pitch < -32768)
		requiredRotationDelta.Pitch += 65536;

	if (requiredRotationDelta.Yaw > 32768)
		requiredRotationDelta.Yaw -= 65536;
	else if (requiredRotationDelta.Yaw < -32768)
		requiredRotationDelta.Yaw += 65536;

	if (requiredRotationDelta.Yaw < 0)
		actualrotationDelta.Yaw = max(-maxRotationDelta, requiredRotationDelta.Yaw);
	else
		actualrotationDelta.Yaw = min(maxRotationDelta, requiredRotationDelta.Yaw);

	if (requiredRotationDelta.Pitch < 0)
		actualrotationDelta.Pitch = max(-maxRotationDelta, requiredRotationDelta.Pitch);
	else
		actualrotationDelta.Pitch = min(maxRotationDelta, requiredRotationDelta.Pitch);

	currentCameraRotation.Pitch += actualrotationDelta.Pitch;
	currentCameraRotation.Yaw += actualrotationDelta.Yaw;
}



simulated event collisionDamage(float magnitude)
{
	if (bCollisionDamageEnabled && magnitude >= minimumCollisionDamageMagnitude)
	{
		//apply damage on the server
		if (ROLE == ROLE_Authority)
			TakeDamage(collisionDamageMagnitudeScale * magnitude, self, Location, vect(0,0,0), class'DamageType');
	}
}

defaultproperties
{
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     positions(0)=(thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",ManifestXPosition=40,ManifestYPosition=40,occupantConnection="Character",occupantAnimation="Pod_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000)
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     exits(2)=(Offset=(Z=300.000000),Position=VP_NULL)
     exits(3)=(Offset=(Z=-300.000000),Position=VP_NULL)
     driverWeaponClass=Class'x2PodWeapon'
     damageComponents(0)=(objectType=Class'Vehicles.DynPodPanelA',attachmentPoint="Panel00")
     damageComponents(1)=(objectType=Class'Vehicles.DynPodPanelB',attachmentPoint="Panel01")
     damageComponents(2)=(objectType=Class'Vehicles.DynPodPanelC',attachmentPoint="Panel02")
     abilities(0)=Class'VehicleClasses.VehiclePod.AI_VehicleMoveTo'
     abilities(1)=Class'VehicleClasses.VehiclePod.AI_VehicleExpellOccupant'
     abilities(2)=Class'VehicleClasses.VehiclePod.AI_VehiclePatrol'
     abilities(3)=Class'VehicleClasses.VehiclePod.AI_VehicleFollow'
     abilities(4)=Class'VehicleClasses.VehiclePod.AI_VehiclePursue'
     abilities(5)=Class'VehicleClasses.VehiclePod.AI_GunnerFireAt'
     abilities(6)=Class'VehicleClasses.VehiclePod.AI_GunnerGuard'
     abilities(7)=Class'VehicleClasses.VehiclePod.AI_PodAttack'
     abilities(8)=Class'VehicleClasses.VehiclePod.AI_VehicleLocalAttack'
     abilities(9)=Class'VehicleClasses.VehiclePod.AI_VehicleGuard'
}
