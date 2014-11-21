class knife extends Gameplay.Mutator config(Fail);

var config float spinfusorProjectileVelocity;

const VERSION_NAME = "knife_v1";

function PreBeginPlay()
{
	//ModifyFlagStands();
	//ModifyVehiclePads();
	//ModifyBaseTurrets();
	ModifyPlayerStart();
	ModifyGameInfo();
}



function	ModifyGameInfo(){
	local Gameplay.GameInfo game;

	ForEach AllActors(class'Gameplay.GameInfo', game){
		game.default.defaultPlayerClassName = VERSION_NAME $ ".FailMultiplayerCharacter";
		game.defaultPlayerClassName = VERSION_NAME $ ".FailMultiplayerCharacter";

		//game.PlayerControllerClassName = VERSION_NAME $ ".FailPlayerCharacterController";
		//game.default.PlayerControllerClassName = VERSION_NAME $ ".FailPlayerCharacterController";
	}
}

function ModifyPlayerStart(){
	local Gameplay.MultiplayerStart s;

	ForEach AllActors(class'Gameplay.MultiplayerStart', s){
		if (s != None)
		{ 
			s.combatRole = class'EquipmentClasses.CombatRoleLight';
			s.invincibleDelay = 2;
		}
	}
}



function Actor ReplaceActor(Actor Other)
{
	if(Other.IsA('WeaponChaingun'))
	{
		Other.Destroy();
	}
	if(Other.IsA('WeaponBlaster'))
	{
		Other.Destroy();
	}
	if(Other.IsA('WeaponSpinfusor'))
	{
		Other.Destroy();
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".FailWeaponEnergyBlade");
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		Other.Destroy();
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		Other.Destroy();
	}
	
	if(Other.IsA('WeaponBurner'))
	{
		Other.Destroy();
	}
	
	if(Other.IsA('WeaponRocketPod'))
	{
		Other.Destroy();
	}
	if(Other.IsA('WeaponBuckler'))
	{
		Other.Destroy();
	}

	//Copied from Vanilla.  Thank you Rapher
	if(Other.IsA('Grappler'))
	{
		Other.Destroy();
	}
		
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = 0.600000;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = 0.2000000;
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponMortar'))
	{
		Other.Destroy();
	}
		if(Other.IsA('WeaponHandGrenade'))
	{
		Other.Destroy();
	}
	return Super.ReplaceActor(Other);
}


function string MutateSpawnCombatRoleClass(Character c)
{	
	local int i, j;

	//Heavies.  Copied from Vanilla Plus. Thank you Odio
	c.team().combatRoleData[2].role.default.armorClass.default.knockbackScale = 1.04;
	c.team().combatRoleData[2].role.default.armorClass.default.health = 225;

	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 20;
			/*
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponBurner')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = 20 + i *5;
				*/
		}

	//c.team().combatRoleData[0].role.default.armorClass.default.AllowedDeployables = class<Armor>(DynamicLoadObject(VERSION_NAME $ ".FailArmorLight", class'class')).default.AllowedDeployables;

	return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
     spinfusorProjectileVelocity=6000.000000
}
