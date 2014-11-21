class UltraRenegades extends Mutator;

function Actor ReplaceActor(Actor Other)
{
	if (Other.IsA('Spinfusor'))
	{
		Log("MUTATOR:  mutated a weapon?");
		return ReplaceWith(Other, "EquipmentClasses.UltraWeaponSpinfusor");
	}

	return Other;
}