class MessageGunnerLeave extends MessageVehicleOccupantChange;

overloaded function construct(Name _vehicle, Name _occupant)
{
	super.construct(_vehicle, _occupant);

	SLog(occupant $ " left gunner position on " $ vehicle);
}

static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "gunner left " $triggeredBy;
}