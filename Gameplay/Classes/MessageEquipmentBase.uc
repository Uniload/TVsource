class MessageEquipmentBase extends Engine.Message
	editinlinenew;

var() Name equipmentName					"The label of the picked-up/dropped equipment";
var() class<Equipment> equipmentClass		"The class of the picked-up/dropped equipment (does a full RTTI check for filtering, so base classes can be specified here when filtering)";


// construct
overloaded function construct(Name _equipmentName, class<Equipment> _equipmentClass)
{
	equipmentName = _equipmentName;
	equipmentClass = _equipmentClass;
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "";
}

// Returns false if the calling script should not be executed (ie message does not pass filter)
function bool passesFilter(Message filterMsg)
{
	local MessageEquipmentBase f;

	f = MessageEquipmentBase(filterMsg);

	// do RTTI check on class name
	if (f.equipmentClass != None)
	{
		if (equipmentClass != f.equipmentClass && !ClassIsChildOf(equipmentClass, f.equipmentClass))
			return false;
	}

	if (f.equipmentName != '')
	{
		if (f.equipmentName != equipmentName)
			return false;
	}

	return true;
}

defaultproperties
{
     specificTo=Class'Equipment'
}
