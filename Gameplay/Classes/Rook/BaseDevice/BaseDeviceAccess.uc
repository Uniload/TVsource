class BaseDeviceAccess extends UseableObject;

var() localized String PowerDownPrompt;
var() localized String IsDisabledPrompt;

function byte GetPromptIndex(Character PotentialUser)
{
	local BaseDevice OwnerBaseDevice;

	OwnerBaseDevice = BaseDevice(Owner);

	if(OwnerBaseDevice.IsFriendly(PotentialUser))
	{	
		if(CanBeUsedBy(PotentialUser))
			return 0;		// standard use message
		else if(OwnerBaseDevice != None)
		{
			if(! OwnerBaseDevice.IsPowered())
				return 1;
			else if(OwnerBaseDevice.isDisabled())
				return 2;
		}
	}

	return 255;
}

// returns a prompt string based on the prompt index
static function string GetPrompt(byte PromptIndex, class<Actor> dataClass)
{
	switch(promptIndex)
	{
	case 0:
		return default.prompt;
	case 1:
		return default.PowerDownPrompt;
	case 2:
		return default.IsDisabledPrompt;
	}

	return "";
}


defaultproperties
{
	PowerDownPrompt = "You cannot use this object because the power is down. Repair your generator.";
	IsDisabledPrompt = "You cannot use this object because it is damaged and needs repairing.";
}