class HealthKitConsumable extends HealthKit;


replication
{
	reliable if (Role < ROLE_Authority)
		requestConsumeHealthKit;
}

function bool canPickup(Character potentialOwner)
{
	return potentialOwner.health < potentialOwner.healthMaximum;
}

function onPickup()
{
	use();
}

simulated function use()
{
	local Character ownerCharacter;

	ownerCharacter = Character(Owner);

	if (ownerCharacter == None)
		return;

	ownerCharacter.removeFlameDamage();

	requestConsumeHealthKit();
}

private function requestConsumeHealthKit()
{
	local float healthToRestore;
	local Character ownerCharacter;
	local float rate;

	ownerCharacter = Character(Owner);

	ownerCharacter.removeEquipment(self);

	ownerCharacter.removeFlameDamage();

	rate = healthPerSecond;
	healthToRestore = FMin(ownerCharacter.healthMaximum - ownerCharacter.health, maxHealthRestored);

	if (GameInfo(Level.Game) != None)
	{
		rate = GameInfo(Level.Game).modifyHealthKitRate(ownerCharacter, rate);
		healthToRestore = GameInfo(Level.Game).modifyHealthKitRate(ownerCharacter, healthToRestore);
	}

	ownerCharacter.healthInjection(rate, healthToRestore);

	Destroy();
}

defaultproperties
{
	bCanDrop = false

	StaticMesh = StaticMesh'Packs.HealthKit'
	DrawType = DT_StaticMesh

	maxHealthRestored = 25.0
	healthPerSecond = 25.0
}