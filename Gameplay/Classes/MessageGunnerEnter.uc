class MessageGunnerEnter extends MessageVehicleOccupantChange;

overloaded function construct(Name _vehicle, Name _occupant)
{
	super.construct(_vehicle, _occupant);

	SLog(occupant $ " entered gunner position on " $ vehicle);
}

static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "gunner entered " $triggeredBy;
}

defaultproperties
{
}
