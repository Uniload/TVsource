class MessageVehicleOccupantChange extends Engine.Message;

var Name vehicle;
var() Name occupant;

overloaded function construct(Name _vehicle, Name _occupant)
{
	vehicle = _vehicle;
	occupant = _occupant;
}

defaultproperties
{
     specificTo=Class'Vehicle'
}
