class TribesVehicleHUD extends TribesInGameHUD;

simulated function UpdateHUDData()
{
	local Vehicle occupiedVehicle;
	local Turret occupiedTurret;
	local int i;
	local Weapon usedWeapon;
	local ClientSideCharacter.HUDPositionData posData;

	super.UpdateHUDData();

	ClearHUDEquipmentData();

	if(Vehicle(Controller.Pawn) != None)
	{
		// we are driving a vehicle
		occupiedVehicle = Vehicle(Controller.Pawn);

		usedWeapon = occupiedVehicle.DriverWeapon;
	}
	else if(VehicleMountedTurret(Controller.Pawn) != None)
	{
		// we are in a vehicle turret
		occupiedVehicle = VehicleMountedTurret(Controller.Pawn).ownerVehicle;
		usedWeapon = VehicleMountedTurret(Controller.Pawn).weapon;
	}
	else if(Turret(Controller.Pawn) != None)
	{
		// we are in a ground turret
		// TODO: put this into a specific turret HUD
		occupiedTurret = Turret(Controller.Pawn);
		usedWeapon = Turret(Controller.Pawn).weapon;
	}

	// update vehicle health
	if(occupiedVehicle != None)
	{
		clientSideChar.vehicleManifestSchematic = occupiedVehicle.ManifestLayoutMaterial;
		clientSideChar.vehicleHealth = occupiedVehicle.health;
		clientSideChar.vehicleHealthMaximum = occupiedVehicle.healthMaximum;

		// update the positions manifest (To be removed for the diagram version)
		clientSideChar.vehiclePositionData.Remove(0, clientSideChar.vehiclePositionData.Length);
		for(i = 0; i < occupiedVehicle.positions.Length; i++)
		{
			posData.PosX = occupiedVehicle.positions[i].ManifestXPosition;
			posData.PosY = occupiedVehicle.positions[i].ManifestYPosition;
			posData.bOccupied = (occupiedVehicle.clientPositions[i].occupant != None);
			posData.bOccupiedByPlayer = (occupiedVehicle.clientPositions[i].occupant == GetCharacter());
			posData.bNotLabelled = occupiedVehicle.positions[i].bNotLabelledInManifest;
			posData.SwitchHotKey = GetHotKey("SwitchVehiclePosition "$(i + 1));

			clientSideChar.vehiclePositionData[i] = posData;
		}
	}
	// update turret health
	else if (occupiedTurret != None)
	{
		clientSideChar.vehicleHealth = occupiedTurret.health;
		clientSideChar.vehicleHealthMaximum = occupiedTurret.healthMaximum;
	}

	if(usedWeapon != None)
	{
		clientSideChar.activeWeapon.type = usedWeapon.class;
		clientSideChar.activeWeapon.ammo = usedWeapon.ammoCount;
		clientSideChar.activeWeapon.bCanFire = usedWeapon.canFire();
		clientSideChar.activeWeapon.refireTime = 1.0 / usedWeapon.roundsPerSecond;
		clientSideChar.activeWeapon.timeSinceLastFire = Level.TimeSeconds - usedWeapon.lastFireTime;
	}

}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesVehicleHUDScript"
	HUDScriptName = "default_VehicleHUD"
}