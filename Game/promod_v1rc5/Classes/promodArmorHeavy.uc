class promodArmorHeavy extends Gameplay.Armor;

//function bool TournamentOn() // is Tournament Mode on?
//{
//       if (!RunInTournamentMode)
//           {
//           if(MultiplayerGameInfo(Level.Game).bTournamentMode)
//          return true;
//           }
//}

//function ModifyMaxAmmo()
//If(TournamentOn)
//	{
//	EquipmentClasses.WeaponSpinfusor',quantity=2;
//	}


defaultproperties
{
     AllowedWeapons(1)=(typeClass=Class'EquipmentClasses.WeaponSpinfusor',quantity=25)
     AllowedWeapons(2)=(typeClass=Class'EquipmentClasses.WeaponMortar',quantity=13)
     AllowedWeapons(3)=(typeClass=Class'EquipmentClasses.WeaponGrenadeLauncher',quantity=20)
     AllowedWeapons(4)=(typeClass=Class'EquipmentClasses.WeaponRocketPod',quantity=96)
     AllowedWeapons(5)=(typeClass=Class'EquipmentClasses.WeaponBlaster')
     AllowedWeapons(6)=(typeClass=Class'EquipmentClasses.WeaponGrappler',quantity=17)
     AllowedWeapons(7)=(typeClass=Class'EquipmentClasses.WeaponBurner')
     AllowedWeapons(8)=(typeClass=Class'EquipmentClasses.WeaponChaingun',quantity=300)
     AllowedGrenades=(typeClass=Class'EquipmentClasses.WeaponHandGrenade',quantity=5)
}
