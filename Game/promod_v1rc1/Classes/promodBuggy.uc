class promodBuggy extends VehicleClasses.VehicleBuggy config(promod);


simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}
	if((character.ArmorClass == class'EquipmentClasses.ArmorHeavy') && (position == VP_DRIVER))
		return false;
	else
		return true;
	
}

simulated function bool canCharacterRespawnAt()
{
	// cannot respawn if there is a driver
	if (clientPositions[0].occupant != None)
		return false;

	return super.canCharacterRespawnAt();
}

function int canOccupy(Character character, VehiclePositionType position, array<VehiclePositionType> secondaryPositions, out byte promptIndex)
{
	local int returnCode;

	returnCode = super.canOccupy(character, position, secondaryPositions, promptIndex);

	if(returnCode != -1 && team() != character.team()){
		
		team().removeVehicleRespawn(self);
		setTeam(character.team());
		team().addVehicleRespawn(self);
	}
	return returnCode;
}

function enableAbandonmentDestruction(float periodSeconds)
{
}

defaultproperties
{
gunnerWeaponClass=None
Health=2000
}
