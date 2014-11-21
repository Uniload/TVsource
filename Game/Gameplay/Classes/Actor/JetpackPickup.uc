class JetpackPickup extends Equipment;

var() class<Jetpack> jetpackClass;

function bool canPickup(Character potentialOwner)
{
	return SingleplayerCharacter(potentialOwner) != None;
}

function pickup(Character newOwner)
{
	SingleplayerCharacter(newOwner).giveJetpack(jetpackClass);
	dispatchMessage(new class'MessageEquipmentPickedUp'(Label, class));
	Destroy();
}

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'lightArmour.jetpackPL'

	jetpackClass=class'Jetpack'
}