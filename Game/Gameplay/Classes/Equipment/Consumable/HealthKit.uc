class HealthKit extends Consumable;

var() float maxHealthRestored;
var() float healthPerSecond;

replication
{
	reliable if (Role < ROLE_Authority)
		requestConsumeHealthKit;
}

function bool canPickup(Character potentialOwner)
{
	local int maxHKs;

	maxHKs = potentialOwner.armorClass.static.maxHealthKits();

	return maxHKs > 0 && potentialOwner.numHealthKitsCarried() < maxHKs;
}

simulated function use()
{
	local Character ownerCharacter;

	ownerCharacter = Character(Owner);

	if (ownerCharacter == None)
		return;

	if (ownerCharacter.health < ownerCharacter.healthMaximum)
	{
		ownerCharacter.removeFlameDamage();
		requestConsumeHealthKit();
	}
}

private function requestConsumeHealthKit()
{
	local float healthToRestore;
	local Character ownerCharacter;

	ownerCharacter = Character(Owner);

	ownerCharacter.removeEquipment(self);

	ownerCharacter.removeFlameDamage();

	healthToRestore = FMin(ownerCharacter.healthMaximum - ownerCharacter.health, maxHealthRestored);
	ownerCharacter.healthInjection(healthPerSecond, healthToRestore);

	Destroy();
}

defaultproperties
{
	bCanDrop = true

	StaticMesh = StaticMesh'Packs.HealthKit'
	DrawType = DT_StaticMesh

	maxHealthRestored = 75.0
	healthPerSecond = 25.0
}