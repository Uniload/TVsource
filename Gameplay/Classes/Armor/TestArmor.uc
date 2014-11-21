class TestArmor extends Armor;

defaultproperties
{
    collisionRadius = 34
    collisionHeight = 78
	health = 100

	AllowedWeapons(0)=(typeClass=class'Spinfusor',quantity=20)
	AllowedWeapons(1)=(typeClass=class'Chaingun',quantity=150)	
	AllowedWeapons(2)=(typeClass=class'GrenadeLauncher',quantity=15)
	AllowedWeapons(3)=(typeClass=class'Grappler')
	AllowedWeapons(4)=(typeClass=class'Burner')
	AllowedWeapons(5)=(typeClass=class'EnergyBlade')
	AllowedWeapons(6)=(typeClass=class'RocketPod',quantity=128)
	AllowedWeapons(7)=(typeClass=class'SniperRifle',quantity=10)
	AllowedWeapons(8)=(typeClass=class'Buckler',quantity=1)

	AllowedGrenades=(typeClass=class'HandGrenade',quantity=8)

	AllowedConsumables(0)=(typeClass=class'HealthKit',quantity=2)
}