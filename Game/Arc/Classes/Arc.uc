class Arc extends Gameplay.Mutator config(Arc);

var config int LightHealth;
var config int MediumHealth;
var config int HeavyHealth;
var config int LightSpinfusorAmmo;
var config int LightGrenadeLauncherAmmo;
var config int LightRocketpodAmmo;
var config int LightGrapplerAmmo;
var config int LightChaingunAmmo;
var config int MediumSpinfusorAmmo;
var config int MediumGrenadeLauncherAmmo;
var config int MediumRocketpodAmmo;
var config int MediumGrapplerAmmo;
var config int MediumChaingunAmmo;
var config int MediumSniperRifleAmmo;
var config int HeavySpinfusorAmmo;
var config int HeavyGrenadeLauncherAmmo;
var config int HeavyRocketpodAmmo;
var config int HeavyGrapplerAmmo;
var config int HeavyChaingunAmmo;
var config int LightHandGrenadeAmmo;
var config int MediumHandGrenadeAmmo;
var config int HeavyHandGrenadeAmmo;
var config int EnergyBladerange; // Energy Blade range.
var config int EnergyBladedamage; // Energy Blade Damage Amount.
var config float MortarRPS; // Mortar Rounds per Second.
var config float MortarVelocity; // Mortar starter speed.
var config float MortarInheretedVelFactor; // Mortar multiplication in speed.
var config float GrenadeLauncherRPS; // Grenade Launcher Rounds per Second.
var config float GrenadeLauncherVelocity; // Grenade Launcher starter speed.
var config float GrenadeLauncherInheretedVelfactor; // Grenade Launcher multiplication in speed.
var config float SpinfusorRPS; // Spinfusor Rounds per Second.
var config float SpinfusorVelocity; // Spinfusor starter speed.
var config float SpinfusorInheretedVelfactor; // Spinfusor multiplication in speed.
var config float EnergyBladeUsage; // Energy Blade Energy Usage.
var config float EnergyBladeknockBack; // Knockback value when hit with an Energy Blade.
var config float EnergyBladeRPS; // Energy Blade Rounds per Second.

function Actor ReplaceActor(Actor Other)
{
   /* if (Other.IsA('Mortar'))
   {
      Mortar(Other).ProjectileClass = class'MortarProjectile';
      Mortar(Other).ProjectileInheritedVelFactor = MortarInheretedVelFactor;
      Mortar(Other).ProjectileVelocity = MortarVelocity;
      Mortar(Other).roundsPerSecond = MortarRPS;
      return Other;
   } */
   if (Other.IsA('WeaponGrenadeLauncher'))
   {
      WeaponGrenadeLauncher(Other).ProjectileClass = class'GrenaderProjectile';
      WeaponGrenadeLauncher(Other).ProjectileInheritedVelFactor = GrenadeLauncherInheretedVelfactor;
      WeaponGrenadeLauncher(Other).ProjectileVelocity = GrenadeLauncherVelocity;
      WeaponGrenadeLauncher(Other).roundsPerSecond = GrenadeLauncherRPS;
      return Other;
   }
   /* else if (Other.IsA('Spinfusor'))
   {
        Spinfusor(Other).ProjectileClass = class'SpinfusorProjectile';
      Spinfusor(Other).ProjectileInheritedVelFactor = SpinfusorInheretedVelfactor;
      Spinfusor(Other).ProjectileVelocity = SpinfusorVelocity;
      Spinfusor(Other).roundsPerSecond = SpinfusorRPS;
      return Other;
   }
   else if (Other.IsA('EnergyBlade'))
   {
      EnergyBlade(Other).damageAmt = EnergyBladedamage;
      EnergyBlade(Other).energyUsage = EnergyBladeUsage;
      EnergyBlade(Other).roundsPerSecond = EnergyBladeRPS;
      EnergyBlade(Other).range = EnergyBladerange;
      EnergyBlade(Other).knockBackVelocity = EnergyBladeKnockBack;
      return Other;
   } */
}
	
function string MutateSpawnCombatRoleClass(Character c)
{
	local int i, j;

		c.team().combatRoleData[0].role.default.armorClass.default.health = LightHealth;
	    c.team().combatRoleData[1].role.default.armorClass.default.health = MediumHealth;
		c.team().combatRoleData[2].role.default.armorClass.default.health = HeavyHealth;	
	
	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponSpinfusor')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightSpinfusorAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightGrapplerAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrenadeLauncher')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightGrenadeLauncherAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponRocketpod')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightRocketpodAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponChaingun')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightChaingunAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponHandGrenade')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = LightHandGrenadeAmmo;				
				}
				for(i = 1; i < c.team().combatRoleData.length; i++)
		for(j = 1; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponSpinfusor')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumSpinfusorAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumGrapplerAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrenadeLauncher')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumGrenadeLauncherAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponRocketpod')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumRocketpodAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponChaingun')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumChaingunAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponHandGrenade')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = MediumHandGrenadeAmmo;				
				}
				for(i = 2; i < c.team().combatRoleData.length; i++)
		for(j = 2; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++){
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponSpinfusor')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavySpinfusorAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavyGrapplerAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrenadeLauncher')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavyGrenadeLauncherAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponRocketpod')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavyRocketpodAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponChaingun')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavyChaingunAmmo;
				else if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponHandGrenade')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = HeavyHandGrenadeAmmo;				
				}
	return Super.MutateSpawnCombatRoleClass(c);
}

defaultproperties
{
MortarRPS = 0.5
MortarVelocity = 4500
MortarInheretedVelFactor = 0.8
GrenadeLauncherRPS = 1
GrenadeLauncherVelocity = 2100
GrenadeLauncherInheretedVelfactor = 0.8
SpinfusorRPS = 0.56
SpinfusorVelocity = 2600
SpinfusorInheretedVelfactor = 0.5
EnergyBladeRPS = 0.5
EnergyBladeUsage = 25.0
EnergyBladedamage = 20.0
EnergyBladerange = 200
EnergyBladeknockBack = 5000
LightSpinfusorAmmo = 15
LightGrenadeLauncherAmmo = 10
LightRocketpodAmmo = 22
LightGrapplerAmmo = 15
LightChaingunAmmo = 150
LightHandGrenadeAmmo = 5
MediumSpinfusorAmmo = 20
MediumGrenadeLauncherAmmo = 15
MediumRocketpodAmmo = 72
MediumGrapplerAmmo = 15
MediumChaingunAmmo = 200
MediumHandGrenadeAmmo = 5
HeavySpinfusorAmmo = 15
HeavyGrenadeLauncherAmmo = 20
HeavyRocketpodAmmo = 96
HeavyGrapplerAmmo = 15
HeavyChaingunAmmo = 300
HeavyHandGrenadeAmmo = 5
LightHealth = 75 
MediumHealth = 100
HeavyHealth = 195
}