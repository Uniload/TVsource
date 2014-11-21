class Mutator extends Gameplay.Mutator;

var class<Gameplay.CombatRole> NewCombatRole;

function PostBeginPlay()
{
	local Gameplay.MultiPlayerStart Start;

	foreach AllActors( class'Gameplay.MultiPlayerStart', Start )
	if(Start != None && Start.combatRole != NewCombatRole;)
	{
		Start.combatRole = NewCombatRole;
	}
}

defaultproperties
{
    GroupName		= "startrole"
    FriendlyName	= "Start Role Override"
    Description		= "Change the default start role"

    //NewCombatRole 	= class'EquipmentClasses.CombatRoleMedium'
    NewCombatRole 	= class'EquipmentClasses.CombatRoleLight'
    //NewCombatRole 	= class'EquipmentClasses.CombatRoleHeavy'
}