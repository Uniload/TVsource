class MessageBaseDevicePowerOn extends Engine.Message;

var Name baseDevice;

overloaded function construct(Name _baseDevice)
{
	baseDevice = _baseDevice;
}

static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Base device " $ triggeredBy $ " re-gains power";
}

defaultproperties
{
	specificTo	= class'BaseDevice'
}