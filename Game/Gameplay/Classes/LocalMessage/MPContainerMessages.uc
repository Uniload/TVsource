class MPContainerMessages extends TribesLocalMessage;

defaultproperties
{
	announcements(0)=(effectEvent=TerritoryConquered,speechTag=FUEL100,debugString="%1 fuel depot is now full.")
	announcements(1)=(effectEvent=TerritoryContested,speechTag=FUEL75,debugString="%1 fuel depot at 75%.")
	announcements(2)=(effectEvent=TerritoryContested,speechTag=FUEL50,debugString="%1 fuel depot at 50%.")
	announcements(3)=(effectEvent=TerritoryContested,speechTag=FUEL25,debugString="%1 fuel depot at 25%.")
	announcements(4)=(effectEvent=TerritoryContested,speechTag=FUEL0,debugString="%1 fuel depot is now empty.")
	announcements(5)=(effectEvent=TerritoryContested,speechTag=FUELEXTRACTING,debugString="%1 are extracting fuel.")
	announcements(6)=(effectEvent=TerritoryContested,speechTag=FUELSTEALING,debugString="%1 are stealing fuel.")
	announcements(7)=(effectEvent=TerritoryContested,speechTag=FUEL0,debugString="Neutral fuel depot depleted.")
}