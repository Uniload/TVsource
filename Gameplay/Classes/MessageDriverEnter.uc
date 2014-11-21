class MessageDriverEnter extends MessageVehicleOccupantChange;

overloaded function construct(Name _vehicle, Name _occupant)
{
	super.construct(_vehicle, _occupant);

	SLog(occupant $ " entered driver position on " $ vehicle);
}

static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "driver entered " $triggeredBy;
}

defaultproperties
{
}
