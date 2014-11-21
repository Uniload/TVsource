class SpeechCategoryManager extends Core.Object
	native
	config(SpeechCategories);

var config Array<String>	categoryNames;
var Array<SpeechCategory>	categories;

///
/// Initialises the array of speech categories based on the categoryNames
/// loaded from config.
///
event LoadCategories()
{
	local int i;

	for(i = 0; i < categoryNames.Length; ++i)
		categories[i] = new(None, categoryNames[i]) class'SpeechCategory';
}

defaultproperties
{
     categoryNames(0)="AboutToCrater"
     categoryNames(1)="AllyHurtCollision"
     categoryNames(2)="AllyHurtWeapon"
     categoryNames(3)="AllyKilled"
     categoryNames(4)="Attack"
     categoryNames(5)="Cower"
     categoryNames(6)="Detect"
     categoryNames(7)="Hit"
     categoryNames(8)="Kill"
     categoryNames(9)="LowHealth"
     categoryNames(10)="Panic"
     categoryNames(11)="suspiciousCombat"
     categoryNames(12)="SuspiciousHear"
     categoryNames(13)="SuspiciousSee"
     categoryNames(14)="TauntMissed"
     categoryNames(15)="TauntStillAlive"
     categoryNames(16)="UseHealth"
     categoryNames(17)="UsePackEnergy"
     categoryNames(18)="UsePackRepair"
     categoryNames(19)="UsePackShield"
     categoryNames(20)="UsePackSpeed"
     categoryNames(21)="AllyBlock"
     categoryNames(22)="Breathing"
     categoryNames(23)="Death"
     categoryNames(24)="DeathCrater"
     categoryNames(25)="DeathScream"
     categoryNames(26)="Hurt"
     categoryNames(27)="HurtLarge"
     categoryNames(28)="Land"
     categoryNames(29)="Miss"
}
